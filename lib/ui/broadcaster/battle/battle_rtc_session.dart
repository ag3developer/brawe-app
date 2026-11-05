import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../data/services/battle_service.dart';

/// Sessão LiveKit do criador durante a batalha `composite`.
///
/// Publica câmera (retrato, 30 fps) + microfone, expõe a pré-visualização
/// local e o vídeo/áudio do adversário e aplica o "silenciar adversário"
/// localmente (para de tocar o áudio dele). É um [ChangeNotifier]: a UI
/// reconstrói quando faixas/participantes mudam.
class BattleRtcSession extends ChangeNotifier {
  BattleRtcSession(this.credentials);

  final BattleRtcCredentials credentials;

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  bool _disposed = false;
  bool _opponentMuted = false;

  Room? get room => _room;

  bool get isConnected =>
      _room?.connectionState == ConnectionState.connected;

  /// Só `disconnected` exige nova conexão (durante `reconnecting` o LiveKit
  /// se recupera sozinho).
  bool get isDisconnected =>
      _room == null || _room!.connectionState == ConnectionState.disconnected;

  /// Vira a câmera (frontal/traseira) sem derrubar a sala.
  Future<void> flipCamera() async {
    final t = localVideo;
    if (t == null) return;
    final cur = t.currentOptions;
    final back = cur is CameraCaptureOptions &&
        cur.cameraPosition == CameraPosition.back;
    await t.setCameraPosition(back ? CameraPosition.front : CameraPosition.back);
    notifyListeners();
  }

  LocalVideoTrack? get localVideo {
    final pubs = _room?.localParticipant?.videoTrackPublications;
    if (pubs == null) return null;
    for (final p in pubs) {
      final t = p.track;
      if (t != null) return t;
    }
    return null;
  }

  RemoteVideoTrack? get remoteVideo {
    final room = _room;
    if (room == null) return null;
    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.videoTrackPublications) {
        final t = pub.track;
        if (pub.subscribed && t != null) return t;
      }
    }
    return null;
  }

  bool get opponentMuted => _opponentMuted;

  /// Conecta e publica câmera + microfone. Lança em falha/timeout.
  Future<void> connect({
    Duration timeout = const Duration(seconds: 8),
    CameraPosition cameraPosition = CameraPosition.front,
  }) async {
    final room = Room(
      roomOptions: RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultCameraCaptureOptions: CameraCaptureOptions(
          cameraPosition: cameraPosition,
          // Retrato 720×1280 @ 30 fps (a composição espera 9:16).
          params: const VideoParameters(
            dimensions: VideoDimensions(1280, 720),
            encoding: VideoEncoding(maxBitrate: 2000000, maxFramerate: 30),
          ),
          maxFrameRate: 30,
        ),
        defaultVideoPublishOptions: const VideoPublishOptions(
          simulcast: false,
          videoEncoding: VideoEncoding(maxBitrate: 2000000, maxFramerate: 30),
        ),
        defaultAudioPublishOptions: const AudioPublishOptions(
          name: 'microphone',
        ),
      ),
    );
    _room = room;
    _listener = room.createListener()
      ..on<RoomDisconnectedEvent>((_) => _notify())
      ..on<ParticipantConnectedEvent>((_) => _notify())
      ..on<ParticipantDisconnectedEvent>((_) => _notify())
      ..on<TrackSubscribedEvent>((_) {
        _applyOpponentMute();
        _notify();
      })
      ..on<TrackUnsubscribedEvent>((_) => _notify())
      ..on<TrackPublishedEvent>((_) => _notify())
      ..on<LocalTrackPublishedEvent>((_) => _notify())
      ..on<LocalTrackUnpublishedEvent>((_) => _notify());
    room.addListener(_notify);

    await room
        .connect(credentials.url, credentials.token)
        .timeout(timeout);
    if (_disposed) return;
    final local = room.localParticipant;
    await local?.setCameraEnabled(true);
    await local?.setMicrophoneEnabled(true);
    _applyOpponentMute();
    _notify();
  }

  /// Para de tocar (ou volta a tocar) o áudio do adversário neste aparelho.
  void setOpponentMuted(bool muted) {
    _opponentMuted = muted;
    _applyOpponentMute();
    _notify();
  }

  void _applyOpponentMute() {
    final room = _room;
    if (room == null) return;
    for (final p in room.remoteParticipants.values) {
      for (final pub in p.audioTrackPublications) {
        final track = pub.track;
        if (track == null) continue;
        if (_opponentMuted) {
          unawaited(track.disable());
        } else {
          unawaited(track.enable());
        }
      }
    }
  }

  /// App foi para o segundo plano: libera a câmera (sem derrubar a sala).
  Future<void> pauseCamera() async {
    try {
      await _room?.localParticipant?.setCameraEnabled(false);
    } catch (e) {
      debugPrint('BattleRtc: pauseCamera falhou: $e');
    }
  }

  /// Voltou ao primeiro plano: reabre a câmera.
  Future<void> resumeCamera() async {
    try {
      await _room?.localParticipant?.setCameraEnabled(true);
      _notify();
    } catch (e) {
      debugPrint('BattleRtc: resumeCamera falhou: $e');
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final room = _room;
    _room = null;
    try {
      room?.removeListener(_notify);
      await _listener?.dispose();
      await room?.localParticipant?.setCameraEnabled(false);
      await room?.localParticipant?.setMicrophoneEnabled(false);
      await room?.disconnect();
      await room?.dispose();
    } catch (e) {
      debugPrint('BattleRtc: dispose falhou: $e');
    }
    super.dispose();
  }
}
