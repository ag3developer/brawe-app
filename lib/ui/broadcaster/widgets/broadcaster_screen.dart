import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
import '../../../core/services/broadcast_audio_session.dart';
import '../../live/streamer/widgets/widgets.dart';

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
  Timer? _battleInviteTimeoutTimer;

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

    // ⭐ Configura AVAudioSession (iOS) / AudioFocus (Android) em modo
    // `videoRecording` ANTES de inicializar a câmera. Isso elimina o chiado
    // causado pelo modo default `voiceChat`/AGC agressivo do iOS.
    await BroadcastAudioSession.activate();

    // Câmera traseira tem sensor melhor e suporta 1080p; a frontal costuma
    // estar capada em 720p (sensor menor, sem OIS). Adaptamos o preset por
    // câmera para extrair o máximo de cada uma sem forçar um modo que ela
    // não suporta (o que causaria fallback silencioso para resolução menor).
    final isRearCamera =
        description.lensDirection == CameraLensDirection.back;
    final preset = isRearCamera
        ? ResolutionPreset.veryHigh // 1080p na traseira (melhor sensor)
        : ResolutionPreset.high;    // 720p na frontal (limite típico)

    final controller = CameraController(
      description,
      // Preview local — mesmo preset do streaming para evitar reescalonar.
      preset,
      enableAudio: true,
      streamingPreset: preset,
      // Android: usa pipeline OpenGL (hardware encoder) — qualidade superior
      // e menor uso de CPU/bateria.
      androidUseOpenGL: true,
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

    // Fechar o dialog automaticamente quando o convite expirar no backend (60s).
    // Usamos uma GlobalKey para poder fechar programaticamente.
    final dialogKey = GlobalKey();
    _battleInviteTimeoutTimer?.cancel();
    _battleInviteTimeoutTimer = Timer(const Duration(seconds: 55), () {
      if (!mounted) return;
      // Fecha o dialog se ainda estiver aberto
      final ctx = dialogKey.currentContext;
      if (ctx != null && Navigator.of(ctx, rootNavigator: true).canPop()) {
        Navigator.of(ctx, rootNavigator: true).pop(false);
      }
      setState(() => _pendingBattleId = null);
      AppSnackBar.showError(context, 'Convite de batalha expirou');
    });

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BattleInviteDialog(
        key: dialogKey,
        fromName: fromName,
        l10n: l10n,
      ),
    );

    _battleInviteTimeoutTimer?.cancel();

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

    // Verificar elegibilidade antes de abrir o sheet (UX antecipado)
    try {
      final eligResp = await ref.read(battleServiceProvider).checkEligibility();
      final data = (eligResp['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final battleData = (data['battle'] as Map?)?.cast<String, dynamic>() ?? {};
      final eligible = battleData['eligible'] as bool? ?? true;
      if (!eligible && mounted) {
        final reason = battleData['reason'] as String? ?? 'Você ainda não pode iniciar batalhas';
        AppSnackBar.showError(context, reason);
        return;
      }
    } catch (_) {
      // Se o endpoint falhar, abre o sheet mesmo assim (o backend valida de novo no invite)
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0E0E14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BattleInviteSheet(
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
    _battleInviteTimeoutTimer?.cancel();
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
    // Libera a sessão de áudio para outras telas/apps usarem o microfone.
    BroadcastAudioSession.deactivate();
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
                MoreOptionTile(
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
                  MoreOptionTile(
                    icon: Icons.flip_camera_ios_outlined,
                    iconColor: Colors.white,
                    title: s.broadcasterMoreSwitchCamera,
                    subtitle: s.broadcasterMoreSwitchCameraSubtitle,
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchCamera();
                    },
                  ),
                MoreOptionTile(
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
                MoreOptionTile(
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
                      BroadcasterTopBar(
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
                        ViewerJoinedToast(
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
                  child: LiveActionBar(
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

// ── Battle Invite Dialog ───────────────────────────────────────────────────
//
// AlertDialog isolado em StatefulWidget para gerenciar o timer de expiração
// visual (55 → 0 seg) sem depender do estado pai.

class _BattleInviteDialog extends StatefulWidget {
  const _BattleInviteDialog({
    super.key,
    required this.fromName,
    required this.l10n,
  });

  final String fromName;
  final S l10n;

  @override
  State<_BattleInviteDialog> createState() => _BattleInviteDialogState();
}

class _BattleInviteDialogState extends State<_BattleInviteDialog> {
  static const _totalSeconds = 55;
  int _remaining = _totalSeconds;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _tick?.cancel();
        // Fecha automaticamente como recusa quando expirar
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(false);
        }
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining / _totalSeconds;
    return AlertDialog(
      backgroundColor: AppColors.slate,
      title: Row(
        children: [
          const Icon(Icons.sports_kabaddi, color: AppColors.electricPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.l10n.battleInviteReceived(widget.fromName),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                _remaining > 15
                    ? AppColors.electricPurple
                    : const Color(0xFFEF4444),
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Expira em ${_remaining}s',
            style: TextStyle(
              color: _remaining > 15 ? Colors.white38 : const Color(0xFFEF4444),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            widget.l10n.battleDecline,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricPurple,
          ),
          child: Text(widget.l10n.battleAccept),
        ),
      ],
    );
  }
}
