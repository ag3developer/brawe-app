import 'package:flutter/material.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/currency_formatter.dart';

/// Badge component to display shipping and discount promotions
/// Shows: "🚚 FREE SHIPPING" or "💰 X% OFF" etc.
class ShopPromotionBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsets padding;

  const ShopPromotionBadge({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  factory ShopPromotionBadge.freeShipping({
    String label = 'FRETE GRÁTIS',
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) => ShopPromotionBadge(
    label: label,
    icon: Icons.local_shipping_outlined,
    backgroundColor: const Color(0xFF10B981), // Green
    textColor: Colors.white,
    padding: padding,
  );

  factory ShopPromotionBadge.discount(
    double percentOff, {
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) => ShopPromotionBadge(
    label: '${percentOff.toStringAsFixed(0)}% OFF',
    icon: Icons.local_offer_outlined,
    backgroundColor: const Color(0xFFEF4444), // Red
    textColor: Colors.white,
    padding: padding,
  );

  factory ShopPromotionBadge.freeShippingThreshold(
    double threshold, {
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) => ShopPromotionBadge(
    label: 'Frete grátis a partir de ${formatBRL(threshold)}',
    icon: Icons.local_shipping_outlined,
    backgroundColor: const Color(0xFF3B82F6), // Blue
    textColor: Colors.white,
    padding: padding,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: textColor ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper text to show free shipping threshold message
class FreeShippingMessage extends StatelessWidget {
  final double currentSubtotal;
  final double freeShippingThreshold;

  const FreeShippingMessage({
    super.key,
    required this.currentSubtotal,
    required this.freeShippingThreshold,
  });

  @override
  Widget build(BuildContext context) {
    if (currentSubtotal >= freeShippingThreshold) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: context.colors.success,
            ),
            const SizedBox(width: 8),
            Text(
              '✅ Você ganhou FRETE GRÁTIS!',
              style: TextStyle(
                color: context.colors.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final remaining = freeShippingThreshold - currentSubtotal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 16,
            color: context.colors.accentPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Adicione ${formatBRL(remaining)} para FRETE GRÁTIS',
              style: TextStyle(
                color: context.colors.accentPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
