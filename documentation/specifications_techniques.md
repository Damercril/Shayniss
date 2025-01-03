# Spécifications Techniques Shayniss

## 1. Fonctionnalités Implémentées

### Interface Client

#### Navigation
- [x] Barre de navigation avec 5 onglets
  - Accueil
  - Recherche
  - Carte (en relief)
  - Rendez-vous
  - Profil

#### Écran d'Accueil
- [x] En-tête avec logo
- [x] Barre de notification
- [x] Carrousel des services
- [x] Feed d'actualités des prestataires
- [x] Système de like
- [x] Compteur de messages non lus

#### Recherche
- [x] Barre de recherche
- [x] Filtres par catégorie
- [x] Liste des prestataires
- [x] Tri par note/distance

#### Carte
- [x] Affichage des prestataires
- [x] Localisation actuelle
- [x] Filtres par service

#### Profil Client
- [x] Photo de profil
- [x] Informations personnelles
- [x] Liste des rendez-vous
- [x] Prestataires favoris
- [x] Paramètres

#### Détails Prestataire
- [x] Galerie photos
- [x] Description
- [x] Services proposés
- [x] Avis clients
- [x] Système de notation
- [x] Bouton de réservation

#### Rendez-vous
- [x] Liste des rendez-vous
- [x] Statut des rendez-vous
- [x] Détails du rendez-vous
- [x] Formulaire de réservation

#### Messagerie
- [x] Liste des conversations
- [x] Indicateur de messages non lus
- [x] Interface de chat

## 2. Fonctionnalités à Implémenter

### Authentification
- [ ] Inscription client/prestataire
- [ ] Connexion
- [ ] Récupération de mot de passe
- [ ] Vérification email
- [ ] Authentification par réseaux sociaux

### Gestion des Données
- [ ] Connexion avec Firebase
- [ ] Stockage des images
- [ ] Gestion des notifications push
- [ ] Synchronisation en temps réel

### Paiements
- [ ] Intégration Stripe
- [ ] Gestion des cartes bancaires
- [ ] Historique des paiements
- [ ] Système de remboursement

### Géolocalisation
- [ ] Calcul des distances
- [ ] Optimisation des itinéraires
- [ ] Zones de service

### Rendez-vous
- [ ] Gestion des disponibilités
- [ ] Confirmation automatique
- [ ] Rappels automatiques
- [ ] Annulation/Modification

### Messagerie
- [ ] Envoi de fichiers
- [ ] Messages vocaux
- [ ] Statut de lecture
- [ ] Notifications en temps réel

## 3. Schéma de Base de Données (Firebase)

### Collections

#### users
```json
{
  "uid": "string",
  "email": "string",
  "phoneNumber": "string",
  "firstName": "string",
  "lastName": "string",
  "profilePicture": "string (URL)",
  "userType": "enum (client/professional)",
  "createdAt": "timestamp",
  "lastLogin": "timestamp",
  "settings": {
    "notifications": "boolean",
    "language": "string",
    "darkMode": "boolean"
  }
}
```

#### professionals
```json
{
  "uid": "string (ref: users)",
  "businessName": "string",
  "description": "string",
  "services": [{
    "id": "string",
    "name": "string",
    "price": "number",
    "duration": "number",
    "description": "string"
  }],
  "categories": ["string"],
  "gallery": ["string (URL)"],
  "location": {
    "address": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "rating": "number",
  "reviewCount": "number",
  "availability": [{
    "day": "number",
    "slots": [{
      "start": "string",
      "end": "string"
    }]
  }]
}
```

#### appointments
```json
{
  "id": "string",
  "clientId": "string (ref: users)",
  "professionalId": "string (ref: professionals)",
  "serviceId": "string",
  "date": "timestamp",
  "duration": "number",
  "status": "enum (pending/confirmed/cancelled/completed)",
  "price": "number",
  "paymentStatus": "enum (pending/paid/refunded)",
  "createdAt": "timestamp",
  "notes": "string"
}
```

#### reviews
```json
{
  "id": "string",
  "clientId": "string (ref: users)",
  "professionalId": "string (ref: professionals)",
  "appointmentId": "string (ref: appointments)",
  "rating": "number",
  "comment": "string",
  "createdAt": "timestamp",
  "images": ["string (URL)"]
}
```

#### messages
```json
{
  "id": "string",
  "conversationId": "string",
  "senderId": "string (ref: users)",
  "receiverId": "string (ref: users)",
  "content": "string",
  "type": "enum (text/image/voice)",
  "createdAt": "timestamp",
  "read": "boolean"
}
```

#### conversations
```json
{
  "id": "string",
  "participants": ["string (ref: users)"],
  "lastMessage": {
    "content": "string",
    "senderId": "string",
    "timestamp": "timestamp"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### payments
```json
{
  "id": "string",
  "appointmentId": "string (ref: appointments)",
  "clientId": "string (ref: users)",
  "professionalId": "string (ref: professionals)",
  "amount": "number",
  "status": "enum (pending/completed/failed/refunded)",
  "paymentMethod": "string",
  "stripePaymentId": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 4. Relations et Indexation

### Indexes Principaux
- users: email, phoneNumber
- professionals: categories, location
- appointments: clientId + date, professionalId + date
- messages: conversationId + createdAt
- reviews: professionalId + createdAt

### Relations
- User -> Professional (1:1)
- Professional -> Services (1:n)
- Professional -> Reviews (1:n)
- User -> Appointments (1:n)
- User -> Conversations (n:n)
- Appointment -> Review (1:1)
- Appointment -> Payment (1:1)

## 5. Sécurité et Règles d'Accès

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles de base à implémenter pour chaque collection
    // avec vérification des rôles et des permissions
  }
}
```
