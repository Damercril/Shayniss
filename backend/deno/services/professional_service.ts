// Service ProfessionalService : CRUD professionnel avec validation et gestion erreurs explicite
import { createSupabaseClient } from "./supabase_client.ts";
import { Professional } from "../models/professional.ts";

export class ProfessionalService {
  static async getProfessionalById(id: string): Promise<{ professional?: Professional; error?: string }> {
    const client = createSupabaseClient();
    const { data, error } = await client.from("professionals").select("*").eq("id", id).maybeSingle();
    if (error) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (!data) {
      return { error: "Professionnel non trouvé." };
    }
    return { professional: data as Professional };
  }

  static async createProfessional(user_id: string, display_name: string, category_id: string, is_active: boolean): Promise<{ professional?: Professional; error?: string }> {
    // Validation
    if (!user_id) {
      return { error: "user_id obligatoire." };
    }
    if (!display_name || display_name.trim() === "") {
      return { error: "Le nom affiché est obligatoire." };
    }
    if (!category_id) {
      return { error: "category_id obligatoire." };
    }
    const client = createSupabaseClient();
    // Vérifier unicité user_id
    const { data: existing, error: findError } = await client.from("professionals").select("id").eq("user_id", user_id).maybeSingle();
    if (findError) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (existing) {
      return { error: "Un professionnel existe déjà pour cet utilisateur." };
    }
    const now = new Date().toISOString();
    const { data, error } = await client.from("professionals").insert([
      { user_id, display_name, category_id, is_active, created_at: now, updated_at: now }
    ]).select().single();
    if (error) {
      return { error: "Erreur lors de la création du professionnel." };
    }
    return { professional: data as Professional };
  }
}
