import 'dart:async';
import '../../core/view_models/hidden_users_view_model.dart';
import 'dart:io' show Platform;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_comment.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/live_viewer_event.dart';
import '../../../domain/models/user.dart';
import 'live_summary_screen.dart';
import '../../live_feed/view_models/live_room_comments_view_model.dart';
import '../../live_feed/view_models/live_room_gifts_view_model.dart';
import '../../live/shared/widgets/overlays/gift_animation_overlay.dart';
import '../../live/shared/widgets/actions/actions.dart';
import '../../live/shared/widgets/chat/chat.dart';
import '../../live_feed/widgets/streamer_battle_hud.dart';
import 'share_live_sheet.dart';
import '../../live/shared/widgets/goal/live_goals.dart';
import '../../live/shared/widgets/hud/live_gift_ticker.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/ui/app_snackbar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/battle_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/services/broadcast_audio_session.dart';
import '../../../core/services/broadcast_audio_processing.dart';
import '../../live/streamer/widgets/widgets.dart';
import 'audio_processor_panel.dart';

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
  bool _isSwitchingCamera = false;
  BroadcastAudioMode _audioMode = BroadcastAudioMode.quality;

  late LiveRoom _room;
  final GlobalKey<LiveGoalsPillState> _goalsKey = GlobalKey<LiveGoalsPillState>();

  /// Editor de metas (botão Metas da barra de ações ou "Mais opções").
  Future<void> _openGoals() async {
    final saved = await LiveGoalsEditorSheet.show(context, roomId: widget.room.id, current: _room.goals);
    if (saved == null || !mounted) return;
    setState(() => _room = _room.copyWith(goals: saved));
    _goalsKey.currentState?.apply(saved);
  }
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
  SocketService? _battleSocket;
  // Anti double-click: a UI do dialog de convite tem 2 botões grandes
  // e o usuário ansioso aperta "Aceitar" 2x rápido → 2 HTTP calls → o
  // 2º falha com 400 "Este convite já foi respondido". Gate simples.
  bool _isAcceptingBattle = false;

  /// Convite RECEBIDO com dialog aberto (sou o streamer B).
  String? _incomingInviteId;
  GlobalKey? _incomingDialogKey;

  /// Convite ENVIADO aguardando resposta (sou o streamer A).
  _OutgoingInvite? _outgoingInvite;

  // Likes (atualizado em tempo real via socket like_count_update)
  // O valor inicial vem de widget.room.totalLikes e é sincronizado pelo LiveRoomCommentsViewModel.

  // Pausa ("Já voltamos"): prazo para retomar antes do encerramento.
  DateTime? _pausedUntil;
  Timer? _pauseTicker;

  /// Depois de retomar: "Voltando ao ar…" enquanto o vídeo chega aos
  /// espectadores (~12-20s de latência do Mux) e, em seguida, "Você está ao
  /// vivo" por alguns segundos — antes o criador não sabia se tinha voltado.
  _ResumeFeedback _resumeFeedback = _ResumeFeedback.none;
  Timer? _resumeFeedbackTimer;

  /// Encerramento em andamento (trava botões e re-entrada).
  bool _isClosing = false;

  // Chat do criador: mensagens sempre visíveis; o input abre sob demanda.
  bool _showChatInput = false;
  final TextEditingController _chatCtrl = TextEditingController();
  final FocusNode _chatFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Fullscreen imersivo: esconde status bar e nav bar durante o broadcast
    // (câmera ocupa 100% da tela, igual Stories/TikTok Live). Restaurado no
    // dispose. Ver ANDROID_EDGE_TO_EDGE_AUDIT.md, Fase E.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _room = widget.room;
    _isPaused = widget.room.isPaused;
    WidgetsBinding.instance.addObserver(this);
    _toastAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _initializeController();
    WakelockPlus.enable();
    // 🚀 Battle wiring: garantir conexão + presença na sala socket ANTES de
    // registrar handlers. Sem isso o `connect:battle:started` chegava antes
    // do handler estar registrado e o HUD nunca aparecia para o criador.
    // (ver _bootstrapBattleWiring para os 3 passos atômicos)
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _bootstrapBattleWiring(),
    );
  }

  bool get _hasStreamingCredentials =>
      (_room.rtmpUrl?.trim().isNotEmpty ?? false) &&
      (_room.streamKey?.trim().isNotEmpty ?? false);

  Future<void> _initializeController() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();

      // `!isGranted` (não só `isDenied`): "negado para sempre"/restrito
      // seguia adiante e falhava no initialize com erro genérico.
      if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            S.of(context).broadcasterPermissionDenied,
          );
          _closeBroadcaster(force: true);
        }
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AppSnackBar.showError(context, S.of(context).broadcasterNoCamera);
          _closeBroadcaster(force: true);
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
          context,
          S.of(context).broadcasterInitCameraError(e.toString()),
        );
        _closeBroadcaster(force: true);
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

  /// Cria e inicializa o controller da câmera. Retorna `false` se falhou.
  Future<bool> _setupCameraController(CameraDescription description) async {
    final old = _controller;
    if (old != null) {
      // Tira o controller antigo da árvore ANTES do dispose — senão o
      // CameraPreview desenha um controller já descartado durante a troca.
      if (mounted) setState(() => _controller = null);
      await old.dispose();
    }

    // ⭐ Configura AVAudioSession (iOS) / AudioFocus (Android) em modo
    // `videoRecording` ANTES de inicializar a câmera. Isso elimina o chiado
    // causado pelo modo default `voiceChat`/AGC agressivo do iOS.
    await BroadcastAudioSession.activate(mode: _audioMode);

    // 🎛️ Inicializa o processador de áudio nativo (EQ + Compressor + Limiter)
    // e aplica o preset salvo pelo streamer antes de iniciar a câmera.
    await BroadcastAudioProcessing.initialize();
    await BroadcastAudioProcessing.setPreset(
      BroadcastAudioProcessing.currentPreset,
    );

    // Câmera traseira tem sensor melhor e suporta 1080p; a frontal costuma
    // estar capada em 720p (sensor menor, sem OIS). Adaptamos o preset por
    // câmera para extrair o máximo de cada uma sem forçar um modo que ela
    // não suporta (o que causaria fallback silencioso para resolução menor).
    final isRearCamera = description.lensDirection == CameraLensDirection.back;
    final preset = isRearCamera
        ? ResolutionPreset
              .veryHigh // 1080p na traseira (melhor sensor)
        : ResolutionPreset.high; // 720p na frontal (limite típico)

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
      if (!mounted) return false;
      setState(() => _isInitialized = true);
      return true;
    } catch (e) {
      debugPrint('Failed to initialize camera controller: $e');
      if (mounted && !_isSwitchingCamera) {
        AppSnackBar.showError(
          context,
          S.of(context).broadcasterInitCameraFailed,
        );
      }
      return false;
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
    // Só marca a live como iniciada se o RTMP realmente subiu.
    if (!_isStreaming) return;
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
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      // Durante a pausa o RTMP está parado, mas a live continua — o
      // heartbeat segue para o servidor não encerrá-la por inatividade.
      if (!mounted || (!_isStreaming && !_isPaused)) {
        _stopHeartbeat();
        return;
      }

      try {
        final response = await ref
            .read(liveRepositoryProvider)
            .sendHeartbeat(_room.id);
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
    // Só `paused`/`hidden` (app realmente em segundo plano). `inactive`
    // dispara com Central de Controle, notificações e Face ID — antes isso
    // derrubava a câmera e pausava a live sem o criador sair do app.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      final CameraController? cameraController = _controller;
      if (cameraController == null ||
          cameraController.value.isInitialized != true) {
        return;
      }
      // `hidden` e `paused` chegam em sequência — libera uma vez só.
      if (_isClosing || _cameraReleasedInBackground) return;
      _cameraReleasedInBackground = true;
      _backgroundRelease = _onEnterBackground(cameraController);
    } else if (state == AppLifecycleState.resumed) {
      // Recriar câmera; criador toca "Retomar" para voltar ao ar.
      // Antes o guard `_controller == null → return` vinha ANTES daqui: como
      // o background já tinha zerado `_controller`, a câmera nunca era
      // recriada (preview preto/spinner e contagem interrompida não
      // retomava) até o criador tocar "Retomar".
      if (!_cameraReleasedInBackground) return;
      _cameraReleasedInBackground = false;
      if (_cameras.isEmpty) return;
      unawaited(_onReturnToForeground(_cameras[_currentCameraIndex]));
    }
  }

  bool _countdownInterrupted = false;

  /// Câmera liberada ao ir pro background (reabrir no `resumed`).
  bool _cameraReleasedInBackground = false;

  /// Dispose em andamento do background — o `resumed` espera ele terminar
  /// antes de abrir a câmera de novo (Android: "camera in use").
  Future<void>? _backgroundRelease;

  Future<void> _onEnterBackground(CameraController camera) async {
    // Contagem "5…4…" em andamento: interrompe (senão ela entra ao vivo
    // com a câmera já descartada e o erro encerrava a live).
    if (_showCountdown) {
      _countdownTimer?.cancel();
      _countdownInterrupted = true;
      if (mounted) setState(() => _showCountdown = false);
    }
    if (_isStreaming) {
      // BACKGROUND PAUSE: para o RTMP ANTES de descartar a câmera (depois
      // do dispose o stop não chega ao nativo e a conexão RTMP vazava).
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _isPaused = true;
          _pausedUntil = DateTime.now().add(_maxPause);
        });
      }
      _stopLiveElapsedTicker();
      _startPauseTicker();
      await _silentPauseOnBackground();
    }
    await camera.dispose();
    if (identical(_controller, camera) && mounted) {
      setState(() => _controller = null);
    }
  }

  Future<void> _onReturnToForeground(CameraDescription description) async {
    final pending = _backgroundRelease;
    _backgroundRelease = null;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {}
    }
    if (_isClosing || !mounted) return;
    // Já recriada por outro caminho (ex.: "Retomar" tocado muito rápido).
    if (_controller != null) return;
    await _setupCameraController(description);
    if (_countdownInterrupted && mounted && !_isStreaming) {
      _countdownInterrupted = false;
      _startCountdown();
    }
  }

  Future<void> _refreshRoomCredentialsIfNeeded() async {
    if (_hasStreamingCredentials || _isResolvingRoom) return;
    setState(() => _isResolvingRoom = true);
    try {
      final freshRoom = await ref
          .read(liveRepositoryProvider)
          .getRoom(_room.id);
      if (!mounted || freshRoom == null) return;
      setState(() => _room = _mergeRoom(_room, freshRoom));
    } on Failure catch (failure) {
      if (mounted) AppSnackBar.showError(context, failure.toDisplayMessage());
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          S.of(context).broadcasterRoomUpdateFailed(error.toString()),
        );
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

  /// Bitrate de acordo com a câmera ativa.
  /// Traseira (1080p): 4.5 Mbps — frontal (720p): 2.5 Mbps.
  /// Valores abaixo de 1.2 Mbps (default) geravam vídeo borrado no iOS.
  int get _streamBitrate {
    final isRear =
        _cameras.isNotEmpty &&
        _cameras[_currentCameraIndex].lensDirection == CameraLensDirection.back;
    return isRear
        ? 4500 *
              1024 // 4.5 Mbps para 1080p
        : 2500 * 1024; // 2.5 Mbps para 720p frontal
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

      if (rtmpUrl == null ||
          rtmpUrl.isEmpty ||
          streamKey == null ||
          streamKey.isEmpty) {
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
      await _controller?.startVideoStreaming(
        fullUrl,
        bitrate: _streamBitrate,
        androidUseOpenGL: true,
      );

      if (mounted) {
        setState(() {
          _isStreaming = true;
          _isTogglingStream = false;
          _liveStartedAt ??= DateTime.now();
        });
        _startHeartbeat();
        _startLiveElapsedTicker();
        AppSnackBar.showSuccess(
          context,
          S.of(context).broadcasterConnectedLive,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _isTogglingStream = false;
        });
        AppSnackBar.showError(
          context,
          S.of(context).broadcasterStreamStartError(error.toString()),
        );
      }
      // Não encerra a live aqui: uma falha momentânea (rede, câmera
      // voltando do background) matava a sala. O criador pode tentar de
      // novo ou encerrar pelo botão.
    }
  }

  /// Tempo máximo de pausa — igual a `LIVE_MAX_PAUSE_SECONDS` no backend.
  /// O `reconnect_window` do Mux é esse valor + 60s; passou disso o Mux
  /// encerraria a transmissão.
  static const _maxPause = Duration(minutes: 5);

  void _startPauseTicker() {
    _pauseTicker?.cancel();
    _pauseTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final until = _pausedUntil;
      if (!mounted || !_isPaused || until == null) {
        _pauseTicker?.cancel();
        return;
      }
      final left = until.difference(DateTime.now());
      if (left <= Duration.zero) {
        _pauseTicker?.cancel();
        AppSnackBar.showError(
          context,
          'A pausa passou de 5 minutos e a live foi encerrada.',
        );
        _closeBroadcaster(force: true);
        return;
      }
      if (left.inSeconds == 60) {
        AppSnackBar.showError(
          context,
          'Falta 1 minuto: retome a live ou ela será encerrada.',
        );
      }
      setState(() {}); // atualiza o contador do painel de pausa
    });
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
          if (rtmpUrl != null &&
              rtmpUrl.isNotEmpty &&
              streamKey != null &&
              streamKey.isNotEmpty) {
            final fullUrl = _buildStreamUrl(rtmpUrl, streamKey);
            await _controller?.startVideoStreaming(
              fullUrl,
              bitrate: _streamBitrate,
              androidUseOpenGL: true,
            );
          }
        }
        try {
          await ref.read(liveRepositoryProvider).resumeLive(_room.id);
        } catch (e) {
          // Ex.: servidor já não considera a live pausada — o RTMP já
          // voltou, então seguimos retomados.
          debugPrint('resumeLive falhou (seguindo): $e');
        }
        _pauseTicker?.cancel();
        if (mounted) {
          setState(() {
            _isPaused = false;
            _isStreaming = true;
            _pausedUntil = null;
          });
          _startHeartbeat();
          _startLiveElapsedTicker();
          _showResumeFeedback();
        }
      } else {
        if (!_isStreaming) return;
        // 1. Servidor primeiro: marca a pausa e avisa os espectadores na
        //    hora (socket `live_paused`). Se falhar, a live segue no ar.
        await ref.read(liveRepositoryProvider).pauseLive(_room.id);
        // 2. PARA o RTMP de verdade — antes a "pausa" só mudava um flag e
        //    câmera + microfone continuavam sendo transmitidos. Com o RTMP
        //    parado o Mux exibe o slate "Já voltamos" aos espectadores.
        try {
          await _controller?.stopVideoStreaming();
        } catch (e) {
          debugPrint('Pause: stopVideoStreaming falhou: $e');
        }
        if (mounted) {
          _resumeFeedbackTimer?.cancel();
          setState(() {
            _isPaused = true;
            _isStreaming = false;
            _pausedUntil = DateTime.now().add(_maxPause);
            _resumeFeedback = _ResumeFeedback.none;
          });
          _stopLiveElapsedTicker();
          _startPauseTicker();
          AppSnackBar.showSuccess(context, S.of(context).broadcasterLivePaused);
        }
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          S.of(context).broadcasterPauseToggleError(error.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingPause = false);
    }
  }

  void _showResumeFeedback() {
    _resumeFeedbackTimer?.cancel();
    setState(() => _resumeFeedback = _ResumeFeedback.resuming);
    _resumeFeedbackTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      setState(() => _resumeFeedback = _ResumeFeedback.live);
      _resumeFeedbackTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _resumeFeedback = _ResumeFeedback.none);
      });
    });
  }

  /// Próxima câmera ao alternar: frontal ⇄ traseira PRINCIPAL.
  ///
  /// iPhones expõem várias lentes traseiras (grande-angular, ultra, tele) em
  /// `availableCameras()`. Antes usávamos `índice + 1`, que caía em outra
  /// lente traseira — a frontal quase nunca voltava.
  int _nextCameraIndex() {
    final current = _cameras[_currentCameraIndex].lensDirection;
    final target = current == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    // A 1ª câmera de cada direção é a principal (grande-angular).
    final idx = _cameras.indexWhere((c) => c.lensDirection == target);
    return idx >= 0 ? idx : (_currentCameraIndex + 1) % _cameras.length;
  }

  /// Troca de câmera com a live no ar.
  ///
  /// O `rtmp_broadcaster` não troca a câmera com o stream ativo: é preciso
  /// parar o RTMP, recriar o controller e reconectar. Durante esse ~1-2s o
  /// Mux mostra o "slate" (ampulheta) para quem assiste — por isso a troca
  /// é feita o mais rápido possível e SEMPRE reconecta (antes, se a nova
  /// câmera falhasse, o RTMP nunca voltava e o slate ficava para sempre).
  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _controller == null || !_isInitialized) return;
    // Evita múltiplos taps enquanto troca
    if (_isSwitchingCamera) return;
    setState(() => _isSwitchingCamera = true);

    final previousIndex = _currentCameraIndex;
    final nextIndex = _nextCameraIndex();
    final wasStreaming = _isStreaming;

    try {
      // 1. Para RTMP silenciosamente (SEM parar heartbeat — live continua ativa)
      if (wasStreaming) {
        try {
          await _controller?.stopVideoStreaming();
        } catch (_) {}
      }

      // 2. Troca o controller para a nova câmera (dispose + init). Se a
      //    nova câmera falhar, volta para a anterior.
      _currentCameraIndex = nextIndex;
      final ok = await _setupCameraController(_cameras[nextIndex]);
      if (!ok && mounted) {
        _currentCameraIndex = previousIndex;
        await _setupCameraController(_cameras[previousIndex]);
        if (mounted) {
          AppSnackBar.showError(context, 'Não foi possível trocar a câmera');
        }
      }

      // 3. Reconecta o RTMP (com retry) — a live nunca pode ficar no slate.
      if (wasStreaming && mounted) await _restartStreamAfterSwitch();
    } catch (e) {
      debugPrint('_switchCamera error: $e');
    } finally {
      if (mounted) setState(() => _isSwitchingCamera = false);
    }
  }

  Future<void> _restartStreamAfterSwitch() async {
    final rtmpUrl = _room.rtmpUrl?.trim();
    final streamKey = _room.streamKey?.trim();
    if (rtmpUrl == null ||
        rtmpUrl.isEmpty ||
        streamKey == null ||
        streamKey.isEmpty) {
      return;
    }
    final fullUrl = _buildStreamUrl(rtmpUrl, streamKey);
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await _controller?.startVideoStreaming(
          fullUrl,
          bitrate: _streamBitrate,
          androidUseOpenGL: true,
        );
        if (mounted) setState(() => _isStreaming = true);
        return;
      } catch (e) {
        debugPrint('_switchCamera: restart RTMP falhou ($attempt/3): $e');
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }
    if (mounted) {
      setState(() => _isStreaming = false);
      AppSnackBar.showError(
        context,
        'A transmissão caiu ao trocar a câmera. Toque em Retomar.',
      );
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
          title: Text(
            s.broadcasterDiscardTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            s.broadcasterDiscardMessage,
            style: const TextStyle(color: AppColors.coolGray),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.broadcasterCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                s.broadcasterDiscard,
                style: const TextStyle(color: AppColors.mutedRed),
              ),
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
        title: Text(
          s.broadcasterEndTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          s.broadcasterEndMessage,
          style: const TextStyle(color: AppColors.coolGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.broadcasterContinueLive),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.broadcasterEnd,
              style: const TextStyle(color: AppColors.mutedRed),
            ),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  /// [force] encerra sem perguntar (pausa expirada, câmera/permissão
  /// indisponível) — antes esses casos abriam o "Encerrar live?" e, se o
  /// criador tocasse em continuar, ficava preso sem câmera nem controles.
  Future<void> _closeBroadcaster({bool force = false}) async {
    if (!mounted || _isClosing) return;

    if (!force) {
      final confirmed = await _confirmCloseDialog();
      if (!confirmed || !mounted || _isClosing) return;
    }
    // Trava re-entrada: X, "Encerrar" e "Mais" continuavam ativos durante
    // os até 8s do endLive → 2º diálogo, 2º endLive, 2ª navegação.
    setState(() => _isClosing = true);
    _pauseTicker?.cancel();

    _stopHeartbeat();
    _stopLiveElapsedTicker();
    _countdownTimer?.cancel();

    try {
      await _controller?.stopVideoStreaming();
    } catch (_) {}

    // ⚠️ BUG HISTÓRICO (Android): ao encerrar a live, o app ficava com uma
    // tela branca travada — não existia nenhuma tela de destino após o
    // `context.pop()`/`context.go('/home')` original, e se a chamada de
    // API abaixo travasse indefinidamente (sem timeout), o usuário ficava
    // preso pra sempre na tela do broadcaster já sem câmera ativa.
    //
    // Correção: 1) timeout de segurança na chamada de API — nunca trava
    // indefinidamente; 2) SEMPRE navega para uma tela de destino real
    // (LiveSummaryScreen) via `context.go` (substitui toda a pilha, não
    // dá pop pra uma tela intermediária que possa estar em estado ruim);
    // 3) fallback para `/home` se por algum motivo a navegação para o
    // resumo falhar.
    Map<String, dynamic> summaryData = const {};
    // 2 tentativas: se o encerramento falhar, a live ficaria "AO VIVO" no
    // feed (sem vídeo) até o monitor do servidor limpar.
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        summaryData = await ref
            .read(liveRepositoryProvider)
            .endLive(_room.id)
            .timeout(const Duration(seconds: 8));
        break;
      } catch (e) {
        debugPrint('endLive failed on close ($attempt/2): $e');
        // Segue mesmo assim — o resumo mostra o estado "indisponível",
        // mas o usuário NUNCA fica travado numa tela branca.
      }
    }

    if (!mounted) return;

    try {
      LiveSummaryScreen.show(
        context,
        data: LiveSummaryData.fromMap(summaryData),
        roomTitle: _room.title,
      );
    } catch (e) {
      debugPrint('Failed to navigate to LiveSummaryScreen: $e');
      if (mounted) context.go('/home');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE
  // ════════════════════════════════════════════════════════════════

  /// 🔧 Boot atômico do wiring de batalha (executado 1× após o 1º frame).
  ///
  /// Fluxo crítico — a ordem importa:
  ///   1. **Conectar** o socket e **aguardar** a conexão estabelecer.
  ///      Antes desse fix, `socket.on(...)` rodava com `_socket == null`
  ///      (registro silenciosamente perdido — `socket_service.dart` faz
  ///      `_socket?.on(...)`). Resultado: o evento `connect:battle:started`
  ///      chegava na sala mas o handler não existia → `_activeBattleId`
  ///      ficava `null` → HUD nunca aparecia para o criador.
  ///   2. **Entrar na sala socket** `live:{room_id}` via `connectToRoom`.
  ///      Sem isso, mesmo com o handler registrado o evento nunca seria
  ///      entregue (o backend só emite para quem fez `join_live`).
  ///   3. **Registrar handlers** de battle (agora seguro — socket pronto).
  ///   4. **Fallback REST**: checar se já existe batalha ativa nesta sala
  ///      (caso o app tenha sido aberto/reaberto no meio de uma batalha).
  ///      Espelha o que o viewer já faz em `_checkActiveBattle`.
  Future<void> _bootstrapBattleWiring() async {
    if (!mounted) return;
    try {
      // 1. Garantir socket conectado (await é essencial aqui)
      await ref.read(socketServiceProvider).connect();
    } catch (e) {
      debugPrint(
        'Broadcaster: socket connect failed (will retry on reconnect): $e',
      );
    }
    if (!mounted) return;

    // 2. Entrar na sala socket — broadcaster precisa receber eventos da sua
    //    própria sala (gifts, battle events, etc). O LiveRoomCommentsViewModel
    //    também faz isso, mas de forma lazy via ref.watch — não confiável
    //    para eventos críticos como battle.
    try {
      await ref.read(liveRepositoryProvider).connectToRoom(_room.id);
    } catch (e) {
      debugPrint('Broadcaster: connectToRoom failed: $e');
    }
    if (!mounted) return;

    // 3. Registrar handlers (agora o socket existe → `on` realmente registra)
    _subscribeToBattleEvents();

    // 4. Fallback REST: sincronizar batalha já em curso (idempotente)
    _checkExistingActiveBattle();
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE — socket wiring
  // ════════════════════════════════════════════════════════════════
  //
  // ⚠️ Sempre `off(evento, handler)`: `off(evento)` sem handler remove os
  // listeners de TODAS as telas/view models (ex.: BattleViewModel) — era
  // por isso que a 2ª batalha nunca aparecia.

  void _subscribeToBattleEvents() {
    _battleSocket = ref.read(socketServiceProvider);
    _attachBattleHandlers();
    // 🔁 Re-anexar handlers automaticamente após reconexões do socket.
    // O socket interno do socket_io_client é recriado nesses casos, então
    // qualquer `on(...)` chamado antes vira no-op.
    _battleSocket!.addReconnectCallback(_reattachBattleHandlers);
  }

  void _attachBattleHandlers() {
    final socket = _battleSocket;
    if (socket == null) return;
    _detachBattleHandlers();
    socket.on(AppConstants.eventBattleInvite, _onBattleInvite);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.on(AppConstants.eventBattleInviteStatus, _onBattleInviteStatus);
    socket.on(AppConstants.eventBattleCancelled, _onBattleCancelled);
  }

  void _detachBattleHandlers() {
    final socket = _battleSocket;
    if (socket == null) return;
    socket.off(AppConstants.eventBattleInvite, _onBattleInvite);
    socket.off(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.off(AppConstants.eventBattleInviteStatus, _onBattleInviteStatus);
    socket.off(AppConstants.eventBattleCancelled, _onBattleCancelled);
  }

  void _reattachBattleHandlers() {
    if (!mounted) return;
    _attachBattleHandlers();
    // Após reconectar também checamos batalha ativa por REST — cobre o caso
    // de o `started` ter sido emitido enquanto estávamos offline.
    _checkExistingActiveBattle();
  }

  void _unsubscribeFromBattleEvents() {
    _detachBattleHandlers();
    _battleSocket?.removeReconnectCallback(_reattachBattleHandlers);
    _battleSocket = null;
  }

  /// Fallback REST para descobrir batalha ativa quando o app foi aberto
  /// (ou recriado) durante uma batalha em andamento. Cobre o caso em que
  /// `connect:battle:started` foi emitido antes do socket estar pronto.
  Future<void> _checkExistingActiveBattle() async {
    if (!mounted || _activeBattleId != null) return;
    try {
      final result = await ref
          .read(battleServiceProvider)
          .getActiveBattleForRoom(_room.id);
      final battleId = result['battle_id'] as String?;
      if (!mounted || battleId == null || battleId.isEmpty) return;
      _enterBattle(battleId);
    } catch (_) {
      // 404 = sem batalha ativa — silencioso.
    }
  }

  void _enterBattle(String battleId) {
    if (!mounted) return;
    setState(() {
      _activeBattleId = battleId;
      if (_outgoingInvite?.battleId == battleId) _outgoingInvite = null;
      // Sincroniza liveType em memória — antes o app continuava achando
      // que estava em SOLO mesmo após o backend ter virado BATTLE.
      _room = _room.copyWith(liveType: 'battle');
    });
  }

  /// Volta para a live normal (fim, saída ou cancelamento da batalha).
  void _leaveBattle() {
    if (!mounted) return;
    setState(() {
      _activeBattleId = null;
      _room = _room.copyWith(liveType: 'solo');
    });
  }

  void _onBattleStarted(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    if (battleId == null || battleId.isEmpty) return;
    final roomA = data['room_a_id'] as String?;
    final roomB = data['room_b_id'] as String?;
    if ((roomA != null || roomB != null) &&
        roomA != _room.id &&
        roomB != _room.id) {
      return; // batalha de outra sala
    }
    _enterBattle(battleId);
  }

  /// Batalha cancelada (ex.: oponente encerrou a live na contagem).
  void _onBattleCancelled(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['battle_id'] != _activeBattleId) return;
    _leaveBattle();
    AppSnackBar.showError(context, 'A batalha foi cancelada');
  }

  /// Converte o payload bruto do socket em Map.
  /// O `socket_io_client` pode entregar o evento já decodificado (`Map`)
  /// ou como `String` JSON — depende do transport (websocket vs polling)
  /// e do encoding no servidor.
  Map<String, dynamic>? _parseSocketPayload(dynamic raw) {
    try {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) return Map<String, dynamic>.from(raw);
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      debugPrint('Broadcaster: socket payload parse error: $e (raw=$raw)');
    }
    return null;
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE — convite RECEBIDO (sou o streamer B)
  // ════════════════════════════════════════════════════════════════

  void _onBattleInvite(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    if (battleId == null || battleId.isEmpty) return;
    if (battleId == _incomingInviteId) return; // evento duplicado
    final fromName = (data['from_streamer'] as String?)?.trim();

    // Ocupado (em batalha, com outro convite aberto ou aguardando resposta
    // de um convite meu): recusa na hora — quem convidou recebe o aviso
    // imediatamente em vez de esperar 60s. Antes os dialogs empilhavam.
    if (_activeBattleId != null ||
        _incomingInviteId != null ||
        _outgoingInvite != null) {
      unawaited(
        ref
            .read(battleServiceProvider)
            .declineBattle(battleId)
            .then((_) {}, onError: (_) {}),
      );
      return;
    }

    final expiresIn = (data['expires_in_seconds'] as num?)?.toInt() ?? 60;
    _showBattleInviteDialog(
      battleId,
      fromName == null || fromName.isEmpty ? 'Um criador' : fromName,
      // Margem de 3s para a resposta chegar antes do backend expirar.
      (expiresIn - 3).clamp(5, 60),
    );
  }

  Future<void> _showBattleInviteDialog(
    String battleId,
    String fromName,
    int seconds,
  ) async {
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = S.of(context);
    final dialogKey = GlobalKey();
    _incomingInviteId = battleId;
    _incomingDialogKey = dialogKey;

    // true = aceitou · false = recusou/expirou localmente ·
    // null = fechado pelo app (convite cancelado/expirado no servidor).
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BattleInviteDialog(
        key: dialogKey,
        fromName: fromName,
        totalSeconds: seconds,
        l10n: l10n,
      ),
    );

    _incomingInviteId = null;
    _incomingDialogKey = null;
    if (!mounted || accepted == null) return;

    if (accepted) {
      // 🛡️ Gate anti double-click.
      if (_isAcceptingBattle) return;
      _isAcceptingBattle = true;
      try {
        await ref.read(battleServiceProvider).acceptBattle(battleId);
        // HUD já abre em "contagem" — o `started` chega em seguida.
        _enterBattle(battleId);
      } catch (e) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            BattleService.errorMessage(e, 'Não foi possível aceitar a batalha'),
          );
        }
      } finally {
        _isAcceptingBattle = false;
      }
    } else {
      try {
        await ref.read(battleServiceProvider).declineBattle(battleId);
      } catch (_) {
        // Já expirado/cancelado no servidor — nada a fazer.
      }
    }
  }

  /// Fecha o dialog de convite recebido sem responder (o servidor já
  /// cancelou/expirou o convite).
  void _closeIncomingDialog() {
    final ctx = _incomingDialogKey?.currentContext;
    if (ctx != null) Navigator.of(ctx).pop();
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE — estado do convite (eventos do servidor p/ os 2 streamers)
  // ════════════════════════════════════════════════════════════════

  void _onBattleInviteStatus(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    final status = data['status'] as String?;
    if (battleId == null || status == null) return;

    final iAmInviter = data['streamer_a_id'] == _room.streamerId;
    final outgoing = _outgoingInvite;
    final isMyOutgoing = outgoing?.battleId == battleId;
    final opponent = outgoing?.opponentName ?? 'O criador';

    switch (status) {
      case 'pending':
        // Cobre convites criados fora do sheet (ex.: revanche).
        if (iAmInviter && !isMyOutgoing && _activeBattleId == null) {
          _startOutgoingInvite(
            battleId,
            'o oponente',
            (data['expires_in_seconds'] as num?)?.toInt() ?? 60,
          );
        }
      case 'accepted':
        if (isMyOutgoing) {
          AppSnackBar.showSuccess(context, '$opponent aceitou! Prepare-se ⚔');
          _enterBattle(battleId);
        }
      case 'declined':
        if (isMyOutgoing) {
          setState(() => _outgoingInvite = null);
          AppSnackBar.showError(context, '$opponent recusou o convite');
        }
      case 'expired':
        if (isMyOutgoing) {
          setState(() => _outgoingInvite = null);
          AppSnackBar.showError(context, '$opponent não respondeu a tempo');
        } else if (_incomingInviteId == battleId) {
          _closeIncomingDialog();
          AppSnackBar.showError(context, 'O convite de batalha expirou');
        }
      case 'cancelled':
        if (isMyOutgoing) {
          setState(() => _outgoingInvite = null);
        } else if (_incomingInviteId == battleId) {
          _closeIncomingDialog();
          AppSnackBar.showError(context, 'O convite de batalha foi cancelado');
        }
        if (_activeBattleId == battleId) _leaveBattle();
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE — convite ENVIADO (sou o streamer A)
  // ════════════════════════════════════════════════════════════════

  void _startOutgoingInvite(String battleId, String opponentName, int seconds) {
    if (!mounted) return;
    setState(() {
      _outgoingInvite = _OutgoingInvite(
        battleId: battleId,
        opponentName: opponentName,
        expiresAt: DateTime.now().add(Duration(seconds: seconds)),
      );
    });
  }

  Future<void> _cancelOutgoingInvite() async {
    final invite = _outgoingInvite;
    if (invite == null) return;
    setState(() => _outgoingInvite = null);
    try {
      await ref.read(battleServiceProvider).cancelInvite(invite.battleId);
    } catch (e) {
      // 409/410: já respondido/expirado — o evento de status resolve a UI.
      debugPrint('Broadcaster: cancel invite failed: $e');
    }
  }

  /// Sem evento do servidor depois do prazo (socket caiu): libera a UI
  /// para o streamer poder convidar de novo.
  void _onOutgoingInviteTimeout(String battleId) {
    if (!mounted || _outgoingInvite?.battleId != battleId) return;
    setState(() => _outgoingInvite = null);
    AppSnackBar.showError(context, 'Sem resposta ao convite de batalha');
  }

  static String? _extractBattleId(Map<String, dynamic> resp) {
    final data = resp['data'];
    final source = data is Map ? data : resp;
    final id = source['battle_id'] ?? source['id'];
    return id is String && id.isNotEmpty ? id : null;
  }

  Future<void> _showBattleSheet(BuildContext context) async {
    if (_activeBattleId != null) return; // já em batalha
    if (_outgoingInvite != null) {
      AppSnackBar.showError(
        context,
        'Aguarde a resposta do convite atual ou cancele-o',
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    // Verificar elegibilidade antes de abrir o sheet (UX antecipado)
    try {
      final eligResp = await ref.read(battleServiceProvider).checkEligibility();
      final data = (eligResp['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final battleData =
          (data['battle'] as Map?)?.cast<String, dynamic>() ?? {};
      final eligible = battleData['eligible'] as bool? ?? true;
      if (!eligible && mounted) {
        final reason =
            battleData['reason'] as String? ??
            'Você ainda não pode iniciar batalhas';
        AppSnackBar.showError(this.context, reason);
        return;
      }
    } catch (_) {
      // Se o endpoint falhar, abre o sheet mesmo assim (o backend valida de novo no invite)
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: this.context,
      backgroundColor: const Color(0xFF0E0E14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ForceDarkTheme(
        child: BattleInviteSheet(
          myRoomId: _room.id,
          onInvite: (candidate, durationSeconds) async {
            try {
              final resp = await ref
                  .read(battleServiceProvider)
                  .inviteBattle(
                    roomId: _room.id,
                    targetRoomId: candidate.roomId,
                    durationSeconds: durationSeconds,
                  );
              final battleId = _extractBattleId(resp);
              if (battleId != null) {
                _startOutgoingInvite(battleId, candidate.displayName, 60);
              }
              return null;
            } catch (e) {
              return BattleService.errorMessage(
                e,
                'Não foi possível enviar o convite',
              );
            }
          },
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CHAT do criador
  // ════════════════════════════════════════════════════════════════
  //
  // As mensagens ficam SEMPRE visíveis (antes o chat começava escondido e
  // o criador não via o que o público escrevia). O botão "Chat" só abre o
  // campo para o criador responder.

  void _toggleChatInput() {
    if (_showChatInput) {
      _closeChatInput();
      return;
    }
    setState(() => _showChatInput = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _chatFocus.requestFocus();
    });
  }

  void _closeChatInput() {
    _chatFocus.unfocus();
    setState(() => _showChatInput = false);
  }

  /// Toque numa mensagem do público → "Responder" com @menção.
  Future<void> _onCommentTap(LiveComment comment) async {
    final action = await ChatUserSheet.show(
      context,
      comment,
      allowProfile: false,
    );
    if (!mounted || action != ChatUserAction.reply) return;
    ChatUserSheet.insertMention(_chatCtrl, comment);
    setState(() => _showChatInput = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _chatFocus.requestFocus();
    });
  }

  Future<void> _sendCreatorComment() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    _chatCtrl.clear();
    _closeChatInput();
    final sent = await ref
        .read(liveRoomCommentsViewModelProvider(widget.room.id).notifier)
        .sendComment(text);
    if (!sent && mounted && _chatCtrl.text.isEmpty) {
      // Devolve o texto para o criador não perder o que digitou.
      _chatCtrl.text = text;
      setState(() => _showChatInput = true);
    }
  }

  @override
  void dispose() {
    _unsubscribeFromBattleEvents();
    _resumeFeedbackTimer?.cancel();
    _pauseTicker?.cancel();
    _chatCtrl.dispose();
    _chatFocus.dispose();
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
    // Restaura as barras do sistema ao sair do broadcast.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
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
                  icon: _isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  iconColor: _isPaused
                      ? const Color(0xFF22C55E)
                      : Colors.orange,
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
                // ── Áudio (só iOS) ─────────────────────────────────────
                // No Android o processamento (Equalizer/DynamicsProcessing)
                // só afeta sessões de REPRODUÇÃO, não o microfone do RTMP, e
                // o modo de áudio só muda atributos de playback — as opções
                // não tinham efeito nenhum na live. Escondidas lá.
                if (Platform.isIOS) ...[
                  // ── Modo de áudio ──────────────────────────────────────
                  MoreOptionTile(
                    icon: _audioMode == BroadcastAudioMode.quality
                        ? Icons.music_note_rounded
                        : Icons.record_voice_over_rounded,
                    iconColor: _audioMode == BroadcastAudioMode.quality
                        ? AppColors.braweBlueLight
                        : const Color(0xFF4FC3F7),
                    title: _audioMode == BroadcastAudioMode.quality
                        ? 'Áudio: Qualidade'
                        : 'Áudio: Redução de ruído',
                    subtitle: _audioMode == BroadcastAudioMode.quality
                        ? 'Full-range 44.1kHz — ideal para música. Toque para ativar redução de ruído.'
                        : 'AEC + supressão de ruído — ideal para conversa. Toque para voltar à qualidade.',
                    onTap: () async {
                      Navigator.pop(ctx);
                      final newMode = _audioMode == BroadcastAudioMode.quality
                          ? BroadcastAudioMode.voice
                          : BroadcastAudioMode.quality;
                      setState(() => _audioMode = newMode);
                      await BroadcastAudioSession.activate(mode: newMode);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newMode == BroadcastAudioMode.voice
                                  ? '🎙️ Redução de ruído ativada'
                                  : '🎵 Modo qualidade ativado',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  // ── Processador de Áudio (EQ + Compressor) ─────────────────
                  MoreOptionTile(
                    icon: Icons.graphic_eq_rounded,
                    iconColor: AppColors.braweSky,
                    title: '🎛️ Processador de áudio',
                    subtitle:
                        'Equalizador + compressor — ${BroadcastAudioProcessing.currentPreset.label}',
                    onTap: () {
                      Navigator.pop(ctx);
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (bCtx) => ForceDarkTheme(
                          child: AudioProcessorPanel(
                            onClose: () => Navigator.pop(bCtx),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                MoreOptionTile(
                  icon: Icons.flag_rounded,
                  iconColor: const Color(0xFFFFD166),
                  title: s.liveGoalOption,
                  subtitle: s.liveGoalOptionSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    _openGoals();
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
                      slug: _room.slug,
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

    // Mantém a fila de animações viva (o overlay lê o mesmo provider).
    ref.watch(liveRoomGiftsViewModelProvider(widget.room.id));
    final hidden = ref.watch(hiddenUsersProvider).value ?? const HiddenUsersState();

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

    final controller = _controller;
    final cameraReady =
        controller != null && controller.value.isInitialized == true;
    // Spinner de tela cheia só na abertura. Durante a troca de câmera o
    // controller fica nulo por um instante — mantemos chat/HUD montados e
    // mostramos só um fundo preto no lugar do preview.
    if (!cameraReady && !_isSwitchingCamera) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // sizeOf: não reconstrói a câmera a cada frame da animação do teclado.
    final size = MediaQuery.sizeOf(context);
    final screenRatio = size.aspectRatio;
    final cameraRatio = cameraReady ? controller.value.aspectRatio : 9 / 16;
    double scale = screenRatio < cameraRatio
        ? cameraRatio / screenRatio
        : screenRatio / cameraRatio;

    final viewerEvent = _lastViewerEvent;

    // Voltar (gesto Android / swipe iOS) passa pelo fluxo de encerramento —
    // antes fechava a tela sem chamar endLive e a sala ficava "AO VIVO".
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeBroadcaster();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ===== Camera Preview =====
              if (cameraReady)
                Center(
                  child: Transform.scale(
                    scale: scale,
                    child: AspectRatio(
                      aspectRatio: cameraRatio,
                      child: CameraPreview(controller),
                    ),
                  ),
                )
              else
                const ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  ),
                ),
              // ===== Gradient overlay (top + bottom) =====
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
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
                    // Sair da batalha / fechar banner de resultado:
                    // volta o broadcaster pra "live normal" (inclusive o
                    // liveType) sem esperar o socket. Idempotente.
                    onBattleClosed: _leaveBattle,
                  ),
                ),

              // ===== UI Layers =====
              // Top bar (HUD) — floating
              Positioned(
                top: 0,
                left: 0,
                right: 0,
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
                          onSwitchCamera: _cameras.length > 1
                              ? _switchCamera
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            LiveGoalsPill(
                              key: _goalsKey,
                              roomId: widget.room.id,
                              streamerId: _room.streamerId,
                              initialGoals: _room.goals,
                              isCreator: true,
                              onEdit: _openGoals,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: LiveGiftTicker(currentRoomId: widget.room.id)),
                          ],
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

              // ===== Painel de pausa (só o criador vê) =====
              // No terço de cima: o chat ocupa a metade de baixo da tela.
              if (_isPaused && _pausedUntil != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.paddingOf(context).top + 96,
                  child: Center(
                    child: _PausedPanel(
                      remaining: _pausedUntil!.difference(DateTime.now()),
                      isBusy: _isTogglingPause,
                      onResume: _togglePause,
                    ),
                  ),
                ),

              // ===== Retomou: "Voltando ao ar…" → "Você está ao vivo" =====
              if (!_isPaused && _resumeFeedback != _ResumeFeedback.none)
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.paddingOf(context).top + 96,
                  child: Center(child: _ResumeFeedbackPill(state: _resumeFeedback)),
                ),

              // ===== Dock inferior: convite pendente + chat + input + ações =====
              // Único widget que acompanha o teclado (a câmera não mexe).
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BroadcasterChatDock(
                  banner: _outgoingInvite == null
                      ? null
                      : _OutgoingInviteBanner(
                          key: ValueKey(_outgoingInvite!.battleId),
                          invite: _outgoingInvite!,
                          onCancel: _cancelOutgoingInvite,
                          onTimeout: () => _onOutgoingInviteTimeout(
                            _outgoingInvite!.battleId,
                          ),
                        ),
                  // Criador lê o chat de longe (celular no tripé) — texto
                  // ~12% maior que o do espectador.
                  tickerBuilder: (maxHeight) => Builder(
                    // Builder: dependência de MediaQuery fica só aqui, não no
                    // State da tela (que reconstruiria a câmera no teclado).
                    builder: (ctx) => MediaQuery(
                      data: MediaQuery.of(ctx).copyWith(
                        textScaler: MediaQuery.textScalerOf(
                          ctx,
                        ).clamp(minScaleFactor: 1.12, maxScaleFactor: 1.4),
                      ),
                      child: ChatTicker(
                giftParts: commentsState.chatGiftParts,
                        // Bloqueados (nos dois sentidos) não aparecem no chat da live.
                        comments: commentsState.comments
                            .where((c) => !hidden.isBlocked(c.userId))
                            .toList(),
                        gifts: commentsState.chatGifts
                            .where((g) => !hidden.isBlocked(g.senderId))
                            .toList(),
                        hostUserId: _room.streamerId,
                        myUserId: _room.streamerId,
                        myUsername: commentsState.myUsername,
                        onCommentTap: _onCommentTap,
                        maxHeight: maxHeight,
                      ),
                    ),
                  ),
                  input: _showChatInput
                      ? _CreatorChatInput(
                          controller: _chatCtrl,
                          focusNode: _chatFocus,
                          hint: S.of(context).liveCommentsHint,
                          onSend: _sendCreatorComment,
                          onClose: _closeChatInput,
                        )
                      : null,
                  actionBar: !_showCountdown && (_isStreaming || _isPaused)
                      ? LiveActionBar(
                          isPaused: _isPaused,
                          isTogglingPause: _isTogglingPause,
                          isTogglingStream: _isTogglingStream,
                          hasBattle: _activeBattleId != null,
                          onBattle: () => _showBattleSheet(context),
                          // Co-host desativado até existir mídia em tempo
                          // real (ver diagnóstico) — botão escondido.
                          onCoHost: null,
                          onPauseResume: _togglePause,
                          onEnd: _closeBroadcaster,
                          onMoreOptions: () => _showMoreOptions(context),
                          onGoals: _openGoals,
                          showChat: _showChatInput,
                          onChatToggle: _toggleChatInput,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Battle Invite Dialog ───────────────────────────────────────────────────
//
// AlertDialog isolado em StatefulWidget para gerenciar o timer de expiração
// visual (N → 0 seg) sem depender do estado pai.

class _BattleInviteDialog extends StatefulWidget {
  const _BattleInviteDialog({
    super.key,
    required this.fromName,
    required this.totalSeconds,
    required this.l10n,
  });

  final String fromName;

  /// Segundos até o convite expirar (vem do `expires_in_seconds` do evento).
  final int totalSeconds;
  final S l10n;

  @override
  State<_BattleInviteDialog> createState() => _BattleInviteDialogState();
}

class _BattleInviteDialogState extends State<_BattleInviteDialog> {
  late int _remaining = widget.totalSeconds;
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
    final progress = _remaining / widget.totalSeconds;
    return AlertDialog(
      backgroundColor: AppColors.slate,
      title: Row(
        children: [
          const Icon(Icons.sports_kabaddi, color: AppColors.braweBlue),
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
                    ? AppColors.braweBlue
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
            backgroundColor: AppColors.braweBlue,
          ),
          child: Text(widget.l10n.battleAccept),
        ),
      ],
    );
  }
}

// ── Convite enviado (streamer A) ────────────────────────────────────────────

class _OutgoingInvite {
  const _OutgoingInvite({
    required this.battleId,
    required this.opponentName,
    required this.expiresAt,
  });

  final String battleId;
  final String opponentName;
  final DateTime expiresAt;
}

/// Pílula "Aguardando @fulano… 42s · Cancelar" enquanto o convite enviado
/// não é respondido. Timer próprio — não reconstrói a tela da câmera.
class _OutgoingInviteBanner extends StatefulWidget {
  const _OutgoingInviteBanner({
    super.key,
    required this.invite,
    required this.onCancel,
    required this.onTimeout,
  });

  final _OutgoingInvite invite;
  final VoidCallback onCancel;

  /// Chamado se nenhum evento do servidor chegar até o prazo + 5s.
  final VoidCallback onTimeout;

  @override
  State<_OutgoingInviteBanner> createState() => _OutgoingInviteBannerState();
}

class _OutgoingInviteBannerState extends State<_OutgoingInviteBanner> {
  Timer? _tick;

  int get _remaining =>
      widget.invite.expiresAt.difference(DateTime.now()).inSeconds;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= -5) {
        _tick?.cancel();
        widget.onTimeout();
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining.clamp(0, 999);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.braweBlue.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.braweBlue,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Aguardando ${widget.invite.opponentName} aceitar… ${remaining}s',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dock inferior do criador ───────────────────────────────────────────────

/// Convite pendente + chat (sempre visível) + input (sob demanda) + ações.
///
/// Único widget que lê `viewInsets`: só ele acompanha a animação do
/// teclado — a câmera não reconstrói. Com o teclado aberto a barra de
/// ações some e o chat encolhe para caber acima do input.
class _BroadcasterChatDock extends StatelessWidget {
  const _BroadcasterChatDock({
    required this.tickerBuilder,
    this.banner,
    this.input,
    this.actionBar,
  });

  final Widget Function(double maxHeight) tickerBuilder;
  final Widget? banner;
  final Widget? input;
  final Widget? actionBar;

  /// Status bar + BroadcasterTopBar + toast de viewer.
  static const _topReserved = 150.0;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final padding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final typing = keyboard > 0;

    final bottomInset = typing ? keyboard + 8 : padding.bottom + 16;
    final below =
        (input != null ? 56.0 : 0) + (!typing && actionBar != null ? 84.0 : 0);
    final free = size.height - padding.top - _topReserved - below - bottomInset;
    final tickerMax = typing
        ? (free * 0.75).clamp(60.0, 200.0)
        : free.clamp(80.0, 220.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (banner != null) ...[
            Align(alignment: Alignment.centerLeft, child: banner),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: Alignment.bottomLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size.width * 0.8),
              child: tickerBuilder(tickerMax),
            ),
          ),
          if (input != null) ...[const SizedBox(height: 8), input!],
          if (!typing && actionBar != null) ...[
            const SizedBox(height: 10),
            actionBar!,
          ],
        ],
      ),
    );
  }
}

/// Campo para o criador responder no chat da própria live.
class _CreatorChatInput extends StatelessWidget {
  const _CreatorChatInput({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onSend,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onSend;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            // Mesmo padrão do campo do espectador (LiveBottomBar): véu
            // escuro leve + borda branca suave.
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              maxLength: LiveBottomBar.maxMessageLength,
              onSubmitted: (_) => onSend(),
              onEditingComplete: () {},
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                // Sem isso o campo herdava o tema global (fundo cinza
                // preenchido + borda azul ao focar).
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: onSend,
          icon: const Icon(Icons.send_rounded, color: AppColors.braweBlueLight),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
        ),
      ],
    );
  }
}

/// Painel central exibido ao criador enquanto a live está pausada.
enum _ResumeFeedback { none, resuming, live }

/// Painel de pausa do criador — compacto, no alto da tela.
class _PausedPanel extends StatelessWidget {
  const _PausedPanel({
    required this.remaining,
    required this.isBusy,
    required this.onResume,
  });

  final Duration remaining;
  final bool isBusy;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final secs = remaining.inSeconds.clamp(0, 3600);
    final time = '${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}';
    final urgent = secs <= 60;
    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xE6070B1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: AppColors.braweOrange, size: 22),
              const SizedBox(width: 8),
              Text(
                s.broadcasterPausedTitle,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.broadcasterPausedHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            s.broadcasterResumeIn(time),
            style: TextStyle(
              color: urgent ? const Color(0xFFFF6B6B) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(s.broadcasterResumeButton, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Retorno da pausa: "Voltando ao ar…" e depois "Você está ao vivo".
class _ResumeFeedbackPill extends StatelessWidget {
  const _ResumeFeedbackPill({required this.state});

  final _ResumeFeedback state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final live = state == _ResumeFeedback.live;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: live ? const Color(0xF022C55E) : const Color(0xE6070B1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: live ? 0.3 : 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          live
              ? const Icon(Icons.sensors_rounded, color: Colors.white, size: 22)
              : const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live ? s.broadcasterBackLive : s.broadcasterResumingTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
                if (!live)
                  Text(
                    s.broadcasterResumingHint,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
