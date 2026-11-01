import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/live_event.dart';
import '../../../domain/models/live_room_event.dart';
import '../../../domain/models/user_award.dart';
import '../../../domain/models/live_viewer_event.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../live/shared/layout/live_dock_metrics.dart';
import '../../live/shared/widgets/competition/medal_colors.dart' show fmtGap;
import '../../live/shared/widgets/award_badge.dart';
import '../../live/shared/widgets/level_chip.dart';
import '../../live/shared/widgets/overlays/gifts_overlay.dart';
import '../view_models/live_room_comments_view_model.dart';
import 'viewer_gamification_layer.dart' show ViewerEntranceToast;
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// 📣 Painel de avisos da live — entre o vídeo e o chat, onde o olho do
/// espectador já está (chat, sacola, rosto do criador). Tudo que é evento
/// passa por aqui, um por vez, por importância:
///
///   1. Pessoal com ação: "Fulano passou você!" + **Retomar** (abre a sacola
///      já no presente que basta).
///   2. Pessoal: "Subiu de nível!".
///   3. Sala: "Novo #1 da live", marco de curtidas.
///
/// Abaixo dos avisos, colada no chat, a faixa de entradas VIP (nível alto /
/// top 3 / o #1 chegou). Nada cobre o vídeo inteiro nem o criador.
class LiveNoticeLane extends ConsumerStatefulWidget {
  const LiveNoticeLane({
    super.key,
    required this.roomId,
    required this.streamerId,
    this.battleIdGetter,
  });

  final String roomId;
  final String streamerId;
  final String? Function()? battleIdGetter;

  @override
  ConsumerState<LiveNoticeLane> createState() => _LiveNoticeLaneState();
}

enum _Kind { overtaken, levelUp, award, newTop, milestone }

class _Notice {
  _Notice(this.kind, this.payload);

  final _Kind kind;
  final Object payload;
  final int seq = _seq++;
  static int _seq = 0;

  int get priority => _Kind.values.indexOf(kind);

  Duration get duration => switch (kind) {
    _Kind.overtaken => const Duration(seconds: 7),
    _Kind.levelUp => const Duration(milliseconds: 3500),
    _Kind.award => const Duration(seconds: 5),
    _Kind.newTop => const Duration(milliseconds: 3500),
    _Kind.milestone => const Duration(seconds: 3),
  };
}

class _LevelUp {
  const _LevelUp(this.level, this.badge, this.colorHex, this.imageUrl);
  final int level;
  final String? badge;
  final String? colorHex;
  final String? imageUrl;
}

class _LiveNoticeLaneState extends ConsumerState<LiveNoticeLane> {
  static const _maxEntrances = 5;
  static const _entranceDedup = Duration(seconds: 60);

  // Avisos
  final List<_Notice> _queue = [];
  _Notice? _current;
  Timer? _noticeTimer;
  int _lastLevel = 0;

  // Entradas VIP
  final List<LiveViewerEvent> _entrances = [];
  final Map<String, DateTime> _recentEntrances = {};
  LiveViewerEvent? _entrance;
  Timer? _entranceTimer;

  StreamSubscription<LiveViewerEvent>? _viewerSub;
  StreamSubscription<LiveRoomEvent>? _roomSub;
  StreamSubscription? _giftSub;

  String? get _myId => ref.read(authStateProvider).value?.id;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(liveRepositoryProvider);
    _viewerSub = repo.watchViewerEvents(widget.roomId).listen(_onViewer);
    _roomSub = repo.watchRoomEvents(widget.roomId).listen(_onRoomEvent);
    _giftSub = repo.watchGifts(widget.roomId).listen((gift) {
      final me = _myId;
      if (me == null || gift.senderId != me || !gift.levelUpgraded) return;
      _levelUp(
        _LevelUp(
          gift.gifterLevel,
          gift.gifterBadge,
          gift.gifterColor,
          gift.gifterImageUrl,
        ),
      );
    });
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _entranceTimer?.cancel();
    _viewerSub?.cancel();
    _roomSub?.cancel();
    _giftSub?.cancel();
    super.dispose();
  }

  // ── Fila de avisos ──────────────────────────────────────────────────────

  void _push(_Notice n) {
    if (!mounted) return;
    // Só o aviso mais recente de cada tipo importa (ex.: novo #1 em rajada).
    _queue.removeWhere((q) => q.kind == n.kind);
    _queue.add(n);
    _queue.sort(
      (a, b) => a.priority != b.priority
          ? a.priority.compareTo(b.priority)
          : a.seq.compareTo(b.seq),
    );
    final cur = _current;
    // Pessoal com ação passa na frente de aviso da sala que está na tela.
    if (cur != null && n.priority < cur.priority && n.kind == _Kind.overtaken) {
      _noticeTimer?.cancel();
      setState(() => _current = null);
    }
    _pump();
  }

  void _pump() {
    if (_current != null || _queue.isEmpty || !mounted) return;
    final next = _queue.removeAt(0);
    setState(() => _current = next);
    if (next.kind == _Kind.overtaken ||
        next.kind == _Kind.levelUp ||
        next.kind == _Kind.award) {
      HapticFeedback.mediumImpact();
    }
    _noticeTimer?.cancel();
    _noticeTimer = Timer(next.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _noticeTimer?.cancel();
    setState(() => _current = null);
    _noticeTimer = Timer(const Duration(milliseconds: 350), _pump);
  }

  void _retake(GifterOvertakenEvent e) {
    _dismiss();
    GiftsOverlay.show(
      context,
      widget.roomId,
      widget.streamerId,
      battleId: widget.battleIdGetter?.call(),
      needPoints: e.gapPoints,
    );
  }

  void _levelUp(_LevelUp l) {
    if (l.level <= 0 || l.level == _lastLevel) return;
    _lastLevel = l.level;
    _push(_Notice(_Kind.levelUp, l));
  }

  /// Evita repetir o cartão quando o mesmo `award_granted` chega por mais de
  /// uma sala/conexão.
  static String? _lastAwardKey;

  void _onAwardGranted(LiveRoomEvent e) {
    final me = _myId;
    final uid = e.data['user_id']?.toString();
    if (me != null && uid != null && uid.isNotEmpty && uid != me) return;
    final award = UserAward.tryParse(e.data['award'] ?? e.data);
    if (award == null) return;
    final key = '${award.id ?? ''}|${award.label.resolve('pt')}|${award.expiresAt}';
    if (key == _lastAwardKey) return;
    _lastAwardKey = key;
    _push(_Notice(_Kind.award, award));
  }

  void _onRoomEvent(LiveRoomEvent e) {
    if (e.type == LiveRoomEvent.awardGranted) {
      _onAwardGranted(e);
      return;
    }
    if (e.type != LiveRoomEvent.levelUp) return;
    final me = _myId;
    final uid = e.data['user_id']?.toString();
    if (me != null && uid != null && uid.isNotEmpty && uid != me) return;
    final badge = e.data['badge'];
    final b = badge is Map ? badge : const {};
    _levelUp(
      _LevelUp(
        int.tryParse('${e.data['new_level']}') ?? 0,
        b['badge']?.toString(),
        b['color']?.toString(),
        _resolveUrl(b['image_url']?.toString()),
      ),
    );
  }

  static String? _resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = raw.trim();
    if (v.startsWith('http')) return v;
    final base = AppConstants.connectApiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return v.startsWith('/') ? '$base$v' : '$base/$v';
  }

  // ── Entradas VIP ────────────────────────────────────────────────────────

  void _onViewer(LiveViewerEvent e) {
    if (!mounted || !e.isSpecialEntry || e.userId == _myId) return;
    final now = DateTime.now();
    _recentEntrances.removeWhere((_, t) => now.difference(t) > _entranceDedup);
    if (_recentEntrances.containsKey(e.userId)) return;
    _recentEntrances[e.userId] = now;
    if (e.rankingPosition == 1) {
      _entrances.insert(0, e);
    } else {
      _entrances.add(e);
    }
    while (_entrances.length > _maxEntrances) {
      _entrances.removeLast();
    }
    _pumpEntrance();
  }

  void _pumpEntrance() {
    if (_entrance != null || _entrances.isEmpty || !mounted) return;
    final next = _entrances.removeAt(0);
    final top = next.rankingPosition == 1;
    // Fila grande → passagens mais curtas para escoar.
    final ms = top ? 3200 : (_entrances.length >= 3 ? 1400 : 2200);
    setState(() => _entrance = next);
    if (top) HapticFeedback.mediumImpact();
    _entranceTimer?.cancel();
    _entranceTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      setState(() => _entrance = null);
      _entranceTimer = Timer(const Duration(milliseconds: 350), _pumpEntrance);
    });
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = liveRoomCommentsViewModelProvider(widget.roomId);
    ref.listen<GifterOvertakenEvent?>(vm.select((s) => s.overtaken), (
      prev,
      next,
    ) {
      if (next != null && next.id != prev?.id)
        _push(_Notice(_Kind.overtaken, next));
    });
    ref.listen<TopGifterChangedEvent?>(vm.select((s) => s.newTopGifter), (
      prev,
      next,
    ) {
      if (next != null && next.id != prev?.id)
        _push(_Notice(_Kind.newTop, next));
    });
    ref.listen<LikeMilestoneEvent?>(vm.select((s) => s.likeMilestone), (
      prev,
      next,
    ) {
      if (next != null && next.id != prev?.id)
        _push(_Notice(_Kind.milestone, next));
    });

    final notice = _current;
    final entrance = _entrance;
    return StageFocusDimmer(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slide(
              notice == null
                  ? const SizedBox.shrink(key: ValueKey('no-notice'))
                  : Padding(
                      key: ValueKey('notice-${notice.seq}'),
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _card(notice),
                    ),
            ),
            _slide(
              entrance == null
                  ? const SizedBox.shrink(key: ValueKey('no-entrance'))
                  : Padding(
                      key: ValueKey(
                        'entrance-${entrance.userId}-${entrance.hashCode}',
                      ),
                      padding: const EdgeInsets.only(bottom: 6),
                      child: IgnorePointer(
                        child: ViewerEntranceToast(event: entrance),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slide(Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.35, 0),
          end: Offset.zero,
        ).animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.bottomLeft,
        children: [...previous, if (current != null) current],
      ),
      child: child,
    );
  }

  Widget _card(_Notice n) {
    final s = S.of(context);
    switch (n.kind) {
      case _Kind.overtaken:
        final e = n.payload as GifterOvertakenEvent;
        return _NoticeCard(
          accent: const Color(0xFFFFB800),
          leading: _NoticeAvatar(
            url: e.byAvatarUrl,
            name: e.byName,
            ring: const Color(0xFFFFB800),
          ),
          title: s.noticeOvertakenTitle(e.byName),
          subtitle: _withMultiplier(
            s.noticeOvertakenBody(fmtGap(e.gapPoints), e.previousRank),
            e.multiplier,
          ),
          action: s.overtakenRetake,
          onAction: () => _retake(e),
          onClose: _dismiss,
          personal: true,
        );
      case _Kind.levelUp:
        final l = n.payload as _LevelUp;
        return _NoticeCard(
          accent: const Color(0xFFFFD166),
          leading: LevelChip(
            level: l.level,
            badge: l.badge,
            colorHex: l.colorHex,
            imageUrl: l.imageUrl,
            height: 22,
          ),
          title: s.liveLevelUpTitle,
          subtitle: s.noticeLevelUpBody(l.level),
          personal: true,
        );
      case _Kind.award:
        final a = n.payload as UserAward;
        return _NoticeCard(
          accent: awardColor(a.badgeColor, const Color(0xFFFFD166)),
          leading: AwardBadge(award: a, height: 30),
          title: s.awardGrantedTitle,
          subtitle: a.localizedLabel(Localizations.localeOf(context).languageCode),
          onClose: _dismiss,
          personal: true,
        );
      case _Kind.newTop:
        final e = n.payload as TopGifterChangedEvent;
        return _NoticeCard(
          accent: const Color(0xFFFFD700),
          leading: _NoticeAvatar(
            url: e.avatarUrl,
            name: e.name,
            ring: const Color(0xFFFFD700),
            badge: LucideIcons.crown,
          ),
          title: s.noticeNewTopTitle,
          subtitle: e.name,
        );
      case _Kind.milestone:
        final e = n.payload as LikeMilestoneEvent;
        return _NoticeCard(
          accent: const Color(0xFFFF3D7F),
          leading: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF3D7F), Color(0xFFFF7A59)],
              ),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          title: s.likeMilestoneBanner(fmtGap(e.milestone)),
        );
    }
  }
}

/// "texto · 2×" quando um evento multiplica os pontos.
String _withMultiplier(String text, double? multiplier) =>
    multiplier == null ? text : '$text · ${formatMultiplier(multiplier)}';

/// Cartão do aviso: vidro escuro com filete na cor do evento. Pessoal ganha
/// borda acesa (é com você) e, quando há, um botão de ação.
class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.accent,
    required this.leading,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
    this.onClose,
    this.personal = false,
  });

  final Color accent;
  final Widget leading;
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;
  final VoidCallback? onClose;
  final bool personal;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.28),
                Colors.black.withValues(alpha: 0.55),
              ],
              stops: const [0, 0.55],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: personal
                  ? accent.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.12),
              width: personal ? 1.3 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.gift,
                          size: 14,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          action!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, right: 2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.7),
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

class _NoticeAvatar extends StatelessWidget {
  const _NoticeAvatar({
    required this.url,
    required this.name,
    required this.ring,
    this.badge,
  });

  final String? url;
  final String name;
  final Color ring;
  final IconData? badge;

  @override
  Widget build(BuildContext context) {
    final has = url != null && url!.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2),
          ),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white24,
            backgroundImage: has
                ? ResizeImage(NetworkImage(url!), width: context.decodePx(30))
                : null,
            child: has
                ? null
                : Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: Center(child: Icon(badge, size: 14, color: ring)),
          ),
      ],
    );
  }
}
