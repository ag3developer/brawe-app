import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'dart:ui' as ui;

import '../../core/themes/app_colors.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import '../../core/view_models/follow_view_model.dart';
import 'battle_gift_alert.dart';

/// Tela do espectador para batalhas 1v1.
///
/// Layout:
/// - Cabeçalho: timer + barra de vantagem
/// - Conteúdo central: dois vídeos lado a lado (placeholders com avatar)
/// - Alerta de gift via overlay (não fullscreen, mas proeminente)
/// - Rodapé: botão "Enviar presente"
class ViewerBattleScreen extends ConsumerStatefulWidget {
  const ViewerBattleScreen({super.key, required this.battleId});

  final String battleId;

  @override
  ConsumerState<ViewerBattleScreen> createState() => _ViewerBattleScreenState();
}

class _ViewerBattleScreenState extends ConsumerState<ViewerBattleScreen>
    with SingleTickerProviderStateMixin {
  // Gift alert queue
  final List<_GiftAlert> _alerts = [];
  StreamSubscription<void>? _alertSub;

  // Countdown overlay
  int? _countdownValue;
  Timer? _countdownClearTimer;

  // Shake animation for score takeover
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _alertSub?.cancel();
    _countdownClearTimer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onNewGift(BattleState s) {
    if (s.lastGiftSender == null || s.lastGiftName == null) return;
    final alert = _GiftAlert(
      sender: s.lastGiftSender!,
      gift: s.lastGiftName!,
      side: s.lastUpdatedSide ?? 'a',
    );
    setState(() => _alerts.add(alert));
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _alerts.remove(alert));
    });
    // Shake when takeover
    if ((s.lastUpdatedSide == 'b' && s.isLeadingB) ||
        (s.lastUpdatedSide == 'a' && s.isLeadingA)) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final asyncState = ref.watch(battleViewModelProvider(widget.battleId));

    // Listen to state changes for gift alerts + countdown
    ref.listen<AsyncValue<BattleState>>(
      battleViewModelProvider(widget.battleId),
      (prev, next) {
        next.whenData((s) {
          // Gift alert
          final prevState = prev?.asData?.value;
          if (prevState?.lastGiftSender != s.lastGiftSender ||
              prevState?.lastGiftName != s.lastGiftName) {
            _onNewGift(s);
          }
          // Countdown phase
          if (s.phase == BattlePhase.countdown) {
            setState(() => _countdownValue = 3);
            _countdownClearTimer?.cancel();
            _countdownClearTimer = Timer(const Duration(seconds: 4), () {
              if (mounted) setState(() => _countdownValue = null);
            });
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: asyncState.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.electricPurple),
              const SizedBox(height: 16),
              Text(
                l10n.battleLoading,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                l10n.battleError,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white54),
                label: Text(
                  'Voltar',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
        data: (battle) => _BattleContent(
          battle: battle,
          alerts: _alerts,
          countdownValue: _countdownValue,
          shakeAnim: _shakeAnim,
          onBack: () => context.pop(),
          l10n: l10n,
        ),
      ),
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _BattleContent extends StatelessWidget {
  const _BattleContent({
    required this.battle,
    required this.alerts,
    required this.countdownValue,
    required this.shakeAnim,
    required this.onBack,
    required this.l10n,
  });

  final BattleState battle;
  final List<_GiftAlert> alerts;
  final int? countdownValue;
  final Animation<double> shakeAnim;
  final VoidCallback onBack;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    // Show result screen when battle is over
    if (battle.isOver) {
      return _BattleResultOverlay(battle: battle, onClose: onBack, l10n: l10n);
    }

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Header novo estilo TikTok
              _Header(battle: battle, onBack: onBack, l10n: l10n),

              // Vídeos ocupam espaço restante
              Expanded(
                child: _VideoSection(
                  battle: battle,
                  shakeAnim: shakeAnim,
                  l10n: l10n,
                ),
              ),

              // Footer com MVP e notificações
              _Footer(l10n: l10n, battle: battle),
            ],
          ),

          // Gift alerts sobreposto
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: _GiftAlertStack(alerts: alerts),
          ),

          // Countdown overlay
          if (countdownValue != null)
            _CountdownOverlay(count: countdownValue!, l10n: l10n),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.battle,
    required this.onBack,
    required this.l10n,
  });

  final BattleState battle;
  final VoidCallback onBack;
  final S l10n;

  String _formatScore(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
          child: Column(
            children: [
              // Barra de progresso com pontuação
              Row(
                children: [
                  // Pontuação lado A
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.electricPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatScore(battle.scoreA),
                      style: TextStyle(
                        color: AppColors.electricPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Barra de progresso inline
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (battle.progressA * 100).toInt().clamp(
                              1,
                              100,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.electricPurple,
                                    Colors.cyan,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: ((1 - battle.progressA) * 100).toInt().clamp(
                              1,
                              100,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.pink, AppColors.hotPink],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  // Pontuação lado B
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.hotPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatScore(battle.scoreB),
                      style: TextStyle(
                        color: AppColors.hotPink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timer centralizado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${battle.timeRemaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${battle.timeRemaining.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Video Section ─────────────────────────────────────────────────────────────

class _VideoSection extends StatelessWidget {
  const _VideoSection({
    required this.battle,
    required this.shakeAnim,
    required this.l10n,
  });

  final BattleState battle;
  final Animation<double> shakeAnim;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StreamerPanel(
            name: battle.streamerAName,
            avatarUrl: battle.streamerAAvatarUrl,
            score: battle.scoreA,
            isLeading: battle.isLeadingA,
            side: 'a',
            shakeAnim: shakeAnim,
            l10n: l10n,
          ),
        ),
        Container(width: 2, color: Colors.black),
        Expanded(
          child: _StreamerPanel(
            name: battle.streamerBName,
            avatarUrl: battle.streamerBAvatarUrl,
            score: battle.scoreB,
            isLeading: battle.isLeadingB,
            side: 'b',
            shakeAnim: shakeAnim,
            l10n: l10n,
          ),
        ),
      ],
    );
  }
}

class _StreamerPanel extends StatelessWidget {
  const _StreamerPanel({
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.isLeading,
    required this.side,
    required this.shakeAnim,
    required this.l10n,
  });

  final String name;
  final String? avatarUrl;
  final double score;
  final bool isLeading;
  final String side;
  final Animation<double> shakeAnim;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    final color = side == 'a' ? AppColors.electricPurple : AppColors.hotPink;
    return AnimatedBuilder(
      animation: shakeAnim,
      builder: (_, child) {
        final offset = (side == 'a' && isLeading) || (side == 'b' && isLeading)
            ? shakeAnim.value
            : 0.0;
        return Transform.translate(
          offset: Offset(0, offset * 0.3),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: isLeading
              ? Border.all(color: color.withValues(alpha: 0.6), width: 1.5)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Avatar / video placeholder
            if (avatarUrl != null)
              Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else
              Center(
                child: Icon(Icons.person, size: 64, color: Colors.white24),
              ),

            // Visual limpo sem overlay

            // Leading crown
            if (isLeading)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Gift Alert Stack ──────────────────────────────────────────────────────────

class _GiftAlertStack extends StatelessWidget {
  const _GiftAlertStack({required this.alerts});
  final List<_GiftAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: alerts
            .take(3)
            .map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: BattleGiftAlert(
                  senderName: a.sender,
                  giftName: a.gift,
                  side: a.side,
                  mode: GiftAlertMode.overlay,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.l10n, required this.battle});
  final S l10n;
  final BattleState battle;

  String _getBattleNotification() {
    // Lógica para mostrar diferentes notificações baseado no estado da batalha
    final remaining = battle.timeRemaining.inSeconds;

    if (remaining <= 30 && remaining > 0) {
      return 'Últimos 30s valem o dobro';
    }
    if (remaining >= 270) {
      // Primeiros 30 segundos de uma batalha de 5 min
      return 'Primeiro presente vale 3x';
    }
    return 'Envie presentes para ajudar!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MVP Poltronas lado esquerdo (lado A)
          Row(
            children: List.generate(3, (i) {
              // Apenas o TOP 1 disponível por agora
              final gifter = i == 0 ? battle.topGifterA : null;
              return Padding(
                padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                child: _MVPSeat(
                  color: AppColors.electricPurple,
                  gifter: gifter,
                ),
              );
            }),
          ),

          // Notificação central minimalista
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rocket_launch,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _getBattleNotification(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // MVP Poltronas lado direito (lado B)
          Row(
            children: List.generate(3, (i) {
              // Apenas o TOP 1 disponível por agora
              final gifter = i == 0 ? battle.topGifterB : null;
              return Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: _MVPSeat(color: AppColors.hotPink, gifter: gifter),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── MVP Seat ─────────────────────────────────────────────────────────────────

class _MVPSeat extends StatelessWidget {
  final Color color;
  final BattleGifter? gifter;

  const _MVPSeat({required this.color, this.gifter});

  @override
  Widget build(BuildContext context) {
    final hasGifter = gifter != null;

    return GestureDetector(
      onTap: hasGifter
          ? () {
              // TODO: Abrir bottom sheet com perfil do MVP
              // Você já tem esse componente no projeto, vincular aqui
              _showProfileSheet(context, gifter!.id);
            }
          : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: hasGifter
              ? Colors.black.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasGifter ? color : color.withValues(alpha: 0.4),
            width: hasGifter ? 2 : 1,
          ),
        ),
        child: hasGifter
            ? Icon(Icons.person, color: color, size: 20)
            : Icon(
                Icons.event_seat,
                color: color.withValues(alpha: hasGifter ? 0.8 : 0.5),
                size: 20,
              ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context, String userId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => _MVPProfileSheet(userId: userId),
    );
  }
}

// ─── MVP Profile Sheet ────────────────────────────────────────────────────────

class _MVPProfileSheet extends ConsumerWidget {
  const _MVPProfileSheet({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followAsync = ref.watch(followViewModelProvider(userId));
    final isFollowing = followAsync.value ?? false;

    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0B14).withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.6,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: _MVPProfileContent(
              userId: userId,
              isFollowing: isFollowing,
              onToggleFollow: () => ref
                  .read(followViewModelProvider(userId).notifier)
                  .toggleFollow(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MVPProfileContent extends ConsumerStatefulWidget {
  const _MVPProfileContent({
    required this.userId,
    required this.isFollowing,
    required this.onToggleFollow,
  });

  final String userId;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  @override
  ConsumerState<_MVPProfileContent> createState() => _MVPProfileContentState();
}

class _MVPProfileContentState extends ConsumerState<_MVPProfileContent> {
  String? _username;
  String? _avatarUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref
          .read(profileRepositoryProvider)
          .getUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          _username = profile.username;
          _avatarUrl = profile.avatarUrl;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.electricPurple.withValues(alpha: 0.3),
          backgroundImage: _avatarUrl != null
              ? NetworkImage(_avatarUrl!)
              : null,
          child: _loading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : _avatarUrl == null
              ? const Icon(Icons.person, size: 40, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),

        // Username
        Text(
          _loading ? '...' : (_username ?? 'MVP'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),

        // Badge MVP
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.electricPurple, AppColors.hotPink],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.workspace_premium, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'TOP GIFTER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Botão seguir
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onToggleFollow();
              if (context.mounted) Navigator.of(context).maybePop();
            },
            icon: Icon(
              widget.isFollowing ? Icons.person_remove : Icons.person_add,
              size: 18,
            ),
            label: Text(widget.isFollowing ? 'Deixar de seguir' : 'Seguir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isFollowing
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.electricPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Ver perfil completo
        TextButton(
          onPressed: () {
            Navigator.of(context).maybePop();
            if (context.mounted) context.push('/profile/${widget.userId}');
          },
          child: Text(
            'Ver perfil completo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Countdown Overlay ────────────────────────────────────────────────────────

class _CountdownOverlay extends StatefulWidget {
  const _CountdownOverlay({required this.count, required this.l10n});
  final int count;
  final S l10n;

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(
      begin: 2.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Text(
              '${widget.count}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Battle Result Overlay ────────────────────────────────────────────────────

class _BattleResultOverlay extends StatelessWidget {
  const _BattleResultOverlay({
    required this.battle,
    required this.onClose,
    required this.l10n,
  });

  final BattleState battle;
  final VoidCallback onClose;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    final isDraw = battle.isDraw;
    final winnerName =
        battle.winnerName ??
        (battle.isLeadingA ? battle.streamerAName : battle.streamerBName);
    final winnerColor = battle.isLeadingA
        ? AppColors.electricPurple
        : AppColors.hotPink;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[900]!],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.battleResultTitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Winner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDraw ? Colors.white24 : winnerColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: (isDraw ? Colors.white : winnerColor).withValues(
                    alpha: 0.08,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isDraw
                          ? Icons.handshake_outlined
                          : Icons.workspace_premium,
                      color: isDraw ? Colors.white54 : winnerColor,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDraw ? l10n.battleDraw : l10n.battleWinner,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    if (!isDraw) ...[
                      const SizedBox(height: 4),
                      Text(
                        winnerName,
                        style: TextStyle(
                          color: winnerColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Score row
              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      name: battle.streamerAName,
                      score: battle.scoreA,
                      color: AppColors.electricPurple,
                      isWinner: battle.isLeadingA && !isDraw,
                      l10n: l10n,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'VS',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ScoreCard(
                      name: battle.streamerBName,
                      score: battle.scoreB,
                      color: AppColors.hotPink,
                      isWinner: battle.isLeadingB && !isDraw,
                      l10n: l10n,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(l10n.battleResultWatchAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.name,
    required this.score,
    required this.color,
    required this.isWinner,
    required this.l10n,
  });

  final String name;
  final double score;
  final Color color;
  final bool isWinner;
  final S l10n;

  String _formatScore(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? color.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _formatScore(score),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          Text(
            'pts',
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Internal models ──────────────────────────────────────────────────────────

class _GiftAlert {
  _GiftAlert({required this.sender, required this.gift, required this.side});
  final String sender;
  final String gift;
  final String side;
}
