// Service AvailabilityExceptionService : gestion exceptions de créneaux (validation stricte, robustesse)
import { createSupabaseClient } from "./supabase_client.ts";
import { AvailabilityException } from "../models/availability_exception.ts";

export class AvailabilityExceptionService {
  static async createException(data: any): Promise<{ exception?: AvailabilityException; error?: string }> {
    let exception: AvailabilityException;
    try {
      exception = new AvailabilityException(data);
    } catch (e) {
      return { error: e.message };
    }
    const client = createSupabaseClient();
    // Vérifier que le créneau existe
    const { data: avail, error: availError } = await client.from("availabilities").select("*").eq("id", exception.availability_id).maybeSingle();
    if (availError) return { error: "Erreur de connexion à la base de données." };
    if (!avail) return { error: "Créneau de disponibilité inexistant" };
    // Vérifier que la date d'exception est dans la plage du créneau (pour créneaux simples)
    if (avail.start_time && avail.end_time && avail.start_time.substring(0,10) !== exception.exception_date) {
      return { error: "Date d'exception hors plage du créneau" };
    }
    // Vérifier doublon
    const { data: existing, error: existError } = await client.from("availability_exceptions").select("id").eq("availability_id", exception.availability_id).eq("exception_date", exception.exception_date).maybeSingle();
    if (existError) return { error: "Erreur de connexion à la base de données." };
    if (existing) return { error: "Exception déjà existante pour cette date" };
    // Création
    const now = new Date().toISOString();
    const { data: created, error } = await client.from("availability_exceptions").insert([
      { ...data, created_at: now, updated_at: now }
    ]).select().single();
    if (error) return { error: "Erreur lors de la création de l'exception." };
    return { exception: created as AvailabilityException };
  }

  static async listExceptions(query: { availability_id?: string }): Promise<{ exceptions?: AvailabilityException[]; error?: string }> {
    const client = createSupabaseClient();
    let req = client.from("availability_exceptions").select("*");
    if (query.availability_id) req = req.eq("availability_id", query.availability_id);
    const { data, error } = await req;
    if (error) return { error: "Erreur lors de la recherche des exceptions." };
    return { exceptions: data as AvailabilityException[] };
  }

  static async deleteException(id: string): Promise<{ error?: string }> {
    const client = createSupabaseClient();
    const { error } = await client.from("availability_exceptions").delete().eq("id", id);
    if (error) return { error: "Erreur lors de la suppression de l'exception." };
    return {};
  }
}
