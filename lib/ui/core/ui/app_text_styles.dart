import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: Colors.white,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.coolGray),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
