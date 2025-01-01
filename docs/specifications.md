# Cahier des Charges - Shayniss

## 1. Introduction

### 1.1. Contexte du projet
Shayniss est une application mobile et web destinée au domaine de la beauté. Initialement, elle sera conçue comme un outil pour les professionnels afin de les aider à mieux organiser leur activité. Dans une deuxième phase, elle s'ouvrira aux clients pour leur permettre de rechercher et réserver des services de beauté.

### 1.2. Objectifs généraux
- Offrir un outil organisationnel performant pour les professionnels de la beauté
- Développer une plateforme intuitive et conviviale pour les clients (phase 2)

### 1.3. Périmètre du projet
Le projet se décompose en deux phases :
- Phase 1 : Développement d'une plateforme organisationnelle pour les professionnels
- Phase 2 : Ajout de fonctionnalités pour les clients permettant de rechercher et réserver des services

## 2. Fonctionnalités principales – Phase 1 (Professionnels)

### 2.1. Fonctionnalités pour les professionnels

#### Gestion de profil
- Création et mise à jour du profil professionnel
- Upload de photos et ajout de descriptions de services

#### Gestion des rendez-vous
- Calendrier interactif pour visualiser et gérer les rendez-vous
- Notifications en cas de nouvelles réservations ou annulations

#### Statistiques et suivi
- Accès aux données sur les vues, réservations et avis
- Analyse des tendances pour optimiser les offres

#### Promotion
- Outils pour lancer des promotions ou offrir des réductions

### 2.2. Fonctionnalités pour les administrateurs

#### Gestion des professionnels
- Validation et vérification des profils professionnels
- Gestion des comptes professionnels

#### Gestion des paiements
- Suivi des transactions entre professionnels et la plateforme
- Gestion des commissions et des retraits

#### Reporting et analyse
- Génération de rapports sur l'activité de la plateforme
- Suivi des performances (taux de conversion, satisfaction des professionnels)

## 3. Fonctionnalités principales – Phase 2 (Ouverture aux clients)

### 3.1. Fonctionnalités pour les utilisateurs finaux

#### Inscription et authentification
- Inscription via email, numéro de téléphone ou réseaux sociaux
- Réinitialisation du mot de passe

#### Recherche et réservation de soins
- Recherche de professionnels par localisation, type de soin, ou disponibilité
- Consultation des profils de professionnels avec photos, avis, et disponibilités
- Prise de rendez-vous en ligne

#### Exploration des tendances
- Accès à des contenus sur les tendances beauté
- Consultation des avant/après des utilisateurs

#### Recommandations et monétisation
- Partage d'expériences personnelles
- Suivi des gains générés par les recommandations
- Portefeuille virtuel pour le suivi des gains et le retrait

#### Notifications
- Rappel des rendez-vous
- Alertes sur les tendances et promotions

## 4. Spécifications techniques

### 4.1. Plateformes cibles
- Mobile : iOS (Apple Store) et Android (Google Play)
- Web : Accessible via navigateurs modernes

### 4.2. Architecture
- Backend : API RESTful, Node.js ou Python (Django/Flask)
- Base de données : MySQL ou PostgreSQL pour les données relationnelles
- Frontend : Flutter pour le mobile, React.js pour le web
- Infrastructure : Serveurs cloud (AWS, Azure, ou Google Cloud)

### 4.3. Intégrations tierces
- Paiements : Stripe, PayPal
- Notifications : Firebase Cloud Messaging
- Cartographie : API Google Maps
- Authentification : Firebase Auth ou OAuth 2.0

## 5. UX/UI Design

### 5.1. Principes directeurs
- Interface intuitive et minimaliste
- Design adapté aux mobiles et au web (responsive)
- Couleurs et typographie évocatrices de la beauté et du bien-être

### 5.2. Wireframes
- Écrans Phase 1 (Professionnels) : Tableau de bord, gestion des services, calendrier
- Écrans Phase 2 (Clients) : Accueil, recherche, réservation, historique
- Écrans admin : Gestion des utilisateurs, modération

## 6. Historique des modifications
- Version 2.0 : 31/12/2023 - Refonte complète du cahier des charges avec focus sur approche en deux phases
- Version 1.0 : 31/12/2023 - Version initiale
