import 'package:flutter/material.dart';

/// Raw, brand-level color palette.
///
/// These are the **unchanging** values that identify Brawe (purples, cyans,
/// pinks, gold). They do NOT change between light and dark mode.
///
/// For surface/text/divider colors that DO change between themes, use
/// [BraweColors] via `context.colors` instead.
class AppColors {
  const AppColors._();

  // ── Brand (fixed across themes) ─────────────────────────────────────────────
  static const Color electricPurple = Color(0xFF6E4DFF);
  static const Color softViolet = Color(0xFF8C6BFF);
  static const Color lightViolet = Color(0xFFB6A6FF);
  static const Color coolCyan = Color(0xFF3BB8FF);
  static const Color hotPink = Color(0xFFEC4899);
  static const Color brandPink = Color(0xFFFF4D8B);
  static const Color gold = Color(0xFFFFD166);
  static const Color amber = Color(0xFFFF9500);

  // ── Status (fixed) ──────────────────────────────────────────────────────────
  static const Color mutedRed = Color(0xFFFF5A6B);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFFC857);

  // ── Legacy / deep brand background tones ────────────────────────────────────
  // Kept for gradients and decorative backgrounds.
  static const Color midnightBlue = Color(0xFF0F1C4D);
  static const Color deepBlue = Color(0xFF1B2B6B);

  // ── Dark theme neutrals (use via BraweColors) ───────────────────────────────
  static const Color darkBackground = Color(0xFF0B0F1A);
  static const Color darkSurface = Color(0xFF141824);
  static const Color darkSurfaceElevated = Color(0xFF1F2737);
  static const Color darkSurfaceHighest = Color(0xFF2A3142);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA6B0C3);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF1E1E2E);
  static const Color darkDivider = Color(0xFF1A1A2E);

  // ── Light theme neutrals (use via BraweColors) ──────────────────────────────
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceHighest = Color(0xFFF1F2F6);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFEEF0F4);

  // ── Deprecated aliases (kept until migration completes) ─────────────────────
  @Deprecated('Use context.colors.background instead')
  static const Color nearBlack = darkBackground;
  @Deprecated('Use context.colors.surfaceElevated instead')
  static const Color slate = darkSurfaceElevated;
  @Deprecated('Use context.colors.textSecondary instead')
  static const Color coolGray = darkTextSecondary;
}
