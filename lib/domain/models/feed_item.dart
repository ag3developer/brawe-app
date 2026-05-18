// Sealed class representing any item that can appear in the For You feed.
// Each variant carries data needed to render its specific UI.

import 'product.dart';
import 'battle_state.dart';

sealed class FeedItem {
  const FeedItem({
    required this.id,
    required this.author,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.userLiked,
    required this.userFollowingAuthor,
    required this.caption,
  });

  final String id;
  final FeedAuthor author;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool userLiked;
  final bool userFollowingAuthor;
  final String caption;
}

class FeedAuthor {
  const FeedAuthor({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
}

/// 🛍️ Live com produtos para vender.
class LiveCommerceItem extends FeedItem {
  const LiveCommerceItem({
    required super.id,
    required super.author,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.userLiked,
    required super.userFollowingAuthor,
    required super.caption,
    required this.thumbnailUrl,
    required this.viewerCount,
    required this.products,
    required this.featuredProductId,
    this.slug,
    this.streamUrl,
  });

  final String thumbnailUrl;
  final int viewerCount;
  final List<Product> products;
  final String featuredProductId; // produto em destaque agora
  final String? slug;
  final String? streamUrl;
}

/// ⚔️ Live de batalha entre dois streamers.
class LiveBattleItem extends FeedItem {
  const LiveBattleItem({
    required super.id,
    required super.author, // streamer A
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.userLiked,
    required super.userFollowingAuthor,
    required super.caption,
    required this.opponent,
    required this.thumbnailUrlA,
    required this.thumbnailUrlB,
    required this.viewerCount,
    required this.battleState,
  });

  final FeedAuthor opponent;
  final String thumbnailUrlA;
  final String thumbnailUrlB;
  final int viewerCount;
  final BattleState battleState;
}

/// 💬 Live de bate-papo.
class LiveChatItem extends FeedItem {
  const LiveChatItem({
    required super.id,
    required super.author,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.userLiked,
    required super.userFollowingAuthor,
    required super.caption,
    required this.thumbnailUrl,
    required this.viewerCount,
    required this.topic,
    this.slug,
    this.streamUrl,
  });

  final String thumbnailUrl;
  final int viewerCount;
  final String topic;
  final String? slug;
  final String? streamUrl;
}

/// 🎥 Post de vídeo (não-ao-vivo).
class VideoFeedItem extends FeedItem {
  const VideoFeedItem({
    required super.id,
    required super.author,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.userLiked,
    required super.userFollowingAuthor,
    required super.caption,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
  });

  final String videoUrl;
  final String thumbnailUrl;
  final Duration duration;
}

/// 📸 Post de foto/texto.
///
/// ⚠️ DEPRECATED no For You — desde o redesign de UX, posts de foto não
/// entram mais no feed vertical fullscreen (que é só vídeo + live).
/// Fotos vivem no /feed dedicado, renderizadas pelo `feed_screen.dart`
/// com aspect ratio respeitado + lightbox. Classe mantida para
/// compatibilidade com `for_you_screen.dart` que ainda faz exhaustive
/// switch sobre os subtipos de FeedItem.
@Deprecated('For You agora é só vídeo+live; fotos vão para o /feed dedicado.')
class PhotoPostFeedItem extends FeedItem {
  const PhotoPostFeedItem({
    required super.id,
    required super.author,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.userLiked,
    required super.userFollowingAuthor,
    required super.caption,
    this.imageUrl,
    required this.createdAt,
  });

  final String? imageUrl;
  final DateTime createdAt;
}
