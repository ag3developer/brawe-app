import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/live_room_event.dart';
import '../../../domain/models/live_viewer_event.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../live/shared/widgets/award_badge.dart';
import '../../live/shared/widgets/level_chip.dart';
import '../view_models/live_room_comments_view_model.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// 🎮 Camada de gamificação do viewer: efeitos de entrada (fila + throttle),
/// celebração de level-up do próprio usuário e linha de sistema no chat
/// quando outro viewer sobe de nível. Tudo some quando o servidor não envia
/// os campos/eventos novos.
class ViewerGamificationLayer extends ConsumerStatefulWidget {
  const ViewerGamificationLayer({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<ViewerGamificationLayer> createState() =>
      _ViewerGamificationLayerState();
}

class _ViewerGamificationLayerState
    extends ConsumerState<ViewerGamificationLayer> {
  StreamSubscription<LiveRoomEvent>? _roomSub;

  String? get _myId => ref.read(authStateProvider).value?.id;

  @override
  void initState() {
    super.initState();
    _roomSub = ref
        .read(liveRepositoryProvider)
        .watchRoomEvents(widget.roomId)
        .listen(_onRoomEvent);
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    super.dispose();
  }

  /// Outro viewer subiu de nível → linha de sistema no chat. Entradas VIP e o
  /// meu level-up aparecem no painel de avisos (`LiveNoticeLane`), acima do
  /// chat — onde o espectador está olhando.
  void _onRoomEvent(LiveRoomEvent e) {
    if (!mounted || e.type != LiveRoomEvent.levelUpPublic) return;
    final uid = e.data['user_id']?.toString();
    if (uid != null && uid == _myId) return;
    final name = e.data['name']?.toString() ?? '';
    final level = int.tryParse('${e.data['new_level']}') ?? 0;
    if (name.isEmpty || level <= 0) return;
    ref
        .read(liveRoomCommentsViewModelProvider(widget.roomId).notifier)
        .addSystemMessage(S.of(context).liveLevelUpPublic(name, level));
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

Color _hexColor(String? hex, [Color fallback = const Color(0xFF4D90FF)]) {
  if (hex == null) return fallback;
  final c = hex.replaceAll('#', '').trim();
  if (c.length != 6) return fallback;
  final v = int.tryParse('FF$c', radix: 16);
  return v == null ? fallback : Color(v);
}

/// Cor da entrada: `entry_effect` define a paleta; senão usa a cor do badge.
Color _entryColor(LiveViewerEvent e) {
  switch (e.entryEffect) {
    case 'spark':
      return const Color(0xFF29B6F6);
    case 'shield':
      return const Color(0xFF9370DB);
    case 'fire':
      return const Color(0xFFFF5722);
    case 'galaxy':
      return const Color(0xFF5C6BC0);
    case 'crown':
      return const Color(0xFFFFC107);
    case 'epic':
      return const Color(0xFF00E5FF);
  }
  return _hexColor(e.badgeColor, const Color(0xFF4D90FF));
}

/// Toast de entrada de viewer VIP (nível >= 10 ou top 3). O #1 ganha um
/// banner maior e dourado.
class ViewerEntranceToast extends StatelessWidget {
  const ViewerEntranceToast({super.key, required this.event});

  final LiveViewerEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isTop = event.rankingPosition == 1;
    final tierName =
        event.localizedTierName(Localizations.localeOf(context).languageCode);
    final color = isTop ? const Color(0xFFFFC107) : _entryColor(event);
    final avatar = event.viewerAvatar;
    final hasAvatar = avatar != null && avatar.isNotEmpty;
    final r = isTop ? 17.0 : 12.0;

    return Container(
      padding: EdgeInsets.fromLTRB(isTop ? 8 : 6, isTop ? 8 : 5, 14, isTop ? 8 : 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isTop ? 0.95 : 0.85),
            color.withValues(alpha: isTop ? 0.55 : 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(isTop ? 26 : 20),
        border: isTop
            ? Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isTop ? 0.65 : 0.4),
            blurRadius: isTop ? 20 : 12,
            spreadRadius: isTop ? 2 : 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: r,
            backgroundColor: Colors.white24,
            backgroundImage: hasAvatar
                ? ResizeImage(NetworkImage(avatar), width: context.decodePx(r * 2))
                : null,
            child: hasAvatar
                ? null
                : Text(
                    event.viewerName.isEmpty
                        ? '?'
                        : event.viewerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTop)
                  Text(
                    l10n.liveEntranceTopOne,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LevelChip(
                      level: event.level,
                      badge: event.badgeEmoji,
                      colorHex: event.badgeColor,
                      imageUrl: event.badgeImageUrl,
                      height: 16,
                    ),
                    if (event.award != null) ...[
                      const SizedBox(width: 4),
                      AwardBadge(award: event.award!, height: 16),
                    ],
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isTop
                            ? event.viewerName
                            : l10n.liveEntranceJoined(event.viewerName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTop ? 14 : 12,
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (tierName != null)
                  Text(
                    tierName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
