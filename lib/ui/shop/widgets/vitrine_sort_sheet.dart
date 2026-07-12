import 'package:flutter/material.dart';

import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Sort options for the vitrine's product list — mirrors the field names
/// already supported by the backend (`sort_by`: created_at/price/
/// total_sold — see `product_service.py::list_public_products`). No
/// invented options: "creator's choice" maps to the default ordering
/// already used (`totalSold` desc, see `_ProductsSliverGrid`).
enum VitrineSortOption {
  creatorChoice,
  newest,
  priceAsc,
  priceDesc,
  bestSelling,
}

/// Minimalist bottom sheet ("Classificar por") triggered by the filter
/// icon in the vitrine's top bar — same visual pattern as
/// [AddressSelectionSheet] (drag handle, title + close, radio list).
class VitrineSortSheet extends StatelessWidget {
  final VitrineSortOption selected;

  const VitrineSortSheet({super.key, required this.selected});

  static Future<VitrineSortOption?> show(
    BuildContext context, {
    required VitrineSortOption selected,
  }) {
    return showModalBottomSheet<VitrineSortOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => VitrineSortSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final options = <(VitrineSortOption, String)>[
      (VitrineSortOption.creatorChoice, s.shopVitrineSortCreatorChoice),
      (VitrineSortOption.bestSelling, s.shopVitrineSortBestSelling),
      (VitrineSortOption.newest, s.shopVitrineSortNewest),
      (VitrineSortOption.priceAsc, s.shopVitrineSortPriceAsc),
      (VitrineSortOption.priceDesc, s.shopVitrineSortPriceDesc),
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.shopVitrineSortTitle,
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
            for (final option in options)
              _SortTile(
                label: option.$2,
                selected: selected == option.$1,
                onTap: () => Navigator.of(context).pop(option.$1),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected
                  ? context.colors.accentPrimary
                  : context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
