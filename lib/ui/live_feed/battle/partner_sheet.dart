import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/live_room.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/view_models/follow_view_model.dart';
import '../../live/shared/widgets/hud/streamer_identity_bar.dart';

/// Gaveta do perfil do adversário/parceiro (a mesma da identidade do criador):
/// Ver perfil, Seguir e — quando [onViewLive] existe — "Ver a live".
void showPartnerSheet(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String name,
  String? avatarUrl,
  String? roomId,
  VoidCallback? onViewLive,
}) {
  if (userId.isEmpty) return;
  final isFollowing = ref.read(followViewModelProvider(userId)).value ?? false;
  final room = LiveRoom(
    id: roomId ?? '',
    slug: roomId ?? '',
    title: '',
    liveType: 'solo',
    isPrivate: false,
    status: 'live',
    viewerCount: 0,
    totalLikes: 0,
    streamerId: userId,
    streamerName: name,
    streamerAvatarUrl: avatarUrl,
  );
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => ForceDarkTheme(
      child: StreamerQuickSheet(
        room: room,
        displayName: name,
        isFollowing: isFollowing,
        onToggleFollow: () =>
            ref.read(followViewModelProvider(userId).notifier).toggleFollow(),
        onViewLive: onViewLive,
      ),
    ),
  );
}
