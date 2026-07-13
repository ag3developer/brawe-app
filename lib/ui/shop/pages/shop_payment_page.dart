import 'dart:async';
import 'dart:convert';

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
/// Accessed via `/shop/checkout/payment/:orderId` route after checkout
/// completion.
///
/// Flow:
/// 1. Display QR code (PIX) or payment instructions
/// 2. Show copy-paste code
/// 3. Poll status every 2 seconds
/// 4. Redirect to order tracking when payment confirmed
///
/// **Layout notes:** content is capped at [_maxContentWidth] and centered
/// so the page looks intentional on tablets/desktop instead of a mobile
/// layout stretched edge-to-edge. Everything scrolls, so nothing overflows
/// on small/short screens.
class ShopPaymentPage extends ConsumerStatefulWidget {
  final String orderId;

  const ShopPaymentPage({super.key, required this.orderId});

  @override
  ConsumerState<ShopPaymentPage> createState() => _ShopPaymentPageState();
}

class _ShopPaymentPageState extends ConsumerState<ShopPaymentPage> {
  static const double _maxContentWidth = 440;

  Timer? _pollingTimer;
  Map<String, dynamic>? _paymentData;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializePayment() async {
    try {
      debugPrint(
        '[ShopPaymentPage] _initializePayment() called for orderId=${widget.orderId}',
      );

      final paymentService = ref.read(marketplacePaymentServiceProvider);
      final data = await paymentService.initiatePayment(widget.orderId, 'pix');

      debugPrint(
        '[ShopPaymentPage] ✅ Payment initiated: '
        'status=${data['payment_status']}, '
        'hasQrCode=${data['pix_qr_code'] != null}, '
        'hasCopyPaste=${data['pix_copy_paste'] != null}',
      );

      if (!mounted) return;
      setState(() {
        _paymentData = data;
        _isLoading = false;
      });
      _startPolling();
    } catch (e) {
      debugPrint('[ShopPaymentPage] ❌ Error in _initializePayment: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object e) {
    // Nunca exibir stack traces/tokens ao usuário — apenas uma mensagem
    // curta e amigável. Detalhes completos já foram para debugPrint acima.
    return 'Não foi possível gerar o pagamento Pix agora. '
        'Seu pedido foi criado normalmente — tente novamente.';
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final paymentService = ref.read(marketplacePaymentServiceProvider);
        final status = await paymentService.checkPaymentStatus(widget.orderId);

        if (!mounted) return;
        setState(() => _paymentData = {..._paymentData ?? {}, ...status});

        if (status['payment_status'] == 'paid') {
          _pollingTimer?.cancel();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ Pagamento confirmado!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) context.go('/shop/orders/${widget.orderId}');
        }
      } catch (e) {
        // Silently continue polling on transient errors.
        debugPrint('[ShopPaymentPage] Polling error: $e');
      }
    });
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    await _initializePayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pagamento',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: _isLoading
                ? _buildLoading(context)
                : _hasError
                ? _buildError(context)
                : _buildPaymentContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
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

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.mutedRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertCircle,
                color: AppColors.mutedRed,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Erro ao gerar pagamento',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Tente novamente mais tarde',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentContent(BuildContext context) {
    final data = _paymentData;
    if (data == null) return const SizedBox.shrink();

    // `pix_qr_code` do backend é a imagem do QR já renderizada em base64
    // (PNG) pelo gateway Wolknow — deve ser exibida como IMAGEM, nunca
    // re-codificada como dado de um novo QR (isso gerava um QR gigante e
    // ilegível, pois a string base64 tem milhares de caracteres).
    final qrImageBase64 = data['pix_qr_code'] as String?;
    final copyPaste = data['pix_copy_paste'] as String?;
    final expiresAt = data['expires_at'] as String?;
    final paymentStatus = data['payment_status'] as String?;
    final total = _asDouble(data['total']);
    final isPaid = paymentStatus == 'paid';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _StatusBadge(isPaid: isPaid)),
          const SizedBox(height: 20),

          // Amount card
          _AmountCard(total: total),
          const SizedBox(height: 20),

          if (!isPaid) ...[
            _QrCodeCard(qrImageBase64: qrImageBase64, copyPaste: copyPaste),
            const SizedBox(height: 16),
            if (copyPaste != null)
              _CopyPasteField(
                code: copyPaste,
                copied: _copied,
                onCopy: () => _handleCopy(copyPaste),
              ),
            const SizedBox(height: 16),
            if (expiresAt != null) _ExpirationChip(isoExpiresAt: expiresAt),
            const SizedBox(height: 24),
            const _InstructionsCard(),
            const SizedBox(height: 24),
            const _PollingIndicator(),
          ] else
            const _PaidConfirmation(),
        ],
      ),
    );
  }

  void _handleCopy(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Código Pix copiado!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Pill badge showing current payment state (waiting vs confirmed).
class _StatusBadge extends StatelessWidget {
  final bool isPaid;
  const _StatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.success : AppColors.electricPurple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? LucideIcons.checkCircle2 : LucideIcons.clock,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isPaid ? 'Pagamento Confirmado' : 'Aguardando Pagamento',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card showing the total amount due, with a subtle brand gradient.
class _AmountCard extends StatelessWidget {
  final double total;
  const _AmountCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.electricPurple.withValues(alpha: 0.10),
            AppColors.coolCyan.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.electricPurple.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Total a pagar',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                color: AppColors.electricPurple,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the PIX QR code. Prefers the pre-rendered base64 PNG from the
/// gateway (`pix_qr_code`); falls back to locally generating a QR image
/// from the copy-paste BR Code if the base64 image is missing/invalid —
/// never encodes the base64 string itself as QR data (that produced the
/// giant unreadable QR reported by users).
class _QrCodeCard extends StatelessWidget {
  final String? qrImageBase64;
  final String? copyPaste;

  const _QrCodeCard({required this.qrImageBase64, required this.copyPaste});

  @override
  Widget build(BuildContext context) {
    final qrWidget = _tryDecodeImage() ?? _tryGenerateFromCopyPaste();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child:
                qrWidget ??
                const Center(
                  child: Icon(
                    LucideIcons.qrCode,
                    size: 48,
                    color: Colors.black26,
                  ),
                ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.scanLine, size: 14, color: Colors.black45),
              SizedBox(width: 6),
              Text(
                'Escaneie com o app do seu banco',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _tryDecodeImage() {
    if (qrImageBase64 == null || qrImageBase64!.isEmpty) return null;
    try {
      // Backend pode enviar com ou sem o prefixo data URI.
      final raw = qrImageBase64!.contains(',')
          ? qrImageBase64!.split(',').last
          : qrImageBase64!;
      final bytes = base64Decode(raw);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            _tryGenerateFromCopyPaste() ?? const SizedBox.shrink(),
      );
    } catch (_) {
      return null;
    }
  }

  Widget? _tryGenerateFromCopyPaste() {
    if (copyPaste == null || copyPaste!.isEmpty) return null;
    return QrImageView(
      data: copyPaste!,
      version: QrVersions.auto,
      backgroundColor: Colors.white,
      padding: EdgeInsets.zero,
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
    );
  }
}

/// Copy-paste PIX code field with copy button + inline confirmation state.
class _CopyPasteField extends StatelessWidget {
  final String code;
  final bool copied;
  final VoidCallback onCopy;

  const _CopyPasteField({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ou copie o código Pix',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onCopy,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: copied
                        ? const Icon(
                            LucideIcons.checkCheck,
                            key: ValueKey('copied'),
                            size: 20,
                            color: AppColors.success,
                          )
                        : const Icon(
                            LucideIcons.copy,
                            key: ValueKey('copy'),
                            size: 20,
                            color: AppColors.electricPurple,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small chip showing the PIX expiration time (HH:mm) — fails silently to
/// "em breve" on unparseable dates instead of throwing.
class _ExpirationChip extends StatelessWidget {
  final String isoExpiresAt;
  const _ExpirationChip({required this.isoExpiresAt});

  String get _formatted {
    try {
      final dt = DateTime.parse(isoExpiresAt).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return 'em breve';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.timer,
            size: 14,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Válido até $_formatted',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Step-by-step "how to pay" card — reusable numbered-step row style.
class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard();

  static const _steps = [
    'Abra o app do seu banco ou carteira Pix',
    'Escaneie o QR Code ou cole o código copiado',
    'Confirme o pagamento',
    'Seu pedido é liberado automaticamente',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como pagar',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == _steps.length - 1 ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.electricPurple,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _steps[i],
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Small "checking payment..." spinner shown while polling.
class _PollingIndicator extends StatelessWidget {
  const _PollingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                AppColors.electricPurple.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verificando pagamento...',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Success state shown once payment_status == 'paid'.
class _PaidConfirmation extends StatelessWidget {
  const _PaidConfirmation();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.checkCircle2,
              color: AppColors.success,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pagamento confirmado!',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Redirecionando para o seu pedido...',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
