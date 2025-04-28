// Utilitaire pour le hash du mot de passe
import { hash } from "https://deno.land/x/bcrypt@v0.4.1/mod.ts";

export async function hashPassword(password: string): Promise<string> {
  return await hash(password);
}
