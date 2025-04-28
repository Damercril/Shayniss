// Modèle Category avec validation stricte
export interface CategoryProps {
  name: string;
  id?: string;
  created_at?: string;
  updated_at?: string;
}

export class Category {
  id?: string;
  name: string;
  created_at?: string;
  updated_at?: string;

  constructor(props: CategoryProps) {
    if (!props.name || props.name.trim() === "") {
      throw new Error("Le nom de la catégorie ne peut pas être vide.");
    }
    this.name = props.name;
    this.id = props.id;
    this.created_at = props.created_at;
    this.updated_at = props.updated_at;
  }

  static fromJson(json: any): Category {
    return new Category({
      id: json.id,
      name: json.name,
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }
}
