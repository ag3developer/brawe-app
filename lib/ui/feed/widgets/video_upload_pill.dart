import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/video_upload_manager.dart';

/// Indicador global do envio de vídeo: fica acima da barra de navegação,
/// ligado ao [VideoUploadManager]. Some sozinho depois de "publicado".
class VideoUploadPill extends ConsumerStatefulWidget {
  const VideoUploadPill({super.key});

  @override
  ConsumerState<VideoUploadPill> createState() => _VideoUploadPillState();
}

class _VideoUploadPillState extends ConsumerState<VideoUploadPill> {
  int? _doneTimerFor;

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(videoUploadManagerProvider);
    final mgr = ref.read(videoUploadManagerProvider.notifier);
    final job = mgr.current;
    if (job == null) return const SizedBox.shrink();
    if (job.status == VideoUploadStatus.done && _doneTimerFor != job.id) {
      _doneTimerFor = job.id;
      Future<void>.delayed(const Duration(seconds: 6), () {
        if (!mounted) return;
        final still = ref
            .read(videoUploadManagerProvider)
            .any((j) => j.id == job.id && j.status == VideoUploadStatus.done);
        if (still) mgr.dismiss(job.id);
      });
    }
    return VideoUploadPillView(
      job: job,
      queued: jobs.where((j) => j.active).length - (job.active ? 1 : 0),
      onCancel: () => mgr.cancel(job.id),
      onRetry: () => mgr.retry(job.id),
      onDismiss: () => mgr.dismiss(job.id),
      onOpen: job.postId == null
          ? null
          : () {
              mgr.dismiss(job.id);
              context.push('/post/${job.postId}');
            },
    );
  }
}

/// Visual puro do indicador (testável sem provider).
class VideoUploadPillView extends StatelessWidget {
  const VideoUploadPillView({
    super.key,
    required this.job,
    required this.onCancel,
    required this.onRetry,
    required this.onDismiss,
    this.onOpen,
    this.queued = 0,
  });

  final VideoUploadJob job;
  final int queued;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    final failed = job.status == VideoUploadStatus.failed;
    final done = job.status == VideoUploadStatus.done;
    final processing = job.status == VideoUploadStatus.processing;
    final accent = failed
        ? c.danger
        : done
        ? c.success
        : c.accentPrimary;

    final story = job.request.isStory;
    final title = switch (job.status) {
      VideoUploadStatus.queued => s.videoUpQueued,
      VideoUploadStatus.uploading =>
        story ? s.storyUpUploading(job.percent) : s.videoUpUploading(job.percent),
      VideoUploadStatus.processing =>
        story ? s.storyUpProcessing : s.videoUpProcessing,
      VideoUploadStatus.done => story ? s.storyUpDone : s.videoUpDone,
      VideoUploadStatus.failed => story ? s.storyUpFailed : s.videoUpFailed,
    };
    final subtitle = failed && job.error == VideoUploadError.cover
        ? s.videoPubCoverUploadError
        : null;
    final cover = job.request.coverPath;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: c.surfaceElevated,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: done ? onOpen : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 6, 8),
                child: Row(
                  children: [
                    _Thumb(
                      path: cover,
                      color: accent,
                      done: done,
                      failed: failed,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          if (failed)
                            TextButton(
                              onPressed: onRetry,
                              style: TextButton.styleFrom(
                                foregroundColor: c.accentPrimary,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 36),
                                alignment: Alignment.centerLeft,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                s.videoUpRetry,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (done && onOpen != null)
                      TextButton(
                        onPressed: onOpen,
                        style: TextButton.styleFrom(
                          foregroundColor: c.accentPrimary,
                          minimumSize: const Size(44, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          s.videoUpView,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    IconButton(
                      tooltip: (failed || done)
                          ? s.videoUpDismiss
                          : s.videoUpCancel,
                      onPressed: (failed || done) ? onDismiss : onCancel,
                      icon: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: c.textSecondary,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  // processando/na fila = indeterminado; resto = % real
                  value: (done || failed)
                      ? (done ? 1 : job.progress)
                      : (processing || job.status == VideoUploadStatus.queued)
                      ? null
                      : job.progress,
                  backgroundColor: c.surfaceHighest,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.path,
    required this.color,
    required this.done,
    required this.failed,
  });
  final String? path;
  final Color color;
  final bool done;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = done
        ? LucideIcons.check
        : failed
        ? LucideIcons.triangleAlert
        : LucideIcons.upload;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: path != null && File(path!).existsSync()
                ? Image.file(
                    File(path!),
                    fit: BoxFit.cover,
                    cacheWidth: 132,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: c.surfaceHighest),
                  )
                : ColoredBox(color: c.surfaceHighest),
          ),
          Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
