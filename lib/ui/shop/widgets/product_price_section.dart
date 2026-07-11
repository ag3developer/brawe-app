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
        // Main price + discount badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Text(
              '$currencyPrefix ${price.toStringAsFixed(decimalPlaces)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),

            // Discount badge (if applicable)
            if (hasDiscount && discountPercentage != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4444), // Red badge
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$discountPercentage% OFF',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Original price (if has discount)
        if (hasDiscount && compareAtPrice != null)
          Text(
            '$currencyPrefix ${compareAtPrice!.toStringAsFixed(decimalPlaces)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}
