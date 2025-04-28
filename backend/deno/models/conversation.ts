export interface Conversation {
  id: string;
  participants: string[]; // array of user ids
  created_at: string;
}

export function fromJsonConversation(json: any): Conversation {
  if (!json.id || !json.participants || !Array.isArray(json.participants) || !json.created_at) {
    throw new Error("Conversation: champs obligatoires manquants ou invalides");
  }
  return {
    id: json.id,
    participants: json.participants,
    created_at: json.created_at
  };
}
