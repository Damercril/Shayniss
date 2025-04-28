// Modèle Professional aligné avec la BDD Supabase
export interface Professional {
  id: string;
  user_id: string;
  display_name: string;
  bio?: string;
  category_id: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
