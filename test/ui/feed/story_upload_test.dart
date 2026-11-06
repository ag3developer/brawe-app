import 'dart:async';

import 'package:brawe_app/data/repositories/stories_repository.dart';
import 'package:brawe_app/data/services/stories_service.dart';
import 'package:brawe_app/ui/feed/view_models/video_upload_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeService extends StoriesService {
  _FakeService() : super(Dio());

  final keys = <String?>[];
  Object? createError;
  Map<String, dynamic> byKey = {'id': 'story-1'};
  Object? byKeyError;
  Map<String, dynamic> feed = {};

  @override
  Future<Map<String, dynamic>> createStory({
    required String filePath,
    String? caption,
    int? durationSeconds,
    String? originPostId,
    String? idempotencyKey,
    String? soundId,
    int soundTrimStartMs = 0,
    int? soundTrimEndMs,
    double soundVolume = 1.0,
    double originalAudioVolume = 1.0,
    String? overlayPath,
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    keys.add(idempotencyKey);
    if (createError != null) throw createError!;
    return {'id': 'story-1'};
  }

  @override
  Future<Map<String, dynamic>> getStoryByKey(String key) async {
    if (byKeyError != null) throw byKeyError!;
    return byKey;
  }

  @override
  Future<Map<String, dynamic>> getFeed() async => feed;
}

DioException _dio(DioExceptionType t, {int? code, Object? data}) =>
    DioException(
      requestOptions: RequestOptions(path: '/stories/upload'),
      type: t,
      response: code == null
          ? null
          : Response(
              requestOptions: RequestOptions(path: '/x'),
              statusCode: code,
              data: data,
            ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StoriesRepository.createStoryResilient', () {
    late _FakeService svc;
    late StoriesRepository repo;
    setUp(() {
      svc = _FakeService();
      repo = StoriesRepository(svc);
    });

    Future<String?> run() => repo.createStoryResilient(
      localFilePath: '/p.png',
      idempotencyKey: 'k1',
      since: DateTime.now(),
      mediaType: 'photo',
    );

    test('sucesso envia a Idempotency-Key', () async {
      expect(await run(), 'story-1');
      expect(svc.keys, ['k1']);
    });

    test('timeout/5xx/resposta ilegível + story gravado => sucesso', () async {
      for (final err in <Object>[
        _dio(DioExceptionType.receiveTimeout),
        _dio(DioExceptionType.connectionError),
        _dio(DioExceptionType.badResponse, code: 502),
        const FormatException('resposta ilegível'),
      ]) {
        svc.createError = err;
        expect(await run(), 'story-1', reason: '$err');
      }
    });

    test('servidor confirma que NÃO gravou => relança o erro', () async {
      svc.createError = _dio(DioExceptionType.receiveTimeout);
      svc.byKeyError = _dio(
        DioExceptionType.badResponse,
        code: 404,
        data: {'detail': 'story_not_found_for_key'},
      );
      await expectLater(run(), throwsA(isA<DioException>()));
    });

    test('4xx definitivo não consulta nada', () async {
      svc.createError = _dio(DioExceptionType.badResponse, code: 422);
      await expectLater(run(), throwsA(isA<DioException>()));
    });

    test('servidor antigo: acha o story recente nos meus stories', () async {
      svc.createError = _dio(DioExceptionType.receiveTimeout);
      svc.byKeyError = _dio(DioExceptionType.badResponse, code: 404);
      svc.feed = {
        'my_story': {
          'user_id': 'me',
          'author': {'name': 'Eu'},
          'stories': [
            {
              'id': 'recent',
              'media_url': 'u',
              'media_type': 'photo',
              'created_at': DateTime.now().toUtc().toIso8601String(),
            },
          ],
        },
      };
      final id = await repo.createStoryResilient(
        localFilePath: '/p.png',
        idempotencyKey: 'k1',
        since: DateTime.now(),
        myUserId: 'me',
        mediaType: 'photo',
      );
      expect(id, 'recent');
    });
  });

  group('story jobs no VideoUploadManager', () {
    ({ProviderContainer c, VideoUploadManager m}) make(StoryUploadRunner r) {
      final c = ProviderContainer(
        overrides: [storyUploadRunnerProvider.overrideWithValue(r)],
      );
      addTearDown(c.dispose);
      return (c: c, m: c.read(videoUploadManagerProvider.notifier));
    }

    VideoUploadJob job(ProviderContainer c) =>
        c.read(videoUploadManagerProvider).first;

    const req = VideoUploadRequest(
      videoPath: '/p.png',
      storyKey: 'draft-key',
    );

    test('progresso -> publicado, sem nenhum listener de provider', () async {
      final gate = Completer<String?>();
      late void Function(double, bool) report;
      final x = make((r, {required cancelToken, required onProgress}) {
        report = onProgress;
        return gate.future;
      });
      x.m.enqueue(req);
      await Future<void>.delayed(Duration.zero);
      report(0.42, false);
      expect(job(x.c).status, VideoUploadStatus.uploading);
      expect(job(x.c).percent, 42);
      report(1, true);
      expect(job(x.c).status, VideoUploadStatus.processing);
      gate.complete('s1');
      await Future<void>.delayed(Duration.zero);
      expect(job(x.c).status, VideoUploadStatus.done);
      expect(job(x.c).postId, isNull);
    });

    test('falha -> retry reusa a MESMA key e conclui', () async {
      final keys = <String?>[];
      var n = 0;
      final x = make((r, {required cancelToken, required onProgress}) async {
        keys.add(r.storyKey);
        if (++n == 1) throw _dio(DioExceptionType.connectionError);
        return 's1';
      });
      x.m.enqueue(req);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(job(x.c).status, VideoUploadStatus.failed);
      x.m.retry(job(x.c).id);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(job(x.c).status, VideoUploadStatus.done);
      expect(keys, ['draft-key', 'draft-key']);
    });
  });
}
