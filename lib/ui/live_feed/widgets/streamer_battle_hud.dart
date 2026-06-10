import 'dart:async';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_colors.dart';
import '../../../data/services/battle_service.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/battle_view_model.dart';
import 'battle_gift_alert.dart';
import 'battle_score_bar.dart';
import 'battle_timer.dart';

// ─── Layout constants ─────────────────────────────────────────────────────
// O `BroadcasterScreen` empilha o `BroadcasterTopBar` POR CIMA do
// `StreamerBattleHud` (ordem do Stack), com:
//   • Padding superior do container         10px
//   • BroadcasterTopBar (1 linha)         ≈ 36px
//   • SizedBox abaixo                        6px
//   ───────────────────────────────────────────
//   Total                                 ≈ 52px (abaixo do SafeArea)
//
// Se não respeitarmos isso, o painel da batalha fica VISUALMENTE escondido
// atrás do top bar (badges, viewers, etc.) — exatamente o que o usuário
// reportou. O spacer abaixo garante que o painel "encoste" na borda
// inferior do top bar, mesmo padrão TikTok PK.
const double _kBroadcasterTopBarHeight = 52;

/// HUD compacto da batalha para o streamer.
///
/// O streamer continua vendo o preview da câmera (gerenciado pelo BroadcasterScreen).
/// Este widget é sobreposto como um HUD — não bloqueia a câmera, não roda
/// overlays pesados, não cobre a tela inteira.
///
/// Uso: sobreponha sobre o BroadcasterScreen via Stack.
class StreamerBattleHud extends ConsumerStatefulWidget {
  const StreamerBattleHud({
    super.key,
    required this.battleId,
    required this.myStreamerId,
    this.onBattleClosed,
  });

  final String battleId;
  final String myStreamerId;

  /// Chamado quando o HUD deve sair da tela (revanche aceita = novo battleId,
  /// ou fechar resultado, ou desistir mid-battle). O broadcaster usa isso
  /// pra zerar `_activeBattleId` e voltar pra live normal.
  final VoidCallback? onBattleClosed;

  @override
  ConsumerState<StreamerBattleHud> createState() => _StreamerBattleHudState();
}

class _StreamerBattleHudState extends ConsumerState<StreamerBattleHud> {
  final List<_ToastAlert> _toasts = [];

  /// Flag pra evitar duplo-clique nos botões Sair / Revanche. Como cada um
  /// envolve uma chamada HTTP que pode demorar, o usuário ansioso aperta 2x
  /// e dispara 2 requests → o 2º falha com 400. Gate simples + spinner.
  bool _isBusy = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _confirmAndEndBattle() async {
    if (_isBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1F),
        title: const Text(
          'Sair da batalha?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'A batalha será encerrada agora e o vencedor será definido pelo placar atual. Você continua na live normal.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isBusy = true);
    try {
      final svc = ref.read(battleServiceProvider);
      await svc.endBattleEarly(widget.battleId);
      // O broadcast `connect:battle:ended` (ou `cancelled`) vai chegar
      // via socket e o BroadcasterScreen vai limpar `_activeBattleId`.
      // Mas damos o sinal explícito também (mais responsivo).
      if (mounted) widget.onBattleClosed?.call();
    } on DioException catch (e) {
      // receiveTimeout: o backend ainda está processando (fire-and-forget).
      // O resultado chega via socket `connect:battle:ended` em < 2s.
      // Tratar como sucesso — não mostrar erro ao usuário.
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        if (mounted) widget.onBattleClosed?.call();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao encerrar batalha: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao encerrar batalha: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _requestRematch() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final svc = ref.read(battleServiceProvider);
      await svc.requestRematch(widget.battleId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convite de revanche enviado 🔄')),
        );
        // Fecha o banner — o socket `connect:battle:invite` chega no
        // oponente, e se ele aceitar, um novo `battle:started` chega
        // aqui e o BroadcasterScreen abre o HUD com o novo battle_id.
        widget.onBattleClosed?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao pedir revanche: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _addToast(BattleState s) {
    if (s.lastGiftSender == null || s.lastGiftName == null) return;
    final toast = _ToastAlert(
      sender: s.lastGiftSender!,
      gift: s.lastGiftName!,
      side: s.lastUpdatedSide ?? 'a',
    );
    setState(() => _toasts.add(toast));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toasts.remove(toast));
    });
  }

  String _formatScore(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final asyncState = ref.watch(battleViewModelProvider(widget.battleId));

    ref.listen<AsyncValue<BattleState>>(
      battleViewModelProvider(widget.battleId),
      (prev, next) {
        next.whenData((s) {
          final prevState = prev?.asData?.value;
          if (prevState?.lastGiftSender != s.lastGiftSender ||
              prevState?.lastGiftName != s.lastGiftName) {
            _addToast(s);
          }
        });
      },
    );

    return asyncState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (battle) {
        if (battle.isOver) {
          return _ResultBanner(
            battle: battle,
            l10n: l10n,
            isBusy: _isBusy,
            onRematch: _requestRematch,
            onClose: () => widget.onBattleClosed?.call(),
          );
        }

        final iAmA = battle.streamerAId == widget.myStreamerId;
        final myScore = iAmA ? battle.scoreA : battle.scoreB;
        final rivalScore = iAmA ? battle.scoreB : battle.scoreA;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Spacer pra ficar abaixo do BroadcasterTopBar (que é
              // empilhado POR CIMA deste HUD no Stack do BroadcasterScreen).
              // Sem isso, o painel ficaria escondido atrás do top bar.
              const SizedBox(height: _kBroadcasterTopBarHeight),

              // ── Top HUD bar ───────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Score row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.battleYouScore(_formatScore(myScore)),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            BattleTimer(
                              timeRemaining: battle.timeRemaining,
                              compact: true,
                            ),
                            Expanded(
                              child: Text(
                                l10n.battleRivalScore(_formatScore(rivalScore)),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Mini score bar
                        BattleScoreBar(
                          progressA: battle.progressA,
                          scoreA: battle.scoreA,
                          scoreB: battle.scoreB,
                          compact: true,
                        ),
                        // ── Action row (Sair da batalha) ─────────────────
                        // Subtle: text-only button alinhado à direita pra
                        // não competir visualmente com o score, mas sempre
                        // disponível pro streamer "fugir" da batalha sem
                        // precisar finalizar a live inteira.
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _isBusy ? null : _confirmAndEndBattle,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.white60,
                            ),
                            icon: _isBusy
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white60,
                                    ),
                                  )
                                : const Icon(Icons.exit_to_app_rounded, size: 14),
                            label: const Text(
                              'Sair da batalha',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Gift toasts ────────────────────────────────────────────
              if (_toasts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _toasts
                        .take(2)
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: BattleGiftAlert(
                                senderName: t.sender,
                                giftName: t.gift,
                                side: t.side,
                                mode: GiftAlertMode.toast,
                              ),
                            ))
                        .toList(),
                  ),
                ),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

// ─── Result Banner (streamer) ─────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.battle,
    required this.l10n,
    required this.isBusy,
    required this.onRematch,
    required this.onClose,
  });
  final BattleState battle;
  final S l10n;
  final bool isBusy;
  final VoidCallback onRematch;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isDraw = battle.isDraw;
    final winnerName = battle.winnerName ??
        (battle.isLeadingA ? battle.streamerAName : battle.streamerBName);
    final winnerColor =
        battle.isLeadingA ? AppColors.electricPurple : AppColors.hotPink;

    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDraw ? Colors.white24 : winnerColor.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Linha do resultado ──────────────────────────
                Row(
                  children: [
                    Icon(
                      isDraw ? Icons.handshake_outlined : Icons.workspace_premium,
                      color: isDraw ? Colors.white54 : winnerColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.battleEnded,
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          Text(
                            isDraw ? l10n.battleDraw : '${l10n.battleWinner}: $winnerName',
                            style: TextStyle(
                              color: isDraw ? Colors.white70 : winnerColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ── Botões de ação ──────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isBusy ? null : onClose,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Fechar', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: isBusy ? null : onRematch,
                        style: FilledButton.styleFrom(
                          backgroundColor: winnerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: isBusy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.replay_rounded, size: 18),
                        label: const Text(
                          'Pedir revanche',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Internal model ────────────────────────────────────────────────────────────

class _ToastAlert {
  _ToastAlert({required this.sender, required this.gift, required this.side});
  final String sender;
  final String gift;
  final String side;
}
