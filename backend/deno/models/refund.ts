export interface Refund {
  id: string;
  booking_id: string;
  user_id: string;
  amount: number;
  status: string; // remboursé, en_attente, refusé...
  policy_applied: string; // total, partiel
  created_at: string;
}

export function fromJsonRefund(json: any): Refund {
  if (!json.booking_id || !json.user_id || typeof json.amount !== 'number' || !json.status || !json.policy_applied || !json.created_at) {
    throw new Error("Refund: champs obligatoires manquants ou invalides");
  }
  return {
    id: json.id,
    booking_id: json.booking_id,
    user_id: json.user_id,
    amount: json.amount,
    status: json.status,
    policy_applied: json.policy_applied,
    created_at: json.created_at
  };
}
