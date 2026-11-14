import 'package:brawe_app/ui/live_feed/widgets/live_solo_video.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sinal 16:9 é tratado como deitado; 9:16 não', () {
    expect(1920 / 1080 > LiveSoloVideo.landscapeRatio, isTrue);
    expect(1080 / 1920 > LiveSoloVideo.landscapeRatio, isFalse);
    expect(1080 / 1080 > LiveSoloVideo.landscapeRatio, isFalse);
  });
}
