import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/marketplace_models.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';
import 'checkout_product_item.dart';

/// Compact per-store section in the checkout: store name header + each
/// product item belonging to that store. When the cart has items from
/// multiple stores, one [StoreSection] is rendered per store (real
/// grouping via `CartItem.storeId`/`storeName`, not mocked).
class StoreSection extends StatelessWidget {
  final String? storeName;
  final List<CartItem> items;
  final double shippingCost;
  final bool isFreeShipping;
  final bool Function(CartItem) isUpdating;
  final void Function(CartItem, int) onQuantityChanged;
  final VoidCallback? onAddNote;

  const StoreSection({
    super.key,
    required this.storeName,
    required this.items,
    required this.shippingCost,
    required this.isFreeShipping,
    required this.isUpdating,
    required this.onQuantityChanged,
    this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.store,
                size: 15,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  storeName ?? s.shopCheckoutSummarySection,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onAddNote != null)
                GestureDetector(
                  onTap: onAddNote,
                  child: Row(
                    children: [
                      Text(
                        s.shopCheckoutAddNote,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 14,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Divider(color: context.colors.divider, height: 16),
          for (final item in items)
            CheckoutProductItem(
              item: item,
              isUpdating: isUpdating(item),
              onQuantityChanged: (q) => onQuantityChanged(item, q),
            ),
          CheckoutShippingRow(
            shippingCost: shippingCost,
            isFree: isFreeShipping,
          ),
        ],
      ),
    );
  }
}
