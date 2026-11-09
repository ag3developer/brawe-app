import 'package:freezed_annotation/freezed_annotation.dart';
import 'post_poll.dart';
import 'sound_preview.dart';

part 'post.freezed.dart';

@freezed
sealed class Post with _$Post {
  const factory Post({
    required String id,
    required String content,
    String? imageUrl,

    /// HLS adaptativo (Bunny) — usar para TOCAR o vídeo quando presente.
    /// `imageUrl` segue com o arquivo original (download/repost no story).
    String? hlsUrl,
    String? hlsThumbnailUrl,
    required int likesCount,
    required int commentsCount,
    required int repostsCount,
    required int viewsCount,
    required DateTime createdAt,
    required PostAuthor author,
    @Default(false) bool userLiked,
    @JsonKey(name: 'user_reaction_type') String? userReactionType,
    @Default(false) bool userReposted,
    @Default(false) bool userFollowingAuthor,
    // Quando o item aparece no feed por causa de um repost de alguém,
    // [repostedBy] traz o autor do repost. Frontend mostra "X repostou".
    PostAuthor? repostedBy,
    DateTime? repostCreatedAt,
    // Brawe Sound: música anexada ao post (opcional).
    SoundPreview? sound,
    // Volume da música anexada (0.0-1.0) ESPECÍFICO deste post — a mesma
    // faixa pode tocar com volumes diferentes em conteúdos diferentes.
    @JsonKey(name: 'sound_volume') @Default(1.0) double soundVolume,
    // Volume do áudio ORIGINAL do vídeo (0.0-1.0) quando há música
    // anexada — permite ao autor abaixar/mutar o som próprio do vídeo
    // pra não competir com a música do Brawe Sounds. Sem música anexada,
    // este valor é ignorado (áudio original toca no volume nativo).
    @JsonKey(name: 'original_audio_volume')
    @Default(1.0)
    double originalAudioVolume,
    // ── Mídia: tamanho real (rotação já corrigida no servidor) ──
    // Com isso o feed reserva o espaço certo ANTES de carregar (sem
    // "esticar e voltar"). Null em posts antigos ainda não medidos.
    int? mediaWidth,
    int? mediaHeight,
    double? durationSec,
    // Capa do vídeo: personalizada pelo autor ou automática (frame).
    String? thumbnailUrl,
    // 'image' | 'video' (null em servidor antigo → decide pela URL).
    String? mediaType,
    // Enquete do post (null = post sem enquete).
    PostPoll? poll,
    // Cidade do post, ex.: "Recife, PE" (null = sem localização).
    PostLocation? location,
    // Privacidade (contrato /privacy): comentários desativados pelo autor,
    // contagem de curtidas oculta e se EU posso comentar neste post.
    @Default(false) bool commentsDisabled,
    @Default(false) bool hideLikeCount,
    @Default(true) bool canComment,
  }) = _Post;

  const Post._();

  /// Proporção largura/altura da mídia, se conhecida.
  double? get aspectRatio {
    final w = mediaWidth, h = mediaHeight;
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w / h;
  }

  /// Capa para exibir: personalizada/automática ou a do HLS.
  String? get coverUrl => (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
      ? thumbnailUrl
      : hlsThumbnailUrl;
}

@freezed
sealed class PostAuthor with _$PostAuthor {
  const factory PostAuthor({
    required String id,
    required String name,
    required String username,
    String? avatarUrl,
    @Default(false) bool isVerified,
  }) = _PostAuthor;
}
