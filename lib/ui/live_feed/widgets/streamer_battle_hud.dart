import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/battle_service.dart';
import '../../../domain/models/battle_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../battle/battle_errors.dart';
import '../battle/battle_hud.dart';
import '../battle/battle_hud_parts.dart';
import '../battle/battle_layout.dart';
import '../view_models/battle_view_model.dart';

/// HUD da batalha para o CRIADOR (compartilha toda a UI com o espectador via
/// [BattleHudOverlay]); aqui entram só as ações do criador:
/// silenciar o adversário (+ indicadores), sair da batalha (desistência —
/// o criador vê o resultado) e pedir revanche.
class StreamerBattleHud extends ConsumerStatefulWidget {
  const StreamerBattleHud({
    super.key,
    required this.battleId,
    required this.myStreamerId,
    required this.myRoomId,
    this.onBattleClosed,
    this.initialCountdown,
  });

  final String battleId;
  final String myStreamerId;
  final String myRoomId;

  /// Fechar o resultado (volta para a live normal).
  final VoidCallback? onBattleClosed;

  final Map<String, dynamic>? initialCountdown;

  @override
  ConsumerState<StreamerBattleHud> createState() => _StreamerBattleHudState();
}

class _StreamerBattleHudState extends ConsumerState<StreamerBattleHud> {
  bool _isBusy = false;
  bool _muteBusy = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmAndLeave() async {
    if (_isBusy) return;
    final l10n = S.of(context);
    final cur = ref.read(battleViewModelProvider(widget.battleId)).value;
    final mine = cur?.sideOf(userId: widget.myStreamerId, roomId: widget.myRoomId);
    final streakNow = mine == null ? null : cur?.winStreakOf(mine);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1F),
        title: Text(
          l10n.battleLeaveTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          battleLeaveWarning(l10n, streakNow),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.battleCancel,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.battleLeaveConfirm,
              style: const TextStyle(
                color: kBattleText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isBusy = true);
    final notifier = ref.read(
      battleViewModelProvider(widget.battleId).notifier,
    );
    try {
      await ref.read(battleServiceProvider).endBattleEarly(widget.battleId);
    } on DioException catch (e) {
      final timeout =
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout;
      if (!timeout) {
        _snack(battleErrorText(l10n, e, fallback: l10n.battleErrEnd));
        if (mounted) setState(() => _isBusy = false);
        return;
      }
    } catch (e) {
      _snack(battleErrorText(l10n, e, fallback: l10n.battleErrEnd));
      if (mounted) setState(() => _isBusy = false);
      return;
    }
    // NÃO fecha: o `connect:battle:ended` (desistência) abre a tela de
    // resultado. Se o evento se perder, busca o resultado por REST.
    unawaited(
      Future<void>.delayed(const Duration(seconds: 3), notifier.resync),
    );
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _toggleMute(BattleState battle, String mySide) async {
    if (_muteBusy) return;
    final l10n = S.of(context);
    final next = !battle.mutedOf(mySide);
    final notifier = ref.read(
      battleViewModelProvider(widget.battleId).notifier,
    );
    setState(() => _muteBusy = true);
    // Otimista: o ícone e o áudio respondem na hora.
    notifier.applyMute(
      a: mySide == 'a' ? next : battle.mutedA,
      b: mySide == 'b' ? next : battle.mutedB,
    );
    try {
      final res = await ref
          .read(battleServiceProvider)
          .setMute(widget.battleId, next);
      if (res != null) notifier.applyMute(a: res.a, b: res.b);
    } catch (e) {
      notifier.applyMute(a: battle.mutedA, b: battle.mutedB);
      _snack(battleErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _muteBusy = false);
    }
  }

  Widget _halfOverlays(
    BuildContext context,
    BattleState battle,
    BattleLayout layout,
  ) {
    final mySide = battle.sideOf(
      userId: widget.myStreamerId,
      roomId: widget.myRoomId,
    );
    if (mySide == null) return const SizedBox.shrink();
    final composite = battle.isComposite;
    final l10n = S.of(context);
    final opp = mySide == 'a' ? 'b' : 'a';
    final iMuted = battle.mutedOf(mySide);
    final oppMutedMe = battle.mutedOf(opp);

    // Canto inferior INTERNO de uma metade: A → direita da metade; B → esquerda.
    Widget innerBottom(String side, Widget child) {
      final r = layout.half(side);
      return Positioned(
        left: side == 'b' ? r.left + 6 : null,
        right: side == 'a' ? layout.screen.width - r.right + 6 : null,
        bottom: layout.screen.height - r.bottom + 6,
        child: child,
      );
    }

    return Stack(
      children: [
        // Silenciar o adversário: botão neutro na metade DELE.
        if (composite)
          innerBottom(
            opp,
            Semantics(
              button: true,
              label: iMuted ? l10n.battleUnmuteOpponent : l10n.battleMuteOpponent,
              child: GestureDetector(
                onTap: () => _toggleMute(battle, mySide),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: battleGlass(radius: 18),
                  child: Icon(
                    iMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    size: 16,
                    color: iMuted ? kBattleTextDim : kBattleText,
                  ),
                ),
              ),
            ),
          ),
        // Linha curta (sem caixa) quando silenciei o adversário.
        if (composite && iMuted)
          Positioned(
            left: layout.half(opp).left + 6,
            width: layout.half(opp).width - 12,
            bottom: layout.screen.height - layout.half(opp).bottom + 40,
            child: IgnorePointer(
              child: Align(
                alignment: opp == 'a' ? Alignment.bottomLeft : Alignment.bottomRight,
                child: Text(
                  l10n.battleMutedLine(battle.nameOf(opp)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: opp == 'a' ? TextAlign.left : TextAlign.right,
                  style: const TextStyle(
                    color: kBattleText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        // O adversário me silenciou: linha curta na MINHA metade.
        if (composite && oppMutedMe)
          Positioned(
            left: layout.half(mySide).left + 6,
            width: layout.half(mySide).width - 12,
            bottom: layout.screen.height - layout.half(mySide).bottom + 8,
            child: IgnorePointer(
              child: Align(
                alignment: mySide == 'a' ? Alignment.bottomLeft : Alignment.bottomRight,
                child: Text(
                  l10n.battleMutedByLine(battle.nameOf(opp)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kBattleTextDim,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        // Sair da batalha (desistência): canto direito do topo da região do chat.
        Positioned(
          right: 8,
          top: layout.chat.top + 44,
          child: TextButton.icon(
            onPressed: _isBusy ? null : _confirmAndLeave,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.white70,
              backgroundColor: const Color(0xB30B0E14),
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
            label: Text(
              l10n.battleLeave,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BattleHudOverlay(
      key: ValueKey('streamer-hud-${widget.battleId}'),
      battleId: widget.battleId,
      splitTop: battleCreatorSplitTop(context),
      myUserId: widget.myStreamerId,
      myRoomId: widget.myRoomId,
      initialCountdown: widget.initialCountdown,
      onClose: () => widget.onBattleClosed?.call(),
      halfOverlays: _halfOverlays,
    );
  }
}
