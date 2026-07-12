import 'package:flutter/material.dart';

import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../utils/currency_formatter.dart';

/// Compact order price breakdown: subtotal, shipping, discount, total.
/// All values come from real `CartState` fields (subtotal/shipping/
/// discount/total) — no mocked cashback/tax rows are rendered.
class OrderPriceSummary extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double discount;
  final double total;

  const OrderPriceSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
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
          Text(
            s.shopCheckoutSummarySection,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _row(context, s.shopCheckoutSubtotal, formatBRL(subtotal)),
          if (shipping > 0)
            _row(context, s.shopCheckoutShippingSection, formatBRL(shipping)),
          if (discount > 0)
            _row(
              context,
              s.shopCheckoutDiscount,
              '-${formatBRL(discount)}',
              valueColor: context.colors.success,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: context.colors.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.shopCheckoutTotal,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                formatBRL(total),
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? context.colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
