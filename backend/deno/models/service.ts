// Modèle Service avec validation stricte selon les contraintes mémoire/database_schema
export interface ServiceProps {
  name: string;
  professional_id: string;
  price: number;
  duration_minutes: number;
  is_active: boolean;
  booking_count: number;
  created_at?: string;
  updated_at?: string;
}

export class Service {
  name: string;
  professional_id: string;
  price: number;
  duration_minutes: number;
  is_active: boolean;
  booking_count: number;
  created_at?: string;
  updated_at?: string;

  constructor(props: ServiceProps) {
    if (!props.name || props.name.trim() === "") {
      throw new Error("Le nom du service ne peut pas être vide.");
    }
    if (props.price < 0) {
      throw new Error("Le prix doit être positif ou nul.");
    }
    if (props.duration_minutes < 0) {
      throw new Error("La durée doit être positive ou nulle.");
    }
    if (props.booking_count < 0) {
      throw new Error("Le nombre de réservations doit être positif ou nul.");
    }
    this.name = props.name;
    this.professional_id = props.professional_id;
    this.price = props.price;
    this.duration_minutes = props.duration_minutes;
    this.is_active = props.is_active;
    this.booking_count = props.booking_count;
    this.created_at = props.created_at;
    this.updated_at = props.updated_at;
  }

  static fromJson(json: any): Service {
    return new Service({
      name: json.name,
      professional_id: json.professional_id,
      price: json.price,
      duration_minutes: json.duration_minutes,
      is_active: json.is_active,
      booking_count: json.booking_count,
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }

  copyWith(update: Partial<ServiceProps>): Service {
    return new Service({
      name: update.name ?? this.name,
      professional_id: update.professional_id ?? this.professional_id,
      price: update.price ?? this.price,
      duration_minutes: update.duration_minutes ?? this.duration_minutes,
      is_active: update.is_active ?? this.is_active,
      booking_count: update.booking_count ?? this.booking_count,
      created_at: update.created_at ?? this.created_at,
      updated_at: update.updated_at ?? this.updated_at,
    });
  }
}
