import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/quest.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import 'reward_collection_animation.dart';

/// Versão melhorada do botão de coleta com animação de sucesso premium.
class EnhancedClaimButton extends ConsumerStatefulWidget {
  final DailyQuest quest;
  final Color color;
  final Function(Future<void> Function() onSuccess) onClaimRequested;

  const EnhancedClaimButton({
    Key? key,
    required this.quest,
    required this.color,
    required this.onClaimRequested,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedClaimButton> createState() =>
      _EnhancedClaimButtonState();
}

class _EnhancedClaimButtonState extends ConsumerState<EnhancedClaimButton>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseCtrl;
  bool _isLoading = false;
  bool _isSuccessAnimating = false;
  late RewardCollectionController _rewardCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rewardCtrl = RewardCollectionController(
      vsync: this,
      mediaQuery: MediaQuery.of(context),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleClaim() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Disparar callback com callback de sucesso
      widget.onClaimRequested(() async {
        // Animação de sucesso
        setState(() => _isSuccessAnimating = true);

        // Simular delay para renderização do sucesso visual
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          // Tocar haptic feedback ao confirmar sucesso
          HapticFeedback.mediumImpact();

          setState(() => _isSuccessAnimating = false);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Erro será tratado no nível superior
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    if (_isSuccessAnimating && !disableAnimations) {
      return _SuccessCheckmark(color: widget.color);
    }

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) {
        final scale = 1.0 + 0.04 * math.sin(_pulseCtrl.value * math.pi * 2);

        return Transform.scale(
          scale: _isLoading ? 0.95 : scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _handleClaim,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.55),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 50,
                          height: 20,
                          child: Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          s.questsActionClaim,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Checkmark animado de sucesso.
class _SuccessCheckmark extends StatefulWidget {
  final Color color;

  const _SuccessCheckmark({super.key, required this.color});

  @override
  State<_SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<_SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    _opacityAnim = Tween<double>(begin: 1, end: 0.7).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _opacityAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.55),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Extensão para acessar tema com segurança.
extension BuildContextExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
