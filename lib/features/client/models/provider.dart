class ServiceProvider {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String location;
  final List<String> categories;
  final List<String> photoUrls;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.categories,
    required this.photoUrls,
  });
}

// Données de test
final List<ServiceProvider> demoProviders = [
  // Coiffure
  ServiceProvider(
    id: '1',
    name: 'Studio Beauté Paris',
    imageUrl: 'https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?ixlib=rb-4.0.3',
    rating: 4.8,
    reviewCount: 128,
    location: 'Paris 8ème',
    categories: ['Coiffure', 'Maquillage'],
    photoUrls: [
      'https://images.unsplash.com/photo-1562322140-8baeececf3df?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1487412912498-0447578fcca8?ixlib=rb-4.0.3',
    ],
  ),
  ServiceProvider(
    id: '2',
    name: 'Hair & Style',
    imageUrl: 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?ixlib=rb-4.0.3',
    rating: 4.6,
    reviewCount: 95,
    location: 'Paris 4ème',
    categories: ['Coiffure'],
    photoUrls: [
      'https://images.unsplash.com/photo-1605497788044-5a32c7078486?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1634449571010-02389ed0f9b0?ixlib=rb-4.0.3',
    ],
  ),

  // Massage
  ServiceProvider(
    id: '3',
    name: 'Zen & Beauty',
    imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?ixlib=rb-4.0.3',
    rating: 4.9,
    reviewCount: 256,
    location: 'Paris 16ème',
    categories: ['Massage', 'Soins'],
    photoUrls: [
      'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?ixlib=rb-4.0.3',
    ],
  ),
  ServiceProvider(
    id: '4',
    name: 'Massage Bien-Être',
    imageUrl: 'https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?ixlib=rb-4.0.3',
    rating: 4.7,
    reviewCount: 183,
    location: 'Paris 15ème',
    categories: ['Massage'],
    photoUrls: [
      'https://images.unsplash.com/photo-1519824145371-296894a0daa9?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-4.0.3',
    ],
  ),

  // Manucure
  ServiceProvider(
    id: '5',
    name: 'Nails & Co',
    imageUrl: 'https://images.unsplash.com/photo-1610992015732-2449b0dd2e3f?ixlib=rb-4.0.3',
    rating: 4.7,
    reviewCount: 184,
    location: 'Paris 4ème',
    categories: ['Manucure', 'Pédicure'],
    photoUrls: [
      'https://images.unsplash.com/photo-1604654894610-df63bc536371?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1631729371254-42c2892f0e6e?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?ixlib=rb-4.0.3',
    ],
  ),
  ServiceProvider(
    id: '6',
    name: 'Beauty Nails Paris',
    imageUrl: 'https://images.unsplash.com/photo-1607779097040-26e80aa4917b?ixlib=rb-4.0.3',
    rating: 4.5,
    reviewCount: 142,
    location: 'Paris 11ème',
    categories: ['Manucure'],
    photoUrls: [
      'https://images.unsplash.com/photo-1632345031435-8727f6897d53?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1604656314066-8ed23c023c2f?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1610992015732-2449b0dd2e3f?ixlib=rb-4.0.3',
    ],
  ),

  // Maquillage
  ServiceProvider(
    id: '7',
    name: 'Make-Up Studio',
    imageUrl: 'https://images.unsplash.com/photo-1487412912498-0447578fcca8?ixlib=rb-4.0.3',
    rating: 4.9,
    reviewCount: 217,
    location: 'Paris 1er',
    categories: ['Maquillage'],
    photoUrls: [
      'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1522337660859-02fbefca4702?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1503236823255-94609f598e71?ixlib=rb-4.0.3',
    ],
  ),
  ServiceProvider(
    id: '8',
    name: 'Beauty Art',
    imageUrl: 'https://images.unsplash.com/photo-1522337094846-8a818d7aad23?ixlib=rb-4.0.3',
    rating: 4.6,
    reviewCount: 156,
    location: 'Paris 9ème',
    categories: ['Maquillage', 'Soins'],
    photoUrls: [
      'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1522336284037-91f7da073525?ixlib=rb-4.0.3',
    ],
  ),

  // Soins
  ServiceProvider(
    id: '9',
    name: 'Spa Luxe',
    imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?ixlib=rb-4.0.3',
    rating: 5.0,
    reviewCount: 324,
    location: 'Paris 8ème',
    categories: ['Soins', 'Massage'],
    photoUrls: [
      'https://images.unsplash.com/photo-1515377905703-c4788e51af15?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1552693673-1bf958298935?ixlib=rb-4.0.3',
    ],
  ),
  ServiceProvider(
    id: '10',
    name: 'Institut Belle Peau',
    imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?ixlib=rb-4.0.3',
    rating: 4.8,
    reviewCount: 198,
    location: 'Paris 6ème',
    categories: ['Soins'],
    photoUrls: [
      'https://images.unsplash.com/photo-1616394584738-fc6e612e71b9?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1570174006382-148305f67837?ixlib=rb-4.0.3',
      'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?ixlib=rb-4.0.3',
    ],
  ),
];
