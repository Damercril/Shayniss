// Service CategoryService : CRUD catégorie avec validation stricte et gestion erreurs explicite
import { createSupabaseClient } from "./supabase_client.ts";
import { Category } from "../models/category.ts";

export class CategoryService {
  static async createCategory(name: string): Promise<{ category?: Category; error?: string }> {
    if (!name || name.trim() === "") {
      return { error: "Le nom de la catégorie ne peut pas être vide." };
    }
    const client = createSupabaseClient();
    // Vérifier unicité du nom
    const { data: existing, error: findError } = await client.from("categories").select("id").eq("name", name).maybeSingle();
    if (findError) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (existing) {
      return { error: "Une catégorie avec ce nom existe déjà." };
    }
    const now = new Date().toISOString();
    const { data, error } = await client.from("categories").insert([
      { name, created_at: now, updated_at: now }
    ]).select().single();
    if (error) {
      return { error: "Erreur lors de la création de la catégorie." };
    }
    return { category: data as Category };
  }

  static async getCategoryById(id: string): Promise<{ category?: Category; error?: string }> {
    const client = createSupabaseClient();
    const { data, error } = await client.from("categories").select("*").eq("id", id).maybeSingle();
    if (error) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (!data) {
      return { error: "Catégorie non trouvée." };
    }
    return { category: data as Category };
  }

  static async searchCategories(query: { search?: string; limit?: number; offset?: number }): Promise<{ categories?: Category[]; error?: string }> {
    const client = createSupabaseClient();
    let req = client.from("categories").select("*");
    if (query.search) {
      req = req.ilike("name", `%${query.search}%`);
    }
    if (query.limit !== undefined) {
      req = req.limit(query.limit);
    }
    if (query.offset !== undefined) {
      req = req.range(query.offset, (query.offset || 0) + (query.limit || 10) - 1);
    }
    const { data, error } = await req;
    if (error) {
      return { error: "Erreur lors de la recherche des catégories." };
    }
    return { categories: data as Category[] };
  }
}
