import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/marketplace_models.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';

/// Compact, single-line delivery address block shown at the top of
/// checkout. Shows ONLY the currently selected/default address — never a
/// list. Tapping the whole block opens address selection (handled by the
/// caller via [onTap]).
///
/// Layout: [pin icon] Recipient name, masked phone
///                     Full address
///                                                    [chevron >]
class DeliveryAddressSection extends StatelessWidget {
  final ShippingAddress address;
  final String? customerPhone;
  final VoidCallback onTap;

  const DeliveryAddressSection({
    super.key,
    required this.address,
    required this.onTap,
    this.customerPhone,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final maskedPhone = _maskPhone(customerPhone);

    return Material(
      color: context.colors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 18,
                color: context.colors.accentPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                address.recipientName ??
                                s.shopCheckoutRecipientName,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (maskedPhone != null)
                            TextSpan(
                              text: ', $maskedPhone',
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fullAddressLine(address),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fullAddressLine(ShippingAddress a) {
    final parts = <String>[
      '${a.street}, ${a.number}',
      if ((a.complement ?? '').isNotEmpty) a.complement!,
      a.neighborhood,
      '${a.city} - ${a.state}',
      a.postalCode,
    ];
    return parts.where((p) => p.trim().isNotEmpty).join(', ');
  }

  /// Masks a phone number keeping country/area code and last 2 digits
  /// visible, e.g. `(+55)47*******29` — matches the reference pattern
  /// without exposing the full number on a checkout summary screen.
  static String? _maskPhone(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return raw.isEmpty ? null : raw;
    final visibleStart = digits.substring(0, digits.length - 2).length >= 4
        ? digits.substring(0, 4)
        : digits.substring(0, digits.length - 2);
    final visibleEnd = digits.substring(digits.length - 2);
    final maskedLength =
        digits.length - visibleStart.length - visibleEnd.length;
    return '(+55)$visibleStart${'*' * (maskedLength < 0 ? 0 : maskedLength)}$visibleEnd';
  }
}
