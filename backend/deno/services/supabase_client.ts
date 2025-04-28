// Service de connexion à Supabase
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_KEY = Deno.env.get("SUPABASE_KEY") ?? "";

export function createSupabaseClient(): SupabaseClient {
  if (!SUPABASE_URL || !SUPABASE_KEY) {
    throw new Error("SUPABASE_URL ou SUPABASE_KEY manquant dans les variables d'environnement");
  }
  return createClient(SUPABASE_URL, SUPABASE_KEY);
}
