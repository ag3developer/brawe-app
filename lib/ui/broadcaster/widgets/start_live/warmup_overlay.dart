import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';

/// Overlay de "Aquecer público" — countdown de 30s antes da live de verdade.
///
/// Comportamento:
/// 1. Mostra contagem regressiva grande no centro
/// 2. Botão "Pular aquecimento" para entrar ao vivo imediatamente
/// 3. Botão "Cancelar" para abortar
/// 4. Quando chega a 0, chama [onComplete] (que dispara `startLive` no backend)
class WarmupOverlay extends StatefulWidget {
  const WarmupOverlay({
    super.key,
    required this.totalSeconds,
    required this.onComplete,
    required this.onCancel,
  });

  final int totalSeconds;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  @override
  State<WarmupOverlay> createState() => _WarmupOverlayState();
}

class _WarmupOverlayState extends State<WarmupOverlay>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _skip() {
    _timer?.cancel();
    widget.onComplete();
  }

  void _cancel() {
    _timer?.cancel();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Aquecendo o público',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Avisando seus seguidores...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ScaleTransition(
                  scale: Tween(begin: 0.92, end: 1.05).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricPurple.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricPurple.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_remaining',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 96,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'A live abre em $_remaining segundo${_remaining == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _skip,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.electricPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: const Text(
                            'Entrar ao vivo agora',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _cancel,
                        child: Text(
                          'Cancelar aquecimento',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
