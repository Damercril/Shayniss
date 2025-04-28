// Modèle Availability avec validation stricte (créneaux simples et récurrents)
export interface AvailabilityProps {
  professional_id: string;
  start_time: string; // ISO string ou HH:mm pour récurrence
  end_time: string;   // ISO string ou HH:mm pour récurrence
  day_of_week?: number; // 0=dimanche, 1=lundi, ...
  recurrence?: "none" | "weekly";
  id?: string;
  created_at?: string;
  updated_at?: string;
}

export class Availability {
  id?: string;
  professional_id: string;
  start_time: string;
  end_time: string;
  day_of_week?: number;
  recurrence?: "none" | "weekly";
  created_at?: string;
  updated_at?: string;

  constructor(props: AvailabilityProps) {
    if (!props.professional_id || props.professional_id.trim() === "") {
      throw new Error("Le professionnel est obligatoire.");
    }
    if (!props.start_time || !props.end_time) {
      throw new Error("Les horaires de début et de fin sont obligatoires.");
    }
    // Cas récurrence (heure HH:mm), sinon ISO
    if (props.day_of_week !== undefined || props.recurrence) {
      // Format HH:mm attendu
      if (!/^\d{2}:\d{2}$/.test(props.start_time) || !/^\d{2}:\d{2}$/.test(props.end_time)) {
        throw new Error("Format horaire HH:mm attendu pour la récurrence.");
      }
    } else {
      // Format ISO attendu
      if (isNaN(Date.parse(props.start_time)) || isNaN(Date.parse(props.end_time))) {
        throw new Error("Format ISO attendu pour start_time et end_time.");
      }
    }
    // Validation cohérence horaire
    if (props.start_time >= props.end_time) {
      throw new Error("L'heure de fin doit être postérieure à l'heure de début.");
    }
    this.professional_id = props.professional_id;
    this.start_time = props.start_time;
    this.end_time = props.end_time;
    this.day_of_week = props.day_of_week;
    this.recurrence = props.recurrence || "none";
    this.id = props.id;
    this.created_at = props.created_at;
    this.updated_at = props.updated_at;
  }

  static fromJson(json: any): Availability {
    return new Availability({
      id: json.id,
      professional_id: json.professional_id,
      start_time: json.start_time,
      end_time: json.end_time,
      day_of_week: json.day_of_week,
      recurrence: json.recurrence,
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }
}
