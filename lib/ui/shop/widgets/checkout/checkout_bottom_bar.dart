import 'package:flutter/material.dart';

import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../utils/currency_formatter.dart';
import '../shop_pill_button.dart';

/// Fixed bottom bar: "Total (N items)  R$ X" + full-width CTA button.
/// Height target ~52-58px for the button itself, respects bottom
/// SafeArea, shows a loading spinner while submitting and disables the
/// button to prevent double-submit.
class CheckoutBottomBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final bool isSubmitting;
  final bool enabled;
  final VoidCallback? onConfirm;

  const CheckoutBottomBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.isSubmitting,
    required this.enabled,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.shopCheckoutTotalItems(itemCount),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    formatBRL(total),
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 52,
              child: ShopPillButton(
                label: s.shopCheckoutConfirmOrder,
                loading: isSubmitting,
                onPressed: enabled && !isSubmitting ? onConfirm : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
