import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔇 Estado global de "mute" para vídeos do For You.
///
/// Persiste entre páginas: se o usuário desmutou um vídeo,
/// o próximo já entra com som — igual TikTok/Reels.
class FeedVideoMuteNotifier extends Notifier<bool> {
  @override
  bool build() => true; // default: muted (UX padrão de feeds verticais)

  void toggle() => state = !state;
  void setMuted(bool v) => state = v;
}

final feedVideoMuteProvider =
    NotifierProvider<FeedVideoMuteNotifier, bool>(FeedVideoMuteNotifier.new);
