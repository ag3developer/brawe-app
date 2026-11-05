import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/services/battle_service.dart';
import '../../../../data/services/link_service.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../../domain/models/live_room.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../live_feed/battle/battle_hud_parts.dart'
    show kBattleText, kBattleTextDim, kBattleInk;
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'shared/_live_overlay.dart';
import 'shared/_live_peek.dart';

/// ⚔️ Card de batalha no For You — mostra a batalha AO VIVO, não uma prévia
/// parada.
///
/// - Tempo real ligado (`rtc_mode == composite`): o HLS da sala já traz a
///   tela dividida montada no servidor → toca em tela cheia (Live Peek).
/// - Sem tempo real (`dual_hls`): metade A toca o stream da sala; metade B
///   mostra a foto do adversário (dois áudios ao mesmo tempo atrapalham).
/// - Estilo aprovado (contrato §16): base neutra; azul/laranja só na barra;
///   placar inteiro dentro da barra; cronômetro em pílula sobre a divisória.
/// - Tap em qualquer lugar entra na live.
class LiveBattleView extends ConsumerStatefulWidget {
  const LiveBattleView({super.key, required this.item, this.isActive = true});
  final LiveBattleItem item;
  final bool isActive;

  @override
  ConsumerState<LiveBattleView> createState() => _LiveBattleViewState();
}

class _LiveBattleViewState extends ConsumerState<LiveBattleView> {
  LiveBattleItem get item => widget.item;

  /// Dados REAIS de `/battle/active`. `null` enquanto não carregou.
  int? _scoreA;
  int? _scoreB;

  /// A sala do card é o lado B da batalha? (§18.1: o dono do card fica à
  /// esquerda/azul; os dados continuam em A/B.)
  bool _ownIsB = false;

  /// URL de baixa latência da conexão (§18.2), se houver.
  String? _llUrl;
  String? _rtcMode;
  DateTime? _endsAt;
  Duration _serverOffset = Duration.zero;
  Duration? _remaining;
  Timer? _tick;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _syncPolling();
  }

  @override
  void didUpdateWidget(covariant LiveBattleView old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) _syncPolling();
  }

  /// Placar atualiza a cada 5s só enquanto o card está na tela.
  void _syncPolling() {
    _poll?.cancel();
    if (widget.isActive) {
      _poll = Timer.periodic(const Duration(seconds: 5), (_) => _load());
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  static DateTime? _ts(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    final hasTz = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(v);
    return DateTime.tryParse(hasTz ? v : '${v}Z')?.toUtc();
  }

  Future<void> _load() async {
    try {
      final d = await ref
          .read(battleServiceProvider)
          .getActiveBattleForRoom(item.id);
      if (!mounted) return;
      final a = d['streamer_a'] is Map ? d['streamer_a'] as Map : const {};
      final b = d['streamer_b'] is Map ? d['streamer_b'] as Map : const {};
      final sa = (d['score_a'] as num?) ?? (a['score'] as num?);
      final sb = (d['score_b'] as num?) ?? (b['score'] as num?);
      final roomB = d['room_b_id']?.toString() ?? b['room_id']?.toString();
      final roomA = d['room_a_id']?.toString() ?? a['room_id']?.toString();
      final ownIsB =
          d['owner_left'] == true && roomB == item.id && roomA != item.id;
      final now = _ts(d['server_now']);
      final ends = _ts(d['ends_at']);
      final left = (d['time_remaining_seconds'] as num?)?.toInt();
      setState(() {
        _scoreA = (sa ?? 0).round();
        _scoreB = (sb ?? 0).round();
        _ownIsB = ownIsB;
        _rtcMode = d['rtc_mode']?.toString();
        if (now != null) {
          _serverOffset = now.difference(DateTime.now().toUtc());
        }
        _endsAt = ends ??
            (left != null
                ? DateTime.now().toUtc().add(
                    _serverOffset + Duration(seconds: left),
                  )
                : null);
      });
      _updateRemaining();
      unawaited(_loadLink());
      _tick ??= _endsAt == null
          ? null
          : Timer.periodic(
              const Duration(seconds: 1),
              (_) => _updateRemaining(),
            );
    } catch (_) {
      // Sem dados reais (batalha acabou / rede): segue sem placar e timer.
    }
  }

  /// Prefere a stream LL-HLS enquanto a sala está numa conexão (§18.2).
  Future<void> _loadLink() async {
    try {
      final l = await ref.read(linkServiceProvider).getActive(item.id);
      final side = l?.sideOf(roomId: item.id);
      final url = (l != null && l.isActive && side != null)
          ? l.playbackOf(side)
          : null;
      if (mounted && url != _llUrl) setState(() => _llUrl = url);
    } catch (_) {
      // Sem conexão / tempo real desligado: segue com a URL normal.
    }
  }

  void _updateRemaining() {
    final e = _endsAt;
    if (e == null || !mounted) return;
    final ms = e
        .difference(DateTime.now().toUtc().add(_serverOffset))
        .inMilliseconds;
    setState(
      () => _remaining = ms <= 0
          ? Duration.zero
          : Duration(seconds: (ms / 1000).ceil()),
    );
  }

  void _enter() {
    final room = LiveRoom(
      id: item.id,
      slug: item.slug ?? item.id,
      title: item.caption,
      liveType: 'battle',
      isPrivate: false,
      status: 'live',
      viewerCount: item.viewerCount,
      totalLikes: item.likesCount,
      thumbnailUrl: item.thumbnailUrlA,
      streamUrl: item.streamUrl,
      streamerId: item.author.id,
      streamerName: item.author.name,
      streamerAvatarUrl: item.author.avatarUrl,
      streamerUsername: item.author.username,
      streamerVerified: item.author.isVerified,
    );
    openLiveRoom(context, item.id, room);
  }

  @override
  Widget build(BuildContext context) {
    final composite = _rtcMode == 'composite';
    final topPad = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enter,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0B0E14)),

          // ── Vídeo ao vivo ─────────────────────────────────────────────
          if (composite)
            LivePeekBackground(
              roomId: item.id,
              thumbnailUrl: item.thumbnailUrlA,
              streamUrl: _llUrl ?? item.streamUrl,
              isActive: widget.isActive,
            )
          else
            Row(
              children: [
                Expanded(
                  child: ClipRect(
                    child: LivePeekBackground(
                      roomId: item.id,
                      thumbnailUrl: item.thumbnailUrlA,
                      streamUrl: _llUrl ?? item.streamUrl,
                      isActive: widget.isActive,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _OpponentHalf(
                    imageUrl: item.thumbnailUrlB,
                    avatarUrl: item.opponent.avatarUrl,
                    name: item.opponent.name,
                  ),
                ),
              ],
            ),

          // ── Gradiente inferior para legibilidade ──────────────────────
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 260,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xD90B0E14)],
                  ),
                ),
              ),
            ),
          ),

          // ── AO VIVO · BATALHA ─────────────────────────────────────────
          Positioned(
            top: topPad + 56,
            left: 16,
            child: LiveBadge(
              viewerCount: item.viewerCount,
              label: S.of(context).liveBadgeBattle,
            ),
          ),

          // ── Rodapé: barra de placar + nomes + entrar ──────────────────
          Positioned(
            left: 16,
            right: 88, // espaço do ActionRail
            bottom: 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_remaining != null) ...[
                  _TimerPill(remaining: _remaining!),
                  const SizedBox(height: 8),
                ],
                _ScoreBar(
                  ownScore: _ownIsB ? _scoreB : _scoreA,
                  partnerScore: _ownIsB ? _scoreA : _scoreB,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Name(
                        name: item.author.name,
                        avatarUrl: item.author.avatarUrl,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Name(
                        name: item.opponent.name,
                        avatarUrl: item.opponent.avatarUrl,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                if (item.caption.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kBattleText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                WatchLiveButton(onTap: _enter),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Metade B sem vídeo (modo sem tempo real): foto do adversário.
class _OpponentHalf extends StatelessWidget {
  const _OpponentHalf({
    required this.imageUrl,
    required this.avatarUrl,
    required this.name,
  });
  final String imageUrl;
  final String? avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final img = imageUrl.isNotEmpty ? imageUrl : (avatarUrl ?? '');
    if (img.isEmpty) {
      return ColoredBox(
        color: const Color(0xFF161B25),
        child: Center(
          child: Text(
            name.isNotEmpty ? name.characters.first.toUpperCase() : '',
            style: const TextStyle(
              color: kBattleTextDim,
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    return Image.network(
      img,
      fit: BoxFit.cover,
      cacheWidth: context.decodeScreenFracPx(0.5),
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF161B25)),
    );
  }
}

/// Barra estilo TikTok: dono do card (esquerda, azul) × parceiro (direita,
/// laranja), placar inteiro dentro (§18.1).
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.ownScore, required this.partnerScore});
  final int? ownScore;
  final int? partnerScore;

  @override
  Widget build(BuildContext context) {
    final a = ownScore ?? 0;
    final b = partnerScore ?? 0;
    final total = a + b;
    final fracA = total == 0 ? 0.5 : (a / total).clamp(0.12, 0.88);
    const tab = [FontFeature.tabularFigures()];
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            Expanded(
              flex: (fracA * 1000).round(),
              child: Container(
                color: AppColors.braweBlue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  ownScore == null ? '' : '$a',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFeatures: tab,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: ((1 - fracA) * 1000).round(),
              child: Container(
                color: AppColors.braweOrange,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  partnerScore == null ? '' : '$b',
                  style: const TextStyle(
                    color: kBattleInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFeatures: tab,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final m = remaining.inMinutes.toString().padLeft(2, '0');
    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xB30B0E14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$m:$s',
        style: const TextStyle(
          color: kBattleText,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _Name extends StatelessWidget {
  const _Name({required this.name, this.avatarUrl, this.alignEnd = false});
  final String name;
  final String? avatarUrl;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 12,
      backgroundColor: const Color(0xFF1C2230),
      backgroundImage: (avatarUrl?.isNotEmpty ?? false)
          ? NetworkImage(avatarUrl!)
          : null,
    );
    final label = Flexible(
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: const TextStyle(
          color: kBattleText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
        ),
      ),
    );
    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: alignEnd
          ? [label, const SizedBox(width: 6), avatar]
          : [avatar, const SizedBox(width: 6), label],
    );
  }
}
