import 'package:flutter/material.dart';

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
    );
  }
}
