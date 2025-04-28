# Endpoints API Deno pour Shayniss

## Authentification
- POST   /auth/register
- POST   /auth/login
- GET    /auth/me
- POST   /auth/logout

## Utilisateurs
- GET    /users/:id
- PUT    /users/:id
- GET    /clients/:id/bookings
- GET    /professionals/:id/bookings

## Profils professionnels
- GET    /professionals/:id
- PUT    /professionals/:id/profile
- PUT    /professionals/:id/settings

## Catégories & recherche
- GET    /categories
- GET    /search/services?category=&minPrice=&maxPrice=&duration=&q=

## Services
- GET    /professionals/:id/services
- GET    /services/:id
- POST   /services
- PUT    /services/:id
- DELETE /services/:id

## Disponibilités
- GET    /professionals/:id/availability
- POST   /availability
- PUT    /availability/:id
- DELETE /availability/:id

## Réservations (Bookings)
- GET    /bookings?userId=&professionalId=
- POST   /bookings
- GET    /bookings/:id
- PUT    /bookings/:id
- DELETE /bookings/:id

## Messagerie
- GET    /conversations?userId=&professionalId=
- POST   /conversations
- GET    /conversations/:id/messages
- POST   /conversations/:id/messages

## Notifications
- GET    /notifications?userId=
- PUT    /notifications/:id/read

## Avis & notations
- GET    /reviews?professionalId=
- POST   /reviews

## Stories
- GET    /professionals/:id/stories
- POST   /stories
- DELETE /stories/:id

---
Chaque endpoint sera documenté avec : méthode, route, description, payload attendu, réponse, et règles d’accès (auth, RLS).

---

### Exemple de documentation détaillée pour chaque endpoint principal (payload, réponse, règles d'accès)

#### POST /auth/register
- Description : Inscription d’un nouvel utilisateur (client ou professionnel)
- Payload attendu :
  {
    "email": "string",
    "password": "string",
    "role": "client" | "professional"
  }
- Réponse :
  201 Created
  {
    "id": "uuid",
    "email": "string",
    "role": "client" | "professional",
    "created_at": "timestamp"
  }
- Règles d’accès : Public (non authentifié)
- Erreurs :
  - 400 : Email déjà utilisé, mot de passe trop court, etc.
  - 500 : Erreur serveur

#### POST /auth/login
- Description : Connexion d’un utilisateur existant
- Payload attendu :
  {
    "email": "string",
    "password": "string"
  }
- Réponse :
  200 OK
  {
    "token": "string",
    "user": {
      "id": "uuid",
      "email": "string",
      "role": "client" | "professional"
    }
  }
- Règles d’accès : Public (non authentifié)
- Erreurs :
  - 401 : Identifiants invalides
  - 500 : Erreur serveur

#### GET /auth/me
- Description : Récupérer les infos de l’utilisateur connecté
- Réponse :
  200 OK
  {
    "id": "uuid",
    "email": "string",
    "role": "client" | "professional"
  }
- Règles d’accès : Authentifié
- Erreurs :
  - 401 : Non authentifié

#### POST /auth/logout
- Description : Déconnexion de l’utilisateur
- Réponse :
  204 No Content
- Règles d’accès : Authentifié

#### GET /users/:id
- Description : Récupérer les informations d’un utilisateur
- Réponse :
  200 OK
  {
    "id": "uuid",
    "email": "string",
    "role": "client" | "professional" | "admin",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
- Règles d’accès : Authentifié (lui-même ou admin)
- Erreurs :
  - 404 : Utilisateur non trouvé
  - 403 : Accès interdit

#### PUT /users/:id
- Description : Mettre à jour les informations d’un utilisateur
- Payload attendu :
  {
    "email"?: "string",
    "phone"?: "string"
  }
- Réponse :
  200 OK
  {
    "id": "uuid",
    "email": "string",
    "phone": "string",
    "updated_at": "timestamp"
  }
- Règles d’accès : Authentifié (lui-même ou admin)
- Erreurs :
  - 404 : Utilisateur non trouvé
  - 403 : Accès interdit
  - 400 : Données invalides

#### GET /clients/:id/bookings
- Description : Liste des réservations d’un client
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "service_id": "uuid",
      "slot_start": "timestamp",
      "slot_end": "timestamp",
      "status": "pending" | "confirmed" | "cancelled"
    }, ...
  ]
- Règles d’accès : Authentifié (lui-même ou admin)

#### GET /professionals/:id/bookings
- Description : Liste des réservations d’un professionnel
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "service_id": "uuid",
      "slot_start": "timestamp",
      "slot_end": "timestamp",
      "status": "pending" | "confirmed" | "cancelled"
    }, ...
  ]
- Règles d’accès : Authentifié (lui-même ou admin)

#### GET /professionals/:id
- Description : Récupérer le profil d’un professionnel
- Réponse :
  200 OK
  {
    "user_id": "uuid",
    "photo_url": "string",
    "description": "string",
    "address": "string",
    "can_travel": true,
    "travel_radius_km": 10,
    "created_at": "timestamp"
  }
- Règles d’accès : Public
- Erreurs :
  - 404 : Professionnel non trouvé

#### PUT /professionals/:id/profile
- Description : Mettre à jour le profil professionnel
- Payload attendu :
  {
    "photo_url"?: "string",
    "description"?: "string",
    "address"?: "string",
    "can_travel"?: true,
    "travel_radius_km"?: 10
  }
- Réponse :
  200 OK
  {
    ...profil mis à jour...
  }
- Règles d’accès : Authentifié (lui-même ou admin)
- Erreurs :
  - 404 : Professionnel non trouvé
  - 403 : Accès interdit
  - 400 : Données invalides

#### PUT /professionals/:id/settings
- Description : Mettre à jour les paramètres professionnels
- Payload attendu :
  {
    ...
  }
- Réponse :
  200 OK
  {
    ...paramètres mis à jour...
  }
- Règles d’accès : Authentifié (lui-même ou admin)
- Erreurs :
  - 404 : Professionnel non trouvé
  - 403 : Accès interdit
  - 400 : Données invalides

#### GET /categories
- Description : Liste des catégories de services
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "name": "string",
      "icon_url": "string"
    }, ...
  ]
- Règles d’accès : Public

#### GET /search/services
- Description : Recherche de services avec filtres dynamiques
- Query params : category, minPrice, maxPrice, duration, q
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "name": "string",
      "price": 50.0,
      "duration_minutes": 60,
      "category_id": "uuid",
      "is_active": true,
      "booking_count": 12
    }, ...
  ]
- Règles d’accès : Public

#### GET /professionals/:id/services
- Description : Liste des services proposés par un professionnel
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "name": "string",
      "price": 50.0,
      "duration_minutes": 60,
      "category_id": "uuid",
      "is_active": true,
      "booking_count": 12
    }, ...
  ]
- Règles d’accès : Public

#### GET /services/:id
- Description : Détail d’un service
- Réponse :
  200 OK
  {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "price": 50.0,
    "duration_minutes": 60,
    "category_id": "uuid",
    "image_url": "string",
    "is_active": true,
    "booking_count": 12,
    "created_at": "timestamp"
  }
- Règles d’accès : Public
- Erreurs :
  - 404 : Service non trouvé

#### POST /services
- Description : Ajouter un nouveau service
- Payload attendu :
  {
    "professional_id": "uuid",
    "name": "string",
    "description": "string",
    "price": 50.0,
    "duration_minutes": 60,
    "category_id": "uuid",
    "image_url": "string"
  }
- Réponse :
  201 Created
  {
    ...service créé...
  }
- Règles d’accès : Authentifié (propriétaire du compte)
- Erreurs :
  - 400 : Données invalides
  - 403 : Accès interdit

#### PUT /services/:id
- Description : Modifier un service existant
- Payload attendu :
  {
    ...
  }
- Réponse :
  200 OK
  {
    ...service mis à jour...
  }
- Règles d’accès : Authentifié (propriétaire du compte)
- Erreurs :
  - 404 : Service non trouvé
  - 403 : Accès interdit

#### DELETE /services/:id
- Description : Supprimer un service
- Réponse :
  204 No Content
- Règles d’accès : Authentifié (propriétaire du compte)
- Erreurs :
  - 404 : Service non trouvé
  - 403 : Accès interdit

#### GET /professionals/:id/availability
- Description : Liste des créneaux de disponibilité d’un professionnel
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "start_time": "timestamp",
      "end_time": "timestamp",
      "recurring_pattern": { ... } | null
    }, ...
  ]
- Règles d’accès : Authentifié (propriétaire ou admin)

#### POST /availability
- Description : Ajouter un créneau de disponibilité
- Payload attendu :
  {
    "professional_id": "uuid",
    "start_time": "timestamp",
    "end_time": "timestamp",
    "recurring_pattern"?: { ... }
  }
- Réponse :
  201 Created
  {
    ...créneau créé...
  }
- Règles d’accès : Authentifié (propriétaire)
- Erreurs :
  - 400 : Données invalides ou conflit
  - 403 : Accès interdit

#### PUT /availability/:id
- Description : Modifier un créneau de disponibilité
- Payload attendu :
  {
    ...
  }
- Réponse :
  200 OK
  {
    ...créneau mis à jour...
  }
- Règles d’accès : Authentifié (propriétaire)
- Erreurs :
  - 404 : Créneau non trouvé
  - 403 : Accès interdit

#### DELETE /availability/:id
- Description : Supprimer un créneau de disponibilité
- Réponse :
  204 No Content
- Règles d’accès : Authentifié (propriétaire)
- Erreurs :
  - 404 : Créneau non trouvé
  - 403 : Accès interdit

#### GET /bookings
- Description : Liste des réservations (filtrable par userId, professionalId)
- Query params : userId, professionalId
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "client_id": "uuid",
      "professional_id": "uuid",
      "service_id": "uuid",
      "slot_start": "timestamp",
      "slot_end": "timestamp",
      "status": "pending" | "confirmed" | "cancelled"
    }, ...
  ]
- Règles d’accès : Authentifié (client, professionnel ou admin)

#### POST /bookings
- Description : Créer une réservation
- Payload attendu :
  {
    "client_id": "uuid",
    "professional_id": "uuid",
    "service_id": "uuid",
    "slot_start": "timestamp",
    "slot_end": "timestamp",
    "location_type": "domicile" | "salon"
  }
- Réponse :
  201 Created
  {
    ...booking créé...
  }
- Règles d’accès : Authentifié (client)
- Erreurs :
  - 400 : Conflit de créneau, données invalides
  - 403 : Accès interdit

#### GET /bookings/:id
- Description : Détail d’une réservation
- Réponse :
  200 OK
  {
    ...
  }
- Règles d’accès : Authentifié (client, professionnel ou admin)
- Erreurs :
  - 404 : Réservation non trouvée
  - 403 : Accès interdit

#### PUT /bookings/:id
- Description : Modifier une réservation (statut, annulation)
- Payload attendu :
  {
    "status": "pending" | "confirmed" | "cancelled"
  }
- Réponse :
  200 OK
  {
    ...booking mis à jour...
  }
- Règles d’accès : Authentifié (client, professionnel ou admin)
- Erreurs :
  - 404 : Réservation non trouvée
  - 403 : Accès interdit

#### DELETE /bookings/:id
- Description : Annuler une réservation
- Réponse :
  204 No Content
- Règles d’accès : Authentifié (client, professionnel ou admin)
- Erreurs :
  - 404 : Réservation non trouvée
  - 403 : Accès interdit

#### GET /conversations
- Description : Liste des conversations d’un utilisateur ou professionnel
- Query params : userId, professionalId
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "client_id": "uuid",
      "professional_id": "uuid",
      "booking_id": "uuid" | null,
      "created_at": "timestamp"
    }, ...
  ]
- Règles d’accès : Authentifié

#### POST /conversations
- Description : Créer une conversation
- Payload attendu :
  {
    "client_id": "uuid",
    "professional_id": "uuid",
    "booking_id"?: "uuid"
  }
- Réponse :
  201 Created
  {
    ...conversation créée...
  }
- Règles d’accès : Authentifié
- Erreurs :
  - 400 : Données invalides

#### GET /conversations/:id/messages
- Description : Liste des messages d’une conversation
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "sender_id": "uuid",
      "content": "string",
      "timestamp": "timestamp"
    }, ...
  ]
- Règles d’accès : Authentifié (participant)
- Erreurs :
  - 404 : Conversation non trouvée
  - 403 : Accès interdit

#### POST /conversations/:id/messages
- Description : Envoyer un message dans une conversation
- Payload attendu :
  {
    "sender_id": "uuid",
    "content": "string"
  }
- Réponse :
  201 Created
  {
    ...message créé...
  }
- Règles d’accès : Authentifié (participant)
- Erreurs :
  - 404 : Conversation non trouvée
  - 403 : Accès interdit

#### GET /notifications
- Description : Liste des notifications d’un utilisateur
- Query params : userId
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "type": "booking" | "message" | "review" | "system",
      "payload": { ... },
      "read": false,
      "created_at": "timestamp"
    }, ...
  ]
- Règles d’accès : Authentifié (propriétaire)

#### PUT /notifications/:id/read
- Description : Marquer une notification comme lue
- Réponse :
  200 OK
  {
    ...notification mise à jour...
  }
- Règles d’accès : Authentifié (propriétaire)
- Erreurs :
  - 404 : Notification non trouvée
  - 403 : Accès interdit

#### GET /reviews
- Description : Liste des avis pour un professionnel
- Query params : professionalId
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "booking_id": "uuid",
      "client_id": "uuid",
      "rating": 5,
      "comment": "string",
      "created_at": "timestamp"
    }, ...
  ]
- Règles d’accès : Public

#### POST /reviews
- Description : Laisser un avis sur un professionnel
- Payload attendu :
  {
    "booking_id": "uuid",
    "client_id": "uuid",
    "professional_id": "uuid",
    "rating": 5,
    "comment": "string"
  }
- Réponse :
  201 Created
  {
    ...review créée...
  }
- Règles d’accès : Authentifié (client)
- Erreurs :
  - 400 : Données invalides

#### GET /professionals/:id/stories
- Description : Liste des stories d’un professionnel
- Réponse :
  200 OK
  [
    {
      "id": "uuid",
      "media_url": "string",
      "media_type": "image" | "video",
      "created_at": "timestamp"
    }, ...
  ]
- Règles d’accès : Public

#### POST /stories
- Description : Ajouter une story
- Payload attendu :
  {
    "professional_id": "uuid",
    "media_url": "string",
    "media_type": "image" | "video"
  }
- Réponse :
  201 Created
  {
    ...story créée...
  }
- Règles d’accès : Authentifié (propriétaire)
- Erreurs :
  - 400 : Données invalides

#### DELETE /stories/:id
- Description : Supprimer une story
- Réponse :
  204 No Content
- Règles d’accès : Authentifié (propriétaire)
- Erreurs :
  - 404 : Story non trouvée
  - 403 : Accès interdit

---
# Pour chaque endpoint, compléter la documentation détaillée (payload, réponse, règles d’accès) selon ce modèle.
