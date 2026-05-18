import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../domain/models/story.dart';
import '../../core/themes/app_colors.dart';
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
    final cb = widget.onStoryViewed;
    if (cb == null) return;
    if (_currentIndex < 0 || _currentIndex >= widget.stories.length) return;
    cb(widget.stories[_currentIndex].id);
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
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isOwn)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Excluir story',
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'delete'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.person_off_outlined,
                    color: Colors.white),
                title: const Text('Deixar de seguir',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'unfollow'),
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.white),
                title: const Text('Bloquear usuário',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'block'),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text('Denunciar',
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'report'),
              ),
            ],
          ],
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
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text('Excluir story',
            style: TextStyle(color: Colors.white)),
        content: const Text('Esta ação não pode ser desfeita.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story excluído.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _resume();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o story.')),
      );
    }
  }

  Future<void> _unfollow() async {
    try {
      await ref.read(socialRepositoryProvider).unfollowUser(_story.authorId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você deixou de seguir @${_story.authorUsername}.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível deixar de seguir.')),
      );
    }
  }

  Future<void> _block() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text('Bloquear usuário',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Você não verá mais conteúdo de @${_story.authorUsername}.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bloquear', style: TextStyle(color: Colors.red)),
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
        SnackBar(content: Text('@${_story.authorUsername} bloqueado.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _resume();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível bloquear.')),
      );
    }
  }

  Future<void> _report() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Por que você está denunciando?',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
            _reasonTile('spam', 'Spam ou enganoso'),
            _reasonTile('harassment', 'Assédio ou bullying'),
            _reasonTile('inappropriate', 'Conteúdo impróprio ou ofensivo'),
            _reasonTile('impersonation', 'Falsa identidade'),
            _reasonTile('other', 'Outro'),
            const SizedBox(height: 8),
          ],
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
        const SnackBar(content: Text('Denúncia enviada. Obrigado.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar a denúncia.')),
      );
    }
  }

  Widget _reasonTile(String r, String label) => ListTile(
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () => Navigator.pop(context, r),
      );

  @override
  Widget build(BuildContext context) {
    final story = _story;
    final isVideo =
        story.isVideo && _videoController?.value.isInitialized == true;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _prevStory();
          } else if (details.globalPosition.dx > width * 2 / 3) {
            _nextStory();
          }
        },
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media
            if (isVideo)
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              )
            else if (story.mediaUrl.isNotEmpty)
              Image.network(
                story.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(story),
              )
            else
              _placeholder(story),

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
                            CircleAvatar(
                              key: _creatorAvatarKey,
                              radius: 18,
                              backgroundColor: AppColors.slate,
                              backgroundImage: (story.authorAvatarUrl != null &&
                                      story.authorAvatarUrl!.isNotEmpty)
                                  ? NetworkImage(story.authorAvatarUrl!)
                                  : null,
                              child: (story.authorAvatarUrl == null ||
                                      story.authorAvatarUrl!.isEmpty)
                                  ? Text(
                                      story.authorName.isNotEmpty
                                          ? story.authorName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(color: Colors.white),
                                    )
                                  : null,
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

  Future<void> _sendQuickReaction() async {
    setState(() => _reactionFlash = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _reactionFlash = false);
    });
    try {
      await ref
          .read(storiesRepositoryProvider)
          .react(_story.id, reaction: '❤️');
    } catch (_) {
      // silencioso
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
        const SnackBar(content: Text('Resposta enviada.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível responder.')),
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
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _replyController,
              focusNode: _replyFocus,
              style: const TextStyle(color: Colors.white),
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onTap: _pause,
              onSubmitted: (_) => _sendReply(),
              decoration: const InputDecoration(
                hintText: 'Responder ao story...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _openGiftSheet(),
          child: const Icon(Icons.card_giftcard,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _sendQuickReaction,
          child: const Icon(Icons.favorite_border,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _sendingReply ? null : _sendReply,
          child: _sendingReply
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send, color: Colors.white, size: 28),
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
                'Enviou ${result.giftName} x${result.quantity} · 💎 ${result.totalCredits}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(Story story) {
    return Container(
      color: AppColors.slate,
      child: Center(
        child: Text(
          story.authorName.isNotEmpty
              ? story.authorName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
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
        _error = 'Não foi possível carregar visualizadores.';
        _loading = false;
      });
    }
  }

  String _relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return 'há ${diff.inMinutes}m';
    if (diff.inDays < 1) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
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
                      ? 'Carregando...'
                      : _total == 1
                          ? '1 visualização'
                          : '$_total visualizações',
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
                        ? const Center(
                            child: Text(
                              'Ainda ninguém viu este story.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            itemCount: _viewers.length,
                            itemBuilder: (_, i) {
                              final v = _viewers[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.slate,
                                  backgroundImage: (v.avatarUrl != null &&
                                          v.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(v.avatarUrl!)
                                      : null,
                                  child: (v.avatarUrl == null ||
                                          v.avatarUrl!.isEmpty)
                                      ? Text(
                                          v.name.isNotEmpty
                                              ? v.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )
                                      : null,
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
                                  '@${v.username} · ${_relative(v.viewedAt)}',
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

