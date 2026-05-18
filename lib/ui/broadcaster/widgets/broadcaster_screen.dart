import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/live_viewer_event.dart';
import '../../live_feed/view_models/live_room_comments_view_model.dart';
import '../../live_feed/view_models/live_room_gifts_view_model.dart';
import '../../live_feed/widgets/gift_animation_overlay.dart';
import '../../live_feed/widgets/live_comments_overlay.dart';
import 'share_live_sheet.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';

class BroadcasterScreen extends ConsumerStatefulWidget {
  const BroadcasterScreen({super.key, required this.room});

  final LiveRoom room;

  @override
  ConsumerState<BroadcasterScreen> createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends ConsumerState<BroadcasterScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  late LiveRoom _room;
  bool _isStreaming = false;
  bool _isPaused = false;
  bool _isInitialized = false;
  bool _isResolvingRoom = false;
  bool _isTogglingStream = false;
  bool _isTogglingPause = false;

  // Countdown state
  int _countdownSeconds = 5;
  bool _showCountdown = false;
  Timer? _countdownTimer;
  Timer? _heartbeatTimer;

  // Live elapsed timer
  DateTime? _liveStartedAt;
  Timer? _elapsedTicker;
  Duration _liveElapsed = Duration.zero;

  // Viewer-joined toast
  StreamSubscription<LiveViewerEvent>? _viewerEventSub;
  LiveViewerEvent? _lastViewerEvent;
  Timer? _viewerToastTimer;
  AnimationController? _toastAnimController;

  // Likes (atualizado em tempo real via socket like_count_update)
  // O valor inicial vem de widget.room.totalLikes e é sincronizado pelo LiveRoomCommentsViewModel.

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _isPaused = widget.room.isPaused;
    WidgetsBinding.instance.addObserver(this);
    _toastAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _initializeController();
    WakelockPlus.enable();
  }

  bool get _hasStreamingCredentials =>
      (_room.rtmpUrl?.trim().isNotEmpty ?? false) &&
      (_room.streamKey?.trim().isNotEmpty ?? false);

  Future<void> _initializeController() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();

      if (cameraStatus.isDenied || microphoneStatus.isDenied) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Precisamos de acesso à câmera e ao microfone para você entrar ao vivo.',
          );
          _closeBroadcaster();
        }
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AppSnackBar.showError(context, 'Nenhuma câmera encontrada neste dispositivo.');
          _closeBroadcaster();
        }
        return;
      }

      // Default: câmera frontal (selfie) — UX padrão para live.
      final frontIdx = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _currentCameraIndex = frontIdx >= 0 ? frontIdx : 0;

      await _setupCameraController(_cameras[_currentCameraIndex]);
      await _refreshRoomCredentialsIfNeeded();
      _subscribeToViewerEvents();

      if (mounted && !_isStreaming && !_showCountdown) {
        _startCountdown();
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao inicializar a câmera: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        AppSnackBar.showError(context, 'Erro ao inicializar a câmera: $e');
        _closeBroadcaster();
      }
    }
  }

  void _subscribeToViewerEvents() {
    _viewerEventSub?.cancel();
    _viewerEventSub = ref
        .read(liveRepositoryProvider)
        .watchViewerEvents(_room.id)
        .listen(_handleViewerEvent);
  }

  void _handleViewerEvent(LiveViewerEvent event) {
    if (!mounted) return;
    if (!event.joined) return; // Mostrar só entradas
    setState(() => _lastViewerEvent = event);
    _toastAnimController?.forward(from: 0);
    _viewerToastTimer?.cancel();
    _viewerToastTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await _toastAnimController?.reverse();
      if (!mounted) return;
      setState(() => _lastViewerEvent = null);
    });
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Failed to initialize camera controller: $e');
      if (mounted) {
        AppSnackBar.showError(context, 'Falha ao inicializar a câmera.');
      }
    }
  }

  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdownSeconds = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownSeconds > 1) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        setState(() => _showCountdown = false);
        _goLiveAutomatically();
      }
    });
  }

  Future<void> _goLiveAutomatically() async {
    await _toggleStreaming();
    try {
      await ref.read(liveRepositoryProvider).startLive(_room.id);
    } catch (e) {
      debugPrint('Error calling startLive API: $e');
    }
  }

  void _startLiveElapsedTicker() {
    _stopLiveElapsedTicker();
    _liveStartedAt ??= DateTime.now();
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _liveElapsed = DateTime.now().difference(_liveStartedAt!);
      });
    });
  }

  void _stopLiveElapsedTicker() {
    _elapsedTicker?.cancel();
    _elapsedTicker = null;
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!mounted || !_isStreaming) {
        _stopHeartbeat();
        return;
      }

      try {
        final response =
            await ref.read(liveRepositoryProvider).sendHeartbeat(_room.id);
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final count = data['viewer_count'];
          if (count is int && mounted) {
            ref.read(liveRepositoryProvider).updateViewerCount(_room.id, count);
          }
        }
      } catch (e) {
        debugPrint('Heartbeat failed: $e');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null ||
        cameraController.value.isInitialized != true) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController.dispose();
      if (_isStreaming) {
        // BACKGROUND PAUSE: marca paused, mantém live no backend (BRB).
        unawaited(_silentPauseOnBackground());
        if (mounted) {
          setState(() {
            _isStreaming = false;
            _isPaused = true;
          });
        }
        _stopLiveElapsedTicker();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Recriar câmera; user precisa clicar "Resume Live" para voltar ao ar.
      _setupCameraController(cameraController.description);
    }
  }

  Future<void> _refreshRoomCredentialsIfNeeded() async {
    if (_hasStreamingCredentials || _isResolvingRoom) return;
    setState(() => _isResolvingRoom = true);
    try {
      final freshRoom =
          await ref.read(liveRepositoryProvider).getRoom(_room.id);
      if (!mounted || freshRoom == null) return;
      setState(() => _room = _mergeRoom(_room, freshRoom));
    } on Failure catch (failure) {
      if (mounted) AppSnackBar.showError(context, failure.toDisplayMessage());
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(context, 'Não foi possível atualizar a live: $error');
      }
    } finally {
      if (mounted) setState(() => _isResolvingRoom = false);
    }
  }

  LiveRoom _mergeRoom(LiveRoom current, LiveRoom fresh) {
    return current.copyWith(
      title: fresh.title.isNotEmpty ? fresh.title : current.title,
      description: fresh.description ?? current.description,
      category: fresh.category ?? current.category,
      liveType: fresh.liveType,
      isPrivate: fresh.isPrivate,
      status: fresh.status,
      viewerCount: fresh.viewerCount,
      playbackId: fresh.playbackId ?? current.playbackId,
      streamUrl: fresh.streamUrl ?? current.streamUrl,
      rtmpUrl: fresh.rtmpUrl ?? current.rtmpUrl,
      streamKey: fresh.streamKey ?? current.streamKey,
      thumbnailUrl: fresh.thumbnailUrl ?? current.thumbnailUrl,
      streamerId: fresh.streamerId,
      streamerName: fresh.streamerName,
      streamerAvatarUrl: fresh.streamerAvatarUrl ?? current.streamerAvatarUrl,
    );
  }

  String _buildStreamUrl(String rtmpUrl, String streamKey) {
    final normalizedUrl = rtmpUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final normalizedKey = streamKey.trim().replaceFirst(RegExp(r'^/+'), '');
    return '$normalizedUrl/$normalizedKey';
  }

  Future<void> _toggleStreaming() async {
    if (!_isInitialized || _controller == null || _isTogglingStream) return;
    setState(() => _isTogglingStream = true);

    try {
      if (_isStreaming) {
        _stopHeartbeat();
        _stopLiveElapsedTicker();
        await _controller?.stopVideoStreaming();
        if (mounted) {
          setState(() {
            _isStreaming = false;
            _isTogglingStream = false;
            _isPaused = false;
          });
        }
        return;
      }

      await _refreshRoomCredentialsIfNeeded();
      if (!mounted) return;

      final rtmpUrl = _room.rtmpUrl?.trim();
      final streamKey = _room.streamKey?.trim();

      if (rtmpUrl == null || rtmpUrl.isEmpty || streamKey == null || streamKey.isEmpty) {
        setState(() => _isTogglingStream = false);
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Não foi possível iniciar: URL RTMP ou chave de transmissão ausente.',
          );
        }
        return;
      }

      final fullUrl = _buildStreamUrl(rtmpUrl, streamKey);
      await _controller?.startVideoStreaming(fullUrl);

      if (mounted) {
        setState(() {
          _isStreaming = true;
          _isTogglingStream = false;
          _liveStartedAt ??= DateTime.now();
        });
        _startHeartbeat();
        _startLiveElapsedTicker();
        AppSnackBar.showSuccess(context, 'Conectado! Você está ao vivo. 🔴');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _isTogglingStream = false;
        });
        AppSnackBar.showError(context, 'Erro ao iniciar transmissão: $error');
      }
      try {
        await ref.read(liveRepositoryProvider).endLive(_room.id);
      } catch (_) {}
    }
  }

  Future<void> _togglePause() async {
    if (_isTogglingPause) return;
    setState(() => _isTogglingPause = true);

    try {
      if (_isPaused) {
        // RESUME: se câmera foi destruída em background, reinicia RTMP.
        if (!_isStreaming) {
          // Garantir câmera ativa antes de retomar
          if (_controller == null || _controller!.value.isInitialized != true) {
            await _setupCameraController(_cameras[_currentCameraIndex]);
          }
          await _refreshRoomCredentialsIfNeeded();
          final rtmpUrl = _room.rtmpUrl?.trim();
          final streamKey = _room.streamKey?.trim();
          if (rtmpUrl != null && rtmpUrl.isNotEmpty && streamKey != null && streamKey.isNotEmpty) {
            final fullUrl = _buildStreamUrl(rtmpUrl, streamKey);
            await _controller?.startVideoStreaming(fullUrl);
          }
        }
        await ref.read(liveRepositoryProvider).resumeLive(_room.id);
        if (mounted) {
          setState(() {
            _isPaused = false;
            _isStreaming = true;
          });
          _startHeartbeat();
          _startLiveElapsedTicker();
          AppSnackBar.showSuccess(context, 'Live retomada — você está ao vivo.');
        }
      } else {
        if (!_isStreaming) return;
        await ref.read(liveRepositoryProvider).pauseLive(_room.id);
        if (mounted) {
          setState(() => _isPaused = true);
          _stopLiveElapsedTicker();
          AppSnackBar.showSuccess(context, 'Live pausada (BRB).');
        }
      }
    } catch (error) {
      if (mounted) AppSnackBar.showError(context, 'Erro ao pausar/retomar: $error');
    } finally {
      if (mounted) setState(() => _isTogglingPause = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _controller == null || !_isInitialized) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    final wasStreaming = _isStreaming;
    if (_isStreaming) {
      _stopHeartbeat();
      await _controller?.stopVideoStreaming();
      setState(() => _isStreaming = false);
    }

    await _setupCameraController(_cameras[_currentCameraIndex]);

    if (wasStreaming && mounted) {
      await _toggleStreaming();
    }
  }

  Future<void> _silentPauseOnBackground() async {
    try {
      await _controller?.stopVideoStreaming();
    } catch (_) {}
    try {
      await ref.read(liveRepositoryProvider).pauseLive(_room.id);
    } catch (_) {}
  }

  Future<bool> _confirmCloseDialog() async {
    if (!_isStreaming && !_isPaused) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.slate,
          title: const Text('Descartar live?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Você criou uma live mas ainda não começou a transmitir. Deseja descartá-la?',
            style: TextStyle(color: AppColors.coolGray),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Descartar', style: TextStyle(color: AppColors.mutedRed)),
            ),
          ],
        ),
      );
      return discard ?? false;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text('Encerrar live?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja finalizar a transmissão? Seus viewers serão desconectados.',
          style: TextStyle(color: AppColors.coolGray),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Continuar ao vivo')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Encerrar', style: TextStyle(color: AppColors.mutedRed)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Future<void> _closeBroadcaster() async {
    if (!mounted) return;

    final confirmed = await _confirmCloseDialog();
    if (!confirmed || !mounted) return;

    _stopHeartbeat();
    _stopLiveElapsedTicker();
    _countdownTimer?.cancel();

    if (_isStreaming) {
      try {
        await _controller?.stopVideoStreaming();
      } catch (_) {}
    }

    try {
      await ref.read(liveRepositoryProvider).endLive(_room.id);
    } catch (e) {
      debugPrint('endLive failed on close: $e');
    }

    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _viewerToastTimer?.cancel();
    _viewerEventSub?.cancel();
    _toastAnimController?.dispose();
    _stopHeartbeat();
    _stopLiveElapsedTicker();
    if (_isStreaming) {
      _controller?.stopVideoStreaming();
    }
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hh > 0) return '$hh:$mm:$ss';
    return '$mm:$ss';
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  Future<void> _showMoreOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _MoreOptionTile(
                  icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  iconColor: _isPaused ? const Color(0xFF22C55E) : Colors.orange,
                  title: _isPaused ? 'Retomar live' : 'Pausar (BRB)',
                  subtitle: _isPaused
                      ? 'Volta ao ar e continua a transmissão'
                      : 'Pausa a transmissão sem encerrar',
                  onTap: () {
                    Navigator.pop(ctx);
                    _togglePause();
                  },
                ),
                if (_cameras.length > 1)
                  _MoreOptionTile(
                    icon: Icons.flip_camera_ios_outlined,
                    iconColor: Colors.white,
                    title: 'Trocar câmera',
                    subtitle: 'Alterna entre frontal e traseira',
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchCamera();
                    },
                  ),
                _MoreOptionTile(
                  icon: Icons.share_outlined,
                  iconColor: Colors.white,
                  title: 'Compartilhar live',
                  subtitle: 'Enviar preview da live aos seus seguidores',
                  onTap: () {
                    Navigator.pop(ctx);
                    ShareLiveSheet.show(
                      context,
                      roomId: widget.room.id,
                      title: widget.room.title,
                      streamerName: widget.room.streamerName,
                      thumbnailUrl: widget.room.thumbnailUrl,
                    );
                  },
                ),
                _MoreOptionTile(
                  icon: Icons.stop_rounded,
                  iconColor: AppColors.mutedRed,
                  title: 'Encerrar live',
                  subtitle: 'Finaliza a transmissão para todos',
                  onTap: () {
                    Navigator.pop(ctx);
                    _closeBroadcaster();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(
      liveRoomCommentsViewModelProvider(widget.room.id),
    );

    ref.watch(liveRoomGiftsViewModelProvider(widget.room.id));

    ref.listen<LiveRoomCommentsState>(
      liveRoomCommentsViewModelProvider(widget.room.id),
      (previous, next) {
        final errorMessage = next.errorMessage;
        if (errorMessage == null || errorMessage == previous?.errorMessage) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
        ref
            .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
            .clearError();
      },
    );

    if (!_isInitialized ||
        _controller == null ||
        _controller!.value.isInitialized != true) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final screenRatio = size.aspectRatio;
    final cameraRatio = _controller!.value.aspectRatio;
    double scale = screenRatio < cameraRatio
        ? cameraRatio / screenRatio
        : screenRatio / cameraRatio;

    final viewerEvent = _lastViewerEvent;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ===== Camera Preview =====
            Center(
              child: Transform.scale(
                scale: scale,
                child: AspectRatio(
                  aspectRatio: cameraRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
            // ===== Gradient overlay (top + bottom) =====
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent, Colors.transparent, Colors.black87],
                  stops: [0.0, 0.18, 0.55, 1.0],
                ),
              ),
            ),

            // ===== Countdown =====
            if (_showCountdown)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Text(
                    '$_countdownSeconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // ===== Gift animations =====
            GiftAnimationOverlay(roomId: widget.room.id),

            // ===== UI Layers =====
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ----- HEADER (compacto: X · LIVE · stats inline · flip) -----
                    _TopBar(
                      isStreaming: _isStreaming,
                      isPaused: _isPaused,
                      viewerCount: commentsState.viewerCount,
                      likes: commentsState.likeCount,
                      messages: commentsState.totalComments,
                      elapsedLabel: _formatDuration(_liveElapsed),
                      countFormatter: _formatCount,
                      onClose: _closeBroadcaster,
                      onSwitchCamera: _cameras.length > 1 ? _switchCamera : null,
                    ),
                    const SizedBox(height: 6),

                    // ----- VIEWER-JOINED TOAST -----
                    if (viewerEvent != null)
                      _ViewerJoinedToast(
                        event: viewerEvent,
                        controller: _toastAnimController!,
                      ),

                    const Spacer(),

                    // ----- COMMENTS (bottom) -----
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isStreaming || _isPaused || commentsState.comments.isNotEmpty)
                            LiveCommentsOverlay(
                              comments: commentsState.comments,
                              isSending: commentsState.isSending,
                              onSendComment: (message) => ref
                                  .read(
                                    liveRoomCommentsViewModelProvider(
                                      widget.room.id,
                                    ).notifier,
                                  )
                                  .sendComment(message),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    // ----- BOTTOM ACTION BAR (compacto) -----
                    if (!_showCountdown && (_isStreaming || _isPaused))
                      _BottomActionBar(
                        isPaused: _isPaused,
                        isTogglingPause: _isTogglingPause,
                        isTogglingStream: _isTogglingStream,
                        onPauseResume: _togglePause,
                        onEnd: _closeBroadcaster,
                        onMoreOptions: () => _showMoreOptions(context),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TOP BAR
// ════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isStreaming,
    required this.isPaused,
    required this.viewerCount,
    required this.likes,
    required this.messages,
    required this.elapsedLabel,
    required this.countFormatter,
    required this.onClose,
    required this.onSwitchCamera,
  });

  final bool isStreaming;
  final bool isPaused;
  final int viewerCount;
  final int likes;
  final int messages;
  final String elapsedLabel;
  final String Function(int) countFormatter;
  final VoidCallback onClose;
  final VoidCallback? onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    final showStats = isStreaming || isPaused;
    return Row(
      children: [
        _CircleIconButton(icon: Icons.close, onTap: onClose),
        const SizedBox(width: 8),
        _LiveOrPausedBadge(isStreaming: isStreaming, isPaused: isPaused),
        const SizedBox(width: 8),
        if (showStats)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _InlineStat(icon: Icons.visibility, label: countFormatter(viewerCount)),
                  const SizedBox(width: 6),
                  _InlineStat(icon: Icons.favorite, label: countFormatter(likes), iconColor: Colors.redAccent),
                  const SizedBox(width: 6),
                  _InlineStat(icon: Icons.chat_bubble_outline, label: countFormatter(messages)),
                  const SizedBox(width: 6),
                  _InlineStat(icon: Icons.timer_outlined, label: elapsedLabel),
                ],
              ),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 6),
        if (onSwitchCamera != null)
          _CircleIconButton(icon: Icons.flip_camera_ios_outlined, onTap: onSwitchCamera!),
      ],
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.icon, required this.label, this.iconColor});
  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _LiveOrPausedBadge extends StatelessWidget {
  const _LiveOrPausedBadge({required this.isStreaming, required this.isPaused});
  final bool isStreaming;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final showPaused = isPaused;
    final showLive = isStreaming && !isPaused;

    if (!showPaused && !showLive) {
      return const SizedBox.shrink();
    }

    final color = showPaused ? Colors.orange : Colors.red;
    final label = showPaused ? 'PAUSED' : 'LIVE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// VIEWER JOINED TOAST
// ════════════════════════════════════════════════════════════════

class _ViewerJoinedToast extends StatelessWidget {
  const _ViewerJoinedToast({required this.event, required this.controller});

  final LiveViewerEvent event;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricPurple.withValues(alpha: 0.85),
                  AppColors.electricPurple.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricPurple.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.white24,
                  backgroundImage: (event.viewerAvatar != null && event.viewerAvatar!.isNotEmpty)
                      ? NetworkImage(event.viewerAvatar!)
                      : null,
                  child: (event.viewerAvatar == null || event.viewerAvatar!.isEmpty)
                      ? Text(
                          event.viewerName.isEmpty ? '?' : event.viewerName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  '${event.viewerName} entrou',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('👋', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// BOTTOM ACTION BAR
// ════════════════════════════════════════════════════════════════

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isPaused,
    required this.isTogglingPause,
    required this.isTogglingStream,
    required this.onPauseResume,
    required this.onEnd,
    required this.onMoreOptions,
  });

  final bool isPaused;
  final bool isTogglingPause;
  final bool isTogglingStream;
  final VoidCallback onPauseResume;
  final VoidCallback onEnd;
  final VoidCallback onMoreOptions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _CompactRoundButton(
            icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: isPaused ? const Color(0xFF22C55E) : Colors.orange.shade600,
            loading: isTogglingPause,
            onTap: onPauseResume,
            tooltip: isPaused ? 'Retomar' : 'Pausar',
          ),
          const SizedBox(width: 10),
          _CompactRoundButton(
            icon: Icons.more_horiz_rounded,
            color: Colors.black.withValues(alpha: 0.55),
            border: true,
            onTap: onMoreOptions,
            tooltip: 'Mais',
          ),
          const SizedBox(width: 10),
          _CompactRoundButton(
            icon: Icons.stop_rounded,
            color: Colors.red,
            loading: isTogglingStream,
            onTap: onEnd,
            tooltip: 'Encerrar',
            glow: true,
          ),
        ],
      ),
    );
  }
}

class _CompactRoundButton extends StatelessWidget {
  const _CompactRoundButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.loading = false,
    this.tooltip,
    this.border = false,
    this.glow = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool loading;
  final String? tooltip;
  final bool border;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border ? Border.all(color: Colors.white24) : null,
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : const [
                  BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              )
            : Icon(icon, color: Colors.white, size: 22),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}


class _MoreOptionTile extends StatelessWidget {
  const _MoreOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }
}
