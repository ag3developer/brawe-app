import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/repositories/explore_repository.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/live_viewer_event.dart';
import '../../../domain/models/user.dart';
import '../../live_feed/view_models/live_room_comments_view_model.dart';
import '../../live_feed/view_models/live_room_gifts_view_model.dart';
import '../../live/shared/widgets/overlays/gift_animation_overlay.dart';
import '../../live_feed/widgets/live_comments_overlay.dart';
import '../../live_feed/widgets/streamer_battle_hud.dart';
import 'share_live_sheet.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/battle_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../gen/l10n/app_localizations.dart';

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

  // Battle state
  String? _activeBattleId;
  String? _pendingBattleId;
  String? _pendingBattleFromName;

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
    // Escutar convites de batalha via Socket.IO
    WidgetsBinding.instance.addPostFrameCallback((_) => _subscribeToBattleEvents());
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
            S.of(context).broadcasterPermissionDenied,
          );
          _closeBroadcaster();
        }
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AppSnackBar.showError(
              context, S.of(context).broadcasterNoCamera);
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
        AppSnackBar.showError(
            context, S.of(context).broadcasterInitCameraError(e.toString()));
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
    // 🚫 Ignorar evento do próprio criador (broadcaster). O backend ecoa o
    // viewer_joined também para quem está transmitindo; não faz sentido
    // exibir "Você entrou" no toast.
    final authState = ref.read(authStateProvider);
    final currentUser = authState is AsyncData<User?> ? authState.value : null;
    final currentUserId = currentUser?.id;
    if (currentUserId != null && event.userId == currentUserId) return;
    // Também ignorar o streamer da sala (defesa extra caso o user id no payload
    // venha como o streamer_id ao invés do current user — mesmo efeito).
    if (event.userId.isNotEmpty && event.userId == _room.streamerId) return;
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
        AppSnackBar.showError(
            context, S.of(context).broadcasterInitCameraFailed);
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
        AppSnackBar.showError(
            context, S.of(context).broadcasterRoomUpdateFailed(error.toString()));
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
            S.of(context).broadcasterMissingStreamCreds,
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
        AppSnackBar.showSuccess(context, S.of(context).broadcasterConnectedLive);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _isTogglingStream = false;
        });
        AppSnackBar.showError(
            context, S.of(context).broadcasterStreamStartError(error.toString()));
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
          AppSnackBar.showSuccess(context, S.of(context).broadcasterLiveResumed);
        }
      } else {
        if (!_isStreaming) return;
        await ref.read(liveRepositoryProvider).pauseLive(_room.id);
        if (mounted) {
          setState(() => _isPaused = true);
          _stopLiveElapsedTicker();
          AppSnackBar.showSuccess(context, S.of(context).broadcasterLivePaused);
        }
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(
            context, S.of(context).broadcasterPauseToggleError(error.toString()));
      }
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
    final s = S.of(context);
    if (!_isStreaming && !_isPaused) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.slate,
          title: Text(s.broadcasterDiscardTitle,
              style: const TextStyle(color: Colors.white)),
          content: Text(
            s.broadcasterDiscardMessage,
            style: const TextStyle(color: AppColors.coolGray),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(s.broadcasterCancel)),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.broadcasterDiscard,
                  style: const TextStyle(color: AppColors.mutedRed)),
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
        title: Text(s.broadcasterEndTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          s.broadcasterEndMessage,
          style: const TextStyle(color: AppColors.coolGray),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.broadcasterContinueLive)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.broadcasterEnd,
                style: const TextStyle(color: AppColors.mutedRed)),
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

  // ════════════════════════════════════════════════════════════════
  // BATTLE
  // ════════════════════════════════════════════════════════════════

  void _subscribeToBattleEvents() {
    final socket = ref.read(socketServiceProvider);
    socket.on(AppConstants.eventBattleInvite, _onBattleInvite);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
  }

  void _unsubscribeFromBattleEvents() {
    final socket = ref.read(socketServiceProvider);
    socket.off(AppConstants.eventBattleInvite);
    socket.off(AppConstants.eventBattleStarted);
  }

  void _onBattleInvite(dynamic raw) {
    if (!mounted) return;
    Map<String, dynamic> data = {};
    if (raw is Map<String, dynamic>) data = raw;
    final battleId = data['battle_id'] as String?;
    final fromName = data['from_streamer'] as String?;
    if (battleId == null) return;
    setState(() {
      _pendingBattleId = battleId;
      _pendingBattleFromName = fromName ?? '?';
    });
    _showBattleInviteDialog(battleId, fromName ?? '?');
  }

  void _onBattleStarted(dynamic raw) {
    if (!mounted) return;
    Map<String, dynamic> data = {};
    if (raw is Map<String, dynamic>) data = raw;
    final battleId = data['battle_id'] as String?;
    if (battleId == null) return;
    setState(() {
      _activeBattleId = battleId;
      _pendingBattleId = null;
    });
  }

  Future<void> _showBattleInviteDialog(String battleId, String fromName) async {
    if (!mounted) return;
    final l10n = S.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: Row(
          children: [
            const Icon(Icons.sports_kabaddi, color: AppColors.electricPurple),
            const SizedBox(width: 10),
            Text(
              l10n.battleInviteReceived(fromName),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.battleDecline,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
            ),
            child: Text(l10n.battleAccept),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (accepted == true) {
      try {
        await ref.read(battleServiceProvider).acceptBattle(battleId);
        setState(() => _activeBattleId = battleId);
      } catch (e) {
        if (mounted) AppSnackBar.showError(context, 'Erro ao aceitar batalha');
      }
    } else {
      try {
        await ref.read(battleServiceProvider).declineBattle(battleId);
      } catch (_) {}
      setState(() => _pendingBattleId = null);
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE SHEET — convidar para batalha
  // ════════════════════════════════════════════════════════════════

  Future<void> _showBattleSheet(BuildContext context) async {
    if (_activeBattleId != null) return; // já em batalha
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0E0E14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _BattleInviteSheet(
        myRoomId: _room.id,
        onInvite: (targetRoomId, durationSeconds) async {
          Navigator.pop(ctx);
          try {
            await ref.read(battleServiceProvider).inviteBattle(
              roomId: _room.id,
              targetRoomId: targetRoomId,
              durationSeconds: durationSeconds,
            );
            if (mounted) {
              AppSnackBar.showSuccess(context, 'Convite de batalha enviado!');
            }
          } catch (e) {
            if (mounted) {
              AppSnackBar.showError(context, 'Erro ao enviar convite');
            }
          }
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CO-HOST SHEET — convidar co-apresentador
  // ════════════════════════════════════════════════════════════════

  Future<void> _showCoHostSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0E0E14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people_alt_rounded,
                          color: Color(0xFF0EA5E9), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Convidar Co-host',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        Text('Transmita junto com outro criador',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Como funciona
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Como funciona:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...[
                        '📲 O co-host recebe uma notificação',
                        '🎥 A tela divide automaticamente',
                        '💬 Vocês compartilham o chat ao vivo',
                        '⏱ Sem limite de tempo',
                      ].map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(t, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Seguidores online (placeholder)
                Text('Seguidores online',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 72,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(Icons.person_outline, color: Colors.white38, size: 22),
                          ),
                          const SizedBox(height: 4),
                          Text('• • •', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(ctx);
                          // TODO: integrar co-host invite
                          AppSnackBar.showSuccess(context, 'Co-host em breve!');
                        },
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Enviar Convite de Co-host',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _unsubscribeFromBattleEvents();
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
    final s = S.of(context);
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
                  title: _isPaused
                      ? s.broadcasterMoreResumeLive
                      : s.broadcasterMorePauseBrb,
                  subtitle: _isPaused
                      ? s.broadcasterMoreResumeSubtitle
                      : s.broadcasterMorePauseSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    _togglePause();
                  },
                ),
                if (_cameras.length > 1)
                  _MoreOptionTile(
                    icon: Icons.flip_camera_ios_outlined,
                    iconColor: Colors.white,
                    title: s.broadcasterMoreSwitchCamera,
                    subtitle: s.broadcasterMoreSwitchCameraSubtitle,
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchCamera();
                    },
                  ),
                _MoreOptionTile(
                  icon: Icons.share_outlined,
                  iconColor: Colors.white,
                  title: s.broadcasterMoreShareLive,
                  subtitle: s.broadcasterMoreShareLiveSubtitle,
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
                  title: s.broadcasterMoreEndLive,
                  subtitle: s.broadcasterMoreEndLiveSubtitle,
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

            // ===== Battle HUD (streamer) =====
            if (_activeBattleId != null)
              Positioned.fill(
                child: StreamerBattleHud(
                  battleId: _activeBattleId!,
                  myStreamerId: _room.streamerId,
                ),
              ),

            // ===== UI Layers =====
            // Top bar (HUD) — floating
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(
                        isStreaming: _isStreaming,
                        isPaused: _isPaused,
                        viewerCount: commentsState.viewerCount,
                        likes: commentsState.likeCount,
                        messages: commentsState.totalComments,
                        totalGiftsValue: commentsState.totalGiftsValue,
                        elapsedLabel: _formatDuration(_liveElapsed),
                        countFormatter: _formatCount,
                        onClose: _closeBroadcaster,
                        onSwitchCamera: _cameras.length > 1 ? _switchCamera : null,
                      ),
                      const SizedBox(height: 6),
                      if (viewerEvent != null)
                        _ViewerJoinedToast(
                          event: viewerEvent,
                          controller: _toastAnimController!,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Comments overlay — left-bottom floating
            Positioned(
              left: 14, right: 80, bottom: 90,
              child: _isStreaming || _isPaused || commentsState.comments.isNotEmpty
                  ? LiveCommentsOverlay(
                      comments: commentsState.comments,
                      isSending: commentsState.isSending,
                      onSendComment: (message) => ref
                          .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
                          .sendComment(message),
                    )
                  : const SizedBox.shrink(),
            ),

            // Bottom action bar — floating glass pill
            if (!_showCountdown && (_isStreaming || _isPaused))
              Positioned(
                left: 14, right: 14, bottom: 16,
                child: SafeArea(
                  top: false,
                  child: _LiveActionBar(
                    isPaused: _isPaused,
                    isTogglingPause: _isTogglingPause,
                    isTogglingStream: _isTogglingStream,
                    hasBattle: _activeBattleId != null,
                    onBattle: () => _showBattleSheet(context),
                    onCoHost: () => _showCoHostSheet(context),
                    onPauseResume: _togglePause,
                    onEnd: _closeBroadcaster,
                    onMoreOptions: () => _showMoreOptions(context),
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
    required this.totalGiftsValue,
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
  final double totalGiftsValue;
  final String elapsedLabel;
  final String Function(int) countFormatter;
  final VoidCallback onClose;
  final VoidCallback? onSwitchCamera;

  String _formatGiftValue(double v) {
    if (v <= 0) return '0';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    if (v >= 10) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

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
                  _InlineStat(
                    icon: Icons.diamond_outlined,
                    label: _formatGiftValue(totalGiftsValue),
                    iconColor: const Color(0xFF7DD3FC),
                  ),
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

    final s = S.of(context);
    final color = showPaused ? Colors.orange : Colors.red;
    final label = showPaused ? s.broadcasterBadgePaused : s.broadcasterBadgeLive;

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
                  S.of(context).broadcasterViewerJoined(event.viewerName),
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
// LIVE ACTION BAR — estilo TikTok Live
// ════════════════════════════════════════════════════════════════

class _LiveActionBar extends StatelessWidget {
  const _LiveActionBar({
    required this.isPaused,
    required this.isTogglingPause,
    required this.isTogglingStream,
    required this.hasBattle,
    required this.onBattle,
    required this.onCoHost,
    required this.onPauseResume,
    required this.onEnd,
    required this.onMoreOptions,
  });

  final bool isPaused;
  final bool isTogglingPause;
  final bool isTogglingStream;
  final bool hasBattle;
  final VoidCallback onBattle;
  final VoidCallback onCoHost;
  final VoidCallback onPauseResume;
  final VoidCallback onEnd;
  final VoidCallback onMoreOptions;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          // Pause / Resume
          _ActionBtn(
            icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            label: isPaused ? 'Retomar' : 'Pausar',
            color: isPaused ? const Color(0xFF22C55E) : Colors.orange,
            loading: isTogglingPause,
            onTap: onPauseResume,
          ),
          // ⚔ Batalha — destaque especial
          _ActionBtn(
            icon: Icons.sports_kabaddi_rounded,
            label: hasBattle ? 'Em batalha' : 'Batalha',
            color: AppColors.electricPurple,
            glow: !hasBattle,
            badge: hasBattle ? '⚔' : null,
            onTap: hasBattle ? null : onBattle,
          ),
          // 👥 Co-host
          _ActionBtn(
            icon: Icons.people_alt_rounded,
            label: 'Co-host',
            color: const Color(0xFF0EA5E9),
            onTap: onCoHost,
          ),
          // ···
          _ActionBtn(
            icon: Icons.more_horiz_rounded,
            label: 'Mais',
            color: Colors.white24,
            onTap: onMoreOptions,
            flat: true,
          ),
          // ⏹ Encerrar
          _ActionBtn(
            icon: Icons.stop_rounded,
            label: 'Encerrar',
            color: const Color(0xFFEF4444),
            glow: true,
            loading: isTogglingStream,
            onTap: onEnd,
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
    this.glow = false,
    this.flat = false,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  final bool glow;
  final bool flat;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: loading || disabled ? null : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: flat ? Colors.black.withValues(alpha: 0.4) : color.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: flat ? Border.all(color: Colors.white24) : null,
                    boxShadow: glow && !disabled
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: loading
                      ? const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : Icon(icon, color: Colors.white, size: 22),
                ),
                if (badge != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(badge!, style: const TextStyle(fontSize: 8)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: disabled ? 0.4 : 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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

// ──────────────────────────────────────────────────────────────────────────────
// Battle Invite Sheet — real live-room search
// ──────────────────────────────────────────────────────────────────────────────
class _BattleInviteSheet extends ConsumerStatefulWidget {
  const _BattleInviteSheet({
    required this.myRoomId,
    required this.onInvite,
  });

  final String myRoomId;
  final void Function(String targetRoomId, int durationSeconds) onInvite;

  @override
  ConsumerState<_BattleInviteSheet> createState() => _BattleInviteSheetState();
}

class _BattleInviteSheetState extends ConsumerState<_BattleInviteSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<LiveRoom> _rooms = [];
  bool _loading = true;
  String? _error;
  LiveRoom? _selected;
  int _durationSeconds = 300;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rooms = await ref.read(liveRepositoryProvider).getLiveFeed(limit: 20);
      if (mounted) {
        setState(() {
          _rooms = rooms.where((r) => r.id != widget.myRoomId).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Não foi possível carregar criadores ao vivo'; _loading = false; });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      _loadFeed();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await ref.read(exploreRepositoryProvider).search(q);
      // Convert live-type results to LiveRoom objects
      final liveRooms = results
          .where((r) => r.type == 'live' && r.id != widget.myRoomId)
          .map((r) => LiveRoom(
                id: r.id,
                slug: r.id,
                title: r.title,
                liveType: 'live',
                isPrivate: false,
                status: 'live',
                streamerId: (r.metadata['streamer_id'] ?? r.id).toString(),
                streamerName: r.subtitle ?? r.title,
                streamerAvatarUrl: r.thumbnail,
                viewerCount: (r.metadata['viewer_count'] as num?)?.toInt() ?? 0,
              ))
          .toList();
      if (mounted) setState(() { _rooms = liveRooms; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erro na busca'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E14),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sports_kabaddi_rounded,
                          color: AppColors.electricPurple, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Iniciar Batalha',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        Text('Escolha um criador ao vivo',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar criador...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                            onPressed: () { _searchCtrl.clear(); },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.07),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.electricPurple, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Duration picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Duração:',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    const SizedBox(width: 10),
                    ...[('3 min', 180), ('5 min', 300), ('10 min', 600)].map((opt) {
                      final selected = _durationSeconds == opt.$2;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _durationSeconds = opt.$2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.electricPurple.withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.electricPurple.withValues(alpha: 0.7)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(opt.$1,
                                style: TextStyle(
                                  color: selected ? AppColors.electricPurple : Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: Colors.white12, height: 20),
              // Rooms list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.electricPurple))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 36),
                                const SizedBox(height: 8),
                                Text(_error!, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                                const SizedBox(height: 12),
                                TextButton(onPressed: _loadFeed, child: const Text('Tentar novamente',
                                    style: TextStyle(color: AppColors.electricPurple))),
                              ],
                            ),
                          )
                        : _rooms.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.live_tv_rounded, color: Colors.white24, size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchCtrl.text.isNotEmpty
                                          ? 'Nenhum criador ao vivo encontrado'
                                          : 'Nenhum criador ao vivo agora',
                                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollCtrl,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                itemCount: _rooms.length,
                                itemBuilder: (_, i) {
                                  final room = _rooms[i];
                                  final isSelected = _selected?.id == room.id;
                                  return GestureDetector(
                                    onTap: () => setState(() =>
                                        _selected = isSelected ? null : room),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.electricPurple.withValues(alpha: 0.15)
                                            : Colors.white.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.electricPurple.withValues(alpha: 0.5)
                                              : Colors.white.withValues(alpha: 0.07),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Avatar with live badge
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor: AppColors.electricPurple.withValues(alpha: 0.3),
                                                backgroundImage: room.streamerAvatarUrl != null
                                                    ? NetworkImage(room.streamerAvatarUrl!)
                                                    : null,
                                                child: room.streamerAvatarUrl == null
                                                    ? Text(
                                                        room.streamerName.isNotEmpty
                                                            ? room.streamerName[0].toUpperCase()
                                                            : '?',
                                                        style: const TextStyle(
                                                            color: Colors.white, fontWeight: FontWeight.w700))
                                                    : null,
                                              ),
                                              Positioned(
                                                bottom: 0, right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFF0E0E14), width: 1.5),
                                                  ),
                                                  child: const Text('AO VIVO',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 7,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 0.3)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(room.streamerName,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 14),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis),
                                                const SizedBox(height: 2),
                                                if (room.title.isNotEmpty)
                                                  Text(room.title,
                                                      style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.45),
                                                          fontSize: 12),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.remove_red_eye_rounded,
                                                      color: Colors.white38, size: 12),
                                                  const SizedBox(width: 3),
                                                  Text('${room.viewerCount}',
                                                      style: const TextStyle(
                                                          color: Colors.white38,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                              if (isSelected)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Icon(Icons.check_circle_rounded,
                                                      color: AppColors.electricPurple, size: 18),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
              // Invite button
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _selected != null
                          ? const LinearGradient(colors: [Color(0xFF7C3AED), AppColors.electricPurple])
                          : null,
                      color: _selected == null ? Colors.white.withValues(alpha: 0.07) : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _selected != null
                          ? [BoxShadow(
                              color: AppColors.electricPurple.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _selected == null
                            ? null
                            : () => widget.onInvite(_selected!.id, _durationSeconds),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send_rounded,
                                  color: _selected != null ? Colors.white : Colors.white30, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _selected != null
                                    ? 'Convidar ${_selected!.streamerName}'
                                    : 'Selecione um criador',
                                style: TextStyle(
                                  color: _selected != null ? Colors.white : Colors.white30,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
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
  }
}
