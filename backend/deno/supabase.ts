// ATTENTION : Ce fichier est conçu pour être exécuté avec Deno.
// Si votre IDE affiche des erreurs sur 'Deno' ou l'import externe, c'est normal.
// Utilisez un plugin Deno ou ignorez ces warnings pour l'édition.

// Import Supabase client (compatible avec Deno)
import { createClient } from "https://esm.sh/v135/@supabase/supabase-js@2.39.7/dist/module/index.js";

// Récupération sécurisée des variables d'environnement
// Pour l'IDE, ignorer l'erreur "Cannot find name 'Deno'" si vous n'utilisez pas Deno
// Ces variables doivent être définies dans votre environnement Deno
const supabaseUrl = typeof Deno !== 'undefined' ? Deno.env.get("SUPABASE_URL") : undefined;
const supabaseKey = typeof Deno !== 'undefined' ? Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") : undefined;

console.log("[SUPABASE] Début initialisation du client Supabase");
console.log("[SUPABASE] URL utilisée :", supabaseUrl);
if (!supabaseUrl || !supabaseKey) {
  console.error("[SUPABASE] Variables d'environnement manquantes : SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY");
  throw new Error("Variables d'environnement Supabase manquantes");
}

export const client = createClient(supabaseUrl, supabaseKey);
console.log("[SUPABASE] Client Supabase initialisé avec succès");
