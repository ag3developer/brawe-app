import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/video_limits_provider.dart';
import '../../../domain/models/video_limits.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../routing/router.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/video_upload_manager.dart';

/// Indicador global do envio de vídeo/story. Fica no nível do app (acima de
/// qualquer tela, ver `MaterialApp.builder` em main.dart), então aparece onde
/// o usuário estiver. Mostra %, "processando", "publicado" (toque para ver) e,
/// se falhar, o MOTIVO em português com "Tentar de novo" / "Descartar".
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
    final limits = ref.watch(videoLimitsProvider).value ?? VideoLimits.fallback;

    Widget child = const SizedBox.shrink();
    if (job != null) {
      if (job.status == VideoUploadStatus.done && _doneTimerFor != job.id) {
        _doneTimerFor = job.id;
        Future<void>.delayed(const Duration(seconds: 8), () {
          if (!mounted) return;
          final still = ref
              .read(videoUploadManagerProvider)
              .any((j) => j.id == job.id && j.status == VideoUploadStatus.done);
          if (still) mgr.dismiss(job.id);
        });
      }
      child = VideoUploadPillView(
        key: ValueKey(job.id),
        job: job,
        queued: jobs.where((j) => j.active).length - (job.active ? 1 : 0),
        maxBytesLabel: limits.maxBytesLabel,
        maxDurationLabel: limits.maxDurationLabel,
        onCancel: () => mgr.cancel(job.id),
        onRetry: () => mgr.retry(job.id),
        onDismiss: () => mgr.dismiss(job.id),
        onOpen: job.postId == null
            ? null
            : () {
                mgr.dismiss(job.id);
                ref.read(routerProvider).push('/post/${job.postId}');
              },
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (w, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(a),
          child: w,
        ),
      ),
      child: child,
    );
  }
}

/// Texto do motivo da falha (pt/en/es via l10n). `null` quando não há
/// motivo específico para mostrar.
String? videoUploadErrorText(
  S s,
  VideoUploadError e, {
  required String maxBytesLabel,
  required String maxDurationLabel,
}) => switch (e) {
  VideoUploadError.none => null,
  VideoUploadError.cover => s.videoPubCoverUploadError,
  VideoUploadError.network => s.videoErrNoConnection,
  VideoUploadError.timeout => s.videoErrTimeout,
  VideoUploadError.tooLarge => s.videoErrTooLargeServer(maxBytesLabel),
  VideoUploadError.tooLong => s.videoErrTooLongServer(maxDurationLabel),
  VideoUploadError.unsupported => s.videoErrUnsupported,
  VideoUploadError.server => s.videoErrServer,
  VideoUploadError.sessionExpired => s.videoErrSession,
  VideoUploadError.processing => s.videoErrProcessing,
  VideoUploadError.other => s.videoErrUnknown,
};

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
    this.maxBytesLabel = '100 MB',
    this.maxDurationLabel = '3 min',
  });

  final VideoUploadJob job;
  final int queued;
  final String maxBytesLabel;
  final String maxDurationLabel;
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
        story
            ? s.storyUpUploading(job.percent)
            : s.videoUpUploading(job.percent),
      VideoUploadStatus.processing =>
        story ? s.storyUpProcessing : s.videoUpProcessing,
      VideoUploadStatus.done => story ? s.storyUpDone : s.videoUpDone,
      VideoUploadStatus.failed => story ? s.storyUpFailed : s.videoUpFailed,
    };
    final subtitle = failed
        ? videoUploadErrorText(
            s,
            job.error,
            maxBytesLabel: maxBytesLabel,
            maxDurationLabel: maxDurationLabel,
          )
        : null;
    final cover = job.request.coverPath;
    final canRetry = failed && job.error.retryable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: c.surfaceElevated,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: failed ? c.danger.withValues(alpha: 0.5) : c.border,
            ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
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
                            ),
                            if (subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  subtitle,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 12.5,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            if (failed)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(
                                  spacing: 4,
                                  children: [
                                    if (canRetry)
                                      _PillAction(
                                        label: s.videoUpRetry,
                                        color: c.accentPrimary,
                                        onTap: onRetry,
                                      ),
                                    _PillAction(
                                      label: s.videoUpDiscard,
                                      color: c.textSecondary,
                                      onTap: onDismiss,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (done && onOpen != null)
                        _PillAction(
                          label: s.videoUpView,
                          color: c.accentPrimary,
                          onTap: onOpen!,
                        ),
                      if (!failed)
                        _CloseButton(
                          label: done ? s.videoUpDismiss : s.videoUpCancel,
                          color: c.textSecondary,
                          onTap: done ? onDismiss : onCancel,
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
      ),
    );
  }
}

/// Botão de texto sem Tooltip/Overlay (o indicador vive acima do Navigator).
class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(LucideIcons.x, size: 18, color: color),
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
