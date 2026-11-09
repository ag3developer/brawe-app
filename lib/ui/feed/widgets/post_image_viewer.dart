import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/post_comment.dart';
import '../../../domain/models/sound_preview.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../view_models/comments_view_model.dart';
import '../view_models/feed_view_model.dart';
import 'comments_sheet.dart';
import 'share_to_chat_sheet.dart';

const Color _kLikeRed = Color(0xFFFF3B7E);

/// Distância (px) de arrasto a partir da qual soltar fecha o visualizador.
const double kPostViewerDismissDistance = 110;

/// Velocidade (px/s) de "flick" que também fecha o visualizador.
const double kPostViewerDismissVelocity = 900;

/// Rota do visualizador fullscreen de foto (fade, sem barreira preta fixa —
/// o fundo escurece/clareia junto com o arrasto e o feed aparece por trás).
Route<void> postImageViewerRoute(Widget page) => PageRouteBuilder<void>(
  opaque: false,
  barrierColor: null,
  transitionDuration: const Duration(milliseconds: 200),
  reverseTransitionDuration: const Duration(milliseconds: 180),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, anim, _, child) =>
      FadeTransition(opacity: anim, child: child),
);

/// Visualizador fullscreen de foto de post (estilo Instagram): cabeçalho
/// no topo, foto `contain` com pinch-to-zoom, rodapé com legenda e ações.
///
/// * toque duplo na foto = curtir (nunca descurte) + coração animado;
/// * botão de coração alterna curtir/descurtir (otimista, com rollback);
/// * botão de comentário abre a [CommentsSheet] e mantém o contador em dia;
/// * arrastar para baixo/cima fecha (a foto segue o dedo, fundo some).
class PostImageViewer extends ConsumerStatefulWidget {
  const PostImageViewer({
    super.key,
    required this.imageUrl,
    required this.postId,
    required this.caption,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.sound,
    this.soundVolume = 1.0,
    required this.initialLiked,
    required this.initialLikesCount,
    required this.commentsCount,
    required this.onLikeChanged,
    this.onCommentsCountChanged,
    this.imageProvider,
  });

  final String imageUrl;
  final String postId;
  final String caption;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final SoundPreview? sound;
  final double soundVolume;
  final bool initialLiked;
  final int initialLikesCount;
  final int commentsCount;

  /// Avisa o cartão de origem para manter curtida/contador em sincronia.
  final void Function(bool liked, int count) onLikeChanged;

  /// Avisa o cartão de origem quando o total de comentários muda.
  final ValueChanged<int>? onCommentsCountChanged;

  /// Permite injetar a imagem (testes); por padrão carrega [imageUrl].
  final ImageProvider? imageProvider;

  @override
  ConsumerState<PostImageViewer> createState() => _PostImageViewerState();
}

class _PostImageViewerState extends ConsumerState<PostImageViewer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Arrasto para fechar
  Offset _drag = Offset.zero;
  bool _dragging = false;
  bool _closing = false;
  final Set<int> _pointers = {};
  Offset _pointerTotal = Offset.zero;
  VelocityTracker? _velocity;
  late final AnimationController _spring;
  Offset _springFrom = Offset.zero;

  // Curtir
  late bool _liked = widget.initialLiked;
  late int _likesCount = widget.initialLikesCount;
  bool _busyLike = false;

  // Comentários
  late int _commentsCount = widget.commentsCount;
  int? _commentsBase;
  ProviderSubscription<AsyncValue<List<PostComment>>>? _commentsSub;

  // Coração do toque duplo
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;
  Offset? _heartAt;
  Offset _lastTapDown = Offset.zero;

  final TransformationController _zoomCtrl = TransformationController();
  bool _pausedByLifecycle = false;

  String get _owner => 'fullscreen:image:${widget.postId}';
  bool get _isZoomed => _zoomCtrl.value.getMaxScaleOnAxis() > 1.05;

  @override
  void initState() {
    super.initState();
    _spring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(_onSpring);
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_heartCtrl);
    _heartCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _heartAt = null);
        _heartCtrl.reset();
      }
    });

    WidgetsBinding.instance.addObserver(this);
    final sound = widget.sound;
    if (sound != null) {
      ref
          .read(soundPlayerViewModelProvider.notifier)
          .play(
            sound.toPlayableSound(volume: widget.soundVolume),
            owner: _owner,
          );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sound = widget.sound;
    if (sound == null) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (ref.read(soundPlayerViewModelProvider).isPlaying) {
          _pausedByLifecycle = true;
          ref.read(soundPlayerViewModelProvider.notifier).pause();
        }
      case AppLifecycleState.resumed:
        if (_pausedByLifecycle) {
          _pausedByLifecycle = false;
          ref
              .read(soundPlayerViewModelProvider.notifier)
              .play(
                sound.toPlayableSound(volume: widget.soundVolume),
                owner: _owner,
              );
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _commentsSub?.close();
    _spring.dispose();
    _heartCtrl.dispose();
    _zoomCtrl.dispose();
    if (widget.sound != null) {
      unawaited(
        ref
            .read(soundPlayerViewModelProvider.notifier)
            .stop()
            .timeout(const Duration(seconds: 2))
            .catchError((_) {}),
      );
    }
    super.dispose();
  }

  /// Espelha curtidas/comentários nos feeds em memória — o cartão de origem
  /// pode já ter sido reciclado pela lista, então não dependemos dele.
  void _syncFeeds({bool? liked, int? likes, int? comments}) {
    Post patch(Post p) => p.copyWith(
      userLiked: liked ?? p.userLiked,
      likesCount: likes ?? p.likesCount,
      commentsCount: comments ?? p.commentsCount,
    );
    try {
      ref.read(feedViewModelProvider.notifier).patchPost(widget.postId, patch);
      ref
          .read(followingFeedViewModelProvider.notifier)
          .patchPost(widget.postId, patch);
    } catch (_) {}
  }

  // ── Curtir ───────────────────────────────────────────────────────────────

  Future<void> _toggleLike() async {
    if (_busyLike) return;
    _busyLike = true;
    final wasLiked = _liked;
    final wasCount = _likesCount;
    final nextCount = (wasCount + (wasLiked ? -1 : 1)).clamp(0, 1 << 30);
    setState(() {
      _liked = !wasLiked;
      _likesCount = nextCount;
    });
    widget.onLikeChanged(!wasLiked, nextCount);
    _syncFeeds(liked: !wasLiked, likes: nextCount);
    try {
      await ref
          .read(postRepositoryProvider)
          .toggleLike(widget.postId, wasLiked);
    } catch (_) {
      if (mounted) {
        setState(() {
          _liked = wasLiked;
          _likesCount = wasCount;
        });
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(S.of(context).feedCannotLike),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      widget.onLikeChanged(wasLiked, wasCount);
      _syncFeeds(liked: wasLiked, likes: wasCount);
    } finally {
      _busyLike = false;
    }
  }

  void _doubleTapLike() {
    HapticFeedback.mediumImpact();
    if (!_liked) _toggleLike();
    setState(() => _heartAt = _lastTapDown);
    _heartCtrl.forward(from: 0);
  }

  // ── Comentários ──────────────────────────────────────────────────────────

  static int _totalOf(List<PostComment> list) =>
      list.fold<int>(0, (n, c) => n + 1 + c.replies.length);

  void _watchComments() {
    if (_commentsSub != null) return;
    _commentsSub = ref.listenManual<AsyncValue<List<PostComment>>>(
      commentsViewModelProvider(widget.postId),
      (_, next) {
        final list = next.value;
        if (list == null || !mounted) return;
        final total = _totalOf(list);
        final base = _commentsBase;
        if (base == null) {
          _commentsBase = total;
          return;
        }
        final updated = (widget.commentsCount + (total - base)).clamp(
          0,
          1 << 30,
        );
        if (updated != _commentsCount) {
          setState(() => _commentsCount = updated);
          widget.onCommentsCountChanged?.call(updated);
          _syncFeeds(comments: updated);
        }
      },
      fireImmediately: true,
    );
  }

  Future<void> _openComments() async {
    HapticFeedback.selectionClick();
    _watchComments();
    await showModalBottomSheet<void>(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: widget.postId),
    );
  }

  void _share() {
    ShareToChatSheet.show(
      context,
      postId: widget.postId,
      postCaption: widget.caption,
      postImageUrl: widget.imageUrl,
      authorName: widget.authorName,
    );
  }

  // ── Arrasto para fechar (Listener: não disputa a arena com o zoom) ──────

  void _onPointerDown(PointerDownEvent e) {
    _pointers.add(e.pointer);
    if (_pointers.length > 1) {
      _cancelDrag();
      return;
    }
    _spring.stop();
    _pointerTotal = Offset.zero;
    _velocity = VelocityTracker.withKind(e.kind)
      ..addPosition(e.timeStamp, e.position);
    _dragging = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_closing || _pointers.length != 1 || _isZoomed) return;
    _velocity?.addPosition(e.timeStamp, e.position);
    if (!_dragging) {
      _pointerTotal += e.delta;
      if (_pointerTotal.dy.abs() > 10 &&
          _pointerTotal.dy.abs() > _pointerTotal.dx.abs() * 1.2) {
        _dragging = true;
        _drag = Offset.zero;
      } else {
        return;
      }
    }
    setState(() => _drag += e.delta);
  }

  void _onPointerUp(PointerUpEvent e) {
    final wasDragging = _dragging;
    _pointers.remove(e.pointer);
    if (!wasDragging || _closing) return;
    _dragging = false;
    final vy = _velocity?.getVelocity().pixelsPerSecond.dy ?? 0;
    final flick =
        vy.abs() > kPostViewerDismissVelocity && vy.sign == _drag.dy.sign;
    if (_drag.dy.abs() > kPostViewerDismissDistance || flick) {
      _closing = true;
      Navigator.of(context).maybePop();
    } else {
      _springBack();
    }
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _pointers.remove(e.pointer);
    _cancelDrag();
  }

  void _cancelDrag() {
    if (_dragging || _drag != Offset.zero) {
      _dragging = false;
      _springBack();
    }
  }

  void _springBack() {
    _springFrom = _drag;
    _spring.forward(from: 0);
  }

  void _onSpring() {
    final t = Curves.easeOutCubic.transform(_spring.value);
    setState(() => _drag = Offset.lerp(_springFrom, Offset.zero, t)!);
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final progress = (_drag.dy.abs() / 300).clamp(0.0, 1.0);
    final chromeOpacity = (1 - progress * 2).clamp(0.0, 1.0);
    final scale = 1 - progress * 0.15;

    final image = widget.imageProvider != null
        ? Image(image: widget.imageProvider!, fit: BoxFit.contain)
        : CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 150),
            placeholder: (_, _) => const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            ),
            errorWidget: (_, _, _) => const Center(
              child: Icon(
                LucideIcons.imageOff,
                color: Colors.white38,
                size: 64,
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 1 - progress),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Column(
          children: [
            Opacity(
              opacity: chromeOpacity,
              child: _Header(
                topInset: media.padding.top,
                authorName: widget.authorName,
                authorUsername: widget.authorUsername,
                authorAvatarUrl: widget.authorAvatarUrl,
                onClose: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.translate(
                      offset: _drag,
                      child: Transform.scale(
                        scale: scale,
                        child: GestureDetector(
                          key: const Key('postViewerPhoto'),
                          behavior: HitTestBehavior.opaque,
                          onDoubleTapDown: (d) =>
                              _lastTapDown = d.localPosition,
                          onDoubleTap: _doubleTapLike,
                          child: InteractiveViewer(
                            transformationController: _zoomCtrl,
                            minScale: 1,
                            maxScale: 5,
                            child: SizedBox.expand(child: image),
                          ),
                        ),
                      ),
                    ),
                    if (_heartAt != null)
                      Positioned(
                        left: _heartAt!.dx - 60,
                        top: _heartAt!.dy - 60,
                        child: IgnorePointer(
                          child: ScaleTransition(
                            key: const Key('postViewerHeartBurst'),
                            scale: _heartScale,
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 120,
                              shadows: [
                                Shadow(color: _kLikeRed, blurRadius: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: chromeOpacity,
              child: _Footer(
                bottomInset: media.padding.bottom,
                maxExpandedHeight: media.size.height * 0.4,
                authorName: widget.authorName,
                caption: widget.caption,
                liked: _liked,
                likesCount: _likesCount,
                commentsCount: _commentsCount,
                onLike: () {
                  HapticFeedback.lightImpact();
                  _toggleLike();
                },
                onComment: _openComments,
                onShare: _share,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.topInset,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatarUrl,
    required this.onClose,
  });

  final double topInset;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4, topInset + 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(LucideIcons.x, color: Colors.white, size: 24),
            onPressed: onClose,
          ),
          BraweAvatar(
            avatarUrl: authorAvatarUrl,
            displayName: authorName,
            size: 36,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  '@$authorUsername',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.bottomInset,
    required this.maxExpandedHeight,
    required this.authorName,
    required this.caption,
    required this.liked,
    required this.likesCount,
    required this.commentsCount,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final double bottomInset;
  final double maxExpandedHeight;
  final String authorName;
  final String caption;
  final bool liked;
  final int likesCount;
  final int commentsCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (caption.trim().isNotEmpty) ...[
            _ExpandableCaption(
              authorName: authorName,
              caption: caption,
              moreLabel: s.shareActionMore,
              maxExpandedHeight: maxExpandedHeight,
            ),
            const SizedBox(height: 14),
          ],
          Wrap(
            spacing: 26,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ViewerAction(
                key: const Key('postViewerLike'),
                icon: Icons.favorite_rounded,
                outlineIcon: LucideIcons.heart,
                filled: liked,
                color: liked ? _kLikeRed : Colors.white,
                label: _formatCount(likesCount),
                onTap: onLike,
              ),
              _ViewerAction(
                key: const Key('postViewerComment'),
                icon: LucideIcons.messageCircle,
                color: Colors.white,
                label: _formatCount(commentsCount),
                onTap: onComment,
              ),
              _ViewerAction(
                key: const Key('postViewerShare'),
                icon: LucideIcons.send,
                color: Colors.white,
                label: s.feedSend,
                onTap: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatCount(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

class _ExpandableCaption extends StatefulWidget {
  const _ExpandableCaption({
    required this.authorName,
    required this.caption,
    required this.moreLabel,
    required this.maxExpandedHeight,
  });

  final String authorName;
  final String caption;
  final String moreLabel;
  final double maxExpandedHeight;

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  static const _collapsedLines = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(color: Colors.white, fontSize: 14, height: 1.4);
    final span = TextSpan(
      style: base,
      children: [
        TextSpan(
          text: '${widget.authorName} ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: widget.caption),
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        final painter = TextPainter(
          text: span,
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: c.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        if (_expanded) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxExpandedHeight),
            child: SingleChildScrollView(child: Text.rich(span)),
          );
        }
        if (!overflows) return Text.rich(span);
        return GestureDetector(
          key: const Key('postViewerCaptionMore'),
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                span,
                maxLines: _collapsedLines,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.moreLabel,
                style: base.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewerAction extends StatelessWidget {
  const _ViewerAction({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.outlineIcon,
    this.filled = true,
  });

  final IconData icon;
  final IconData? outlineIcon;
  final bool filled;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(filled ? icon : (outlineIcon ?? icon), color: color, size: 26),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
