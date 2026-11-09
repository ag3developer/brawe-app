import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/sound_preview.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sound_player_bottom_sheet.dart';
import 'content_sound_attribution.dart';

/// Atribuição musical do Brawe Sounds anexada a um post, usada no feed
/// (`PostCard`) e — por reaproveitamento — na tela de detalhe do post
/// (`PostDetailScreen`, que renderiza `PostCard`).
///
/// Fina camada sobre o componente único [ContentSoundAttribution]: aqui só
/// resolvemos o estado de "está tocando" a partir do player global
/// (`SoundPlayerViewModel`) e abrimos o `SoundPlayerBottomSheet` ao tocar.
/// Mantido como classe própria (em vez de usar `ContentSoundAttribution`
/// diretamente em `feed_screen.dart`) para não duplicar essa lógica de
/// leitura de estado em cada tela que exibe posts.
class SoundPreviewChip extends ConsumerWidget {
  const SoundPreviewChip({super.key, required this.sound, this.volume = 1.0});
  final SoundPreview sound;

  /// Volume (0.0-1.0) ESPECÍFICO do conteúdo que anexou esta faixa
  /// (`post.soundVolume`). Aplicado ao abrir o preview no bottom sheet.
  final double volume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(soundPlayerViewModelProvider);
    final isCurrent = playerState.sound?.id == sound.id;
    final isPlaying = isCurrent && playerState.isPlaying;
    final isUnavailable =
        isCurrent && playerState.status == SoundPlayerStatus.error;

    return ContentSoundAttribution(
      trackId: sound.id,
      title: sound.title,
      artistName: sound.artistName,
      coverUrl: sound.coverUrl,
      isPlaying: isPlaying,
      isUnavailable: isUnavailable,
      contentType: ContentSoundSurface.feedPost,
      onTap: () => _openPlayer(context),
    );
  }

  void _openPlayer(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          SoundPlayerBottomSheet(sound: sound.toPlayableSound(volume: volume)),
    );
  }
}
