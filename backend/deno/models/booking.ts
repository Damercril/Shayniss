// Modèle Booking avec validation stricte
export interface BookingProps {
  id?: string;
  client_id: string;
  professional_id: string;
  availability_id: string;
  booking_date: string; // ISO string
  status?: string; // 'confirmed', 'cancelled', etc.
  created_at?: string;
  updated_at?: string;
}

export class Booking {
  id?: string;
  client_id: string;
  professional_id: string;
  availability_id: string;
  booking_date: string;
  status: string;
  created_at?: string;
  updated_at?: string;

  constructor(props: BookingProps) {
    if (!props.client_id || !props.professional_id || !props.availability_id) {
      throw new Error("Client, professionnel et créneau sont obligatoires.");
    }
    if (!props.booking_date || isNaN(Date.parse(props.booking_date))) {
      throw new Error("Date de réservation invalide.");
    }
    this.id = props.id;
    this.client_id = props.client_id;
    this.professional_id = props.professional_id;
    this.availability_id = props.availability_id;
    this.booking_date = props.booking_date;
    this.status = props.status || 'confirmed';
    this.created_at = props.created_at;
    this.updated_at = props.updated_at;
  }

  static fromJson(json: any): Booking {
    return new Booking({
      id: json.id,
      client_id: json.client_id,
      professional_id: json.professional_id,
      availability_id: json.availability_id,
      booking_date: json.booking_date,
      status: json.status,
      created_at: json.created_at,
      updated_at: json.updated_at,
    });
  }
}
