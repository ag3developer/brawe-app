import 'package:freezed_annotation/freezed_annotation.dart';
import 'sound.dart';

part 'sound_preview.freezed.dart';
part 'sound_preview.g.dart';

/// Preview leve de uma música do Brawe Sounds anexada a um post ou story.
///
/// Espelha `SoundPreview` (Pydantic) em
/// `brawe-connect/backend/app/schemas/post.py`. Deliberadamente NÃO
/// reaproveita o modelo `Sound` completo (`lib/domain/models/sound.dart`):
/// aqui só vêm os campos necessários para exibir/reproduzir no feed —
/// sem analytics (play_count/usage_count) nem dados de licenciamento.
///
/// IMPORTANTE: [trimStartMs]/[trimEndMs] são o trecho ESPECÍFICO escolhido
/// para ESTE post/story — não o trecho padrão sugerido pelo artista. A
/// mesma música pode aparecer em vários conteúdos com trims diferentes.
@freezed
sealed class SoundPreview with _$SoundPreview {
  const factory SoundPreview({
    required String id,
    required String title,
    @JsonKey(name: 'artist_name') required String artistName,
    @JsonKey(name: 'artist_avatar_url') String? artistAvatarUrl,
    @JsonKey(name: 'cover_url') String? coverUrl,
    @JsonKey(name: 'audio_url') required String audioUrl,
    @JsonKey(name: 'duration_ms') @Default(0) int durationMs,
    @JsonKey(name: 'trim_start_ms') @Default(0) int trimStartMs,
    @JsonKey(name: 'trim_end_ms') int? trimEndMs,
  }) = _SoundPreview;

  factory SoundPreview.fromJson(Map<String, dynamic> json) =>
      _$SoundPreviewFromJson(json);
}

/// Converte um [SoundPreview] (dados leves anexados a um post/story) em um
/// [Sound] reproduzível pelo `SoundPlayerViewModel` já existente
/// (`lib/ui/sounds/view_models/sound_player_view_model.dart`), sem precisar
/// duplicar a lógica de player só para tocar músicas vindas do feed.
///
/// [allowTrim] é forçado a `true` e os campos de trim vêm do preview (que já
/// reflete o trecho ESPECÍFICO escolhido para aquele conteúdo) — o player
/// então recorta exatamente o pedaço que o autor escolheu ao publicar.
///
/// [volume] (0.0-1.0): volume ESPECÍFICO com que essa faixa deve tocar
/// NESTE conteúdo — vem de `post.soundVolume`/`story.soundVolume` (campo
/// top-level do Post/Story, não do preview da música em si, já que a
/// mesma faixa pode ter volumes diferentes em conteúdos diferentes).
/// Default 1.0 preserva o comportamento de conteúdo antigo/sem volume.
extension SoundPreviewPlayback on SoundPreview {
  Sound toPlayableSound({double volume = 1.0}) {
    return Sound(
      id: id,
      artistId: '', // não necessário para reprodução
      title: title,
      audioUrl: audioUrl,
      coverUrl: coverUrl,
      durationMs: durationMs,
      allowTrim: true,
      trimStartMs: trimStartMs,
      trimEndMs: trimEndMs,
      volume: volume,
      artist: SoundArtist(
        id: '',
        userId: '',
        artistName: artistName,
        avatarUrl: artistAvatarUrl,
      ),
    );
  }
}
