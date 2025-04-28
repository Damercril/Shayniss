// Service BookingService : gestion des réservations (validation stricte, robustesse)
import { createSupabaseClient } from "./supabase_client.ts";
import { Booking } from "../models/booking.ts";
import { NotificationService } from "./notification_service.ts";
import { RefundService } from "./refund_service.ts";

export class BookingService {
  static async createBooking(data: any): Promise<{ booking?: Booking; error?: string }> {
    const client = createSupabaseClient();
    // 1. Validation stricte des champs obligatoires
    if (!data.client_id || !data.availability_id || !data.booking_date) {
      console.log("Erreur: champs obligatoires manquants", data);
      return { error: "Champs obligatoires manquants" };
    }
    // 2. Vérification disponibilité
    const { data: avail, error: availError } = await client.from("availabilities").select("*").eq("id", data.availability_id).maybeSingle();
    if (availError || !avail) {
      console.log("Erreur: disponibilité introuvable", data.availability_id, availError);
      return { error: "Disponibilité introuvable" };
    }
    // 3. Validation stricte des horaires (début < fin, format ISO)
    const start = new Date(avail.start_time);
    const end = new Date(avail.end_time);
    if (isNaN(start.getTime()) || isNaN(end.getTime()) || start >= end) {
      console.log("Erreur: horaires invalides", avail.start_time, avail.end_time);
      return { error: "Horaires invalides" };
    }
    // 4. Vérifier si le créneau est déjà réservé (statut confirmé/non annulé)
    const { data: existing, error: existErr } = await client.from("bookings").select("*")
      .eq("availability_id", data.availability_id)
      .not("status", "eq", "cancelled");
    if (existErr) {
      console.log("Erreur requête existante", existErr);
      return { error: "Erreur lors de la vérification du créneau" };
    }
    if (existing && existing.length > 0) {
      console.log("Conflit: créneau déjà réservé", data.availability_id);
      return { error: "Créneau déjà réservé" };
    }
    // 5. Vérifier chevauchement de réservation du même client
    const { data: clientBookings, error: clientErr } = await client.from("bookings").select("b:*,a:start_time,a:end_time")
      .eq("b.client_id", data.client_id)
      .not("b.status", "eq", "cancelled")
      .join("availabilities:a", "b.availability_id", "a.id");
    if (clientErr) {
      console.log("Erreur requête réservations client", clientErr);
      return { error: "Erreur lors de la vérification des chevauchements" };
    }
    for (const cb of clientBookings || []) {
      const cbStart = new Date(cb.a_start_time);
      const cbEnd = new Date(cb.a_end_time);
      // Chevauchement si (start < cbEnd && end > cbStart)
      if (start < cbEnd && end > cbStart) {
        console.log("Conflit: chevauchement réservation client", data.client_id, avail.start_time, avail.end_time, cb.a_start_time, cb.a_end_time);
        return { error: "Conflit avec une autre réservation du client" };
      }
    }
    // 6. Création
    const now = new Date().toISOString();
    const { data: created, error } = await client.from("bookings").insert([
      { ...data, professional_id: avail.professional_id, status: 'confirmed', created_at: now, updated_at: now }
    ]).select().single();
    if (error) {
      console.log("Erreur création réservation", error);
      return { error: "Erreur lors de la création de la réservation" };
    }
    // Notifier client
    await NotificationService.createNotification(
      data.client_id,
      "booking_created",
      `Votre réservation du ${avail.start_time} avec le professionnel ${avail.professional_id} est confirmée.`
    );
    // Notifier professionnel
    await NotificationService.createNotification(
      avail.professional_id,
      "booking_new_client",
      `Une nouvelle réservation a été créée par le client ${data.client_id} pour le ${avail.start_time}.`
    );
    return { booking: created as Booking };
  }

  static async listBookings(query: { professional_id?: string, client_id?: string }): Promise<{ bookings?: Booking[]; error?: string }> {
    const client = createSupabaseClient();
    let req = client.from("bookings").select("*");
    if (query.professional_id) req = req.eq("professional_id", query.professional_id);
    if (query.client_id) req = req.eq("client_id", query.client_id);
    const { data, error } = await req;
    if (error) return { error: "Erreur lors de la recherche des réservations." };
    return { bookings: data as Booking[] };
  }

  static async getBookingById(id: string): Promise<{ booking?: Booking; error?: string; notFound?: boolean }> {
    const client = createSupabaseClient();
    const { data, error } = await client.from("bookings").select("*").eq("id", id).maybeSingle();
    if (error) return { error: "Erreur lors de la récupération de la réservation." };
    if (!data) return { notFound: true, error: "Réservation non trouvée" };
    return { booking: data as Booking };
  }

  static async deleteBooking(id: string): Promise<{ error?: string; alreadyCancelled?: boolean; notFound?: boolean }> {
    const client = createSupabaseClient();
    // Vérifier statut
    const { data, error: getError } = await client.from("bookings").select("*").eq("id", id).maybeSingle();
    if (getError) return { error: "Erreur lors de la récupération de la réservation." };
    if (!data) return { notFound: true, error: "Réservation non trouvée" };
    if (data.status === 'cancelled') return { alreadyCancelled: true, error: "Réservation déjà annulée" };
    // Mise à jour du statut (soft delete)
    const { error } = await client.from("bookings").update({ status: 'cancelled', updated_at: new Date().toISOString() }).eq("id", id);
    if (error) return { error: "Erreur lors de l'annulation de la réservation." };
    // Gestion du remboursement si réservation payée
    if (data.paid && data.amount_paid > 0) {
      // Calcul du délai avant la réservation
      const now = new Date();
      const bookingDate = new Date(data.booking_date);
      const diffMs = bookingDate.getTime() - now.getTime();
      const diffH = diffMs / (1000 * 60 * 60);
      let refundAmount = data.amount_paid;
      let policy = "total";
      if (diffH < 24) {
        refundAmount = Math.round(data.amount_paid * 0.5);
        policy = "partiel";
      }
      const refundRes = await RefundService.createRefund(data.id, data.client_id, refundAmount, policy);
      if (!refundRes.error) {
        // Notification client
        await NotificationService.createNotification(
          data.client_id,
          "refund_processed",
          `Un remboursement de ${refundAmount}€ a été effectué pour votre réservation du ${data.booking_date} (politique : ${policy}).`
        );
        // Notification pro
        await NotificationService.createNotification(
          data.professional_id,
          "refund_processed",
          `Un remboursement de ${refundAmount}€ a été traité pour la réservation du client ${data.client_id} (${policy}).`
        );
      } else {
        console.log("Erreur remboursement ou déjà remboursé:", refundRes.error);
      }
    }
    // Notifier client et professionnel (annulation)
    await NotificationService.createNotification(
      data.client_id,
      "booking_cancelled",
      `Votre réservation du ${data.booking_date} avec le professionnel ${data.professional_id} a été annulée.`
    );
    await NotificationService.createNotification(
      data.professional_id,
      "booking_cancelled",
      `La réservation du client ${data.client_id} prévue le ${data.booking_date} a été annulée.`
    );
    return {};
  }
}
