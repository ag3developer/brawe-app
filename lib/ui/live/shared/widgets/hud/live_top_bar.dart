import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../domain/models/live_room.dart';
import '../../../../../ui/live_feed/view_models/live_room_comments_view_model.dart';
import '../../../../core/themes/force_dark_theme.dart';
import '../../../../core/view_models/follow_view_model.dart';
import '../competition/medal_colors.dart';
import '../sheets/gifter_ranking_sheet.dart';
import 'metric_pill.dart';
import 'streamer_identity_bar.dart';
import 'viewers_stack.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

/// 🎬 Top bar do viewer da live — linha 1 (~56 px):
/// pílula do criador (foto 36, nome 14, curtidas 12, Seguir) à esquerda;
/// à direita só 2 fotos do ranking (ouro/prata), a pílula de contagem de
/// espectadores (nunca quebra linha) e o X por último. O "⋯" (mais) vive na
/// `LiveBottomBar`. Igual em TODOS os modos (solo, conexão, batalha).
class LiveTopBar extends ConsumerWidget {
  const LiveTopBar({
    super.key,
    required this.room,
    required this.viewerCount,
    required this.likesCount,
    required this.roomId,
    required this.onBack,
    required this.onShare,
    this.recentViewerAvatars = const [],
    this.gifterRanking = const [],
    this.qualityLabel,
    this.onQualityTap,
  });
  final LiveRoom room;
  final int viewerCount;
  final int likesCount;
  final String roomId;
  final VoidCallback onBack;
  final VoidCallback onShare;

  /// Mantido por compatibilidade (não usado nesta versão do topo).
  final List<String> recentViewerAvatars;

  /// Ranking de presenteadores — passado ao sheet ao tocar.
  final List<GifterEntry> gifterRanking;

  /// Label da qualidade atual (ex: "Auto", "720p"). null = oculto.
  final String? qualityLabel;
  final VoidCallback? onQualityTap;

  static const double height = 56;

  static IconData _qualityIcon(String? label) => switch (label) {
    '480p' => LucideIcons.monitor,
    '720p HD' => LucideIcons.monitor,
    '1080p Full HD' => LucideIcons.monitor,
    _ => LucideIcons.monitor, // Auto
  };

  void _openRanking(BuildContext context) => GifterRankingSheet.show(
    context,
    roomId: roomId,
    streamerId: room.streamerId,
    ranking: gifterRanking,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing =
        ref.watch(followViewModelProvider(room.streamerId)).value ?? false;
    final top2 = gifterRanking.take(2).toList();
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Pílula do criador ─────────────────────────────────────────
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => showModalBottomSheet<void>(
                  useRootNavigator: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withValues(alpha: 0.5),
                  builder: (_) => ForceDarkTheme(
                    child: StreamerQuickSheet(
                      room: room,
                      displayName: StreamerIdentityBar.displayStreamerName(
                        room,
                      ),
                      isFollowing: isFollowing,
                      onToggleFollow: () => ref
                          .read(
                            followViewModelProvider(room.streamerId).notifier,
                          )
                          .toggleFollow(sourceRoomId: room.id),
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 6, 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF1A6DFF),
                              backgroundImage: room.streamerAvatarUrl != null
                                  ? ResizeImage(
                                      NetworkImage(room.streamerAvatarUrl!),
                                      width: context.decodePx(36),
                                    )
                                  : null,
                              child: room.streamerAvatarUrl == null
                                  ? const Icon(
                                      LucideIcons.user,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            // "+" pequeno: segue; some quando já segue.
                            if (!isFollowing)
                              Positioned(
                                right: -4,
                                bottom: -4,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => ref
                                      .read(
                                        followViewModelProvider(
                                          room.streamerId,
                                        ).notifier,
                                      )
                                      .toggleFollow(sourceRoomId: room.id),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A6DFF),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF0B0F1A),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      LucideIcons.plus,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    StreamerIdentityBar.displayStreamerName(
                                      room,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (room.streamerVerified)
                                  const VerifiedBadge(size: 13, gap: 3),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.heart,
                                  color: Color(0xFFFF3D6E),
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  MetricPill.formatCount(likesCount),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── 2 fotos do ranking (ouro/prata) ───────────────────────────
          GestureDetector(
            onTap: () => _openRanking(context),
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (top2.isEmpty)
                    const Icon(
                      LucideIcons.trophy,
                      size: 18,
                      color: Colors.white70,
                    )
                  else
                    for (var i = 0; i < top2.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1A1D2B),
                            border: Border.all(
                              color: medalColor(i + 1),
                              width: 1.8,
                            ),
                          ),
                          child: ClipOval(
                            child: top2[i].avatarUrl != null
                                ? Image.network(
                                    top2[i].avatarUrl!,
                                    cacheWidth: context.decodePx(28),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _initial(top2[i].name),
                                  )
                                : _initial(top2[i].name),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),

          // ── Contagem (NUNCA quebra linha) ─────────────────────────────
          GestureDetector(
            onTap: () => _openRanking(context),
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.eye,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ViewersStack.formatBucket(viewerCount),
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (onQualityTap != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onQualityTap,
              child: Icon(
                _qualityIcon(qualityLabel),
                color: Colors.white60,
                size: 18,
              ),
            ),
          ],

          // ── X (sair) na ponta direita ─────────────────────────────────
          GestureDetector(
            onTap: onBack,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(LucideIcons.x, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _initial(String name) => Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
