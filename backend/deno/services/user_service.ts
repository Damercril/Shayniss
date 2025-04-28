// Service UserService : CRUD utilisateur avec validation et gestion erreurs explicite
import { createSupabaseClient } from "./supabase_client.ts";
import { User } from "../models/user.ts";
import { hashPassword } from "../utils/hash.ts";

export class UserService {
  static async getUserById(id: string): Promise<{ user?: User; error?: string }> {
    const client = createSupabaseClient();
    const { data, error } = await client.from("users").select("*").eq("id", id).maybeSingle();
    if (error) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (!data) {
      return { error: "Utilisateur non trouvé." };
    }
    return { user: data as User };
  }

  static async createUser(email: string, password: string, role: "client" | "professional"): Promise<{ user?: User; error?: string }> {
    // Validation
    if (!email || !email.includes("@")) {
      return { error: "Email invalide." };
    }
    if (!password || password.length < 8) {
      return { error: "Le mot de passe doit contenir au moins 8 caractères." };
    }
    if (role !== "client" && role !== "professional") {
      return { error: "Rôle invalide." };
    }
    const client = createSupabaseClient();
    // Vérifier unicité email
    const { data: existing, error: findError } = await client.from("users").select("id").eq("email", email).maybeSingle();
    if (findError) {
      return { error: "Erreur de connexion à la base de données." };
    }
    if (existing) {
      return { error: "Cet email est déjà utilisé." };
    }
    // Hash du mot de passe
    const password_hash = await hashPassword(password);
    const now = new Date().toISOString();
    const { data, error } = await client.from("users").insert([
      { email, password_hash, role, created_at: now, updated_at: now }
    ]).select().single();
    if (error) {
      return { error: "Erreur lors de la création de l'utilisateur." };
    }
    return { user: data as User };
  }

  // TESTS TDD pour countUsers
  // Cas 1 : La table users existe et retourne un nombre
  // Entrée : aucune, Sortie attendue : { data: { count: number }, error: null }
  // Cas 2 : La table users n'existe pas ou base inaccessible
  // Entrée : aucune, Sortie attendue : { data: null, error: objet erreur ou message }
  // Chaque test vérifie la robustesse de la méthode pour le healthcheck

  static async countUsers(): Promise<{ data: { count: number } | null; error: any | null }> {
    console.log("[UserService][countUsers] Début comptage des utilisateurs");
    try {
      const client = createSupabaseClient();
      const { count, error } = await client.from("users").select("*", { count: "exact", head: true });
      if (error) {
        console.error("[UserService][countUsers] Erreur Supabase:", error);
        return { data: null, error };
      }
      console.log("[UserService][countUsers] Nombre d'utilisateurs:", count);
      return { data: { count: count ?? 0 }, error: null };
    } catch (e) {
      console.error("[UserService][countUsers] Exception:", e);
      return { data: null, error: e };
    }
  }
}
