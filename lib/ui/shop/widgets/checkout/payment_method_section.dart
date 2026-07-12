import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';

/// The 3 payment methods actually wired up in the app today (see
/// `ShopPaymentPage` / `CheckoutRequest.paymentMethod`). Kept identical to
/// the pre-existing options — this redesign only changes the presentation
/// (compact selectable cards instead of `RadioListTile`), not the set of
/// available methods.
enum CheckoutPaymentMethod { pix, card, crypto }

/// Compact, premium payment method picker — a row of selectable cards
/// instead of a tall `RadioListTile` list.
class PaymentMethodSection extends StatelessWidget {
  final CheckoutPaymentMethod selected;
  final ValueChanged<CheckoutPaymentMethod> onChanged;

  const PaymentMethodSection({
    super.key,
    required this.selected,
    required this.onChanged,
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
            s.shopCheckoutPaymentSection,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            icon: LucideIcons.qrCode,
            label: s.shopCheckoutPaymentPix,
            selected: selected == CheckoutPaymentMethod.pix,
            onTap: () => onChanged(CheckoutPaymentMethod.pix),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            icon: LucideIcons.creditCard,
            label: s.shopCheckoutPaymentCard,
            selected: selected == CheckoutPaymentMethod.card,
            onTap: () => onChanged(CheckoutPaymentMethod.card),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            icon: LucideIcons.bitcoin,
            label: s.shopCheckoutPaymentCrypto,
            selected: selected == CheckoutPaymentMethod.crypto,
            onTap: () => onChanged(CheckoutPaymentMethod.crypto),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.colors.accentPrimary.withValues(alpha: 0.08)
          : context.colors.surfaceHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? context.colors.accentPrimary
                  : Colors.transparent,
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? context.colors.accentPrimary
                    : context.colors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: selected
                    ? context.colors.accentPrimary
                    : context.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
