import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class EdenTheme {
  // Radius
  static final double radiusLg = 24.r;
  static final double radiusMd = 20.r;
  static final double radiusSm = 16.r;

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.primary.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get secondaryGradient => LinearGradient(
        colors: [
          AppColors.secondary,
          AppColors.secondary.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: softShadow,
      );

  static BoxDecoration get primaryCardDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: softShadow,
      );

  static BoxDecoration get secondaryCardDecoration => BoxDecoration(
        gradient: secondaryGradient,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: softShadow,
      );

  // Input Decorations
  static InputDecoration inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16.sp,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.secondary,
        size: 20.w,
      ),
      suffixIcon: suffixIcon != null
          ? Icon(
              suffixIcon,
              color: AppColors.secondary,
              size: 20.w,
            )
          : null,
      filled: true,
      fillColor: AppColors.primary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: AppColors.secondary,
          width: 1,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ),
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 16.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      );

  // Text Styles
  static TextStyle get headingLarge => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      );

  static TextStyle get headingMedium => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      );

  static TextStyle get headingSmall => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        color: AppColors.text,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        color: AppColors.text,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        color: AppColors.textSecondary,
      );
}
