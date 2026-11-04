import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/services/qr_login_service.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Tela de câmera para escanear QR codes da Brawe.
///
/// Reconhece dois tipos de conteúdo:
/// 1. Link de perfil (`https://brawe.app/connect/u/<handle>`) → navega
///    direto para `/profile/<handle>`.
/// 2. Token de QR login (string opaca gerada por `POST /auth/qr/create`,
///    exibida em outro dispositivo, ex.: navegador) → mostra um diálogo
///    de confirmação e, se aprovado, chama `POST /auth/qr/approve`.
///
/// Qualquer outro conteúdo é tratado como inválido (snackbar de erro).
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Extrai o handle/id de um link de perfil Brawe, ou null se não bater
  /// com o padrão esperado.
  String? _profileHandleFrom(String raw) {
    final prefix = '${AppConstants.publicBaseUrl}/connect/u/';
    if (!raw.startsWith(prefix)) return null;
    final handle = raw.substring(prefix.length).trim();
    return handle.isEmpty ? null : handle;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handled = true;
    await _controller.stop();

    final profileHandle = _profileHandleFrom(raw);
    if (profileHandle != null) {
      if (!mounted) return;
      context.pushReplacement('/profile/$profileHandle');
      return;
    }

    // Não é um link de perfil conhecido — trata como possível token de
    // QR login e pede confirmação antes de aprovar (ação sensível: dá
    // acesso à conta em outro dispositivo).
    await _confirmAndApproveLogin(raw);
  }

  Future<void> _confirmAndApproveLogin(String qrToken) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.qrScannerLoginConfirmTitle),
        content: Text(s.qrScannerLoginConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.actionApprove),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      if (!mounted) return;
      setState(() => _handled = false);
      await _controller.start();
      return;
    }

    try {
      await ref.read(qrLoginServiceProvider).approveSession(qrToken);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.qrScannerLoginApproved)));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.qrScannerLoginError(_shortError(e)))),
      );
      setState(() => _handled = false);
      await _controller.start();
    }
  }

  String _shortError(Object e) {
    final text = e.toString();
    return text.length > 80 ? '${text.substring(0, 80)}…' : text;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(s.qrScannerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  s.qrScannerCameraPermissionDenied,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          // Moldura minimalista de foco, apenas decorativa.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Text(
              s.qrScannerHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
