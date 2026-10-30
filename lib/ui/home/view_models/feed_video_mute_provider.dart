import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔇 Estado global de "mute" para vídeos e prévias de live do For You.
///
/// - Padrão: COM SOM (apps de live — TikTok/Kwai/Bigo — abrem com som; a
///   prévia da live sem áudio parece uma foto e não segura o usuário).
/// - A escolha do usuário é salva no aparelho: quem silenciou continua
///   mudo nas próximas aberturas, até ativar o som de novo.
/// - Vale para o feed inteiro (mesmo botão nos vídeos e nas lives).
/// - Botão físico de AUMENTAR volume tira do mudo (TikTok) — antes o iOS
///   mostrava o indicador de volume, mas o vídeo seguia sem som.
class FeedVideoMuteNotifier extends Notifier<bool> {
  static const _prefsKey = 'feed_video_muted';

  @override
  bool build() {
    _restore();
    _listenHardwareVolume();
    return false; // default: com som
  }

  static bool _listening = false;
  double? _lastSystemVolume;

  /// Registrado UMA vez e nunca removido: ao remover, o plugin desativa a
  /// sessão de áudio do iOS (`setActive(false)`), o que cortaria o áudio de
  /// outros players — ou o microfone de uma live em andamento.
  void _listenHardwareVolume() {
    if (_listening || !(Platform.isIOS || Platform.isAndroid)) return;
    _listening = true;
    try {
      FlutterVolumeController.addListener(
        _onSystemVolume,
        // Mesma categoria que o video_player usa para tocar o feed.
        category: AudioSessionCategory.playback,
      ).onError((_) {});
    } catch (_) {
      _listening = false;
    }
  }

  void _onSystemVolume(double volume) {
    final last = _lastSystemVolume;
    _lastSystemVolume = volume;
    if (last == null) return; // 1º valor (emitOnStart) — só referência
    if (volume > last && state) setMuted(false);
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefsKey);
    if (saved != null && saved != state) state = saved;
  }

  void toggle() => setMuted(!state);

  void setMuted(bool v) {
    state = v;
    SharedPreferences.getInstance().then((p) => p.setBool(_prefsKey, v));
  }
}

final feedVideoMuteProvider =
    NotifierProvider<FeedVideoMuteNotifier, bool>(FeedVideoMuteNotifier.new);
