import 'package:flutter/material.dart';

import '../../core/themes/brawe_colors.dart';

/// Widget that displays product pricing information.
///
/// Shows:
/// - Main price (required)
/// - Original/compare price (if provided and > main price)
/// - Discount badge (calculated percentage if compare price exists)
class ProductPriceSection extends StatelessWidget {
  /// Main selling price
  final double price;

  /// Original/compare price (if null, no discount shown)
  final double? compareAtPrice;

  /// Currency symbol/prefix (default: R$)
  final String currencyPrefix;

  /// Decimal places for formatting (default: 2)
  final int decimalPlaces;

  const ProductPriceSection({
    super.key,
    required this.price,
    this.compareAtPrice,
    this.currencyPrefix = 'R\$',
    this.decimalPlaces = 2,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = compareAtPrice != null && compareAtPrice! > price;
    final discountPercentage = hasDiscount
        ? ((compareAtPrice! - price) / compareAtPrice! * 100).toStringAsFixed(0)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main price + discount badge — tamanhos compactos (premium
        // marketplaces não usam display-size para preço de item).
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$currencyPrefix ${price.toStringAsFixed(decimalPlaces)}',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            if (hasDiscount && compareAtPrice != null) ...[
              const SizedBox(width: 8),
              Text(
                '$currencyPrefix ${compareAtPrice!.toStringAsFixed(decimalPlaces)}',
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            if (hasDiscount && discountPercentage != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-$discountPercentage%',
                  style: TextStyle(
                    color: context.colors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
