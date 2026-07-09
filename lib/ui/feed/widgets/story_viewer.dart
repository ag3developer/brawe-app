import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../domain/models/story.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../../core/widgets/brawe_story_media.dart';
import '../../profile/widgets/profile_screen.dart' show userStoriesProvider;
import '../view_models/stories_view_model.dart';
import 'story_gift_sheet.dart';
import 'gift_flight_overlay.dart';

/// Visualizador de stories full-screen.
///
/// Recursos:
/// - Avatar real do autor + selo de verificado
/// - Reprodução de vídeo (mediaType == 'video') com video_player
/// - Progress bar sincronizada (imagem: 5s; vídeo: duração real)
/// - Tap esquerdo/direito para navegar; long-press para pausar
/// - Menu (•••): excluir (próprio) / deixar de seguir / bloquear / denunciar
class StoryViewer extends ConsumerStatefulWidget {
  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.onStoryViewed,
  });

  final List<Story> stories;
  final int initialIndex;
  final void Function(String storyId)? onStoryViewed;

  @override
  ConsumerState<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends ConsumerState<StoryViewer>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  final GlobalKey _creatorAvatarKey = GlobalKey();

  late AnimationController _progressController;
  Timer? _timer;
  VideoPlayerController? _videoController;
  bool _paused = false;
  bool _muted = false;
  bool _sendingReply = false;
  bool _reactionFlash = false;
  // Quando o long-press abre o menu, evita que `onLongPressEnd` retome o
  // story (o menu cuida do resume ao fechar).
  bool _menuOpenedByLongPress = false;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();

  static const _imageDuration = Duration(seconds: 5);

  Story get _story => widget.stories[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(vsync: this);
    _startStory();
    _notifyViewed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  void _notifyViewed() {
    if (_currentIndex < 0 || _currentIndex >= widget.stories.length) return;
    final storyId = widget.stories[_currentIndex].id;
    // Callback do parent (UI cache).
    widget.onStoryViewed?.call(storyId);
    // Persiste no backend (fire-and-forget; ignora falhas silenciosamente).
    // Backend não conta view do próprio autor, então é seguro chamar sempre.
    ref.read(storiesRepositoryProvider).markAsViewed(storyId).catchError((_) {});
  }

  Future<void> _startStory() async {
    _timer?.cancel();
    await _videoController?.dispose();
    _videoController = null;
    _progressController.reset();
    _paused = false;

    final story = _story;
    if (story.isVideo && story.mediaUrl.isNotEmpty) {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl));
      _videoController = ctrl;
      try {
        await ctrl.initialize();
        if (!mounted) return;
        await ctrl.setVolume(_muted ? 0 : 1);
        final duration = ctrl.value.duration > Duration.zero
            ? ctrl.value.duration
            : _imageDuration;
        _progressController.duration = duration;
        await ctrl.play();
        _progressController.forward();
        _timer = Timer(duration, _nextStory);
        setState(() {});
      } catch (_) {
        _progressController.duration = _imageDuration;
        _progressController.forward();
        _timer = Timer(_imageDuration, _nextStory);
      }
    } else {
      _progressController.duration = _imageDuration;
      _progressController.forward();
      _timer = Timer(_imageDuration, _nextStory);
    }

    // 🚀 Pré-cache do próximo story em background — quando o usuário
    // avançar, a próxima mídia já estará no cache (ou pelo menos com
    // DNS+TLS aquecidos para vídeo). Best-effort, ignora falhas.
    _precacheNeighbors();
  }

  /// Pré-baixa silenciosamente o story imediatamente seguinte (e o
  /// anterior, p/ usuários que voltam) para tornar a navegação fluida.
  void _precacheNeighbors() {
    // i+1 é o caso comum (usuário sempre avança).
    final next = _currentIndex + 1;
    if (next < widget.stories.length) {
      final s = widget.stories[next];
      if (s.mediaUrl.isNotEmpty) {
        if (s.isVideo) {
          // Warm-up assíncrono (DNS+TLS+manifest); não bloqueia UI.
          unawaited(StoryMediaPrecache.warmUpVideo(s.mediaUrl));
        } else if (mounted) {
          unawaited(
            StoryMediaPrecache.precacheStoryImage(context, s.mediaUrl),
          );
        }
      }
    }
  }

  void _pause() {
    if (_paused) return;
    _paused = true;
    _timer?.cancel();
    _progressController.stop();
    _videoController?.pause();
  }

  void _resume() {
    if (!_paused) return;
    _paused = false;
    final total = _progressController.duration ?? _imageDuration;
    final remaining = total * (1 - _progressController.value);
    _progressController.forward();
    _videoController?.play();
    _timer = Timer(remaining, _nextStory);
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _startStory();
      _notifyViewed();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _startStory();
      _notifyViewed();
    } else {
      _startStory();
    }
  }

  Future<void> _openMenu() async {
    _pause();
    final currentUserId = ref.read(authStateProvider).value?.id;
    final isOwn = currentUserId != null && currentUserId == _story.authorId;

    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => ForceDarkTheme(
        child: Container(
          decoration: BoxDecoration(
            color: sheetCtx.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sheetCtx.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (isOwn)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text(S.of(sheetCtx).viewerDeleteStory,
                        style: const TextStyle(color: Colors.red)),
                    onTap: () => Navigator.pop(sheetCtx, 'delete'),
                  )
                else ...[
                  ListTile(
                    leading: Icon(Icons.person_off_outlined,
                        color: sheetCtx.colors.textPrimary),
                    title: Text(S.of(sheetCtx).viewerUnfollow,
                        style: TextStyle(color: sheetCtx.colors.textPrimary)),
                    onTap: () => Navigator.pop(sheetCtx, 'unfollow'),
                  ),
                  ListTile(
                    leading: Icon(Icons.block, color: sheetCtx.colors.textPrimary),
                    title: Text(S.of(sheetCtx).viewerBlockUser,
                        style: TextStyle(color: sheetCtx.colors.textPrimary)),
                    onTap: () => Navigator.pop(sheetCtx, 'block'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: Colors.red),
                    title: Text(S.of(sheetCtx).viewerReport,
                        style: const TextStyle(color: Colors.red)),
                    onTap: () => Navigator.pop(sheetCtx, 'report'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (action == null) {
      _resume();
      return;
    }
    switch (action) {
      case 'delete':
        await _deleteStory();
        break;
      case 'unfollow':
        await _unfollow();
        _resume();
        break;
      case 'block':
        await _block();
        break;
      case 'report':
        await _report();
        _resume();
        break;
    }
  }

  Future<void> _deleteStory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // evita fechar por toque fora
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: Text(S.of(context).viewerDeleteStory,
            style: const TextStyle(color: Colors.white)),
        content: Text(S.of(context).viewerDeleteConfirm,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(S.of(context).viewerCancel,
                style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(S.of(context).viewerDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      _resume();
      return;
    }
    try {
      await ref
          .read(storiesViewModelProvider.notifier)
          .deleteStory(_story.id);
      // Invalida também o cache do anel de stories do perfil — sem isso o
      // anel colorido continua aparecendo e o usuário acha que "não deletou".
      ref.invalidate(userStoriesProvider(_story.authorId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerStoryDeleted)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _resume();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerDeleteError(e))),
      );
    }
  }

  Future<void> _unfollow() async {
    try {
      await ref.read(socialRepositoryProvider).unfollowUser(_story.authorId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerUnfollowed(_story.authorUsername))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerUnfollowError)),
      );
    }
  }

  Future<void> _block() async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        title: Text(S.of(ctx).viewerBlockUser,
            style: TextStyle(color: ctx.colors.textPrimary)),
        content: Text(
          S.of(ctx).viewerBlockConfirm(_story.authorUsername),
          style: TextStyle(color: ctx.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).viewerCancel,
                style: TextStyle(color: ctx.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(ctx).viewerBlock, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      _resume();
      return;
    }
    try {
      await ref.read(socialActionsServiceProvider).blockUser(
            _story.authorUsername.isNotEmpty
                ? _story.authorUsername
                : _story.authorId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerBlocked(_story.authorUsername))),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _resume();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerBlockError)),
      );
    }
  }

  Future<void> _report() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => ForceDarkTheme(
        child: Container(
          decoration: BoxDecoration(
            color: sheetCtx.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sheetCtx.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(sheetCtx).viewerReportPrompt,
                        style: TextStyle(
                            color: sheetCtx.colors.textSecondary, fontSize: 13)),
                  ),
                ),
                _reasonTile(sheetCtx, 'spam', S.of(sheetCtx).viewerReportSpam),
                _reasonTile(sheetCtx, 'harassment', S.of(sheetCtx).viewerReportHarassment),
                _reasonTile(sheetCtx, 'inappropriate', S.of(sheetCtx).viewerReportInappropriate),
                _reasonTile(sheetCtx, 'impersonation', S.of(sheetCtx).viewerReportImpersonation),
                _reasonTile(sheetCtx, 'other', S.of(sheetCtx).viewerReportOther),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
    if (reason == null) return;
    try {
      await ref.read(socialActionsServiceProvider).report(
            targetType: 'story',
            targetId: _story.id,
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerReportSent)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerReportError)),
      );
    }
  }

  Widget _reasonTile(BuildContext ctx, String r, String label) => ListTile(
        title: Text(label, style: TextStyle(color: ctx.colors.textPrimary)),
        trailing: Icon(Icons.chevron_right, color: ctx.colors.textTertiary),
        onTap: () => Navigator.pop(ctx, r),
      );

  @override
  Widget build(BuildContext context) {
    final story = _story;

    // ── AnnotatedRegion ────────────────────────────────────────────────
    // Mesmo com `SystemUiMode.immersiveSticky` definido em `story_ring_avatar.dart`,
    // o usuário pode trazer a status/nav bar com swipe da borda (Android)
    // ou top edge (iOS). Quando reaparecerem, queremos que fiquem:
    //   • Status bar: transparente, ícones BRANCOS (sobre fundo escuro do story)
    //   • Nav bar Android: transparente, ícones BRANCOS
    // Sem AnnotatedRegion, o sistema usa o estilo herdado do Scaffold pai,
    // que no nosso app é light (ícones pretos sobre fundo claro) — ficariam
    // invisíveis sobre o fundo preto do story. Padrão Instagram/TikTok.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
      backgroundColor: Colors.black,
      // ── Imersivo: estende corpo atrás de status bar e nav bar ─────
      // Sem `extendBody*` o Scaffold reservaria padding pras barras
      // do sistema (mesmo elas estando escondidas), criando uma faixa
      // preta no topo/rodapé do story de 24-48px. Como o nosso story
      // já trata `MediaQuery.padding` internamente para posicionar
      // header/footer, extender o corpo é seguro.
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _prevStory();
          } else if (details.globalPosition.dx > width * 2 / 3) {
            _nextStory();
          }
        },
        onLongPressStart: (_) {
          // Segurar abre o menu de ações imediatamente (com vibração).
          // `_openMenu` já pausa o story e o retoma quando o sheet fecha.
          HapticFeedback.mediumImpact();
          _menuOpenedByLongPress = true;
          _openMenu();
        },
        onLongPress: () {
          // Já tratado em onLongPressStart; mantido vazio para suprimir
          // o comportamento padrão.
        },
        onLongPressEnd: (_) {
          if (_menuOpenedByLongPress) {
            _menuOpenedByLongPress = false;
            return;
          }
          _resume();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Mídia (imagem ou vídeo) — usa BraweStoryMedia para um
            // loading profissional sem expor a "letra inicial gigante"
            // enquanto o vídeo está inicializando ou a imagem baixando.
            // Ver `lib/ui/core/widgets/brawe_story_media.dart`.
            BraweStoryMedia(
              isVideo: story.isVideo,
              mediaUrl: story.mediaUrl,
              videoController: _videoController,
              authorName: story.authorName.isNotEmpty
                  ? story.authorName
                  : story.authorUsername,
              authorAvatarUrl: story.authorAvatarUrl,
              onRetry: _startStory,
              // Dimensões reais da mídia — disponíveis quando publicado via web.
              // Permitem detectar imagens landscape e aplicar contain + fundo blur
              // em vez de cover (que cortaria a imagem de forma indesejada).
              mediaWidth: story.mediaWidth,
              mediaHeight: story.mediaHeight,
            ),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent, Colors.black45],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
            ),

            // Header top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: List.generate(widget.stories.length, (i) {
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: SizedBox(
                                  height: 3,
                                  child: i < _currentIndex
                                      ? Container(color: Colors.white)
                                      : i == _currentIndex
                                          ? AnimatedBuilder(
                                              animation: _progressController,
                                              builder: (_, __) =>
                                                  LinearProgressIndicator(
                                                value: _progressController.value,
                                                backgroundColor: Colors.white30,
                                                color: Colors.white,
                                                minHeight: 3,
                                              ),
                                            )
                                          : Container(color: Colors.white30),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // Avatar com cache, skeleton e fallback
                            // determinístico de cor — ver BraweAvatar.
                            // Substitui o CircleAvatar legado que mostrava
                            // a letra inicial enquanto baixava.
                            Padding(
                              key: _creatorAvatarKey,
                              padding: EdgeInsets.zero,
                              child: BraweAvatar(
                                avatarUrl: story.authorAvatarUrl,
                                displayName: story.authorName.isNotEmpty
                                    ? story.authorName
                                    : story.authorUsername,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          story.authorName.isNotEmpty
                                              ? story.authorName
                                              : story.authorUsername,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (story.isVerified) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          color: AppColors.electricPurple,
                                          size: 14,
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    story.timeAgo,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (story.isVideo)
                              IconButton(
                                icon: Icon(
                                  _muted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleMute,
                              ),
                            IconButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onPressed: _openMenu,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (story.caption != null)
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Text(
                  story.caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ),

            // Chip "Ver post original" quando o story é um repost
            if (story.originPostId != null && story.originPostId!.isNotEmpty)
              Positioned(
                bottom: story.caption != null ? 120 : 80,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // TODO: navegar para post detail quando a rota existir.
                    // Por ora, fecha o viewer para o usuário voltar ao feed.
                    Navigator.of(context).maybePop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          S.of(context).viewerSeeOriginalPost,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Reaction flash overlay (animação ❤ ao reagir)
            if (_reactionFlash)
              const Center(
                child: Icon(
                  Icons.favorite,
                  size: 140,
                  color: Color(0xFFFF3B7E),
                ),
              ),

            // Reply bar / viewers indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(16, 8, 16,
                          8 + MediaQuery.of(context).viewInsets.bottom),
                  child: _isOwn
                      ? _buildOwnerFooter(story)
                      : _buildReplyBar(story),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  bool get _isOwn {
    final me = ref.read(authStateProvider).value?.id;
    return me != null && me == _story.authorId;
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _videoController?.setVolume(_muted ? 0 : 1);
  }

  Future<void> _sendQuickReaction({String emoji = '❤️'}) async {
    HapticFeedback.mediumImpact();
    setState(() => _reactionFlash = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _reactionFlash = false);
    });
    try {
      await ref
          .read(storiesRepositoryProvider)
          .react(_story.id, reaction: emoji);
    } catch (_) {
      // silencioso
    }
  }

  Future<void> _openReactionPicker() async {
    _pause();
    HapticFeedback.selectionClick();
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StoryReactionPicker(),
    );
    if (!mounted) return;
    _resume();
    if (result != null) {
      await _sendQuickReaction(emoji: result);
    }
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sendingReply) return;
    setState(() => _sendingReply = true);
    try {
      await ref.read(storiesRepositoryProvider).reply(_story.id, text);
      if (!mounted) return;
      _replyController.clear();
      _replyFocus.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerReplySent)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).viewerReplyError)),
      );
    } finally {
      if (mounted) setState(() => _sendingReply = false);
      _resume();
    }
  }

  Future<void> _openViewers() async {
    _pause();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.nearBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StoryViewersSheet(storyId: _story.id),
    );
    if (mounted) _resume();
  }

  Widget _buildOwnerFooter(Story story) {
    return GestureDetector(
      onTap: _openViewers,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              story.viewsCount == 1
                  ? '1 visualização'
                  : '${story.viewsCount} visualizações',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar(Story story) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Campo de resposta — glassmorphism (blur + glass white).
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _replyController,
                  focusNode: _replyFocus,
                  cursorColor: AppColors.electricPurple,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onTap: _pause,
                  onSubmitted: (_) => _sendReply(),
                  decoration: InputDecoration(
                    hintText: S.of(context).viewerReplyHint,
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Botão de presente — chip glass.
        _StoryActionChip(
          icon: Icons.card_giftcard,
          onTap: _openGiftSheet,
        ),
        const SizedBox(width: 6),
        // Botão de coração — chip glass. Long-press abre picker de 6 reações.
        _StoryActionChip(
          icon: Icons.favorite_border,
          onTap: () => _sendQuickReaction(),
          onLongPress: _openReactionPicker,
        ),
        const SizedBox(width: 6),
        // Botão enviar — pulsa no gradient da marca.
        GestureDetector(
          onTap: _sendingReply ? null : _sendReply,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.electricPurple, AppColors.coolCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricPurple.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: _sendingReply
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Future<void> _openGiftSheet() async {
    _pause();
    final story = _story;
    final result = await StoryGiftSheet.show(
      context,
      storyId: story.id,
      creatorName: story.authorUsername.isNotEmpty
          ? story.authorUsername
          : story.authorName,
      creatorAvatarUrl: story.authorAvatarUrl,
    );
    if (!mounted) return;
    _resume();
    if (result != null) {
      GiftFlightOverlay.play(
        context,
        label: result.giftName,
        emoji: result.giftEmoji,
        iconUrl: result.iconUrl,
        quantity: result.quantity,
        endKey: _creatorAvatarKey,
      );
      _showGiftToast(result);
    }
  }

  void _showGiftToast(StoryGiftResult result) {
    final emoji = (result.giftEmoji != null && result.giftEmoji!.isNotEmpty)
        ? result.giftEmoji!
        : '🎁';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.electricPurple.withValues(alpha: 0.92),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                S.of(context).viewerGiftSent(result.giftName, result.quantity, result.totalCredits),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryViewersSheet extends ConsumerStatefulWidget {
  const _StoryViewersSheet({required this.storyId});
  final String storyId;
  @override
  ConsumerState<_StoryViewersSheet> createState() =>
      _StoryViewersSheetState();
}

class _StoryViewersSheetState extends ConsumerState<_StoryViewersSheet> {
  bool _loading = true;
  String? _error;
  List<StoryViewerInfo> _viewers = const [];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ref
          .read(storiesRepositoryProvider)
          .getViewers(widget.storyId);
      if (!mounted) return;
      setState(() {
        _viewers = res.viewers;
        _total = res.total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = S.of(context).viewerLoadViewersError;
        _loading = false;
      });
    }
  }

  String _relative(BuildContext context, DateTime dt) {
    final s = S.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return s.viewerTimeNow;
    if (diff.inHours < 1) return s.viewerTimeMinutes(diff.inMinutes);
    if (diff.inDays < 1) return s.viewerTimeHours(diff.inHours);
    return s.viewerTimeDays(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.visibility,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _loading
                      ? S.of(context).viewerLoading
                      : S.of(context).viewerViewsCount(_total),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.electricPurple),
                  )
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )
                    : _viewers.isEmpty
                        ? Center(
                            child: Text(
                              S.of(context).viewerNoViewers,
                              style: const TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            itemCount: _viewers.length,
                            itemBuilder: (_, i) {
                              final v = _viewers[i];
                              return ListTile(
                                leading: BraweAvatar(
                                  avatarUrl: v.avatarUrl,
                                  displayName: v.name,
                                  size: 40,
                                ),
                                title: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        v.name.isNotEmpty
                                            ? v.name
                                            : v.username,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (v.isVerified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified,
                                        color: AppColors.electricPurple,
                                        size: 14,
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  '@${v.username} · ${_relative(context, v.viewedAt)}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                                trailing: v.reaction != null &&
                                        v.reaction!.isNotEmpty
                                    ? Text(
                                        v.reaction!,
                                        style:
                                            const TextStyle(fontSize: 20),
                                      )
                                    : null,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

/// Chip de ação na reply bar (presente / coração) — glass + blur.
class _StoryActionChip extends StatelessWidget {
  const _StoryActionChip({
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Picker de reações para stories (6 emojis grandes em barra horizontal).
/// Espelha visualmente o reactions_bar do feed, mas é apresentado via
/// modal bottom sheet pois o story viewer já está em fullscreen.
class _StoryReactionPicker extends StatelessWidget {
  static const _emojis = ['❤️', '🔥', '😂', '😮', '😢', '👍'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final e in _emojis)
                _ReactionEmojiButton(
                  emoji: e,
                  onTap: () => Navigator.of(context).pop(e),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionEmojiButton extends StatefulWidget {
  const _ReactionEmojiButton({required this.emoji, required this.onTap});
  final String emoji;
  final VoidCallback onTap;

  @override
  State<_ReactionEmojiButton> createState() => _ReactionEmojiButtonState();
}

class _ReactionEmojiButtonState extends State<_ReactionEmojiButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 1.35 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}

