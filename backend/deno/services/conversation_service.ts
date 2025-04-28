import { Conversation } from "../models/conversation.ts";
import { client } from "../supabase.ts";

export class ConversationService {
  static async createOrGetConversation(participants: string[]): Promise<{ conversation?: Conversation; error?: string }> {
    console.log("[INFO][CONV] ➡️ Début création ou récupération conversation", { participants });
    // Vérifier si une conversation existe déjà avec exactement ces participants
    const { data: existing } = await client.from("conversations").select("*").contains("participants", participants).single();
    if (existing) {
      console.log("[INFO][CONV] ✅ Conversation existante trouvée", existing);
      return { conversation: existing as Conversation };
    }
    // Créer la conversation
    const now = new Date().toISOString();
    const { data, error } = await client.from("conversations").insert([
      { participants, created_at: now }
    ]).select().single();
    if (error) {
      console.log("[ERROR][CONV] ❌ Erreur lors de la création de la conversation", error);
      return { error: "Erreur lors de la création de la conversation" };
    }
    console.log("[INFO][CONV] ✅ Nouvelle conversation créée", data);
    return { conversation: data as Conversation };
  }
}
