import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/text/brawe_rich_text.dart';
import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
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
      decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle),
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
                  child: Icon(icon, size: 11, color: Colors.white),
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
    final (icon, color) = iconFor(n);
    final xp = (n.data?['xp_reward'] as num?)?.toInt();
    final grouped = n.isGrouped && NotifPresentation.kindOf(n) != null;
    final hasThumb = n.thumbnailUrl != null && n.thumbnailUrl!.isNotEmpty;
    final title = NotifPresentation.title(s, n);
    final style = TextStyle(
      fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
    );

    final actors = n.actors.isNotEmpty
        ? n.actors
        : [NotifActor(id: n.actorId ?? '', name: n.actorName ?? '', avatar: n.actorAvatar)];

    return Semantics(
      container: true,
      label: unread ? '${s.notifUnreadLabel}. $title' : title,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: unread
              ? colors.accentPrimary.withValues(alpha: 0.06)
              : Colors.transparent,
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationAvatars(actors: actors, icon: icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: grouped
                            ? [TextSpan(text: title, style: style)]
                            : _titleSpans(n, style),
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    if (n.message.isNotEmpty) ...[
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
                    if (n.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        timeAgo(context, n.createdAt!),
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (xp != null && xp > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+$xp XP',
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else ...[
                if (hasThumb)
                  ClipRRect(
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
                  ),
                if (unread)
                  Padding(
                    padding: EdgeInsets.only(left: hasThumb ? 8 : 0, top: 6),
                    child: Container(
                      key: const ValueKey('notif-unread-dot'),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: colors.accentPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Título com o selo de verificado logo após o nome do autor.
  List<InlineSpan> _titleSpans(AppNotification n, TextStyle style) {
    if (!n.actorIsVerified) return [TextSpan(text: n.title, style: style)];
    final name = n.actorName?.trim() ?? '';
    if (name.isNotEmpty && n.title.startsWith(name)) {
      return [
        TextSpan(text: name, style: style),
        VerifiedBadge.span(size: 13, gap: 3),
        TextSpan(text: n.title.substring(name.length), style: style),
      ];
    }
    return [
      TextSpan(text: n.title, style: style),
      VerifiedBadge.span(size: 13, gap: 3),
    ];
  }

  static (IconData, Color) iconFor(AppNotification n) {
    if (NotifPresentation.filterOf(n) == NotifFilter.brawe &&
        (n.type == 'system' ||
            n.type == 'quest' ||
            n.type == 'quest_completed')) {
      return (LucideIcons.trophy, const Color(0xFFF59E0B));
    }
    switch (n.type) {
      case 'follow':
        return (LucideIcons.userPlus, const Color(0xFF3B82F6));
      case 'like':
      case 'post_liked':
      case 'story_reaction':
        return (LucideIcons.heart, const Color(0xFFEF4444));
      case 'comment':
      case 'post_commented':
      case 'story_reply':
        return (LucideIcons.messageCircle, const Color(0xFF0EA5E9));
      case 'reply':
      case 'comment_replied':
        return (LucideIcons.cornerUpLeft, const Color(0xFF0EA5E9));
      case 'comment_mention':
        return (LucideIcons.atSign, const Color(0xFF8B5CF6));
      case 'gift':
      case 'gift_received':
      case 'mystery_gift_received':
      case 'mystery_gift_revealed':
        return (LucideIcons.gift, const Color(0xFFF59E0B));
      case 'live_start':
      case 'live_started':
      case 'mystery_gifter_live':
        return (LucideIcons.radio, const Color(0xFFEF4444));
      case 'live_starting':
        return (LucideIcons.clock, const Color(0xFFF97316));
      case 'message':
      case 'new_message':
        return (LucideIcons.messageSquare, const Color(0xFF0EA5E9));
      case 'quest_reminder':
        return (LucideIcons.target, const Color(0xFFF59E0B));
      case 'new_post':
        return (LucideIcons.image, const Color(0xFF8B5CF6));
      case 'purchase':
        return (LucideIcons.shoppingBag, const Color(0xFF10B981));
      case 'battle_invite':
        return (LucideIcons.swords, const Color(0xFFEF4444));
      case 'creator_approved':
        return (LucideIcons.badgeCheck, const Color(0xFF3B82F6));
      case 'award_received':
        return (LucideIcons.award, const Color(0xFFF59E0B));
      case 'creator_level_up':
        return (LucideIcons.trendingUp, const Color(0xFF10B981));
      default:
        return (LucideIcons.bell, const Color(0xFF64748B));
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
