import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';

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
          style: TextStyle(color: context.colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      S.of(context).shopPaymentOrderNumber(orderId),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildPixMock(context),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => context.go('/shop/orders'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context).shopPaymentViewOrders,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
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
    return Column(
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
        const SizedBox(height: 16),
        Container(
          height: 220,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Icon(
            LucideIcons.qrCode,
            size: 96,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          S.of(context).shopPaymentPixInstructions,
          style: TextStyle(color: context.colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.go('/shop/orders'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.accentPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            S.of(context).shopPaymentAlreadyPaid,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
