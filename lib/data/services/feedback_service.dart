import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// 🎵 + 📳 Centraliza haptic feedback e sons curtos do app (UX moderna).
///
/// Por que centralizado?
/// - Garante consistência (toda interação de "like" usa mesma vibração).
/// - Permite usuário desativar via SettingsViewModel (`sounds_enabled`)
///   sem precisar mudar dezenas de call-sites.
/// - Carrega assets uma vez e reutiliza o [AudioPlayer] (fast play).
/// - Falha silenciosa se o asset não existir (ex.: durante dev quando
///   sons opcionais ainda não foram adicionados em `assets/sounds/`).
///
/// Uso:
/// ```dart
/// final fb = ref.read(feedbackServiceProvider);
/// await fb.like();   // pop + vibração leve
/// await fb.post();   // ding + vibração média
/// ```
class FeedbackService {
  FeedbackService();

  // Players pré-carregados — um por som para tocar simultâneos sem race.
  final Map<_Sound, AudioPlayer> _players = {};
  bool _soundsEnabled = true;

  /// Permite SettingsViewModel desligar sons. Haptic continua ativo
  /// (Apple HIG e Material Design recomendam não desativar haptic).
  void setSoundsEnabled(bool enabled) {
    _soundsEnabled = enabled;
  }

  // ── Públicos: interações comuns ─────────────────────────────────────────

  /// Like normal: tap leve + pop curto.
  Future<void> like() async {
    HapticFeedback.lightImpact();
    await _play(_Sound.like);
  }

  /// Reação (long-press): tap médio + pop maior.
  Future<void> reaction() async {
    HapticFeedback.mediumImpact();
    await _play(_Sound.reaction);
  }

  /// Compartilhar com sucesso: selectionClick + sound de swoosh.
  Future<void> share() async {
    HapticFeedback.selectionClick();
    await _play(_Sound.share);
  }

  /// Repost: vibração de seleção (igual swipe-to-refresh).
  Future<void> repost() async {
    HapticFeedback.selectionClick();
    await _play(_Sound.repost);
  }

  /// Seguir alguém: tap suave.
  Future<void> follow() async {
    HapticFeedback.lightImpact();
  }

  /// Publicar novo post/vídeo: vibração forte + chime de sucesso.
  Future<void> postPublished() async {
    HapticFeedback.mediumImpact();
    await _play(_Sound.publish);
  }

  /// Gift enviado/recebido: vibração heavy + sino mágico.
  Future<void> gift() async {
    HapticFeedback.heavyImpact();
    await _play(_Sound.gift);
  }

  /// Navegação imersiva (swipe vertical entre vídeos no feed).
  Future<void> swipe() async {
    HapticFeedback.selectionClick();
  }

  /// Erro genérico.
  Future<void> error() async {
    HapticFeedback.heavyImpact();
  }

  // ── Internos ─────────────────────────────────────────────────────────────

  Future<void> _play(_Sound s) async {
    if (!_soundsEnabled) return;
    final asset = s.assetPath;
    if (asset == null) return; // som ainda não disponível — silencioso

    try {
      var player = _players[s];
      if (player == null) {
        player = AudioPlayer();
        await player.setAsset(asset);
        _players[s] = player;
      }
      // Reinicia do começo para reproduzir rápido em taps consecutivos.
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      // Asset inexistente, codec falho, etc. — não quebra a UI.
      if (kDebugMode) {
        debugPrint('[FeedbackService] som $s falhou: $e');
      }
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
  }
}

/// Sons curtos do app. Quando o asset ainda não existe em
/// `assets/sounds/`, basta deixar `null` em [_assetMap] — o serviço
/// vai apenas vibrar sem tocar nada (graceful degradation).
enum _Sound { like, reaction, share, repost, publish, gift }

extension on _Sound {
  String? get assetPath {
    // Coloque novos sons em assets/sounds/ e mapeie aqui.
    // Recomendado: .mp3 < 100KB, 44.1kHz mono, ~200ms.
    const map = <_Sound, String?>{
      _Sound.like: null,       // TODO: assets/sounds/like_pop.mp3
      _Sound.reaction: null,   // TODO: assets/sounds/reaction_pop.mp3
      _Sound.share: null,      // TODO: assets/sounds/share_swoosh.mp3
      _Sound.repost: null,     // TODO: assets/sounds/repost.mp3
      _Sound.publish: null,    // TODO: assets/sounds/publish_chime.mp3
      _Sound.gift: null,       // TODO: assets/sounds/gift_bell.mp3
    };
    return map[this];
  }
}

/// Provider singleton. Acessar via `ref.read(feedbackServiceProvider)`.
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final svc = FeedbackService();
  ref.onDispose(svc.dispose);
  return svc;
});
