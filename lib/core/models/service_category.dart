class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
