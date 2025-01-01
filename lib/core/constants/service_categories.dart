class ServiceCategory {
  final String name;
  final String icon;
  final String description;

  const ServiceCategory({
    required this.name,
    required this.icon,
    required this.description,
  });
}

const List<ServiceCategory> serviceCategories = [
  ServiceCategory(
    name: 'Coiffure',
    icon: '💇‍♀️',
    description: 'Coupes, colorations, coiffures',
  ),
  ServiceCategory(
    name: 'Maquillage',
    icon: '💄',
    description: 'Maquillage jour et soirée',
  ),
  ServiceCategory(
    name: 'Ongles',
    icon: '💅',
    description: 'Manucure et pédicure',
  ),
  ServiceCategory(
    name: 'Soins',
    icon: '✨',
    description: 'Soins visage et corps',
  ),
  ServiceCategory(
    name: 'Massage',
    icon: '💆‍♀️',
    description: 'Massages relaxants',
  ),
  ServiceCategory(
    name: 'Épilation',
    icon: '🌸',
    description: 'Épilation visage et corps',
  ),
];
