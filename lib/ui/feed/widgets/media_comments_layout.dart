import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/post_comment.dart';
import '../view_models/comments_view_model.dart';
import 'comments_sheet.dart';

/// Abre/fecha o painel de comentários embutido em um [MediaCommentsLayout].
class MediaCommentsController extends ChangeNotifier {
  String? _postId;
  String? _highlightCommentId;

  bool get isOpen => _postId != null;
  String? get postId => _postId;
  String? get highlightCommentId => _highlightCommentId;

  void open(String postId, {String? highlightCommentId}) {
    if (_postId == postId) return;
    _postId = postId;
    _highlightCommentId = highlightCommentId;
    notifyListeners();
  }

  void close() {
    if (_postId == null) return;
    _postId = null;
    _highlightCommentId = null;
    notifyListeners();
  }
}

/// Acompanha os comentários de [postId] e avisa o novo total
/// (`initialCount` + o que foi adicionado desde que o painel abriu).
/// A assinatura morre junto com o widget dono do [ref].
ProviderSubscription<AsyncValue<List<PostComment>>> watchCommentsCount(
  WidgetRef ref,
  String postId,
  int initialCount,
  ValueChanged<int> onChanged,
) {
  int? base;
  return ref.listenManual<AsyncValue<List<PostComment>>>(
    commentsViewModelProvider(postId),
    (_, next) {
      final list = next.value;
      if (list == null) return;
      final total = list.fold<int>(0, (n, c) => n + 1 + c.replies.length);
      if (base == null) {
        base = total;
        return;
      }
      onChanged((initialCount + (total - base!)).clamp(0, 1 << 30));
    },
    fireImmediately: true,
  );
}

/// Layout "estilo Reels/TikTok" para telas de mídia: ao abrir os comentários
/// a mídia ENCOLHE para a área acima do painel (e continua tocando) em vez de
/// ficar coberta. Com o teclado aberto o painel sobe e a mídia encolhe mais
/// (mínimo ~22% da altura). Tocar na mídia encolhida fecha o painel; o painel
/// pode ser arrastado (fechar / expandir). Voltar (Android / gesto do iOS)
/// fecha o painel antes da tela. Respeita "reduzir movimento" e centraliza
/// em tablets (painel com no máximo 640 de largura).
///
/// [media] é o conteúdo que encolhe (vídeo); [overlay] são os controles por
/// cima (somem enquanto os comentários estão abertos).
class MediaCommentsLayout extends StatefulWidget {
  const MediaCommentsLayout({
    super.key,
    required this.controller,
    required this.media,
    this.overlay,
    this.onTap,
    this.background = Colors.black,
  });

  final MediaCommentsController controller;
  final Widget media;
  final Widget? overlay;

  /// Toque na mídia com os comentários fechados (ex.: pausar / mostrar controles).
  final VoidCallback? onTap;
  final Color background;

  static const double panelFraction = 0.62;
  static const double expandedFraction = 0.92;
  static const double minMediaFraction = 0.22;
  static const double maxPanelWidth = 640;

  @override
  State<MediaCommentsLayout> createState() => _MediaCommentsLayoutState();
}

class _MediaCommentsLayoutState extends State<MediaCommentsLayout>
    with TickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  String? _shownId;
  String? _highlight;
  double _frac = MediaCommentsLayout.panelFraction;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _anim.addStatusListener((st) {
      if (st == AnimationStatus.dismissed && mounted) {
        setState(() {
          _shownId = null;
          _highlight = null;
          _frac = MediaCommentsLayout.panelFraction;
        });
      }
    });
    if (widget.controller.isOpen) {
      _shownId = widget.controller.postId;
      _highlight = widget.controller.highlightCommentId;
      _anim.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void didUpdateWidget(covariant MediaCommentsLayout old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
      _onController();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _anim.dispose();
    _snap.dispose();
    super.dispose();
  }

  Duration get _duration =>
      _reduceMotion ? Duration.zero : const Duration(milliseconds: 250);

  void _onController() {
    if (!mounted) return;
    final c = widget.controller;
    _anim.duration = _duration;
    if (c.isOpen) {
      setState(() {
        _shownId = c.postId;
        _highlight = c.highlightCommentId;
      });
      _anim.forward();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
      _anim.reverse();
    }
  }

  /// Distância entre a base deste layout e a base da tela (ex.: barra de
  /// navegação do app). Serve para saber quanto do teclado / área segura
  /// realmente invade o layout.
  double _distanceBelow() {
    final ro = context.findRenderObject();
    if (ro is RenderBox && ro.attached && ro.hasSize) {
      try {
        final screenH = MediaQuery.sizeOf(context).height;
        final bottom = ro.localToGlobal(Offset(0, ro.size.height)).dy;
        return (screenH - bottom).clamp(0.0, screenH);
      } catch (_) {}
    }
    return 0;
  }

  void _dragUpdate(double dy, double height) {
    _snap.stop();
    setState(() {
      _frac = (_frac - dy / height).clamp(
        0.3,
        MediaCommentsLayout.expandedFraction,
      );
    });
  }

  void _dragEnd(double velocity) {
    if (velocity > 700 || _frac < 0.45) {
      widget.controller.close();
      return;
    }
    final target = (velocity < -700 || _frac > 0.77)
        ? MediaCommentsLayout.expandedFraction
        : MediaCommentsLayout.panelFraction;
    final from = _frac;
    _snap.reset();
    void tick() {
      if (!mounted) return;
      setState(() {
        _frac =
            from + (target - from) * Curves.easeOutCubic.transform(_snap.value);
      });
    }

    _snap
      ..duration = _duration
      ..addListener(tick)
      ..forward().whenComplete(() => _snap.removeListener(tick));
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final open = controller.isOpen;
    return PopScope(
      canPop: !open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.close();
      },
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final mq = MediaQuery.of(context);
          final below = _distanceBelow();
          final kb = math.max(0.0, mq.viewInsets.bottom - below);
          final safeBottom = math.max(0.0, mq.viewPadding.bottom - below);
          final topInset = mq.padding.top;

          // Altura efetiva do painel: respeita o mínimo de mídia visível.
          final maxPanel = h - kb - MediaCommentsLayout.minMediaFraction * h;
          var panelH = math.min(_frac * h, maxPanel);
          panelH = math.max(panelH, math.min(180.0, maxPanel));
          panelH = math.max(panelH, 0);

          final targetScale = ((h - kb - panelH - topInset - 8) / h).clamp(
            0.12,
            1.0,
          );

          return AnimatedBuilder(
            animation: _t,
            builder: (context, _) {
              final t = _t.value;
              final scale = 1 + (targetScale - 1) * t;
              final dy = topInset * t;
              final radius = scale <= 0 ? 0.0 : 16 * t / scale;
              final showPanel = _shownId != null && t > 0;

              return ColoredBox(
                color: widget.background,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: open ? controller.close : widget.onTap,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform(
                              alignment: Alignment.topCenter,
                              transform:
                                  Matrix4.translationValues(0, dy, 0) *
                                  Matrix4.diagonal3Values(scale, scale, 1),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(radius),
                                child: AbsorbPointer(
                                  absorbing: open,
                                  child: widget.media,
                                ),
                              ),
                            ),
                            if (widget.overlay != null)
                              IgnorePointer(
                                ignoring: open,
                                child: Opacity(
                                  opacity: 1 - t,
                                  child: widget.overlay,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (showPanel)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: kb,
                        height: panelH,
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * (panelH + kb)),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: math.min(
                                  w,
                                  MediaCommentsLayout.maxPanelWidth,
                                ),
                              ),
                              child: CommentsPanel(
                                key: ValueKey(_shownId),
                                postId: _shownId!,
                                highlightCommentId: _highlight,
                                bottomSafe: kb > 0 ? 0 : safeBottom,
                                onClose: controller.close,
                                onDragUpdate: (d) => _dragUpdate(d, h),
                                onDragEnd: _dragEnd,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
