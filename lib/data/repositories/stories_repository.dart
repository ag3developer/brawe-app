import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/story.dart';
import '../../domain/models/story_active_status.dart';
import '../services/stories_service.dart';
part 'stories_repository.g.dart';

@riverpod
StoriesRepository storiesRepository(Ref ref) {
  return StoriesRepository(ref.watch(storiesServiceProvider));
}

class StoriesRepository {
  final StoriesService _service;
  StoriesRepository(this._service);

  /// Stories feed: meu story (se houver) primeiro, depois quem eu sigo.
  /// Resposta: { my_story: StoryGroup?, stories: [StoryGroup] }
  Future<List<UserStoriesGroup>> getFeed() async {
    try {
      final raw = await _service.getFeed();
      final groups = <UserStoriesGroup>[];
      final myStory = raw['my_story'];
      if (myStory is Map<String, dynamic>) {
        groups.add(_groupFromJson(myStory));
      }
      final others = (raw['stories'] as List<dynamic>? ?? []);
      for (final g in others) {
        groups.add(_groupFromJson(g as Map<String, dynamic>));
      }
      return groups;
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> markAsViewed(String storyId) async {
    try {
      await _service.markAsViewed(storyId);
    } catch (_) {
      // silent — view ack não deve quebrar UX
    }
  }

  Future<void> react(String storyId, {String reaction = '❤️'}) async {
    try {
      await _service.react(storyId, reactionType: reaction);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> reply(String storyId, String message) async {
    try {
      await _service.reply(storyId, message);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Lista de visualizadores de um story (apenas o dono).
  Future<({List<StoryViewerInfo> viewers, int total})> getViewers(
    String storyId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final raw = await _service.getViewers(storyId, limit: limit, offset: offset);
      final list = (raw['viewers'] as List<dynamic>? ?? [])
          .map((e) => StoryViewerInfo.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = (raw['total'] ?? list.length) as int;
      return (viewers: list, total: total);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw const Failure.unauthorized();
      }
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _service.deleteStory(storyId);
    } on DioException {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Cria um story: upload multipart de mídia local.
  /// O backend infere media_type (photo/video) pelo MIME.
  ///
  /// [idempotencyKey] (opcional): vai como header `Idempotency-Key`.
  /// Backend persiste em `stories.idempotency_key` (UNIQUE) e devolve o
  /// registro existente se a mesma key chegar 2x — evita duplicatas
  /// quando o usuário toca "Compartilhar" várias vezes em rede lenta.
  Future<void> createStory({
    required String localFilePath,
    String? caption,
    int? durationSeconds,
    String? originPostId,
    String? idempotencyKey,
  }) async {
    try {
      await _service.createStory(
        filePath: localFilePath,
        caption: caption,
        durationSeconds: durationSeconds,
        originPostId: originPostId,
        idempotencyKey: idempotencyKey,
      );
    } on DioException {
      // ⚠️ Re-lança o DioException ORIGINAL para o composer poder
      // diferenciar timeouts (que podem ter sucesso no backend) de
      // erros 4xx hard. NÃO converter para Failure.network() aqui.
      rethrow;
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Stories de um usuário específico (GET /stories/user/{user_id}).
  /// Retorna lista vazia se o usuário não tiver stories ativos.
  Future<List<Story>> getUserStories(String userId) async {
    try {
      final raw = await _service.getUserStories(userId);
      final author = (raw['author'] as Map<String, dynamic>?) ?? const {};
      final authorName =
          (author['name'] ?? author['username'] ?? 'Usuário') as String;
      final authorUsername = (author['username'] ?? userId) as String;
      final authorAvatarUrl = author['avatar_url'] as String?;
      final isVerified = (author['is_verified'] ?? false) as bool;
      final list = (raw['stories'] as List<dynamic>? ?? []);
      return list
          .map((s) => _storyFromJson(
                s as Map<String, dynamic>,
                authorId: userId,
                authorName: authorName,
                authorUsername: authorUsername,
                authorAvatarUrl: authorAvatarUrl,
                isVerified: isVerified,
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Status (has_stories / has_unviewed) em LOTE para vários usuários.
  ///
  /// Retorna um mapa `userId → StoryActiveStatus`. Todos os IDs pedidos
  /// estão presentes na resposta — usuários sem stories vêm como
  /// `StoryActiveStatus.empty`. Em caso de erro, devolve mapa vazio
  /// (o UI deve degradar para "sem anel" — não é dado crítico).
  Future<Map<String, StoryActiveStatus>> getActiveStatusBatch(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const {};
    try {
      final raw = await _service.getActiveStatusBatch(userIds);
      final users = (raw['users'] as Map<String, dynamic>? ?? const {});
      final out = <String, StoryActiveStatus>{};
      users.forEach((id, value) {
        if (value is Map<String, dynamic>) {
          out[id] = StoryActiveStatus.fromJson(value);
        }
      });
      return out;
    } on DioException catch (_) {
      return const {};
    } catch (_) {
      return const {};
    }
  }

  // ───── Helpers (parsing) ───────────────────────────────────
  /// Backend StoryGroupResponse:
  /// { user_id, author: {id,name,username,avatar_url,is_verified},
  ///   stories: [...], has_unviewed, latest_at }
  UserStoriesGroup _groupFromJson(Map<String, dynamic> json) {
    final userId = (json['user_id'] ?? '') as String;
    final author = (json['author'] as Map<String, dynamic>?) ?? const {};
    final displayName = author['name'] as String?;
    final username = author['username'] as String?;
    final avatarUrl = author['avatar_url'] as String?;
    final isVerified = (author['is_verified'] ?? false) as bool;
    final hasUnviewed = (json['has_unviewed'] ?? false) as bool;
    final isLive = (json['is_live'] ?? false) as bool;
    final liveRoomId = json['live_room_id'] as String?;
    final stories = ((json['stories'] as List<dynamic>?) ?? [])
        .map((s) => _storyFromJson(
              s as Map<String, dynamic>,
              authorId: userId,
              authorName: displayName ?? username ?? 'Usuário',
              authorUsername: username ?? userId,
              authorAvatarUrl: avatarUrl,
              isVerified: isVerified,
            ))
        .toList();
    return UserStoriesGroup(
      userId: userId,
      displayName: displayName,
      username: username,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      hasUnviewed: hasUnviewed,
      isLive: isLive,
      liveRoomId: liveRoomId,
      stories: stories,
    );
  }

  Story _storyFromJson(
    Map<String, dynamic> json, {
    String? authorId,
    String authorName = '',
    String authorUsername = '',
    String? authorAvatarUrl,
    bool isVerified = false,
  }) {
    return Story(
      id: (json['id'] ?? '') as String,
      authorId: authorId ?? (json['user_id'] ?? '') as String,
      authorName: authorName,
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
      mediaUrl: (json['media_url'] ?? '') as String,
      mediaType: (json['media_type'] ?? 'photo') as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      viewsCount: (json['views_count'] ?? 0) as int,
      reactionsCount: (json['reactions_count'] ?? 0) as int,
      createdAt: DateTime.tryParse((json['created_at'] ?? '') as String) ??
          DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      isSeen: (json['is_viewed'] ?? false) as bool,
      isVerified: isVerified,
      originPostId: json['origin_post_id'] as String?,
    );
  }
}
