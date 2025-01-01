import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF9747FF);
  static const Color secondary = Color(0xFF7B61FF);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F8FA);

  // Text Colors
  static const Color text = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF657786);
  static const Color textLight = Color(0xFF6C757D);

  // Action Colors
  static const Color like = Color(0xFFE0245E);
  static const Color repost = Color(0xFF17BF63);
  static const Color link = Color(0xFF1DA1F2);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // Gradient Colors
  static List<Color> primaryGradient = [
    primary,
    primary.withOpacity(0.8),
  ];
}
