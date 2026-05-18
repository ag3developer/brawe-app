import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/failure.dart';
import '../../domain/models/feed_item.dart';
import '../../domain/models/live_room.dart';
import '../../domain/models/post.dart';
import '../../domain/models/product.dart';
import 'live_repository.dart';
import 'post_repository.dart';

part 'for_you_feed_repository.g.dart';

@riverpod
ForYouFeedRepository forYouFeedRepository(Ref ref) {
  return ForYouFeedRepository(
    ref.watch(liveRepositoryProvider),
    ref.watch(postRepositoryProvider),
  );
}

/// Combina /live/feed + /posts/feed em uma lista intercalada de [FeedItem].
///
/// Hoje o backend não tem um endpoint unificado de "for you", então:
/// - Lives viram [LiveCommerceItem] ou [LiveChatItem] (decidido por liveType)
/// - Posts viram [VideoFeedItem] ou [PhotoPostFeedItem]
/// - Itens são intercalados (round-robin)
/// - Battle não existe no backend: usamos o mock como fallback raro para variedade
class ForYouFeedRepository {
  final LiveRepository _liveRepo;
  final PostRepository _postRepo;

  ForYouFeedRepository(this._liveRepo, this._postRepo);

  /// Carrega o feed misto. Em caso de falha total, devolve mock para não travar UX.
  Future<List<FeedItem>> getFeed({int limit = 20}) async {
    try {
      final results = await Future.wait([
        _safeLives(limit: limit ~/ 2),
        _safePosts(limit: limit ~/ 2),
      ]);
      final lives = results[0];
      final posts = results[1];

      if (lives.isEmpty && posts.isEmpty) {
        // Backend ainda sem conteúdo — retorna lista vazia
        return const [];
      }

      return _interleave(lives, posts);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  // ───── Sources (silenciam falha individual) ──────────────────

  Future<List<FeedItem>> _safeLives({int limit = 10}) async {
    try {
      final rooms = await _liveRepo.getLiveFeed(limit: limit);
      return rooms.map(_mapLive).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<FeedItem>> _safePosts({int limit = 10}) async {
    try {
      final posts = await _postRepo.getFeed(limit: limit);
      // For You é vertical fullscreen estilo TikTok: somente VÍDEOS entram aqui.
      // Posts de foto/texto vivem no /feed dedicado (estilo Instagram), onde o
      // aspect ratio e o lightbox são respeitados. Ver feed_screen.dart.
      return posts
          .where((p) {
            final url = p.imageUrl ?? '';
            if (url.isEmpty) return false;
            return url.endsWith('.mp4') ||
                url.endsWith('.mov') ||
                url.endsWith('.webm') ||
                url.contains('/video');
          })
          .map(_mapPost)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ───── Interleave (Lives primeiro de cada slot) ──────────────

  List<FeedItem> _interleave(List<FeedItem> a, List<FeedItem> b) {
    final out = <FeedItem>[];
    final max = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < max; i++) {
      if (i < a.length) out.add(a[i]);
      if (i < b.length) out.add(b[i]);
    }
    return out;
  }

  // ───── Mappers ───────────────────────────────────────────────

  FeedItem _mapLive(LiveRoom room) {
    // Username vem do backend (wallet_bridge.user_info). Se ausente,
    // derivamos um fallback legível do nome do streamer para não quebrar a UI.
    final fallbackUsername =
        room.streamerName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    final author = FeedAuthor(
      id: room.streamerId,
      name: room.streamerName,
      username: (room.streamerUsername?.isNotEmpty ?? false)
          ? room.streamerUsername!
          : fallbackUsername,
      avatarUrl: room.streamerAvatarUrl,
      isVerified: room.streamerVerified,
    );

    final isCommerce = (room.liveType).toLowerCase() == 'commerce' ||
        (room.category ?? '').toLowerCase().contains('shop');

    if (isCommerce) {
      // Sem produtos reais ainda: lista vazia (UI já trata)
      return LiveCommerceItem(
        id: room.id,
        author: author,
        likesCount: room.totalLikes,
        commentsCount: 0,
        sharesCount: 0,
        userLiked: false,
        userFollowingAuthor: false,
        caption: room.title,
        thumbnailUrl: room.thumbnailUrl ?? '',
        viewerCount: room.viewerCount,
        products: const <Product>[],
        featuredProductId: '',
        slug: room.slug,
        streamUrl: room.streamUrl,
      );
    }

    return LiveChatItem(
      id: room.id,
      author: author,
      likesCount: room.totalLikes,
      commentsCount: 0,
      sharesCount: 0,
      userLiked: false,
      userFollowingAuthor: false,
      caption: room.title,
      thumbnailUrl: room.thumbnailUrl ?? '',
      viewerCount: room.viewerCount,
      topic: room.category ?? 'Chat',
      slug: room.slug,
      streamUrl: room.streamUrl,
    );
  }

  FeedItem _mapPost(Post post) {
    final author = FeedAuthor(
      id: post.author.id,
      name: post.author.name,
      username: post.author.username,
      avatarUrl: post.author.avatarUrl,
      isVerified: post.author.isVerified,
    );

    final url = post.imageUrl ?? '';
    final isVideo =
        url.endsWith('.mp4') || url.endsWith('.mov') || url.contains('/video');

    if (isVideo) {
      return VideoFeedItem(
        id: post.id,
        author: author,
        likesCount: post.likesCount,
        commentsCount: post.commentsCount,
        sharesCount: post.repostsCount,
        userLiked: post.userLiked,
        userFollowingAuthor: false,
        caption: post.content,
        videoUrl: url,
        thumbnailUrl: url,
        duration: Duration.zero,
      );
    }

    // Foto não deveria chegar aqui: For You é só vídeo+live agora.
    // Se chegar (defensivo), tratamos como vídeo silenciosamente — o filtro
    // upstream em _safePosts já exclui o caso normal.
    return VideoFeedItem(
      id: post.id,
      author: author,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      sharesCount: post.repostsCount,
      userLiked: post.userLiked,
      userFollowingAuthor: false,
      caption: post.content,
      videoUrl: url,
      thumbnailUrl: url,
      duration: Duration.zero,
    );
  }
}
