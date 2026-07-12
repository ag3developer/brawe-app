import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/marketplace_models.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';

/// Bottom sheet listing all saved addresses, letting the user pick one or
/// start the "add new address" flow. Keeps the main checkout screen
/// compact — the address list never appears inline on the page itself.
///
/// Returns:
/// - a [ShippingAddress] if the user picked one from the list;
/// - the sentinel string `'__new__'` if the user tapped "add new address";
/// - `null` if dismissed without a choice.
class AddressSelectionSheet extends StatelessWidget {
  final List<ShippingAddress> addresses;
  final ShippingAddress? selected;

  const AddressSelectionSheet({
    super.key,
    required this.addresses,
    this.selected,
  });

  static Future<Object?> show(
    BuildContext context, {
    required List<ShippingAddress> addresses,
    ShippingAddress? selected,
  }) {
    return showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) =>
          AddressSelectionSheet(addresses: addresses, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.shopCheckoutAddressSection,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: context.colors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final isSelected = address.id == selected?.id;
                    return _AddressTile(
                      address: address,
                      isSelected: isSelected,
                      onTap: () => Navigator.of(context).pop(address),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop('__new__'),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(s.shopCheckoutAddNewAddress),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.textPrimary,
                        side: BorderSide(color: context.colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddressTile extends StatelessWidget {
  final ShippingAddress address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Material(
      color: context.colors.surfaceHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? context.colors.accentPrimary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected ? LucideIcons.checkCircle2 : LucideIcons.mapPin,
                size: 18,
                color: isSelected
                    ? context.colors.accentPrimary
                    : context.colors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label?.isNotEmpty == true
                          ? '${address.label} · ${address.street}, ${address.number}'
                          : '${address.street}, ${address.number}',
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.neighborhood}, ${address.city} - ${address.state} · ${address.postalCode}',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.recipientName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${s.shopCheckoutRecipientName}: ${address.recipientName}',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
