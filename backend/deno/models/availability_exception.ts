// Modèle AvailabilityException avec validation stricte
export interface AvailabilityExceptionProps {
  availability_id: string;
  exception_date: string; // Format YYYY-MM-DD
  id?: string;
  created_at?: string;
  updated_at?: string;
}

export class AvailabilityException {
  id?: string;
  availability_id: string;
  exception_date: string;
  created_at?: string;
  updated_at?: string;

  constructor(props: AvailabilityExceptionProps) {
    if (!props.availability_id || props.availability_id.trim() === "") {
      throw new Error("Le créneau de disponibilité est obligatoire.");
    }
    if (!props.exception_date || !/^\d{4}-\d{2}-\d{2}$/.test(props.exception_date)) {
      throw new Error("La date d'exception doit être au format YYYY-MM-DD.");
    }
    this.availability_id = props.availability_id;
    this.exception_date = props.exception_date;
    this.id = props.id;
    this.created_at = props.created_at;
    this.updated_at = props.updated_at;
  }

  static fromJson(json: any): AvailabilityException {
    return new AvailabilityException({
      id: json.id,
      availability_id: json.availability_id,
      exception_date: json.exception_date,
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }
}
