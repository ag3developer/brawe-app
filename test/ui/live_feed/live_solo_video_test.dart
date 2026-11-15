import 'package:brawe_app/data/model/live_room_dto.dart';
import 'package:brawe_app/ui/live_feed/widgets/live_solo_video.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sinal 16:9 é tratado como deitado; 9:16 não', () {
    expect(1920 / 1080 > LiveSoloVideo.landscapeRatio, isTrue);
    expect(1080 / 1920 > LiveSoloVideo.landscapeRatio, isFalse);
    expect(1080 / 1080 > LiveSoloVideo.landscapeRatio, isFalse);
  });

  test('Modo Gamer segue a prévia aprovada (390×844)', () {
    final g = GamerGeometry.of(const Size(390, 844));
    expect(g.camH, closeTo(318, 0.01));
    expect(g.stripH, 48);
    expect(g.gameH, closeTo(219.375, 0.01));
    expect(g.gameTop, closeTo(366, 0.01));
    expect(g.chatTop, closeTo(585.375, 0.01));
  });

  test('Modo Gamer só monta com tema gamer, câmera e cena deitada', () {
    const wide = Size(1920, 1080);
    const tall = Size(720, 1280);
    expect(
      LiveSoloVideo.gamerActive('gamer', [0.7, 0.66, 0.28, 0.3], wide),
      isTrue,
    );
    expect(LiveSoloVideo.gamerActive('gamer', null, wide), isFalse);
    expect(
      LiveSoloVideo.gamerActive('gamer', [0, 0.1, 1, 0.32], tall),
      isFalse,
    );
    expect(
      LiveSoloVideo.gamerActive('camera', [0.7, 0.66, 0.28, 0.3], wide),
      isFalse,
    );
  });

  test('retângulo da câmera vindo da API', () {
    expect(parseLayoutCam({'x': 0.7, 'y': 0.66, 'w': 0.28, 'h': 0.3}), [
      0.7,
      0.66,
      0.28,
      0.3,
    ]);
    expect(parseLayoutCam({'x': 0.7, 'y': 0.66, 'w': 0.28}), isNull);
    expect(parseLayoutCam(null), isNull);
    expect(parseLayoutCam({'x': 0.1, 'y': 0.1, 'w': 0.0, 'h': 0.3}), isNull);
  });
}
