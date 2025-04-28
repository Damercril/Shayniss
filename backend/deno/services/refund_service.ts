import { Refund } from "../models/refund.ts";
import { client } from "../supabase.ts";

export class RefundService {
  static async createRefund(booking_id: string, user_id: string, amount: number, policy_applied: string): Promise<{ refund?: Refund; error?: string }> {
    console.log("[INFO][REFUND] ➡️ Début création remboursement", { booking_id, user_id, amount, policy_applied });
    // Vérifier qu'il n'existe pas déjà un remboursement pour cette réservation
    const { data: existing } = await client.from("refunds").select("*").eq("booking_id", booking_id);
    if (existing && existing.length > 0) {
      console.log("[ERROR][REFUND] ⚠️ Remboursement déjà effectué", existing);
      return { error: "Remboursement déjà effectué" };
    }
    const now = new Date().toISOString();
    const { data, error } = await client.from("refunds").insert([
      { booking_id, user_id, amount, status: "remboursé", policy_applied, created_at: now }
    ]).select().single();
    if (error) {
      console.log("[ERROR][REFUND] ❌ Erreur création remboursement", error);
      return { error: "Erreur lors de la création du remboursement" };
    }
    console.log("[INFO][REFUND] ✅ Remboursement créé", data);
    return { refund: data as Refund };
  }

  static async listRefunds(booking_id: string): Promise<{ refunds?: Refund[]; error?: string }> {
    console.log("[INFO][REFUND] ➡️ Début récupération remboursements", { booking_id });
    const { data, error } = await client.from("refunds").select("*").eq("booking_id", booking_id);
    if (error) {
      console.log("[ERROR][REFUND] ❌ Erreur récupération remboursements", error);
      return { error: "Erreur lors de la récupération des remboursements" };
    }
    console.log("[INFO][REFUND] ✅ Remboursements récupérés", data);
    return { refunds: data as Refund[] };
  }
}
