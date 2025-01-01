class LoyaltyLevel {
  final String name;
  final int requiredPoints;
  final double discount;
  final String? icon;
  final List<String> benefits;

  const LoyaltyLevel({
    required this.name,
    required this.requiredPoints,
    required this.discount,
    this.icon,
    required this.benefits,
  });
}

class LoyaltyPoints {
  final String clientId;
  final int points;
  final LoyaltyLevel currentLevel;
  final int pointsToNextLevel;
  final DateTime lastUpdated;

  const LoyaltyPoints({
    required this.clientId,
    required this.points,
    required this.currentLevel,
    required this.pointsToNextLevel,
    required this.lastUpdated,
  });

  factory LoyaltyPoints.initial(String clientId) {
    return LoyaltyPoints(
      clientId: clientId,
      points: 0,
      currentLevel: bronzeLevel,
      pointsToNextLevel: silverLevel.requiredPoints,
      lastUpdated: DateTime.now(),
    );
  }
}

// Niveaux de fidélité prédéfinis
const bronzeLevel = LoyaltyLevel(
  name: 'Bronze',
  requiredPoints: 0,
  discount: 0,
  icon: '🥉',
  benefits: [
    'Cumul de points',
    'Offre anniversaire',
  ],
);

const silverLevel = LoyaltyLevel(
  name: 'Argent',
  requiredPoints: 100,
  discount: 5,
  icon: '🥈',
  benefits: [
    'Cumul de points',
    'Offre anniversaire',
    '5% de réduction',
    'Accès prioritaire aux promotions',
  ],
);

const goldLevel = LoyaltyLevel(
  name: 'Or',
  requiredPoints: 300,
  discount: 10,
  icon: '🥇',
  benefits: [
    'Cumul de points',
    'Offre anniversaire',
    '10% de réduction',
    'Accès prioritaire aux promotions',
    'Rendez-vous prioritaires',
    'Cadeaux exclusifs',
  ],
);

const platinumLevel = LoyaltyLevel(
  name: 'Platine',
  requiredPoints: 1000,
  discount: 15,
  icon: '💎',
  benefits: [
    'Cumul de points',
    'Offre anniversaire',
    '15% de réduction',
    'Accès prioritaire aux promotions',
    'Rendez-vous prioritaires',
    'Cadeaux exclusifs',
    'Service VIP personnalisé',
    'Invitations événements privés',
  ],
);

// Liste de tous les niveaux dans l'ordre
const allLevels = [
  bronzeLevel,
  silverLevel,
  goldLevel,
  platinumLevel,
];
