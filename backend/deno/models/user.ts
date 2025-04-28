// Modèle User aligné avec la BDD Supabase
export interface User {
  id: string;
  email: string;
  phone?: string;
  password_hash: string;
  role: "client" | "professional" | "admin";
  created_at: string;
  updated_at: string;
}
