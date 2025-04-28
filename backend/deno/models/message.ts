export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  content: string;
  created_at: string;
  lu: boolean;
}

export function fromJsonMessage(json: any): Message {
  if (!json.id || !json.conversation_id || !json.sender_id || !json.content || !json.created_at || typeof json.lu !== 'boolean') {
    throw new Error("Message: champs obligatoires manquants ou invalides");
  }
  return {
    id: json.id,
    conversation_id: json.conversation_id,
    sender_id: json.sender_id,
    content: json.content,
    created_at: json.created_at,
    lu: json.lu
  };
}
