import 'package:brawe_app/ui/home/view_models/feed_video_mute_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('primeira vez: começa com som', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(feedVideoMuteProvider), isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(feedVideoMuteProvider), isFalse);
  });

  test('lembra que o usuário silenciou', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    first.read(feedVideoMuteProvider.notifier).toggle(); // silencia
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    final next = ProviderContainer(); // "próxima abertura do app"
    addTearDown(next.dispose);
    next.read(feedVideoMuteProvider);
    await Future<void>.delayed(Duration.zero);
    expect(next.read(feedVideoMuteProvider), isTrue);
  });
}
