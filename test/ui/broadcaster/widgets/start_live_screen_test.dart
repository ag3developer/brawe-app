import 'package:brawe_app/data/model/create_live_room_request_dto.dart';
import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/ui/broadcaster/widgets/start_live_screen.dart';
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
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Stream with me');
      await tester.pump();

      // Select category
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gaming').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create live'));
      await tester.pumpAndSettle();

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
