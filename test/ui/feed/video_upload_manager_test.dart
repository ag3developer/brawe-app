import 'dart:async';

import 'package:brawe_app/data/repositories/post_repository.dart';
import 'package:brawe_app/ui/feed/view_models/video_upload_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const req = VideoUploadRequest(videoPath: '/v.mp4', content: 'oi');

  ({ProviderContainer c, VideoUploadManager m}) make(VideoUploadRunner runner) {
    final c = ProviderContainer(
      overrides: [videoUploadRunnerProvider.overrideWithValue(runner)],
    );
    addTearDown(c.dispose);
    return (c: c, m: c.read(videoUploadManagerProvider.notifier));
  }

  VideoUploadJob job(ProviderContainer c) =>
      c.read(videoUploadManagerProvider).first;

  test('fluxo completo com progresso que nunca regride', () async {
    final gate = Completer<String?>();
    late void Function(double, bool) report;
    final x = make((r, {required checkpoint, required cancelToken, required onProgress}) {
      report = onProgress;
      return gate.future;
    });
    x.m.enqueue(req);
    await Future<void>.delayed(Duration.zero);
    report(0.45, false);
    expect(job(x.c).status, VideoUploadStatus.uploading);
    expect(job(x.c).percent, 45);
    report(0.30, false);
    expect(job(x.c).percent, 45);
    report(0.9, true);
    expect(job(x.c).status, VideoUploadStatus.processing);
    gate.complete('p42');
    await Future<void>.delayed(Duration.zero);
    expect(job(x.c).status, VideoUploadStatus.done);
    expect(job(x.c).postId, 'p42');
  });

  test('falha -> retry reaproveita o checkpoint e não duplica etapas', () async {
    var calls = 0;
    final cps = <VideoPublishCheckpoint>[];
    final x = make((r, {required checkpoint, required cancelToken, required onProgress}) async {
      calls++;
      cps.add(checkpoint);
      if (calls == 1) {
        checkpoint.coverUrl = 'https://cdn/cover.jpg';
        throw const VideoCoverUploadFailure();
      }
      return 'ok';
    });
    x.m.enqueue(req);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(job(x.c).status, VideoUploadStatus.failed);
    expect(job(x.c).error, VideoUploadError.cover);
    x.m.retry(job(x.c).id);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(job(x.c).status, VideoUploadStatus.done);
    expect(calls, 2);
    expect(identical(cps[0], cps[1]), isTrue);
    expect(cps[1].coverUrl, 'https://cdn/cover.jpg');
  });

  test('cancelar remove o job e aborta o token', () async {
    late CancelToken tok;
    final x = make((r, {required checkpoint, required cancelToken, required onProgress}) {
      tok = cancelToken;
      return Completer<String?>().future;
    });
    final id = x.m.enqueue(req);
    await Future<void>.delayed(Duration.zero);
    x.m.cancel(id);
    expect(tok.isCancelled, isTrue);
    expect(x.c.read(videoUploadManagerProvider), isEmpty);
  });

  test('fila sequencial: o segundo só começa quando o primeiro termina', () async {
    final gates = [Completer<String?>(), Completer<String?>()];
    var i = 0;
    final x = make((r, {required checkpoint, required cancelToken, required onProgress}) => gates[i++].future);
    x.m.enqueue(req);
    x.m.enqueue(req);
    await Future<void>.delayed(Duration.zero);
    final jobs = x.c.read(videoUploadManagerProvider);
    expect(jobs[0].status, VideoUploadStatus.uploading);
    expect(jobs[1].status, VideoUploadStatus.queued);
    gates[0].complete('a');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(x.c.read(videoUploadManagerProvider)[1].status, VideoUploadStatus.uploading);
  });

  test('voltou do background com envio caído: tenta de novo sozinho', () async {
    var calls = 0;
    final x = make((r, {required checkpoint, required cancelToken, required onProgress}) async {
      calls++;
      if (calls == 1) throw DioException(requestOptions: RequestOptions());
      return 'ok';
    });
    x.m.enqueue(req);
    x.m.debugMarkBackground();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(job(x.c).status, VideoUploadStatus.failed);
    x.m.didChangeAppLifecycleState(AppLifecycleState.paused);
    x.m.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(job(x.c).status, VideoUploadStatus.done);
    expect(calls, 2);
  });
}
