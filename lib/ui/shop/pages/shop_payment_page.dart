import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/providers/marketplace_payment_providers.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';

/// Payment page that displays QR code for PIX payment.
///
/// Accessed via `/shop/payment/:order_id` route after checkout completion.
///
/// Flow:
/// 1. Display QR code (PIX) or payment instructions
/// 2. Show copy-paste code
/// 3. Poll status every 2 seconds
/// 4. Redirect to order tracking when payment confirmed
class ShopPaymentPage extends ConsumerStatefulWidget {
  final String orderId;

  const ShopPaymentPage({super.key, required this.orderId});

  @override
  ConsumerState<ShopPaymentPage> createState() => _ShopPaymentPageState();
}

class _ShopPaymentPageState extends ConsumerState<ShopPaymentPage> {
  late Timer _pollingTimer;
  Map<String, dynamic>? _paymentData;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  Future<void> _initializePayment() async {
    try {
      // Initiate payment on backend
      final paymentService = ref.read(marketplacePaymentServiceProvider);
      _paymentData = await paymentService.initiatePayment(
        widget.orderId,
        'pix', // Default to PIX
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Start polling for payment confirmation
        _startPolling();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final paymentService = ref.read(marketplacePaymentServiceProvider);
        final status = await paymentService.checkPaymentStatus(widget.orderId);

        if (mounted) {
          setState(() {
            _paymentData = status;
          });

          // Check if payment is confirmed
          if (status['payment_status'] == 'paid') {
            _pollingTimer.cancel();

            // Show success and redirect
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✓ Pagamento confirmado!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Redirect to order tracking after short delay
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                context.go('/shop/orders/${widget.orderId}');
              }
            }
          }
        }
      } catch (e) {
        // Silently continue polling on error
        debugPrint('Polling error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pagamento',
          style: TextStyle(color: context.colors.textPrimary),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _hasError
          ? _buildError()
          : _buildPaymentContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.electricPurple),
          const SizedBox(height: 16),
          Text(
            'Preparando pagamento...',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Erro ao processar pagamento',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Tente novamente mais tarde',
            style: TextStyle(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = null;
              });
              _initializePayment();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent() {
    if (_paymentData == null) return const SizedBox.shrink();

    final qrCode = _paymentData!['pix_qr_code'] as String?;
    final copyPaste = _paymentData!['pix_copy_paste'] as String?;
    final expiresAt = _paymentData!['expires_at'] as String?;
    final paymentStatus = _paymentData!['payment_status'] as String?;
    final total = _paymentData!['total'] ?? 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: paymentStatus == 'paid'
                    ? Colors.green.withValues(alpha: 0.1)
                    : AppColors.electricPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                paymentStatus == 'paid'
                    ? '✓ Pagamento Confirmado'
                    : 'Aguardando Pagamento',
                style: TextStyle(
                  color: paymentStatus == 'paid'
                      ? Colors.green
                      : AppColors.electricPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            Text(
              'Total a Pagar',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${(total as num).toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.coolCyan,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // QR Code
            if (qrCode != null && paymentStatus != 'paid')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.surfaceElevated),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: qrCode,
                  version: QrVersions.auto,
                  size: 280,
                  backgroundColor: Colors.white,
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF000000),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Copy paste code
            if (copyPaste != null && paymentStatus != 'paid') ...[
              Text(
                'Ou copie e cole este código:',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        copyPaste,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        LucideIcons.copy,
                        size: 18,
                        color: AppColors.electricPurple,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: copyPaste));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✓ Código copiado!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Expiration time
            if (expiresAt != null)
              Text(
                'Válido até: ${_formatTime(expiresAt)}',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),

            const SizedBox(height: 32),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como pagar:',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _instructionStep(
                    '1',
                    'Abra seu app de banco ou carteira PIX',
                  ),
                  _instructionStep(
                    '2',
                    'Escaneie o código QR ou cole o código',
                  ),
                  _instructionStep('3', 'Confirme o pagamento'),
                  _instructionStep(
                    '4',
                    'Seu pedido será confirmado automaticamente',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Polling indicator
            if (paymentStatus != 'paid')
              Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.electricPurple.withValues(alpha: 0.5),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verificando pagamento...',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _instructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.electricPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final hours = dateTime.hour.toString().padLeft(2, '0');
      final minutes = dateTime.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    } catch (_) {
      return 'em breve';
    }
  }
}
