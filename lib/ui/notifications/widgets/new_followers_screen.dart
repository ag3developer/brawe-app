import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/notifications_repository.dart';
import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/image_decode.dart';

/// Quem entrou num grupo de notificação (ex.: novos seguidores do dia).
final notificationActorsProvider = FutureProvider.autoDispose
    .family<List<NotifActor>, String>(
      (ref, id) => ref.read(notificationsRepositoryProvider).actors(id),
    );

/// Lista dos novos seguidores de um grupo `follow:{user}:{dia}`.
class NewFollowersScreen extends ConsumerWidget {
  const NewFollowersScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(notificationActorsProvider(notificationId));
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          s.notifNewFollowersTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.notificationsLoadError),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(notificationActorsProvider(notificationId)),
                child: Text(s.notificationsTryAgain),
              ),
            ],
          ),
        ),
        data: (actors) => actors.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    s.notifNewFollowersEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: actors.length,
                itemBuilder: (_, i) => FollowerRow(
                  actor: actors[i],
                  onTap: () => context.push('/profile/${actors[i].id}'),
                ),
              ),
      ),
    );
  }
}

class FollowerRow extends StatelessWidget {
  const FollowerRow({super.key, required this.actor, required this.onTap});

  final NotifActor actor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasAvatar = actor.avatar != null && actor.avatar!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipOval(
              child: hasAvatar
                  ? CachedNetworkImage(
                      memCacheWidth: context.decodePx(44),
                      imageUrl: actor.avatar!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _fallback(colors),
                    )
                  : _fallback(colors),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                actor.name.isEmpty ? '?' : actor.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _fallback(BraweColors colors) => Container(
    width: 44,
    height: 44,
    color: colors.surfaceHighest,
    alignment: Alignment.center,
    child: Icon(LucideIcons.user, size: 20, color: colors.textTertiary),
  );
}
