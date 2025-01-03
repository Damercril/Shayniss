class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String icon;
  final int serviceCount;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.icon,
    required this.serviceCount,
  });
}

// Données de test
final List<Category> demoCategories = [
  Category(
    id: '1',
    name: 'Coiffure',
    imageUrl: 'https://images.unsplash.com/photo-1560869713-da86a9ec94f6?ixlib=rb-4.0.3',
    icon: '💇‍♀️',
    serviceCount: 150,
  ),
  Category(
    id: '2',
    name: 'Massage',
    imageUrl: 'https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?ixlib=rb-4.0.3',
    icon: '💆‍♀️',
    serviceCount: 85,
  ),
  Category(
    id: '3',
    name: 'Manucure',
    imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?ixlib=rb-4.0.3',
    icon: '💅',
    serviceCount: 120,
  ),
  Category(
    id: '4',
    name: 'Maquillage',
    imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?ixlib=rb-4.0.3',
    icon: '💄',
    serviceCount: 95,
  ),
  Category(
    id: '5',
    name: 'Soins',
    imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?ixlib=rb-4.0.3',
    icon: '✨',
    serviceCount: 110,
  ),
];
