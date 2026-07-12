import 'package:flutter/material.dart';

import '../../core/themes/brawe_colors.dart';

/// Premium, full-height pill-shaped CTA button shared across the shop
/// module (cart, checkout, payment, vitrine, store) for a consistent
/// look & feel. Supports both filled (primary) and outlined variants.
class ShopPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool outlined;
  final Widget? icon;
  final bool loading;

  const ShopPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.outlined = false,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                outlined
                    ? context.colors.accentPrimary
                    : context.colors.textOnAccent,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          );

    final button = outlined
        ? OutlinedButton(
            onPressed: (loading || onPressed == null) ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.textPrimary,
              side: BorderSide(color: context.colors.border),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: child,
          )
        : FilledButton(
            onPressed: (loading || onPressed == null) ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.accentPrimary,
              foregroundColor: context.colors.textOnAccent,
              disabledBackgroundColor: context.colors.accentPrimary.withValues(
                alpha: 0.4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: child,
          );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
