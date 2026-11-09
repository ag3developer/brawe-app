import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/text/brawe_rich_text.dart';
import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../data/services/privacy_ux_service.dart';
import '../../core/view_models/follow_view_model.dart';
import '../notification_presentation.dart';

/// Até 3 avatares empilhados (cascata diagonal) numa caixa fixa de 52x48.
/// Com 1 ator mostra o avatar grande + selo do tipo; sem foto, o ícone do tipo.
class NotificationAvatars extends StatelessWidget {
  const NotificationAvatars({
    super.key,
    required this.actors,
    required this.icon,
    required this.color,
  });

  final List<NotifActor> actors;
  final IconData icon;
  final Color color;

  static const double width = 52;
  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = actors.take(3).toList();

    Widget typeIcon(double size, double iconSize) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: 0.16),
          colors.background,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: iconSize),
    );

    Widget avatar(NotifActor a, double size) {
      final url = a.avatar;
      if (url == null || url.isEmpty) return typeIcon(size, size * 0.46);
      return ClipOval(
        child: CachedNetworkImage(
          memCacheWidth: context.decodePx(size),
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, _) => typeIcon(size, size * 0.46),
          errorWidget: (_, _, _) => typeIcon(size, size * 0.46),
        ),
      );
    }

    Widget ringed(Widget child, double size) => Container(
      width: size + 4,
      height: size + 4,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
      ),
      child: child,
    );

    if (shown.length <= 1) {
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 2,
              top: 0,
              child: shown.isEmpty ? typeIcon(48, 22) : avatar(shown.first, 48),
            ),
            if (shown.isNotEmpty &&
                shown.first.avatar != null &&
                shown.first.avatar!.isNotEmpty)
              Positioned(
                left: 36,
                top: 33,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.background, width: 2),
                  ),
                  child: Icon(icon, size: 11, color: colors.textOnAccent),
                ),
              ),
          ],
        ),
      );
    }

    final two = shown.length == 2;
    final size = two ? 32.0 : 28.0;
    final positions = two
        ? const [Offset(0, 0), Offset(18, 14)]
        : const [Offset(0, 0), Offset(22, 2), Offset(11, 20)];
    // Desenha do último para o primeiro: o mais recente (índice 0) fica em cima.
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = shown.length - 1; i >= 0; i--)
            Positioned(
              left: positions[i].dx,
              top: positions[i].dy,
              child: ringed(avatar(shown[i], size), size),
            ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final n = notification;
    final unread = !n.isRead;
    final (icon, color) = iconFor(n, colors);
    final xp = (n.data?['xp_reward'] as num?)?.toInt();
    final hasThumb = n.thumbnailUrl != null && n.thumbnailUrl!.isNotEmpty;
    final title = NotifPresentation.title(s, n);
    final (who, rest) = NotifPresentation.titleParts(s, n);

    final actors = n.actors.isNotEmpty
        ? n.actors
        : [
            NotifActor(
              id: n.actorId ?? '',
              name: n.actorName ?? '',
              avatar: n.actorAvatar,
            ),
          ];

    final kind = NotifPresentation.kindOf(n);
    final followActor =
        kind == NotifKind.follow &&
            n.actorsCount <= 1 &&
            actors.length == 1 &&
            actors.first.id.isNotEmpty
        ? actors.first.id
        : null;

    final nameStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    );
    final bodyStyle = TextStyle(
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
    );

    final isRequest =
        NotifPresentation.followKind(n) == 'follow_request' &&
        actors.isNotEmpty &&
        actors.first.id.isNotEmpty;

    final Widget trailing;
    if (isRequest) {
      trailing = const SizedBox.shrink();
    } else if (followActor != null) {
      trailing = _FollowBackButton(userId: followActor);
    } else if (xp != null && xp > 0) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.accentGold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '+$xp XP',
          style: TextStyle(
            color: colors.accentGold,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    } else if (hasThumb) {
      trailing = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          key: const ValueKey('notif-thumb'),
          memCacheWidth: context.decodePx(44),
          imageUrl: n.thumbnailUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, _) =>
              Container(width: 44, height: 44, color: colors.surfaceHighest),
          errorWidget: (_, _, _) =>
              Container(width: 44, height: 44, color: colors.surfaceHighest),
        ),
      );
    } else {
      trailing = _PillButton(label: s.notifActionView, onTap: onTap);
    }

    return Semantics(
      container: true,
      label: unread ? '${s.notifUnreadLabel}. $title' : title,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NotificationAvatars(actors: actors, icon: icon, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              ..._titleSpans(
                                n,
                                who,
                                rest,
                                nameStyle,
                                bodyStyle,
                              ),
                              if (n.createdAt != null)
                                TextSpan(
                                  text: '  ${timeAgo(context, n.createdAt!)}',
                                  style: TextStyle(
                                    color: colors.textTertiary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        if (isRequest)
                          _FollowRequestActions(
                            requesterId: actors.first.id,
                            notificationId: n.id,
                          ),
                        if (n.message.isNotEmpty && !isRequest) ...[
                          const SizedBox(height: 2),
                          Text(
                            BraweRichText.humanize(
                              n.message,
                              sharedPostLabel: s.linkSharedPost,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  trailing,
                ],
              ),
            ),
            if (unread)
              Positioned(
                left: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    key: const ValueKey('notif-unread-dot'),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.accentPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Nome em negrito (com selo de verificado) + ação em peso normal.
  List<InlineSpan> _titleSpans(
    AppNotification n,
    String who,
    String rest,
    TextStyle nameStyle,
    TextStyle bodyStyle,
  ) {
    if (who.isEmpty) {
      return [
        TextSpan(text: rest, style: bodyStyle),
        if (n.actorIsVerified) VerifiedBadge.span(size: 13, gap: 3),
      ];
    }
    return [
      TextSpan(text: who, style: nameStyle),
      if (n.actorIsVerified && n.actorsCount <= 1)
        VerifiedBadge.span(size: 13, gap: 3),
      if (rest.isNotEmpty) TextSpan(text: ' $rest', style: bodyStyle),
    ];
  }

  static (IconData, Color) iconFor(AppNotification n, BraweColors c) {
    if (NotifPresentation.filterOf(n) == NotifFilter.brawe &&
        (n.type == 'system' ||
            n.type == 'quest' ||
            n.type == 'quest_completed')) {
      return (LucideIcons.trophy, c.accentGold);
    }
    switch (n.type) {
      case 'follow':
        return (LucideIcons.userPlus, c.accentPrimary);
      case 'like':
      case 'post_liked':
      case 'story_reaction':
        return (LucideIcons.heart, c.accentPink);
      case 'comment':
      case 'post_commented':
      case 'story_reply':
        return (LucideIcons.messageCircle, c.accentSecondary);
      case 'reply':
      case 'comment_replied':
        return (LucideIcons.cornerUpLeft, c.accentSecondary);
      case 'comment_mention':
        return (LucideIcons.atSign, c.accentPrimary);
      case 'gift':
      case 'gift_received':
      case 'mystery_gift_received':
      case 'mystery_gift_revealed':
        return (LucideIcons.gift, c.accentGold);
      case 'live_start':
      case 'live_started':
      case 'mystery_gifter_live':
        return (LucideIcons.radio, c.danger);
      case 'live_starting':
        return (LucideIcons.clock, c.warning);
      case 'message':
      case 'new_message':
        return (LucideIcons.messageSquare, c.accentSecondary);
      case 'quest_reminder':
        return (LucideIcons.target, c.accentGold);
      case 'new_post':
        return (LucideIcons.image, c.accentPrimary);
      case 'purchase':
        return (LucideIcons.shoppingBag, c.success);
      case 'battle_invite':
        return (LucideIcons.swords, c.danger);
      case 'creator_approved':
        return (LucideIcons.badgeCheck, c.accentPrimary);
      case 'award_received':
        return (LucideIcons.award, c.accentGold);
      case 'creator_level_up':
        return (LucideIcons.trendingUp, c.success);
      default:
        return (LucideIcons.bell, c.textTertiary);
    }
  }

  static String timeAgo(BuildContext context, DateTime dt) {
    final s = S.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return s.notificationsTimeNow;
    if (diff.inMinutes < 60) return s.notificationsTimeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return s.notificationsTimeHours(diff.inHours);
    if (diff.inDays < 7) return s.notificationsTimeDays(diff.inDays);
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

/// Botão compacto de contorno suave ("Ver").
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120, minHeight: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? colors.accentPrimary : colors.surfaceHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: filled ? colors.textOnAccent : colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Seguir de volta" / "Seguindo" usando o mesmo view model do resto do app.
class _FollowBackButton extends ConsumerWidget {
  const _FollowBackButton({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final state = ref.watch(followViewModelProvider(userId));
    if (state.isLoading) {
      return _PillButton(label: s.notifFollowBack, onTap: null);
    }
    final following = state.value ?? false;
    return _PillButton(
      label: following ? s.actionUnfollow : s.notifFollowBack,
      filled: !following,
      onTap: () =>
          ref.read(followViewModelProvider(userId).notifier).toggleFollow(),
    );
  }
}

/// Confirmar / Excluir um pedido para seguir, direto na linha.
class _FollowRequestActions extends ConsumerStatefulWidget {
  const _FollowRequestActions({
    required this.requesterId,
    required this.notificationId,
  });

  final String requesterId;
  final String notificationId;

  @override
  ConsumerState<_FollowRequestActions> createState() =>
      _FollowRequestActionsState();
}

class _FollowRequestActionsState extends ConsumerState<_FollowRequestActions> {
  bool _busy = false;
  bool? _accepted; // null = pendente

  Future<void> _answer(bool accept) async {
    if (_busy) return;
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final svc = ref.read(privacyUxServiceProvider);
      if (accept) {
        await svc.acceptRequest(widget.requesterId);
      } else {
        await svc.declineRequest(widget.requesterId);
      }
      ref.invalidate(pendingFollowRequestsProvider);
      if (!mounted) return;
      setState(() {
        _accepted = accept;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(s.relActionError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    if (_accepted != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          _accepted! ? s.privUxRequestAccepted : s.privUxRequestDeclined,
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _PillButton(
            label: s.privUxConfirm,
            filled: true,
            onTap: _busy ? null : () => _answer(true),
          ),
          const SizedBox(width: 8),
          _PillButton(
            label: s.privUxDelete,
            filled: false,
            onTap: _busy ? null : () => _answer(false),
          ),
        ],
      ),
    );
  }
}
