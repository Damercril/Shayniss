import 'package:flutter/material.dart';

class ServicePromotion {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> serviceIds;
  final bool isActive;

  ServicePromotion({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.serviceIds,
    this.isActive = true,
  });

  bool get isValid => DateTime.now().isBefore(endDate) && DateTime.now().isAfter(startDate);

  factory ServicePromotion.fromJson(Map<String, dynamic> json) {
    return ServicePromotion(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      serviceIds: List<String>.from(json['serviceIds'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'serviceIds': serviceIds,
      'isActive': isActive,
    };
  }
}
