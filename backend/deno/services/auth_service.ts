// Service AuthService : inscription utilisateur avec validation et hash du mot de passe
import { createSupabaseClient } from "./supabase_client.ts";
import { User } from "../models/user.ts";
import { hashPassword } from "../utils/hash.ts";

export class AuthService {
  static async register(email: string, password: string, role: "client" | "professional"): Promise<{ user?: User; error?: string }> {
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
}
