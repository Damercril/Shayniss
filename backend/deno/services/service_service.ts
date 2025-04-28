// Service ServiceService : CRUD service avec validation stricte et gestion erreurs explicite
import { createSupabaseClient } from "./supabase_client.ts";
import { Service } from "../models/service.ts";

export class ServiceService {
  static async getServiceById(id: string): Promise<{ service?: Service; error?: string }> {
    const client = createSupabaseClient();
    const { data, error } = await client.from("services").select("*").eq("id", id).maybeSingle();
    if (error) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (!data) {
      return { error: "Service non trouvé." };
    }
    return { service: data as Service };
  }

  static async createService(
    name: string,
    professional_id: string,
    price: number,
    duration_minutes: number,
    is_active: boolean
  ): Promise<{ service?: Service; error?: string }> {
    // Validation stricte côté métier
    if (!name || name.trim() === "") {
      return { error: "Le nom du service ne peut pas être vide." };
    }
    if (price < 0) {
      return { error: "Le prix doit être positif ou nul." };
    }
    if (duration_minutes < 0) {
      return { error: "La durée doit être positive ou nulle." };
    }
    // Vérifier que le professionnel existe
    const client = createSupabaseClient();
    const { data: pro, error: proErr } = await client.from("professionals").select("id").eq("id", professional_id).maybeSingle();
    if (proErr) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (!pro) {
      return { error: "Le professionnel spécifié est introuvable." };
    }
    const now = new Date().toISOString();
    const { data, error } = await client.from("services").insert([
      { name, professional_id, price, duration_minutes, is_active, booking_count: 0, created_at: now, updated_at: now }
    ]).select().single();
    if (error) {
      return { error: "Erreur lors de la création du service." };
    }
    return { service: data as Service };
  }

  // Recherche/filtres avancés
  static async searchServices(query: {
    search?: string;
    category_id?: string;
    max_price?: number;
    order_by?: string;
    limit?: number;
    offset?: number;
    [key: string]: any;
  }): Promise<{ services?: any[]; error?: string }> {
    // Vérification des filtres autorisés
    const allowed = ["search", "category_id", "max_price", "order_by", "limit", "offset"];
    for (const k of Object.keys(query)) {
      if (!allowed.includes(k)) {
        return { error: `Filtre inconnu : ${k}` };
      }
    }
    const client = createSupabaseClient();
    let req = client.from("services").select("*").eq("is_active", true);
    if (query.search) {
      req = req.ilike("name", `%${query.search}%`); // full-text simple
    }
    if (query.category_id) {
      req = req.eq("category_id", query.category_id);
    }
    if (query.max_price !== undefined) {
      req = req.lte("price", query.max_price);
    }
    if (query.order_by) {
      req = req.order(query.order_by, { ascending: false });
    }
    if (query.limit !== undefined) {
      req = req.limit(query.limit);
    }
    if (query.offset !== undefined) {
      req = req.range(query.offset, (query.offset || 0) + (query.limit || 10) - 1);
    }
    const { data, error } = await req;
    if (error) {
      return { error: "Erreur lors de la recherche de services." };
    }
    return { services: data };
  }
}
