import 'package:intl/intl.dart';

import '../../domain/models/app_notification.dart';
import '../../gen/l10n/app_localizations.dart';

/// Filtros (chips) da central de notificações.
enum NotifFilter { all, likes, comments, followers, gifts, mentions, brawe }

/// Seções por data.
enum NotifBucket { today, week, older }

/// Tipo de evento agrupável (espelha `KINDS` do backend).
enum NotifKind { like, comment, reply, follow, gift, mention, storyReaction }

/// Regras puras (testáveis) de apresentação da central de notificações.
class NotifPresentation {
  const NotifPresentation._();

  static NotifKind? kindOf(AppNotification n) {
    final key = n.groupKey ?? '';
    if (key.startsWith('like:')) return NotifKind.like;
    if (key.startsWith('comment:')) return NotifKind.comment;
    if (key.startsWith('reply:')) return NotifKind.reply;
    if (key.startsWith('follow:')) return NotifKind.follow;
    if (key.startsWith('gift:')) return NotifKind.gift;
    if (key.startsWith('mention:')) return NotifKind.mention;
    if (key.startsWith('story_reaction:')) return NotifKind.storyReaction;
    switch (n.type) {
      case 'post_liked':
      case 'like':
        return NotifKind.like;
      case 'post_commented':
      case 'comment':
        return NotifKind.comment;
      case 'comment_replied':
      case 'reply':
        return NotifKind.reply;
      case 'follow':
        return NotifKind.follow;
      case 'gift_received':
      case 'gift':
        return NotifKind.gift;
      case 'comment_mention':
        return NotifKind.mention;
      case 'story_reaction':
        return NotifKind.storyReaction;
    }
    return null;
  }

  /// Chip em que a notificação aparece (além de "Tudo"); `null` = só em "Tudo"
  /// (lives, novos posts, mensagens, convites de batalha).
  static NotifFilter? filterOf(AppNotification n) {
    final kind = n.data?['kind']?.toString() ?? '';
    if (kind.contains('quest')) return NotifFilter.brawe;
    switch (n.type) {
      case 'post_liked':
      case 'like':
      case 'story_reaction':
        return NotifFilter.likes;
      case 'post_commented':
      case 'comment':
      case 'comment_replied':
      case 'reply':
      case 'story_reply':
        return NotifFilter.comments;
      case 'follow':
        return NotifFilter.followers;
      case 'gift_received':
      case 'gift':
      case 'mystery_gift_received':
      case 'mystery_gift_revealed':
        return NotifFilter.gifts;
      case 'comment_mention':
        return NotifFilter.mentions;
      case 'live_start':
      case 'live_started':
      case 'live_starting':
      case 'battle_invite':
      case 'mystery_gifter_live':
      case 'new_post':
      case 'message':
      case 'new_message':
        return null;
      default:
        return NotifFilter.brawe; // system, purchase, quest, award, creator…
    }
  }

  static bool matches(NotifFilter f, AppNotification n) =>
      f == NotifFilter.all || filterOf(n) == f;

  static NotifBucket bucketOf(DateTime? dt, DateTime now) {
    if (dt == null) return NotifBucket.older;
    final today = DateTime(now.year, now.month, now.day);
    final local = dt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return NotifBucket.today;
    if (diff < 7) return NotifBucket.week;
    return NotifBucket.older;
  }

  /// Seguidores novos agrupados: toque abre a lista de quem seguiu.
  static bool isFollowGroup(AppNotification n) =>
      kindOf(n) == NotifKind.follow && n.actorsCount > 1;

  /// Texto resumido ("Ana, Bruno e mais 12 curtiram seu post"). Notificações
  /// sem agrupamento (backend antigo / outros tipos) usam o título do servidor.
  static String title(S s, AppNotification n) {
    final kind = kindOf(n);
    if (kind == null || !n.isGrouped || n.actors.isEmpty) return n.title;
    final names = [
      for (final a in n.actors) a.name.trim().isEmpty ? '?' : a.name.trim(),
    ];
    final total = n.actorsCount < names.length ? names.length : n.actorsCount;
    final String who;
    if (total <= 1) {
      who = names[0];
    } else if (total == 2 && names.length >= 2) {
      who = s.notifActorsTwo(names[0], names[1]);
    } else if (total == 3 && names.length >= 3) {
      who = s.notifActorsThree(names[0], names[1], names[2]);
    } else if (names.length >= 2) {
      who = s.notifActorsMore(names[0], names[1], total - 2);
    } else {
      return n.title;
    }
    final verb = switch (kind) {
      NotifKind.like => s.notifVerbLike(total),
      NotifKind.comment => s.notifVerbComment(total),
      NotifKind.reply => s.notifVerbReply(total),
      NotifKind.follow => s.notifVerbFollow(total),
      NotifKind.gift => s.notifVerbGift(total),
      NotifKind.mention => s.notifVerbMention(total),
      NotifKind.storyReaction => s.notifVerbStoryReaction(total),
    };
    var out = '$who $verb';
    if (kind == NotifKind.gift && n.groupValue > 0) {
      final f = NumberFormat.decimalPattern(s.localeName).format(n.groupValue);
      out += ' ${s.notifGiftDiamonds(n.groupValue, f)}';
    }
    return out;
  }
}
