import 'dart:async';

import 'package:brawe_app/core/utils/live_video.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Live de 30 s de janela: a posição nativa continua andando depois do fim.
class _FakeLive extends VideoPlayerPlatform with MockPlatformInterfaceMixin {
  final seeks = <Duration>[];
  Duration native = Duration.zero;
  final _events = StreamController<VideoEvent>();

  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async => 1;
  @override
  Future<int?> create(DataSource dataSource) async => 1;
  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    scheduleMicrotask(
      () => _events.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(1280, 720),
          duration: const Duration(seconds: 30),
        ),
      ),
    );
    return _events.stream;
  }

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    seeks.add(position);
    native = position;
  }

  @override
  Future<Duration> getPosition(int playerId) async => native;
  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> play(int playerId) async {}
  @override
  Future<void> pause(int playerId) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<void> dispose(int playerId) async {}
  @override
  Widget buildView(int playerId) => const SizedBox();
  @override
  Widget buildViewWithOptions(VideoViewOptions options) => const SizedBox();
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeLive fake;

  setUp(() {
    fake = _FakeLive();
    VideoPlayerPlatform.instance = fake;
  });

  test('playLive não volta para o início depois do ponto ao vivo', () async {
    final c = VideoPlayerController.networkUrl(Uri.parse('https://x/y.m3u8'));
    await c.initialize();
    await c.seekTo(c.value.duration); // ponto ao vivo
    expect(c.value.position, c.value.duration);

    fake.seeks.clear();
    await c.playLive();
    expect(fake.seeks, isEmpty, reason: 'play() comum faria seekTo(0)');
    await c.dispose();
  });

  test('livePosition lê a posição real, além da duração travada', () async {
    final c = VideoPlayerController.networkUrl(Uri.parse('https://x/y.m3u8'));
    await c.initialize();
    await c.seekTo(c.value.duration);
    fake.native = const Duration(seconds: 42); // a live continuou
    expect(await c.livePosition(), const Duration(seconds: 42));
    await c.dispose();
  });
}
