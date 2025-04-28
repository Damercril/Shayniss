# Schéma de la base de données Shayniss (Supabase)

## users
- id (uuid, pk)
- email (text, unique)
- phone (text, unique, nullable)
- password_hash (text)
- role (enum: client | professional | admin)
- created_at (timestamp)
- updated_at (timestamp)

## professionals
- user_id (uuid, pk, fk → users.id)
- photo_url (text)
- description (text)
- address (text)
- can_travel (bool)
- travel_radius_km (int)
- created_at (timestamp)
- updated_at (timestamp)

## categories
- id (uuid, pk)
- name (text, unique)
- icon_url (text)
- created_at (timestamp)
- updated_at (timestamp)

## services
- id (uuid, pk)
- professional_id (uuid, fk → professionals.user_id)
- name (text)
- description (text)
- price (decimal ≥ 0)
- duration_minutes (int ≥ 0)
- category_id (uuid, fk → categories.id)
- image_url (text)
- is_active (bool)
- booking_count (int ≥ 0, default 0)
- created_at (timestamp)
- updated_at (timestamp)

## availability
- id (uuid, pk)
- professional_id (uuid, fk → professionals.user_id)
- start_time (timestamp)
- end_time (timestamp)
- recurring_pattern (json, nullable)
- created_at (timestamp)
- updated_at (timestamp)

## bookings
- id (uuid, pk)
- client_id (uuid, fk → users.id)
- professional_id (uuid, fk → professionals.user_id)
- service_id (uuid, fk → services.id)
- slot_start (timestamp)
- slot_end (timestamp)
- location_type (enum: domicile | salon)
- status (enum: pending | confirmed | cancelled)
- created_at (timestamp)
- updated_at (timestamp)

## conversations
- id (uuid, pk)
- participants (uuid[], not null) — liste des utilisateurs participants
- created_at (timestamp, default now())

### Contraintes
- Unicité des conversations pour un ensemble de participants (clé composite ou contrainte logique)

### RLS
- Seuls les participants peuvent lire, écrire ou supprimer la conversation

## messages
- id (uuid, pk)
- conversation_id (uuid, fk → conversations.id, not null)
- sender_id (uuid, not null)
- content (text, not null)
- created_at (timestamp, default now())
- lu (boolean, default false)

### Index
- Index sur (conversation_id, created_at)

### RLS
- Seuls les participants de la conversation peuvent lire, écrire ou supprimer les messages

## notifications
- id (uuid, pk)
- user_id (uuid, fk → users.id)
- type (enum: booking | message | review | system)
- payload (json)
- read (bool)
- created_at (timestamp)

## reviews
- id (uuid, pk)
- booking_id (uuid, fk → bookings.id)
- client_id (uuid, fk → users.id)
- professional_id (uuid, fk → professionals.user_id)
- rating (int 1-5)
- comment (text)
- created_at (timestamp)

## stories
- id (uuid, pk)
- professional_id (uuid, fk → professionals.user_id)
- media_url (text)
- media_type (enum: image | video)
- created_at (timestamp)
- expires_at (timestamp)
- seen_count (int)

## story_views
- story_id (uuid, fk → stories.id)
- user_id (uuid, fk → users.id)
- viewed_at (timestamp)
- pk composite (story_id, user_id)

---
### Contraintes & Index
- GIN index sur services(name, description) pour recherche full-text
- Index composite sur services(category_id, price, duration_minutes)
- Index sur booking_count
- Triggers pour updated_at automatique et purge stories expirées
- RLS : seul owner peut modifier ses données, lecture publique pour services actifs