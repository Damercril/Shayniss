# Arborescence du projet

```
/ (racine du projet)
├── android/                  # Projet Android natif
├── assets/                   # Images, icônes, polices, etc.
├── build/                    # Fichiers générés (à ignorer)
├── docs/                     # Documentation technique
├── documentation/            # Documents additionnels
├── lib/                      # Code source principal Flutter/Dart
│   ├── core/                 # Cœur de l'application (services, modèles, utilitaires...)
│   │   ├── auth/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── database/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── services/         # Services génériques (BaseDatabaseService, SupabaseService...)
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/             # Fonctionnalités métier (découpées par domaine)
│   │   ├── affiliation/
│   │   ├── appointments/
│   │   ├── auth/
│   │   ├── calendar/
│   │   ├── client/
│   │   ├── clients/
│   │   ├── dashboard/
│   │   ├── home/
│   │   ├── loyalty/
│   │   ├── messages/
│   │   │   ├── models/
│   │   │   │   ├── notification.ts
│   │   │   │   ├── refund.ts
│   │   │   │   ├── conversation.ts
│   │   │   │   ├── message.ts
│   │   │   ├── services/
│   │   │   │   ├── notification_service.ts
│   │   │   │   ├── refund_service.ts
│   │   │   │   ├── conversation_service.ts
│   │   │   │   ├── message_service.ts
│   │   │   ├── routes/
│   │   │   │   ├── notifications.ts
│   │   │   │   ├── refunds.ts
│   │   │   │   ├── conversations.ts
│   │   │   │   ├── messages.ts
│   │   │   └── tests/
│   │   │       ├── notification_test.ts
│   │   │       ├── refund_test.ts
│   │   │       ├── messaging_test.ts
│   │   ├── navigation/
│   │   ├── notifications/
│   │   ├── payments/
│   │   ├── professional/
│   │   ├── profile/
│   │   ├── services/         # Gestion des services (modèles, écrans, widgets...)
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   ├── settings/
│   │   ├── shared/
│   │   └── stories/          # Système de stories (modèles, services, widgets)
│   │       ├── models/
│   │       ├── services/
│   │       └── widgets/
│   ├── firebase_options.dart # Config Firebase
│   └── main.dart             # Point d'entrée de l'app
├── memory/                   # Notes, contextes, schémas, instructions
│   ├── arborescence.md
│   ├── context_metier.md
│   ├── database_schema.md
│   ├── instructions.md
│   └── tech_context.md
├── pubspec.yaml              # Dépendances du projet
├── pubspec.lock
├── README.md
├── scripts/                  # Scripts utilitaires
├── supabase/                 # Config et migrations Supabase
├── test/                     # Tests unitaires et widget
├── web/                      # Support web Flutter
├── web-booking/              # Module web de réservation
└── windows/                  # Projet Windows natif

**Remarques :**
- Les dossiers `features/services` et `features/stories` contiennent toute la logique métier liée aux services et aux stories.
- Le dossier `core/services` regroupe les services techniques réutilisables (base, supabase, etc).
- Le dossier `memory/` sert à structurer la documentation et le contexte métier/technique du projet.
- Les dossiers `android/`, `windows/`, `web/` assurent la compatibilité multiplateforme.

Cette arborescence reflète la structure modulaire et scalable du projet.