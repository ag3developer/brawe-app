import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Card displaying store information.
///
/// Shows:
/// - Store logo (circular avatar)
/// - Store name
/// - "View Store" button
///
/// Note: affiliate/partnership commission is NOT shown here. Commission is
/// internal information between the store owner and the partner (affiliate),
/// it must never be visible to the buyer in the storefront/checkout flow.
class ProductStoreCard extends StatelessWidget {
  /// Store ID (for navigation)
  final String? storeId;

  /// Store name/display name
  final String storeName;

  /// Store logo URL
  final String? storeLogoUrl;

  /// Store slug (for deep link to /shop/store/{slug})
  final String? storeSlug;

  const ProductStoreCard({
    super.key,
    this.storeId,
    required this.storeName,
    this.storeLogoUrl,
    this.storeSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: logo + name
            Row(
              children: [
                // Store logo
                if (storeLogoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: storeLogoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          _buildLogoPlaceholder(),
                    ),
                  )
                else
                  _buildLogoPlaceholder(),

                const SizedBox(width: 12),

                // Store name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).shopProductStore,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        storeName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // View Store button
            if (storeSlug != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/shop/store/$storeSlug'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(S.of(context).shopProductViewStore),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(LucideIcons.store, size: 24, color: Colors.grey),
    );
  }
}
