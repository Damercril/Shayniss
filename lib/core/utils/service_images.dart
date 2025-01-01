class ServiceImages {
  // Images de démonstration pour les services (utilisant Picsum pour des images stables)
  static const List<String> demoServiceImages = [
    // Coiffure
    'https://picsum.photos/id/64/800/600',  // Salon
    'https://picsum.photos/id/65/800/600',  // Style
    'https://picsum.photos/id/66/800/600',  // Modern
    'https://picsum.photos/id/67/800/600',  // Classic
    'https://picsum.photos/id/68/800/600',  // Trendy
    // Coupe
    'https://picsum.photos/id/69/800/600',  // Short
    'https://picsum.photos/id/70/800/600',  // Medium
    'https://picsum.photos/id/71/800/600',  // Long
    // Coloration
    'https://picsum.photos/id/72/800/600',  // Blonde
    'https://picsum.photos/id/73/800/600',  // Brown
    'https://picsum.photos/id/74/800/600',  // Red
    // Soin
    'https://picsum.photos/id/75/800/600',  // Treatment
    'https://picsum.photos/id/76/800/600',  // Mask
    'https://picsum.photos/id/77/800/600',  // Oil
  ];

  // Obtenir des images aléatoires pour un service
  static List<String> getRandomServiceImages({int count = 3}) {
    final List<String> shuffled = List.from(demoServiceImages)..shuffle();
    return shuffled.take(count).toList();
  }

  // Obtenir des images par catégorie (basé sur l'index pour la démo)
  static List<String> getServiceImagesByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'coiffure':
        return demoServiceImages.sublist(0, 5);
      case 'coupe':
        return demoServiceImages.sublist(5, 8);
      case 'coloration':
        return demoServiceImages.sublist(8, 11);
      case 'soin':
        return demoServiceImages.sublist(11, 14);
      default:
        return getRandomServiceImages();
    }
  }
}
