import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Lightweight one-shot sound effects for the chat (WhatsApp-style).
///
/// Reuses a small pool of pre-loaded [AudioPlayer]s — one per sound — so
/// that playback is instantaneous and concurrent calls don't cut each
/// other off mid-bleep.
class ChatSoundsService {
  ChatSoundsService();

  static const _sentAsset = 'assets/sounds/message_sent.mp3';
  static const _receivedAsset = 'assets/sounds/message_received.mp3';

  final AudioPlayer _sentPlayer = AudioPlayer();
  final AudioPlayer _receivedPlayer = AudioPlayer();

  bool _initialized = false;
  bool _enabled = true;

  /// Globally enable/disable the chat sound effects.
  void setEnabled(bool value) => _enabled = value;
  bool get isEnabled => _enabled;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      await _sentPlayer.setAsset(_sentAsset);
      await _receivedPlayer.setAsset(_receivedAsset);
      _initialized = true;
    } catch (e) {
      debugPrint('[ChatSoundsService] init failed: $e');
    }
  }

  /// Play "message sent" tap.
  Future<void> playSent() => _play(_sentPlayer);

  /// Play "message received" pop.
  Future<void> playReceived() => _play(_receivedPlayer);

  Future<void> _play(AudioPlayer player) async {
    if (!_enabled) return;
    await _ensureInitialized();
    if (!_initialized) return;
    try {
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint('[ChatSoundsService] play failed: $e');
    }
  }

  Future<void> dispose() async {
    await _sentPlayer.dispose();
    await _receivedPlayer.dispose();
  }
}

/// Singleton provider — kept alive for the whole app lifetime so the
/// pre-loaded audio buffers stay warm.
final chatSoundsServiceProvider = Provider<ChatSoundsService>((ref) {
  final svc = ChatSoundsService();
  ref.onDispose(svc.dispose);
  return svc;
});
