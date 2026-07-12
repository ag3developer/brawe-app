import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/marketplace_models.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../utils/currency_formatter.dart';
import 'quantity_selector.dart';

/// Compact product row for the checkout screen: 72–88px image, name
/// (max 2 lines), variant, price and a compact quantity stepper.
///
/// Quantity changes are debounced by the caller (see
/// [_ShopCheckoutPageState._onQuantityChanged]) to avoid firing a request
/// per keystroke-like taps.
class CheckoutProductItem extends StatelessWidget {
  final CartItem item;
  final bool isUpdating;
  final ValueChanged<int> onQuantityChanged;

  const CheckoutProductItem({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.productImage != null
                ? CachedNetworkImage(
                    imageUrl: item.productImage!,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _imageFallback(context),
                  )
                : _imageFallback(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantName != null &&
                    item.variantName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variantName!,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formatBRL(item.unitPrice),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (isUpdating)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            context.colors.accentPrimary,
                          ),
                        ),
                      )
                    else
                      QuantitySelector(
                        quantity: item.quantity,
                        onChanged: onQuantityChanged,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      color: context.colors.surfaceHighest,
      child: Icon(
        Icons.image_outlined,
        color: context.colors.textSecondary,
        size: 24,
      ),
    );
  }
}

/// Delivery estimate + shipping fee row shown under a store's product list.
/// Shows the ORIGINAL shipping cost struck through when free shipping
/// applies, matching real cart data (`CartState.shipping`/`discount`) — no
/// mocked "estimated delivery" date since the backend doesn't provide one
/// per store yet.
class CheckoutShippingRow extends StatelessWidget {
  final double shippingCost;
  final bool isFree;

  const CheckoutShippingRow({
    super.key,
    required this.shippingCost,
    required this.isFree,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              s.shopCheckoutShippingSection,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          if (isFree && shippingCost > 0) ...[
            Text(
              formatBRL(shippingCost),
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 12,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            isFree ? s.shopCheckoutFreeShipping : formatBRL(shippingCost),
            style: TextStyle(
              color: isFree
                  ? context.colors.success
                  : context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
