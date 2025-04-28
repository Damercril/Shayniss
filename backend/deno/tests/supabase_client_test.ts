import { assert } from "https://deno.land/std@0.181.0/testing/asserts.ts";
import { createSupabaseClient } from "../services/supabase_client.ts";

// Test 1 : La connexion à Supabase retourne bien un client valide (non-null)
Deno.test("Connexion à Supabase retourne un client valide", () => {
  const client = createSupabaseClient();
  console.log("Client Supabase:", client);
  assert(client !== null, "Le client Supabase ne doit pas être null");
});

// Test 2 : Une requête simple ne renvoie pas d’erreur (liste des tables)
Deno.test("Requête simple sur Supabase ne renvoie pas d’erreur", async () => {
  const client = createSupabaseClient();
  const { data, error } = await client.from("users").select("id").limit(1);
  console.log("Résultat requête:", data, error);
  assert(!error, "La requête ne doit pas renvoyer d’erreur");
});
