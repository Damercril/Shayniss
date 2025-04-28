export interface Notification {
  id: string;
  user_id: string;
  type: string; // booking_created, booking_new_client, booking_cancelled...
  message: string;
  created_at: string;
  lu: boolean;
}

export function fromJsonNotification(json: any): Notification {
  if (!json.user_id || !json.type || !json.message || !json.created_at) {
    throw new Error("Notification: champs obligatoires manquants");
  }
  return {
    id: json.id,
    user_id: json.user_id,
    type: json.type,
    message: json.message,
    created_at: json.created_at,
    lu: json.lu ?? false
  };
}
