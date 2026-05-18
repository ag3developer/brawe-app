import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/app_radius.dart';
import '../ui/app_text_styles.dart';
import 'brawe_colors.dart';

/// Centralised Material 3 themes for Brawe.
///
/// All colors that change between light/dark mode are exposed via
/// [BraweColors] (use `context.colors.*` in widgets). Brand accents and
/// fixed palette values live in `AppColors`.
class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    const tokens = BraweColors.dark;
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.dark(
      primary: tokens.accentPrimary,
      onPrimary: tokens.textOnAccent,
      secondary: tokens.accentSecondary,
      onSecondary: tokens.textOnAccent,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.surfaceHighest,
      error: tokens.danger,
      onError: Colors.white,
      outline: tokens.border,
    );
    return _build(
      base: base,
      tokens: tokens,
      colorScheme: colorScheme,
      systemOverlay: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: tokens.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  static ThemeData light() {
    const tokens = BraweColors.light;
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.light(
      primary: tokens.accentPrimary,
      onPrimary: tokens.textOnAccent,
      secondary: tokens.accentSecondary,
      onSecondary: tokens.textOnAccent,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.surfaceHighest,
      error: tokens.danger,
      onError: Colors.white,
      outline: tokens.border,
    );
    return _build(
      base: base,
      tokens: tokens,
      colorScheme: colorScheme,
      systemOverlay: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: tokens.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static ThemeData _build({
    required ThemeData base,
    required BraweColors tokens,
    required ColorScheme colorScheme,
    required SystemUiOverlayStyle systemOverlay,
  }) {
    final textTheme = AppTextStyles.textTheme(base.textTheme).apply(
      bodyColor: tokens.textPrimary,
      displayColor: tokens.textPrimary,
    );
    return base.copyWith(
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      canvasColor: tokens.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlay,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: tokens.textPrimary),
      ),
      iconTheme: IconThemeData(color: tokens.textPrimary),
      dividerColor: tokens.divider,
      dividerTheme: DividerThemeData(
        color: tokens.divider,
        thickness: 0.5,
        space: 0.5,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceHighest,
        hintStyle: TextStyle(color: tokens.textTertiary),
        labelStyle: TextStyle(color: tokens.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tokens.accentPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tokens.danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.accentPrimary,
          foregroundColor: tokens.textOnAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: tokens.accentPrimary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.textPrimary,
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surfaceElevated,
        modalBackgroundColor: tokens.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.surfaceElevated,
        contentTextStyle: TextStyle(
          color: tokens.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: tokens.border),
        ),
        elevation: 8,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: tokens.accentPrimary,
        selectionColor: tokens.accentPrimary.withValues(alpha: 0.3),
        selectionHandleColor: tokens.accentPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tokens.textOnAccent;
          return tokens.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.accentPrimary;
          }
          return tokens.surfaceHighest;
        }),
      ),
    );
  }
}
