import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic color tokens for Brawe.
///
/// Use these via `context.colors` instead of raw hex/`AppColors`/`Colors.white`
/// so the UI follows light/dark mode correctly.
///
/// ```dart
/// Container(
///   color: context.colors.surface,
///   child: Text('Hi', style: TextStyle(color: context.colors.textPrimary)),
/// )
/// ```
@immutable
class BraweColors extends ThemeExtension<BraweColors> {
  const BraweColors({
    // Surfaces
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHighest,
    // Text
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnAccent,
    // Lines
    required this.border,
    required this.divider,
    // Brand accents (passthrough — same across modes, exposed here for ergonomics)
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentPink,
    required this.accentGold,
    // Status
    required this.success,
    required this.warning,
    required this.danger,
    // Special
    required this.overlay,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  // Surfaces
  final Color background; // App scaffold bg
  final Color surface; // Cards / lists default
  final Color surfaceElevated; // Modals / sheets / floating
  final Color surfaceHighest; // Inputs / chips / pressed states

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnAccent; // Text drawn on top of accentPrimary buttons

  // Lines
  final Color border;
  final Color divider;

  // Brand accents (fixed)
  final Color accentPrimary;
  final Color accentSecondary;
  final Color accentPink;
  final Color accentGold;

  // Status
  final Color success;
  final Color warning;
  final Color danger;

  // Special
  final Color overlay; // backdrop dimmer for sheets/dialogs
  final Color shimmerBase;
  final Color shimmerHighlight;

  // ── Presets ────────────────────────────────────────────────────────────────
  static const BraweColors dark = BraweColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceElevated: AppColors.darkSurfaceElevated,
    surfaceHighest: AppColors.darkSurfaceHighest,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    textOnAccent: Colors.white,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    accentPrimary: AppColors.braweBlueBright,
    accentSecondary: AppColors.braweSky,
    accentPink: AppColors.brandPink,
    accentGold: AppColors.gold,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.mutedRed,
    overlay: Color(0xCC000000),
    shimmerBase: Color(0xFF1A1F2E),
    shimmerHighlight: Color(0xFF252A3A),
  );

  static const BraweColors light = BraweColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceElevated: AppColors.lightSurfaceElevated,
    surfaceHighest: AppColors.lightSurfaceHighest,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    textOnAccent: Colors.white,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    accentPrimary: AppColors.braweBlue,
    accentSecondary: AppColors.braweSky,
    accentPink: AppColors.brandPink,
    accentGold: AppColors.gold,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.mutedRed,
    overlay: Color(0x80000000),
    shimmerBase: Color(0xFFE8EAF0),
    shimmerHighlight: Color(0xFFF4F5F9),
  );

  @override
  BraweColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceHighest,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnAccent,
    Color? border,
    Color? divider,
    Color? accentPrimary,
    Color? accentSecondary,
    Color? accentPink,
    Color? accentGold,
    Color? success,
    Color? warning,
    Color? danger,
    Color? overlay,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return BraweColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceHighest: surfaceHighest ?? this.surfaceHighest,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      accentPink: accentPink ?? this.accentPink,
      accentGold: accentGold ?? this.accentGold,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      overlay: overlay ?? this.overlay,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  BraweColors lerp(ThemeExtension<BraweColors>? other, double t) {
    if (other is! BraweColors) return this;
    return BraweColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentPink: Color.lerp(accentPink, other.accentPink, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

/// Ergonomic access to [BraweColors] from a [BuildContext].
///
/// Falls back to the dark preset if the extension isn't installed yet (useful
/// during the in-flight migration so widgets never crash).
extension BraweColorsContext on BuildContext {
  BraweColors get colors =>
      Theme.of(this).extension<BraweColors>() ?? BraweColors.dark;

  /// Quick check for callers that want to branch on brightness.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
