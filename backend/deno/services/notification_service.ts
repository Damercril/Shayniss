import { Notification } from "../models/notification.ts";
import { client } from "../supabase.ts";

export class NotificationService {
  static async createNotification(user_id: string, type: string, message: string): Promise<{ notification?: Notification; error?: string }> {
    console.log("[INFO][NOTIF] ➡️ Début création notification", { user_id, type, message });
    const now = new Date().toISOString();
    const { data, error } = await client.from("notifications").insert([
      { user_id, type, message, created_at: now, lu: false }
    ]).select().single();
    if (error) {
      console.log("[ERROR][NOTIF] ❌ Erreur création notification", error);
      return { error: "Erreur lors de la création de la notification" };
    }
    console.log("[INFO][NOTIF] ✅ Notification créée", data);
    return { notification: data as Notification };
  }

  static async listNotifications(user_id: string): Promise<{ notifications?: Notification[]; error?: string }> {
    console.log("[INFO][NOTIF] ➡️ Début récupération notifications", { user_id });
    const { data, error } = await client.from("notifications").select("*").eq("user_id", user_id).order("created_at", { ascending: false });
    if (error) {
      console.log("[ERROR][NOTIF] ❌ Erreur récupération notifications", error);
      return { error: "Erreur lors de la récupération des notifications" };
    }
    console.log("[INFO][NOTIF] ✅ Notifications récupérées", data);
    return { notifications: data as Notification[] };
  }
}
