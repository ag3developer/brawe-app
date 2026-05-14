import 'package:flutter/material.dart';

import '../ui/app_radius.dart';
import '../ui/app_text_styles.dart';
import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.electricPurple,
      secondary: AppColors.coolCyan,
      surface: AppColors.slate,
      error: AppColors.mutedRed,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.nearBlack,
      textTheme: AppTextStyles.textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerColor: Colors.white12,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate.withValues(alpha: 0.9),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        elevation: 8,
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = const ColorScheme.light(
      primary: AppColors.electricPurple,
      secondary: AppColors.coolCyan,
      surface: Colors.white,
      error: AppColors.mutedRed,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      textTheme: AppTextStyles.textTheme(base.textTheme).apply(
        bodyColor: const Color(0xFF111827),
        displayColor: const Color(0xFF111827),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        centerTitle: false,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF111827)),
      dividerColor: const Color(0xFFE5E7EB),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        contentTextStyle: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        elevation: 4,
      ),
    );
  }
}
