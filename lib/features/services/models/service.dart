import 'package:uuid/uuid.dart';

class Service {
  final String id;
  final String name;
  final String category;
  final double price;
  final int duration; // in minutes
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    String? id,
    required this.name,
    required this.category,
    required this.price,
    required this.duration,
    this.description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        isActive = isActive ?? true,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'duration': duration,
      'description': description,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      duration: map['duration'],
      description: map['description'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Service copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? duration,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
