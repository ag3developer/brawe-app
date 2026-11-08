import 'package:brawe_app/data/model/create_live_room_request_dto.dart';
import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/domain/models/live_eligibility.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/broadcaster/widgets/start_live_screen.dart';
import 'package:brawe_app/ui/live/view_models/live_eligibility_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'StartLiveScreen opens broadcaster flow instead of returning to live feed',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const StartLiveScreen(),
          ),
          GoRoute(
            path: '/live',
            builder: (context, state) =>
                const Scaffold(body: Text('live-feed-screen')),
          ),
          GoRoute(
            path: '/live/broadcast',
            builder: (context, state) =>
                const Scaffold(body: Text('broadcaster-screen')),
          ),
          GoRoute(
            path: '/welcome',
            builder: (context, state) =>
                const Scaffold(body: Text('welcome-screen')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveRepositoryProvider.overrideWithValue(
              LiveRepository(_SuccessLiveService()),
            ),
            // Sem isso o overlay de elegibilidade cobre a tela e bate na rede.
            liveEligibilityProvider.overrideWith(
              (ref) async => const LiveEligibility(
                canGoLive: true,
                code: 'ok',
                message: '',
                missing: [],
                hasAvatar: true,
                isCreator: true,
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            locale: const Locale('en'),
          ),
        ),
      );

      // Deixa resolver a elegibilidade. O bootstrap da câmera depende de
      // plugins nativos (sem handler no teste) e fica no spinner — por isso
      // não dá para usar pumpAndSettle nesta tela.
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField).first, 'Stream with me');
      await tester.pump();

      // Categoria agora é um grid inline de chips.
      await tester.tap(find.text('Gaming'));
      await tester.pump();

      // "Notificar seguidores" vem ligado por padrão e abriria o warm-up de
      // 30s antes de ir ao broadcaster; desliga para ir direto.
      await tester.tap(find.text('Notify'));
      await tester.pump();

      await tester.tap(find.text('GO LIVE'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('broadcaster-screen'), findsOneWidget);
      expect(find.text('live-feed-screen'), findsNothing);
    },
  );
}

class _SuccessLiveService extends LiveService {
  _SuccessLiveService() : super(Dio());

  @override
  Future<Map<String, dynamic>> createLiveRoom(
    CreateLiveRoomRequestDto request,
  ) async {
    return {
      'id': 'room-42',
      'title': request.title,
      'status': 'waiting',
      'live_type': 'solo',
      'is_private': false,
      'streamer_name': 'You',
      'stream_config': {
        'rtmp_url': 'rtmp://global-live.mux.com:5222/app',
        'stream_key': 'sk_live_room_42',
        'playback_url': 'https://cdn.example.com/live/room-42.m3u8',
      },
    };
  }
}
