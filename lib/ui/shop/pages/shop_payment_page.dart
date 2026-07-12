import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../widgets/shop_pill_button.dart';

/// Payment page accessed via `/shop/checkout/payment/:orderId`.
///
/// **MVP / mock scope:** This screen intentionally does NOT integrate a
/// real payment gateway. It only mocks the visual flow per payment method
/// selected in [ShopCheckoutPage]:
/// - PIX: placeholder QR code + "I already paid" button.
/// - Card: "coming soon" placeholder.
/// - Crypto: "coming soon" placeholder.
///
/// **TODO (gap):** Replace mocked PIX/card/crypto UI with real Wolknow
/// gateway integration (out of scope for this task). Order detail is not
/// fetched here (no `GET /marketplace/orders/:id` endpoint wired yet) — we
/// only display the `orderId` we were navigated with. Wire up
/// `paymentStatusProvider` once a real `paymentId` exists (returned from
/// `createPayment`).
class ShopPaymentPage extends ConsumerWidget {
  final String orderId;

  const ShopPaymentPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          S.of(context).shopPaymentTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.receipt,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).shopPaymentOrderNumber(orderId),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildPixMock(context),
              const SizedBox(height: 28),
              ShopPillButton(
                label: S.of(context).shopPaymentViewOrders,
                outlined: true,
                expand: true,
                onPressed: () => context.go('/shop/orders'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mocked PIX flow — QR code placeholder + confirmation button.
  ///
  /// **TODO (gap):** Real payment method should be read from the order/
  /// payment intent instead of always showing PIX. Since there is no
  /// `GET /marketplace/orders/:id` endpoint yet to fetch the chosen
  /// `payment_method`, and gateway integration is out of scope, we show
  /// the PIX mock unconditionally as the primary MVP path.
  Widget _buildPixMock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).shopPaymentPixTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surfaceHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              LucideIcons.qrCode,
              size: 96,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            S.of(context).shopPaymentPixInstructions,
            style: TextStyle(color: context.colors.textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ShopPillButton(
            label: S.of(context).shopPaymentAlreadyPaid,
            expand: true,
            onPressed: () => context.go('/shop/orders'),
          ),
        ],
      ),
    );
  }
}
