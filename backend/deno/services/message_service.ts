import { Message } from "../models/message.ts";
import { client } from "../supabase.ts";
import { NotificationService } from "./notification_service.ts";

export class MessageService {
  static async sendMessage(conversation_id: string, sender_id: string, content: string): Promise<{ message?: Message; error?: string }> {
    console.log("[INFO][MESSAGING] ➡️ Début de l'envoi d'un message");
    console.log("[INFO][MESSAGING] 📥 Données reçues :", { conversation_id, sender_id, content });
    // Récupérer la conversation et vérifier que le sender est participant
    const { data: conv, error: convError } = await client.from("conversations").select("*").eq("id", conversation_id).single();
    if (convError) {
      console.log("[ERROR][MESSAGING] ❌ Erreur lors de la récupération de la conversation :", convError.message);
      return { error: "Erreur lors de la récupération de la conversation" };
    }
    if (!conv || !conv.participants.includes(sender_id)) {
      console.log("[ERROR][MESSAGING] ⚠️ Accès refusé ou conversation introuvable");
      return { error: "Accès refusé ou conversation introuvable" };
    }
    console.log("[INFO][MESSAGING] ✅ Conversation trouvée :", conv);
    const now = new Date().toISOString();
    const { data, error } = await client.from("messages").insert([
      { conversation_id, sender_id, content, created_at: now, lu: false }
    ]).select().single();
    if (error) {
      console.log("[ERROR][MESSAGING] ❌ Erreur lors de l'envoi du message :", error.message);
      return { error: "Erreur lors de l'envoi du message" };
    }
    console.log("[INFO][MESSAGING] ✅ Message inséré dans la base :", data);
    // Notifier les autres participants
    for (const user_id of conv.participants) {
      if (user_id !== sender_id) {
        console.log(`[INFO][MESSAGING] 🔔 Notification envoyée à ${user_id}`);
        await NotificationService.createNotification(
          user_id,
          "new_message",
          `Nouveau message de ${sender_id}: ${content}`
        );
      }
    }
    console.log("[INFO][MESSAGING] ✅ Message envoyé avec succès");
    return { message: data as Message };
  }

  static async listMessages(conversation_id: string, user_id: string, limit = 10, offset = 0): Promise<{ messages?: Message[]; error?: string }> {
    console.log("[INFO][MESSAGING] ➡️ Début de la récupération des messages");
    console.log("[INFO][MESSAGING] 📥 Paramètres reçus :", { conversation_id, user_id, limit, offset });
    // Vérifier que l'utilisateur est participant
    const { data: conv, error: convError } = await client.from("conversations").select("*").eq("id", conversation_id).single();
    if (convError) {
      console.log("[ERROR][MESSAGING] ❌ Erreur lors de la récupération de la conversation :", convError.message);
      return { error: "Erreur lors de la récupération de la conversation" };
    }
    if (!conv || !conv.participants.includes(user_id)) {
      console.log("[ERROR][MESSAGING] ⚠️ Accès refusé à la conversation");
      return { error: "Accès refusé à la conversation" };
    }
    console.log("[INFO][MESSAGING] ✅ Conversation trouvée :", conv);
    const { data, error } = await client.from("messages").select("*").eq("conversation_id", conversation_id).order("created_at", { ascending: true }).range(offset, offset + limit - 1);
    if (error) {
      console.log("[ERROR][MESSAGING] ❌ Erreur lors de la récupération des messages :", error.message);
      return { error: "Erreur lors de la récupération des messages" };
    }
    console.log("[INFO][MESSAGING] ✅ Messages récupérés :", data);
    return { messages: data as Message[] };
  }

  static async deleteMessages(conversation_id: string, user_id: string): Promise<{ deleted: boolean; error?: string }> {
    console.log("[INFO][MESSAGING] ➡️ Début de la suppression des messages d'une conversation");
    console.log("[INFO][MESSAGING] 📥 Paramètres reçus :", { conversation_id, user_id });
    // Vérifier que l'utilisateur est participant
    const { data: conv, error: convError } = await client.from("conversations").select("*").eq("id", conversation_id).single();
    if (convError) {
      console.log("[ERROR][MESSAGING] ❌ Erreur lors de la récupération de la conversation :", convError.message);
      return { deleted: false, error: "Erreur lors de la récupération de la conversation" };
    }
    if (!conv || !conv.participants.includes(user_id)) {
      console.log("[ERROR][MESSAGING] ⚠️ Accès refusé à la conversation");
      return { deleted: false, error: "Accès refusé à la conversation" };
    }
    console.log("[INFO][MESSAGING] ✅ Conversation trouvée :", conv);
    // Suppression logique (on marque les messages comme supprimés pour ce user, à adapter si soft delete par user)
    // Ici, on supprime pour tous (hard delete)
    const { error } = await client.from("messages").delete().eq("conversation_id", conversation_id);
    if (error) {
      console.log("[ERROR][MESSAGING] ❌ Erreur lors de la suppression :", error.message);
      return { deleted: false, error: "Erreur lors de la suppression" };
    }
    console.log("[INFO][MESSAGING] ✅ Messages supprimés avec succès");
    return { deleted: true };
  }
}
