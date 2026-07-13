import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/providers/cart_notifier_provider.dart';
import '../../../domain/models/marketplace_models.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../utils/currency_formatter.dart';
import '../widgets/shop_pill_button.dart';

/// Cart page accessed via `/shop/cart` route.
///
/// Displays the current cart contents (server-backed via
/// [cartNotifierProvider]) with quantity controls, per-item removal, a
/// "clear cart" action and a fixed footer with totals + CTA to checkout.
class ShopCartPage extends ConsumerWidget {
  const ShopCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          S.of(context).shopCartTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!cartState.isEmpty)
            IconButton(
              icon: Icon(
                LucideIcons.trash2,
                size: 20,
                color: context.colors.textSecondary,
              ),
              tooltip: S.of(context).shopCartClear,
              onPressed: () => _confirmClearCart(context, ref),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, ref, cartState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CartState state) {
    if (state.isLoading && state.cart == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(context.colors.accentPrimary),
        ),
      );
    }

    if (state.error != null && state.cart == null) {
      return _buildErrorState(context, ref);
    }

    if (state.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _CartItemTile(item: state.items[index]);
            },
          ),
        ),
        _buildFooter(context, state),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).shopCartError,
              style: TextStyle(color: context.colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ShopPillButton(
              label: S.of(context).actionRetry,
              onPressed: () =>
                  ref.read(cartNotifierProvider.notifier).loadCart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.shoppingCart,
              size: 60,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context).shopCartEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).shopCartEmptyBody,
              style: TextStyle(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ShopPillButton(
              label: S.of(context).shopCartViewShowcase,
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/shop');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, CartState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryRow(
              context,
              S.of(context).shopCartSubtotal,
              formatBRL(state.subtotal),
            ),
            if (state.shipping > 0)
              _summaryRow(
                context,
                S.of(context).shopCartShipping,
                formatBRL(state.shipping),
              ),
            if (state.discount > 0)
              _summaryRow(
                context,
                S.of(context).shopCartDiscount,
                '-${formatBRL(state.discount)}',
              ),
            if (state.discount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colors.accentPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.accentPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 16,
                      color: context.colors.accentPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Você economizou ${formatBRL(state.discount)}!',
                        style: TextStyle(
                          color: context.colors.accentPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 4),
            Divider(color: context.colors.divider, height: 20),
            _summaryRow(
              context,
              S.of(context).shopCartTotal,
              formatBRL(state.total),
              emphasize: true,
            ),
            const SizedBox(height: 16),
            ShopPillButton(
              label: S.of(context).shopCartContinueToCheckout,
              onPressed: state.isEmpty
                  ? null
                  : () => context.push('/shop/checkout'),
              expand: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
          )
        : Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).shopCartClearConfirmTitle),
        content: Text(S.of(ctx).shopCartClearConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(ctx).shopCartClear),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref.read(cartNotifierProvider.notifier).clear();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).shopCartClearError)));
    }
  }
}

/// A single row in the cart list showing product info, quantity controls
/// and subtotal for that item.
class _CartItemTile extends ConsumerWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantName != null && item.variantName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.variantName!,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  formatBRL(item.unitPrice),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityStepper(item: item),
                    const Spacer(),
                    Text(
                      formatBRL(item.totalPrice),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.trash2,
              size: 20,
              color: context.colors.textSecondary,
            ),
            tooltip: S.of(context).shopCartRemoveItem,
            onPressed: () async {
              final ok = await ref
                  .read(cartNotifierProvider.notifier)
                  .removeItem(item.id);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).shopCartRemoveError)),
                );
              }
            },
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
        LucideIcons.image,
        color: context.colors.textSecondary,
        size: 24,
      ),
    );
  }
}

/// Compact -/+ stepper for updating a cart item's quantity.
class _QuantityStepper extends ConsumerWidget {
  final CartItem item;

  const _QuantityStepper({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              LucideIcons.minus,
              size: 14,
              color: context.colors.textPrimary,
            ),
            iconSize: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => _updateQuantity(context, ref, item.quantity - 1),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                item.quantity.toString(),
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.plus,
              size: 14,
              color: context.colors.textPrimary,
            ),
            iconSize: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => _updateQuantity(context, ref, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuantity(
    BuildContext context,
    WidgetRef ref,
    int newQuantity,
  ) async {
    if (newQuantity < 1) {
      final ok = await ref
          .read(cartNotifierProvider.notifier)
          .removeItem(item.id);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).shopCartRemoveError)),
        );
      }
      return;
    }
    final ok = await ref
        .read(cartNotifierProvider.notifier)
        .updateQuantity(item.id, newQuantity);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopCartUpdateError)),
      );
    }
  }
}
