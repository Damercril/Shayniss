// Service AvailabilityService : CRUD disponibilité avec validation stricte et gestion conflits/erreurs
import { createSupabaseClient } from "./supabase_client.ts";
import { Availability } from "../models/availability.ts";

export class AvailabilityService {
  static async createAvailability(data: any): Promise<{ availability?: Availability; error?: string }> {
    // Validation stricte côté modèle
    let availability: Availability;
    try {
      availability = new Availability(data);
    } catch (e) {
      return { error: e.message };
    }
    const client = createSupabaseClient();
    // Vérifier pro existe
    const { data: pro, error: proError } = await client.from("professionals").select("id").eq("id", availability.professional_id).maybeSingle();
    if (proError) return { error: "Erreur de connexion à la base de données." };
    if (!pro) return { error: "Professionnel inexistant" };
    // Vérifier chevauchement
    const { data: overlaps, error: overlapError } = await client.from("availabilities")
      .select("id,start_time,end_time")
      .eq("professional_id", availability.professional_id)
      .or(`and(start_time,lt.${availability.end_time}),and(end_time,gt.${availability.start_time})`);
    if (overlapError) return { error: "Erreur lors de la vérification des conflits." };
    if (overlaps && overlaps.length > 0) return { error: "Créneau en conflit" };
    // Création
    const now = new Date().toISOString();
    const { data: created, error } = await client.from("availabilities").insert([
      { ...data, created_at: now, updated_at: now }
    ]).select().single();
    if (error) return { error: "Erreur lors de la création de la disponibilité." };
    return { availability: created as Availability };
  }

  static async getAvailabilityById(id: string): Promise<{ availability?: Availability; error?: string }> {
    const client = createSupabaseClient();
    const { data, error } = await client.from("availabilities").select("*").eq("id", id).maybeSingle();
    if (error) return { error: "Erreur de connexion à la base de données." };
    if (!data) return { error: "Disponibilité non trouvée." };
    return { availability: data as Availability };
  }

  static async updateAvailability(id: string, patch: any): Promise<{ availability?: Availability; error?: string }> {
    const client = createSupabaseClient();
    // Récupérer l'existant
    const { data: existing, error: getError } = await client.from("availabilities").select("*").eq("id", id).maybeSingle();
    if (getError) return { error: "Erreur de connexion à la base de données." };
    if (!existing) return { error: "Disponibilité non trouvée." };
    let updated;
    try {
      updated = new Availability({ ...existing, ...patch });
    } catch (e) {
      return { error: e.message };
    }
    // Vérifier chevauchement (hors self)
    const { data: overlaps, error: overlapError } = await client.from("availabilities")
      .select("id,start_time,end_time")
      .eq("professional_id", updated.professional_id)
      .neq("id", id)
      .or(`and(start_time,lt.${updated.end_time}),and(end_time,gt.${updated.start_time})`);
    if (overlapError) return { error: "Erreur lors de la vérification des conflits." };
    if (overlaps && overlaps.length > 0) return { error: "Créneau en conflit" };
    // Update
    const now = new Date().toISOString();
    const { data: patched, error } = await client.from("availabilities").update({ ...patch, updated_at: now }).eq("id", id).select().single();
    if (error) return { error: "Erreur lors de la modification de la disponibilité." };
    return { availability: patched as Availability };
  }

  static async deleteAvailability(id: string): Promise<{ error?: string }> {
    const client = createSupabaseClient();
    const { error } = await client.from("availabilities").delete().eq("id", id);
    if (error) return { error: "Erreur lors de la suppression de la disponibilité." };
    return {};
  }

  static async searchAvailabilities(query: { pro?: string; day?: number }): Promise<{ availabilities?: Availability[]; error?: string }> {
    const client = createSupabaseClient();
    let req = client.from("availabilities").select("*");
    if (query.pro) req = req.eq("professional_id", query.pro);
    if (query.day !== undefined) req = req.eq("day_of_week", query.day);
    const { data, error } = await req;
    if (error) return { error: "Erreur lors de la recherche des disponibilités." };
    return { availabilities: data as Availability[] };
  }
}
