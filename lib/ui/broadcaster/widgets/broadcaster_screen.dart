import 'dart:async';
import '../../core/view_models/hidden_users_view_model.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:dio/dio.dart' show DioException, DioExceptionType;

import 'package:flutter/material.dart';
import '../../live/shared/widgets/overlays/combo_tier_layer.dart';
import '../../live/shared/widgets/overlays/entrance_effect_layer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import 'package:livekit_client/livekit_client.dart' as lk show CameraPosition;
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
import '../../live/shared/widgets/sheets/moderators_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../live_feed/widgets/streamer_battle_hud.dart';
import '../../live_feed/battle/battle_errors.dart';
import '../../live_feed/battle/battle_hud.dart';
import '../../live_feed/battle/battle_layout.dart';
import '../../live_feed/view_models/battle_view_model.dart';
import '../../../domain/models/battle_state.dart';
import '../battle/battle_creator_stage.dart';
import '../battle/battle_rtc_session.dart';
import '../../../data/services/link_service.dart';
import '../../../domain/models/battle_config.dart';
import '../../../domain/models/link_state.dart';
import '../../live_feed/battle/link_hud.dart';
import 'share_live_sheet.dart';
import '../../live/shared/widgets/goal/live_goals.dart';
import '../../live/shared/widgets/hud/live_gift_ticker.dart';
import '../../live/shared/widgets/hud/live_event_chip.dart';
import '../../live/shared/widgets/sheets/event_page_sheet.dart';
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
  final GlobalKey<LiveGoalsPillState> _goalsKey =
      GlobalKey<LiveGoalsPillState>();

  /// Editor de metas (botão Metas da barra de ações ou "Mais opções").
  Future<void> _openGoals() async {
    final saved = await LiveGoalsEditorSheet.show(
      context,
      roomId: widget.room.id,
      current: _room.goals,
    );
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

  /// Batalha acabou (resultado na tela): a barra de ações volta ao normal.
  bool _battleEnded = false;

  /// Última batalha encerrada (alvo do botão "Revanche" da barra de ações).
  String? _rematchId;
  Timer? _rematchTimer;
  bool _rematchBusy = false;
  Map<String, dynamic>? _countdownPayload;

  // ── Conexão entre criadores (§8) ──
  LinkState? _link;
  bool _linkEnabled = false;
  bool _linkBusy = false;
  bool get _split => _activeBattleId != null || _link != null;

  /// Como (re)obter as credenciais do LiveKit da sessão atual.
  Future<BattleRtcCredentials> Function()? _rtcLoader;

  // ── Tempo real (LiveKit) da batalha `composite` ──
  BattleRtcSession? _rtcSession;

  /// Mídia do criador está no LiveKit (RTMP parado, câmera do plugin liberada).
  bool _rtcActive = false;
  bool _rtcSwitching = false;
  bool _rtcRestoring = false;
  bool _pendingRtmpRestore = false;
  final Set<String> _rtcTried = <String>{};
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
    // Tempo real da batalha: a câmera do LiveKit é liberada no background e
    // reaberta ao voltar (sala reconectada se caiu); a live NÃO é pausada.
    if (_rtcActive && _rtcSession != null) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden) {
        unawaited(_rtcSession?.pauseCamera());
      } else if (state == AppLifecycleState.resumed) {
        final session = _rtcSession;
        if (session != null && session.isDisconnected) {
          unawaited(_reconnectRtc());
        } else {
          unawaited(session?.resumeCamera());
        }
      }
      return;
    }
    if (state == AppLifecycleState.resumed && _pendingRtmpRestore) {
      unawaited(_restoreRtmp());
      return;
    }
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
    // Durante o tempo real da batalha a mídia está no LiveKit.
    if (_rtcActive) {
      AppSnackBar.showError(context, S.of(context).battlePauseUnavailable);
      return;
    }
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
    if (_rtcActive) {
      // Tempo real: vira a câmera do track local do LiveKit.
      try {
        await _rtcSession?.flipCamera();
      } catch (e) {
        debugPrint('Battle RTC: flipCamera falhou: $e');
      }
      return;
    }
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

  /// Aviso extra quando há batalha ativa (ninguém vence + perde a sequência).
  String? _activeBattleWarning() {
    final id = _activeBattleId;
    if (id == null || _battleEnded) return null;
    final st = ref.read(battleViewModelProvider(id)).value;
    if (st == null || st.isOver) return null;
    final side = st.sideOf(userId: _room.streamerId, roomId: _room.id);
    return battleLeaveWarning(S.of(context), side == null ? null : st.winStreakOf(side));
  }

  Future<bool> _confirmCloseDialog() async {
    final s = S.of(context);
    final battleWarn = _activeBattleWarning();
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
          battleWarn == null
              ? s.broadcasterEndMessage
              : '${s.broadcasterEndMessage}\n\n$battleWarn',
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

    // Encerrar a live no meio da batalha: solta o LiveKit (sem religar RTMP).
    await _stopRtc(restoreRtmp: false);

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
    unawaited(_probeLink());
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
    socket.on(AppConstants.eventLinkInvite, _onLinkInvite);
    socket.on(AppConstants.eventLinkInviteStatus, _onLinkInviteStatus);
    socket.on(AppConstants.eventLinkStarted, _onLinkStarted);
    socket.on(AppConstants.eventLinkEnded, _onLinkEnded);
    socket.on(AppConstants.eventLinkMute, _onLinkMute);
    socket.on(AppConstants.eventBattleCountdown, _onBattleCountdown);
    socket.on(AppConstants.eventBattleStarted, _onBattleStarted);
    socket.on(AppConstants.eventBattleInviteStatus, _onBattleInviteStatus);
    socket.on(AppConstants.eventBattleCancelled, _onBattleCancelled);
  }

  void _detachBattleHandlers() {
    final socket = _battleSocket;
    if (socket == null) return;
    socket.off(AppConstants.eventBattleInvite, _onBattleInvite);
    socket.off(AppConstants.eventLinkInvite, _onLinkInvite);
    socket.off(AppConstants.eventLinkInviteStatus, _onLinkInviteStatus);
    socket.off(AppConstants.eventLinkStarted, _onLinkStarted);
    socket.off(AppConstants.eventLinkEnded, _onLinkEnded);
    socket.off(AppConstants.eventLinkMute, _onLinkMute);
    socket.off(AppConstants.eventBattleCountdown, _onBattleCountdown);
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
    BattleRoomScope.set(battleId, _room.id);
    setState(() {
      if (_activeBattleId != battleId) {
        _battleEnded = false;
        _rematchId = null;
      }
      _activeBattleId = battleId;
      if (_outgoingInvite?.battleId == battleId) _outgoingInvite = null;
      // Sincroniza liveType em memória — antes o app continuava achando
      // que estava em SOLO mesmo após o backend ter virado BATTLE.
      _room = _room.copyWith(liveType: 'battle');
    });
  }

  /// Volta para a live normal (fechou o resultado ou a batalha foi cancelada).
  void _leaveBattle() {
    if (!mounted) return;
    setState(() {
      _activeBattleId = null;
      _battleEnded = false;
      _countdownPayload = null;
      _room = _room.copyWith(liveType: 'solo');
    });
    // Garante o RTMP de volta (idempotente) — exceto dentro de uma conexão,
    // onde a mídia continua no LiveKit.
    if (_link == null) unawaited(_stopRtc(restoreRtmp: true));
  }

  /// Meu lado agora: conexão > batalha > token (só como último recurso).
  String _mySideNow() {
    final l = _link?.sideOf(userId: _room.streamerId, roomId: _room.id);
    if (l != null) return l;
    final id = _activeBattleId;
    final b = id == null
        ? null
        : ref.read(battleViewModelProvider(id)).value?.sideOf(
            userId: _room.streamerId,
            roomId: _room.id,
          );
    return b ?? _rtcSession?.credentials.side ?? 'a';
  }

  /// Lado desenhado à esquerda (§18.1): o meu, só se o servidor sinalizou
  /// `owner_left` (conexão ou batalha); senão A à esquerda como antes.
  String _layoutSide() {
    final id = _activeBattleId;
    final b = id == null ? null : ref.read(battleViewModelProvider(id)).value;
    final flag = b != null ? b.ownerLeft : (_link?.ownerLeft ?? false);
    return flag ? _mySideNow() : 'a';
  }

  /// Reaplica o mudo vigente (conexão ou batalha) a uma sessão recém-criada.
  void _applyMuteTo(BattleRtcSession session) {
    final side = _mySideNow();
    final lk = _link;
    if (lk != null) {
      session.setOpponentMuted(lk.mutedOf(side));
      return;
    }
    final id = _activeBattleId;
    final st = id == null ? null : ref.read(battleViewModelProvider(id)).value;
    if (st != null) session.setOpponentMuted(st.mutedOf(side));
  }

  bool _isMyBattleEvent(Map<String, dynamic> data) {
    final roomA = data['room_a_id'] as String?;
    final roomB = data['room_b_id'] as String?;
    if (roomA == null && roomB == null) return true;
    return roomA == _room.id || roomB == _room.id;
  }

  /// Contagem 3·2·1: abre o HUD e, se for `composite`, troca RTMP → LiveKit.
  void _onBattleCountdown(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    if (battleId == null || battleId.isEmpty) return;
    if (!_isMyBattleEvent(data)) return;
    if (_activeBattleId != battleId) {
      _countdownPayload = data;
      _enterBattle(battleId);
    }
    if (data['rtc_mode'] == 'composite') unawaited(_startRtc(battleId));
  }

  void _onBattleStarted(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    if (battleId == null || battleId.isEmpty) return;
    if (!_isMyBattleEvent(data)) return; // batalha de outra sala
    _enterBattle(battleId);
    // Perdeu a contagem (entrou tarde)? Troca agora.
    if (data['rtc_mode'] == 'composite') unawaited(_startRtc(battleId));
  }

  /// Batalha cancelada (ex.: oponente encerrou a live na contagem).
  void _onBattleCancelled(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['battle_id'] != _activeBattleId) return;
    _leaveBattle();
    AppSnackBar.showError(context, S.of(context).battleCancelledMsg);
  }

  /// Reage ao estado da batalha: sincroniza o "silenciar" com o áudio do
  /// adversário e encerra o tempo real no fim / cancelamento / fallback.
  void _onBattleStateChanged(BattleState s) {
    if (!mounted) return;
    final mySide = s.sideOf(userId: _room.streamerId, roomId: _room.id);
    // Dentro de uma conexão o mudo é o da CONEXÃO (não o da batalha).
    if (_link == null && mySide != null) {
      _rtcSession?.setOpponentMuted(s.mutedOf(mySide));
    }
    if ((s.isOver || s.isCancelled) && !_battleEnded) {
      setState(() {
        _battleEnded = true;
        if (s.isOver) _rematchId = s.battleId;
      });
      if (s.isOver) {
        // O botão "Revanche" não fica preso: some em 30 s (o convite normal
        // de batalha volta a ficar acessível).
        _rematchTimer?.cancel();
        _rematchTimer = Timer(const Duration(seconds: 30), () {
          if (mounted) setState(() => _rematchId = null);
        });
      }
    }
    final rtcWanted = s.isComposite && !s.isOver && !s.isCancelled;
    if (!rtcWanted && _link == null && (_rtcActive || _rtcSession != null)) {
      final fallback = !s.isComposite && !s.isOver && !s.isCancelled;
      unawaited(_stopRtc(restoreRtmp: true, showFallback: fallback));
    } else if (rtcWanted &&
        !_rtcActive &&
        (s.phase == BattlePhase.countdown || s.phase == BattlePhase.active)) {
      unawaited(_startRtc(s.battleId));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE — tempo real (LiveKit) no modo `composite`
  // ════════════════════════════════════════════════════════════════
  //
  // Fluxo (contrato §4): GET /rtc → para o RTMP (o Mux segura a live pela
  // janela de reconexão) → libera a câmera do plugin → conecta no LiveKit e
  // publica câmera + microfone. No fim/cancelamento/fallback: desconecta,
  // reabre a câmera e retoma o RTMP para o MESMO ingest. Se o LiveKit não
  // conectar em 8 s, retoma o RTMP e a batalha segue (o backend faz fallback).

  Future<void> _startRtc(String battleId) {
    // Dentro de uma conexão a mídia já está no LiveKit.
    if (_link != null) return Future.value();
    return _startRtcCore(
      key: battleId,
      loader: () => ref.read(battleServiceProvider).getRtc(battleId),
      wanted: () => _activeBattleId == battleId,
    );
  }

  /// Android 12+ exige BLUETOOTH_CONNECT em tempo de execução para o áudio
  /// da conversa sair/entrar pelo fone Bluetooth. Pede uma única vez; se a
  /// pessoa negar (ou já negou para sempre), segue pelo aparelho.
  Future<void> _ensureBluetoothPermission() async {
    if (!Platform.isAndroid) return;
    try {
      final status = await Permission.bluetoothConnect.status;
      if (status.isGranted || status.isPermanentlyDenied) return;
      await Permission.bluetoothConnect.request();
    } catch (e) {
      debugPrint('Bluetooth: permissão não solicitada ($e)');
    }
  }

  Future<void> _startRtcCore({
    required String key,
    required Future<BattleRtcCredentials> Function() loader,
    required bool Function() wanted,
  }) async {
    if (!mounted ||
        _rtcActive ||
        _rtcSwitching ||
        _isClosing ||
        _rtcTried.contains(key)) {
      return;
    }
    // Sem live no ar (nada para trocar) ou em pausa: segue como está.
    if (!_isStreaming || _isPaused) return;
    _rtcTried.add(key);
    _rtcSwitching = true;
    _rtcLoader = loader;
    final l10n = S.of(context);
    BattleRtcCredentials creds;
    try {
      creds = await loader();
      if (!creds.isValid) throw StateError('rtc credentials invalid');
    } catch (e) {
      debugPrint('Battle RTC: sem credenciais ($e) — segue no RTMP');
      _rtcSwitching = false;
      return;
    }
    if (!mounted || !wanted() || _isClosing) {
      _rtcSwitching = false;
      return;
    }
    // Fone Bluetooth na conversa em tempo real (Android 12+): pede antes de
    // parar o RTMP, com a live ainda no ar. Negar não impede a conexão.
    await _ensureBluetoothPermission();
    if (!mounted || !wanted() || _isClosing) {
      _rtcSwitching = false;
      return;
    }
    try {
      // 1) Mostra o palco (tela de espera) e para o RTMP.
      setState(() => _rtcActive = true);
      try {
        await _controller?.stopVideoStreaming();
      } catch (_) {}
      // 2) Libera a câmera/microfone do plugin RTMP.
      final cam = _controller;
      if (cam != null) {
        if (mounted) setState(() => _controller = null);
        try {
          await cam.dispose();
        } catch (_) {}
      }
      try {
        await BroadcastAudioSession.deactivate();
      } catch (_) {}
      // 3) Conecta no LiveKit (até 8 s) e publica câmera + microfone.
      // Corrida: a batalha/conexão pode ter acabado durante o GET /rtc ou a
      // liberação da câmera — não cria sessão à toa.
      if (!mounted || !wanted() || _isClosing) {
        _rtcSwitching = false;
        await _stopRtc(restoreRtmp: true);
        return;
      }
      final session = BattleRtcSession(creds);
      _rtcSession = session;
      await session.connect(
        timeout: const Duration(seconds: 8),
        cameraPosition:
            _cameras.isNotEmpty &&
                _cameras[_currentCameraIndex].lensDirection ==
                    CameraLensDirection.back
            ? lk.CameraPosition.back
            : lk.CameraPosition.front,
      );
      if (!mounted) return;
      if (!wanted()) {
        _rtcSwitching = false;
        await _stopRtc(restoreRtmp: true);
        return;
      }
      // Aplica o estado atual do "silenciar" (conexão > batalha).
      _applyMuteTo(session);
      setState(() {});
    } catch (e) {
      debugPrint('Battle RTC: falha ao conectar ($e) — voltando ao RTMP');
      if (mounted) AppSnackBar.showError(context, l10n.battleRtcFallback);
      _rtcSwitching = false;
      await _stopRtc(restoreRtmp: true);
      return;
    }
    _rtcSwitching = false;
  }

  Future<void> _stopRtc({
    required bool restoreRtmp,
    bool showFallback = false,
  }) async {
    final session = _rtcSession;
    if (session == null && !_rtcActive) return;
    _rtcSession = null;
    await session?.dispose();
    if (!mounted) return;
    if (showFallback) {
      AppSnackBar.showError(context, S.of(context).battleRtcFallback);
    }
    if (restoreRtmp && _isStreaming && !_isClosing && !_isPaused) {
      final life = WidgetsBinding.instance.lifecycleState;
      if (life != null && life != AppLifecycleState.resumed) {
        // Em segundo plano o iOS não abre a câmera: restaura ao voltar.
        _pendingRtmpRestore = true;
        return;
      }
      await _restoreRtmp();
      return;
    }
    if (mounted) setState(() => _rtcActive = false);
  }

  /// Reabre a câmera do plugin e retoma o RTMP para o mesmo ingest.
  Future<void> _restoreRtmp() async {
    if (!mounted || _cameras.isEmpty || _rtcRestoring) return;
    _rtcRestoring = true;
    _pendingRtmpRestore = false;
    try {
      // Mantém `_rtcActive` até a câmera voltar (evita spinner de tela cheia).
      await _setupCameraController(_cameras[_currentCameraIndex]);
      if (mounted && _controller != null) {
        await _restartStreamAfterSwitch();
      }
    } finally {
      _rtcRestoring = false;
      if (mounted) setState(() => _rtcActive = false);
    }
  }

  Future<void> _reconnectRtc() async {
    final loader = _rtcLoader;
    if (loader == null || _rtcSwitching) return;
    _rtcSwitching = true;
    try {
      await _rtcSession?.dispose();
      final creds = await loader();
      final session = BattleRtcSession(creds);
      _rtcSession = session;
      await session.connect(timeout: const Duration(seconds: 8));
      _applyMuteTo(session);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Battle RTC: reconexão falhou ($e)');
      _rtcSwitching = false;
      await _stopRtc(restoreRtmp: true);
      return;
    }
    _rtcSwitching = false;
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

  // ════════════════════════════════════════════════════════════════
  // CONEXÃO entre criadores (§8)
  // ════════════════════════════════════════════════════════════════

  /// Sonda: `GET /link/candidates` responde 503 com o tempo real desligado
  /// (então "Conectar" some e "Batalha" usa o fluxo antigo).
  Future<void> _probeLink() async {
    try {
      await ref.read(linkServiceProvider).getCandidates(limit: 1);
      if (!mounted) return;
      setState(() => _linkEnabled = true);
    } catch (_) {
      if (mounted) setState(() => _linkEnabled = false);
      return;
    }
    // Conexão já em curso (app reaberto)?
    try {
      final l = await ref.read(linkServiceProvider).getActive(_room.id);
      if (l != null && l.isActive && mounted && _link == null) {
        _beginLink(l);
      }
    } catch (_) {}
  }

  void _beginLink(LinkState l) {
    setState(() {
      _link = l;
      _outgoingInvite = null;
    });
    unawaited(
      _startRtcCore(
        key: 'link-${l.linkId}',
        loader: () => ref.read(linkServiceProvider).getRtc(l.linkId),
        wanted: () => _link?.linkId == l.linkId,
      ),
    );
  }

  bool _isMyLink(LinkState l) =>
      l.a.roomId == _room.id ||
      l.b.roomId == _room.id ||
      l.a.id == _room.streamerId ||
      l.b.id == _room.streamerId;

  void _onLinkStarted(dynamic raw) {
    if (!mounted) return;
    final l = LinkState.tryParse(_parseSocketPayload(raw));
    if (l == null || !_isMyLink(l) || _link?.linkId == l.linkId) return;
    _beginLink(l);
  }

  void _onLinkEnded(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null || data['link_id'] != _link?.linkId) return;
    _clearLink();
  }

  void _clearLink() {
    if (_link == null) return;
    setState(() {
      _link = null;
      _rematchId = null;
    });
    AppSnackBar.showError(context, S.of(context).linkEnded);
    // Desconecta do LiveKit e volta ao RTMP (a batalha, se houver, termina
    // sozinha por `live_ended`/`forfeit` e o resultado segue na tela).
    unawaited(_stopRtc(restoreRtmp: true));
  }

  void _onLinkMute(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    final cur = _link;
    if (data == null || cur == null || data['link_id'] != cur.linkId) return;
    final m = data['muted'];
    if (m is! Map) return;
    final next = cur.copyWith(mutedA: m['a'] == true, mutedB: m['b'] == true);
    setState(() => _link = next);
    final side = next.sideOf(userId: _room.streamerId, roomId: _room.id);
    if (side != null) _rtcSession?.setOpponentMuted(next.mutedOf(side));
  }

  Future<void> _toggleLinkMute() async {
    final cur = _link;
    if (cur == null || _linkBusy) return;
    final side = cur.sideOf(userId: _room.streamerId, roomId: _room.id);
    if (side == null) return;
    final next = !cur.mutedOf(side);
    setState(() {
      _link = cur.copyWith(
        mutedA: side == 'a' ? next : cur.mutedA,
        mutedB: side == 'b' ? next : cur.mutedB,
      );
    });
    _rtcSession?.setOpponentMuted(next);
    try {
      final res = await ref.read(linkServiceProvider).setMute(cur.linkId, next);
      if (res != null && mounted && _link != null) {
        setState(() => _link = _link!.copyWith(mutedA: res.a, mutedB: res.b));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _link = cur);
      _rtcSession?.setOpponentMuted(cur.mutedOf(side));
      AppSnackBar.showError(context, battleErrorText(S.of(context), e));
    }
  }

  Future<void> _requestRematch() async {
    final id = _rematchId;
    if (id == null || _rematchBusy) return;
    final l10n = S.of(context);
    setState(() => _rematchBusy = true);
    try {
      await ref.read(battleServiceProvider).requestRematch(id);
      if (!mounted) return;
      AppSnackBar.showSuccess(context, l10n.battleRematchSent);
      setState(() => _rematchId = null);
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          battleErrorText(l10n, e, fallback: l10n.battleErrRematch),
        );
      }
    } finally {
      if (mounted) setState(() => _rematchBusy = false);
    }
  }

  Future<void> _confirmDisconnect() async {
    final cur = _link;
    if (cur == null || _linkBusy) return;
    final l10n = S.of(context);
    final side = cur.sideOf(userId: _room.streamerId, roomId: _room.id) ?? 'a';
    final partner = cur.peer(side == 'a' ? 'b' : 'a').name;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1F),
        title: Text(
          l10n.linkDisconnectTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          _activeBattleWarning() == null
              ? l10n.linkDisconnectBody(partner)
              : '${l10n.linkDisconnectBody(partner)}\n\n${_activeBattleWarning()}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.battleCancel,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.linkDisconnect,
              style: const TextStyle(
                color: AppColors.braweOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _linkBusy = true);
    var ended = false;
    try {
      await ref.read(linkServiceProvider).end(cur.linkId);
      ended = true;
    } on DioException catch (e) {
      // Timeout de recebimento: o servidor segue processando (fire-and-forget).
      ended = e.type == DioExceptionType.receiveTimeout;
      if (!ended && mounted) {
        AppSnackBar.showError(
          context,
          battleErrorText(S.of(context), e, fallback: S.of(context).linkErrDisconnect),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          battleErrorText(
            S.of(context),
            e,
            fallback: S.of(context).linkErrDisconnect,
          ),
        );
      }
    }
    if (mounted) setState(() => _linkBusy = false);
    if (!ended) return; // falhou: o servidor segue conectado, não sai sozinho
    // Rede de segurança: se o `link:ended` se perder, limpa localmente.
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted && _link?.linkId == cur.linkId) _clearLink();
    });
  }

  /// "Batalha" dentro da conexão: escolhe a duração e convida o parceiro
  /// (o servidor recebe `link_id`; o vídeo não muda).
  Future<void> _startBattleInLink() async {
    final cur = _link;
    if (cur == null || _activeBattleId != null) return;
    if (_outgoingInvite != null) {
      AppSnackBar.showError(context, S.of(context).battleInviteWait);
      return;
    }
    final side = cur.sideOf(userId: _room.streamerId, roomId: _room.id) ?? 'a';
    final partner = cur.peer(side == 'a' ? 'b' : 'a');
    final roomId = partner.roomId;
    if (roomId == null || roomId.isEmpty) return;
    final l10n = S.of(context);
    var durations = const [180, 300, 600];
    var def = 300;
    try {
      final cfg = BattleConfig.tryParse(
        await ref.read(battleServiceProvider).getBattleConfig(),
      );
      if (cfg != null && cfg.durationsS.isNotEmpty) {
        durations = cfg.durationsS;
        def = cfg.defaultDurationS;
      }
    } catch (_) {}
    if (!mounted) return;
    final seconds = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFF0E0E14),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.battleStartTitle} · ${l10n.battleDurationLabel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final d in durations)
                    ChoiceChip(
                      label: Text(
                        d % 60 == 0
                            ? l10n.battleDurationMinutes(d ~/ 60)
                            : l10n.battleDurationSeconds(d),
                      ),
                      selected: d == def,
                      onSelected: (_) => Navigator.pop(ctx, d),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (seconds == null || !mounted) return;
    setState(() => _linkBusy = true);
    try {
      final resp = await ref
          .read(battleServiceProvider)
          .inviteBattle(
            roomId: _room.id,
            targetRoomId: roomId,
            durationSeconds: seconds,
            linkId: cur.linkId,
          );
      final id = _extractBattleId(resp);
      if (id != null) _startOutgoingInvite(id, partner.name, 60);
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          battleErrorText(
            S.of(context),
            e,
            fallback: S.of(context).battleErrSendInvite,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _linkBusy = false);
    }
  }

  Future<void> _showLinkSheet(BuildContext context) async {
    if (_link != null || _activeBattleId != null) return;
    if (_outgoingInvite != null) {
      AppSnackBar.showError(context, S.of(context).battleInviteWait);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
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
          linkMode: true,
          loader: (q, cursor) => ref
              .read(linkServiceProvider)
              .getCandidates(query: q, cursor: cursor),
          onInvite: (candidate, _) async {
            try {
              final resp = await ref
                  .read(linkServiceProvider)
                  .invite(opponentRoomId: candidate.roomId);
              final id = resp['link_id']?.toString();
              if (id != null) {
                _startOutgoingInvite(
                  id,
                  candidate.displayName,
                  60,
                  isLink: true,
                );
              }
              return null;
            } catch (e) {
              return battleErrorText(
                S.of(this.context),
                e,
                fallback: S.of(this.context).linkErrInvite,
              );
            }
          },
        ),
      ),
    );
  }

  void _onLinkInvite(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final linkId = data['link_id']?.toString();
    if (linkId == null || linkId.isEmpty || linkId == _incomingInviteId) return;
    final fromName = (data['from_name'] as String?)?.trim();
    if (_link != null ||
        _activeBattleId != null ||
        _incomingInviteId != null ||
        _outgoingInvite != null) {
      unawaited(
        ref
            .read(linkServiceProvider)
            .decline(linkId)
            .then((_) {}, onError: (_) {}),
      );
      return;
    }
    final expiresAt = DateTime.tryParse('${data['expires_at'] ?? ''}');
    final serverNow = DateTime.tryParse('${data['server_now'] ?? ''}');
    final seconds = (expiresAt != null && serverNow != null)
        ? expiresAt.difference(serverNow).inSeconds - 2
        : 55;
    if (seconds < 3) return;
    _showBattleInviteDialog(
      linkId,
      fromName == null || fromName.isEmpty
          ? S.of(context).battleSomeCreator
          : fromName,
      seconds.clamp(3, 120),
      avatarUrl: data['from_avatar_url'] as String?,
      durationSeconds: (data['duration_seconds'] as num?)?.toInt(),
      isLink: true,
      withBattle: data['with_battle'] == true,
    );
  }

  void _onLinkInviteStatus(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final linkId = data['link_id']?.toString();
    final status = data['status'] as String?;
    if (linkId == null || status == null) return;
    final l10n = S.of(context);
    final out = _outgoingInvite;
    final isMine = out != null && out.isLink && out.battleId == linkId;
    final nameA = (data['streamer_a_name'] as String?)?.trim();
    final nameB = (data['streamer_b_name'] as String?)?.trim();
    // Quem convidou é A: o nome do outro é o oposto de mim.
    final opponent = isMine
        ? (nameB != null && nameB.isNotEmpty ? nameB : out.opponentName)
        : (nameA ?? l10n.battleOpponentFallback);
    switch (status) {
      case 'accepted':
        if (isMine) {
          AppSnackBar.showSuccess(context, l10n.linkInviteAccepted(opponent));
          setState(() => _outgoingInvite = null);
        }
      case 'declined':
        if (isMine) {
          setState(() => _outgoingInvite = null);
          AppSnackBar.showError(context, l10n.battleInviteDeclined(opponent));
        }
      case 'expired':
        if (isMine) {
          setState(() => _outgoingInvite = null);
          AppSnackBar.showError(context, l10n.battleInviteNoReply(opponent));
        } else if (_incomingInviteId == linkId) {
          _closeIncomingDialog();
          AppSnackBar.showError(context, l10n.battleInviteExpired);
        }
      case 'cancelled':
        if (isMine) {
          setState(() => _outgoingInvite = null);
        } else if (_incomingInviteId == linkId) {
          _closeIncomingDialog();
          AppSnackBar.showError(context, l10n.battleInviteCancelled);
        }
    }
  }

  void _onBattleInvite(dynamic raw) {
    if (!mounted) return;
    final data = _parseSocketPayload(raw);
    if (data == null) return;
    final battleId = data['battle_id'] as String?;
    if (battleId == null || battleId.isEmpty) return;
    if (battleId == _incomingInviteId) return; // evento duplicado
    final fromName = (data['from_streamer'] as String?)?.trim();
    final avatar =
        (data['from_avatar'] ??
                data['from_avatar_url'] ??
                data['streamer_a_avatar'])
            as String?;
    final durationSeconds = (data['duration_seconds'] as num?)?.toInt();

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

    // Prazo pelo relógio do servidor (`expires_at − server_now`); sem os
    // campos novos, cai no `expires_in_seconds` (com margem de 3 s).
    final expiresAt = DateTime.tryParse('${data['expires_at'] ?? ''}');
    final serverNow = DateTime.tryParse('${data['server_now'] ?? ''}');
    int seconds;
    if (expiresAt != null && serverNow != null) {
      seconds = expiresAt.difference(serverNow).inSeconds - 2;
    } else {
      seconds = ((data['expires_in_seconds'] as num?)?.toInt() ?? 60) - 3;
    }
    if (seconds < 3) return; // já praticamente expirado
    _showBattleInviteDialog(
      battleId,
      fromName == null || fromName.isEmpty
          ? S.of(context).battleSomeCreator
          : fromName,
      seconds.clamp(3, 120),
      avatarUrl: avatar,
      durationSeconds: durationSeconds,
    );
  }

  Future<void> _showBattleInviteDialog(
    String battleId,
    String fromName,
    int seconds, {
    String? avatarUrl,
    int? durationSeconds,
    bool isLink = false,
    bool withBattle = false,
  }) async {
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
        avatarUrl: avatarUrl,
        durationSeconds: durationSeconds,
        totalSeconds: seconds,
        l10n: l10n,
        isLink: isLink,
        withBattle: withBattle,
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
        if (isLink) {
          // A tela dupla abre no `connect:link:started`.
          await ref.read(linkServiceProvider).accept(battleId);
        } else {
          await ref.read(battleServiceProvider).acceptBattle(battleId);
          // HUD já abre em "contagem" — o `countdown`/`started` chegam em seguida.
          _enterBattle(battleId);
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            battleErrorText(
              S.of(context),
              e,
              fallback: isLink
                  ? S.of(context).linkErrAccept
                  : S.of(context).battleErrAccept,
            ),
          );
        }
      } finally {
        _isAcceptingBattle = false;
      }
    } else {
      try {
        if (isLink) {
          await ref.read(linkServiceProvider).decline(battleId);
        } else {
          await ref.read(battleServiceProvider).declineBattle(battleId);
        }
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
    final l10n = S.of(context);

    final iAmInviter = data['streamer_a_id'] == _room.streamerId;
    final outgoing = _outgoingInvite;
    final isMyOutgoing = outgoing?.battleId == battleId;
    // Nome do outro criador vem do próprio evento (v2).
    final eventName =
        (iAmInviter ? data['streamer_b_name'] : data['streamer_a_name'])
            as String?;
    final opponent = (eventName != null && eventName.trim().isNotEmpty)
        ? eventName.trim()
        : (outgoing?.opponentName ?? l10n.battleOpponentFallback);

    switch (status) {
      case 'pending':
        // Cobre convites criados fora do sheet (ex.: revanche).
        if (iAmInviter && !isMyOutgoing && _activeBattleId == null) {
          final expiresAt = DateTime.tryParse('${data['expires_at'] ?? ''}');
          final serverNow = DateTime.tryParse('${data['server_now'] ?? ''}');
          final secs = (expiresAt != null && serverNow != null)
              ? expiresAt.difference(serverNow).inSeconds
              : ((data['expires_in_seconds'] as num?)?.toInt() ?? 60);
          _startOutgoingInvite(battleId, opponent, secs.clamp(3, 120));
        }
      case 'accepted':
        if (isMyOutgoing) {
          AppSnackBar.showSuccess(context, l10n.battleInviteAccepted(opponent));
          _enterBattle(battleId);
        }
      case 'declined':
        if (isMyOutgoing) {
          setState(() => _outgoingInvite = null);
          AppSnackBar.showError(context, l10n.battleInviteDeclined(opponent));
        }
      case 'expired':
        if (isMyOutgoing) {
          setState(() => _outgoingInvite = null);
          AppSnackBar.showError(context, l10n.battleInviteNoReply(opponent));
        } else if (_incomingInviteId == battleId) {
          _closeIncomingDialog();
          AppSnackBar.showError(context, l10n.battleInviteExpired);
        }
      case 'cancelled':
        if (isMyOutgoing) {
          setState(() => _outgoingInvite = null);
        } else if (_incomingInviteId == battleId) {
          _closeIncomingDialog();
          AppSnackBar.showError(context, l10n.battleInviteCancelled);
        }
        if (_activeBattleId == battleId) _leaveBattle();
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BATTLE — convite ENVIADO (sou o streamer A)
  // ════════════════════════════════════════════════════════════════

  void _startOutgoingInvite(
    String battleId,
    String opponentName,
    int seconds, {
    bool isLink = false,
  }) {
    if (!mounted) return;
    setState(() {
      _outgoingInvite = _OutgoingInvite(
        isLink: isLink,
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
      if (invite.isLink) {
        await ref.read(linkServiceProvider).cancel(invite.battleId);
      } else {
        await ref.read(battleServiceProvider).cancelInvite(invite.battleId);
      }
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
    AppSnackBar.showError(context, S.of(context).battleInviteNoAnswer);
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
      AppSnackBar.showError(context, S.of(context).battleInviteWait);
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
        AppSnackBar.showError(
          this.context,
          S.of(this.context).battleErrNotEligible,
        );
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
              // Tempo real ligado: "Batalha" é o atalho que conecta E convida
              // (POST /live/link/invite with_battle=true).
              if (_linkEnabled) {
                final lr = await ref
                    .read(linkServiceProvider)
                    .invite(
                      opponentRoomId: candidate.roomId,
                      withBattle: true,
                      durationSeconds: durationSeconds,
                    );
                final lid = lr['link_id']?.toString();
                if (lid != null) {
                  _startOutgoingInvite(
                    lid,
                    candidate.displayName,
                    60,
                    isLink: true,
                  );
                }
                return null;
              }
              final resp = await ref
                  .read(battleServiceProvider)
                  .inviteBattle(
                    roomId: _room.id,
                    targetRoomId: candidate.roomId,
                    durationSeconds: durationSeconds,
                  );
              final battleId = _extractBattleId(resp);
              if (battleId != null) {
                final body = resp['data'] is Map
                    ? Map<String, dynamic>.from(resp['data'] as Map)
                    : resp;
                final exp = DateTime.tryParse('${body['expires_at'] ?? ''}');
                final now = DateTime.tryParse('${body['server_now'] ?? ''}');
                final secs = (exp != null && now != null)
                    ? exp.difference(now).inSeconds
                    : ((body['expires_in_seconds'] as num?)?.toInt() ?? 60);
                _startOutgoingInvite(
                  battleId,
                  candidate.displayName,
                  secs.clamp(3, 120),
                );
              }
              return null;
            } catch (e) {
              return battleErrorText(
                S.of(this.context),
                e,
                fallback: S.of(this.context).battleErrSendInvite,
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
      // O criador sempre pode moderar (exceto a si mesmo).
      moderation: comment.userId == _room.streamerId
          ? null
          : const ChatModerationAccess(isCreator: true),
    );
    if (!mounted || action == null) return;
    if (action.isModeration) {
      await performChatModeration(
        context,
        ref,
        roomId: widget.room.id,
        comment: comment,
        action: action,
      );
      return;
    }
    if (action != ChatUserAction.reply) return;
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
    _rematchTimer?.cancel();
    _rtcSession?.dispose();
    _rtcSession = null;
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

  /// Compacto e sem quebra: 1,2k / 3,4M (vírgula em pt/es).
  String _formatCount(int n) {
    final comma = const ['pt', 'es'].contains(Localizations.localeOf(context).languageCode);
    String f(double v) {
      final t = v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return comma ? t.replaceAll('.', ',') : t;
    }
    if (n >= 1000000) return '${f(n / 1000000)}M';
    if (n >= 1000) return '${f(n / 1000)}k';
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
                  icon: LucideIcons.shield,
                  iconColor: const Color(0xFF4FC3F7),
                  title: s.modModeratorsTitle,
                  subtitle: s.modModeratorsSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    ModeratorsSheet.show(context);
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
    final hidden =
        ref.watch(hiddenUsersProvider).value ?? const HiddenUsersState();

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

    if (_activeBattleId != null) {
      ref.listen<AsyncValue<BattleState>>(
        battleViewModelProvider(_activeBattleId!),
        (prev, next) {
          final st = next.asData?.value;
          if (st != null) _onBattleStateChanged(st);
        },
      );
    }

    final controller = _controller;
    final cameraReady =
        controller != null && controller.value.isInitialized == true;
    // Spinner de tela cheia só na abertura. Durante a troca de câmera o
    // controller fica nulo por um instante — mantemos chat/HUD montados e
    // mostramos só um fundo preto no lugar do preview.
    if (!cameraReady && !_isSwitchingCamera && !_rtcActive) {
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
              // Batalha com tempo real: própria câmera + adversário (LiveKit)
              // no layout do contrato (eu à esq / parceiro à dir, §18.1).
              if (_rtcActive && _rtcSession != null)
                BattleCreatorStage(
                  layout: battleLayoutOf(
                    context,
                    splitTop: battleCreatorSplitTop(context),
                    ownSide: _layoutSide(),
                  ),
                  session: _rtcSession!,
                  mySide: _mySideNow(),
                  battle: _activeBattleId == null
                      ? null
                      : ref
                            .watch(battleViewModelProvider(_activeBattleId!))
                            .value,
                )
              else if (cameraReady)
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
              if (!(_rtcActive && _rtcSession != null))
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

              // Tela dupla: área do chat com fundo escuro sólido.
              if (_split)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: battleLayoutOf(
                    context,
                    splitTop: battleCreatorSplitTop(context),
                    ownSide: _layoutSide(),
                  ).chat.top,
                  child: const ColoredBox(color: Color(0xFF0B0E14)),
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
              // ===== Efeito de entrada de viewer (criador vê quem chega) =====
              // Em batalha: efeitos de entrada/combo ficam na região de baixo.
              if (_split) ...[
                battleRegionWrap(
                  context,
                  battleLayoutOf(
                    context,
                    splitTop: battleCreatorSplitTop(context),
                    ownSide: _layoutSide(),
                  ).chat,
                  EntranceEffectLayer(
                    roomId: widget.room.id,
                    ignoreUserId: widget.room.streamerId,
                  ),
                ),
                battleRegionWrap(
                  context,
                  battleLayoutOf(
                    context,
                    splitTop: battleCreatorSplitTop(context),
                    ownSide: _layoutSide(),
                  ).chat,
                  ComboTierLayer(roomId: widget.room.id),
                ),
              ] else ...[
                EntranceEffectLayer(
                  roomId: widget.room.id,
                  ignoreUserId: widget.room.streamerId,
                ),
                // ===== Degraus do combo =====
                ComboTierLayer(roomId: widget.room.id),
              ],

              // ===== Conexão (tela dupla sem batalha) =====
              if (_link != null && _activeBattleId == null)
                Positioned.fill(
                  child: LinkHudOverlay(
                    link: _link!,
                    layout: battleLayoutOf(
                      context,
                      splitTop: battleCreatorSplitTop(context),
                      ownSide: _layoutSide(),
                    ),
                    ownSide:
                        _link!.sideOf(
                          userId: _room.streamerId,
                          roomId: _room.id,
                        ) ??
                        'a',
                    isCreator: true,
                  ),
                ),

              // ===== Silenciar o parceiro: faixa escura do topo, acima da
              // metade dele (conexão E batalha — a conversa continua). =====
              if (_link != null)
                Builder(
                  builder: (context) {
                    final layout = battleLayoutOf(
                      context,
                      splitTop: battleCreatorSplitTop(context),
                      ownSide: _layoutSide(),
                    );
                    final own =
                        _link!.sideOf(
                          userId: _room.streamerId,
                          roomId: _room.id,
                        ) ??
                        'a';
                    final partner = own == 'a' ? 'b' : 'a';
                    final h = layout.half(partner);
                    return Positioned(
                      top: layout.split.top - kLinkControlBandH + 4,
                      // §18.1: o parceiro fica à direita; o botão segue a metade dele.
                      left: layout.isLeft(partner) ? h.left + 8 : null,
                      right: !layout.isLeft(partner)
                          ? layout.screen.width - h.right + 8
                          : null,
                      child: LinkMuteButton(
                        muted: _link!.mutedOf(own),
                        onTap: _linkBusy ? null : _toggleLinkMute,
                      ),
                    );
                  },
                ),

              // ===== Battle HUD (streamer) =====
              if (_activeBattleId != null)
                Positioned.fill(
                  child: StreamerBattleHud(
                    battleId: _activeBattleId!,
                    myStreamerId: _room.streamerId,
                    myRoomId: _room.id,
                    initialCountdown: _countdownPayload,
                    // Fechar o resultado: volta para a "live normal"
                    // (inclusive o liveType). Idempotente.
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
                            Flexible(
                              child: LiveEventChip(
                                expand: true,
                                roomId: widget.room.id,
                                initialEvent: _room.event,
                                onTap: (event) => EventPageSheet.show(
                                  context,
                                  roomId: widget.room.id,
                                  streamerId: _room.streamerId,
                                  event: event,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: LiveGoalsPill(
                                expand: true,
                                key: _goalsKey,
                                roomId: widget.room.id,
                                streamerId: _room.streamerId,
                                initialGoals: _room.goals,
                                isCreator: true,
                                onEdit: _openGoals,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LiveGiftTicker(
                                expand: true,
                                currentRoomId: widget.room.id,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (viewerEvent != null && _activeBattleId == null)
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
                  child: Center(
                    child: _ResumeFeedbackPill(state: _resumeFeedback),
                  ),
                ),

              // ===== Dock inferior: convite pendente + chat + input + ações =====
              // Único widget que acompanha o teclado (a câmera não mexe).
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                // Em batalha o dock começa ABAIXO da faixa do jogo (fileira do
                // time + narrador) e é recortado: o chat nunca a cobre.
                top: _split
                    ? battleLayoutOf(
                        context,
                        splitTop: battleCreatorSplitTop(context),
                        ownSide: _layoutSide(),
                      ).rowsBottom
                    : null,
                child: BattleDockClip(
                  enabled: _split,
                  child: _BroadcasterChatDock(
                  battleChatTop: _split
                      ? battleLayoutOf(
                          context,
                          splitTop: battleCreatorSplitTop(context),
                          ownSide: _layoutSide(),
                        ).rowsBottom
                      : null,
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
                      child: PinnedAboveChat(
                        roomId: widget.room.id,
                        isHost: true,
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
                  ),
                  input: _showChatInput
                      ? ChatErrorAbove(
                          roomId: widget.room.id,
                          child: _CreatorChatInput(
                            controller: _chatCtrl,
                            focusNode: _chatFocus,
                            hint: S.of(context).liveCommentsHint,
                            onSend: _sendCreatorComment,
                            onClose: _closeChatInput,
                          ),
                        )
                      : null,
                  actionBar: !_showCountdown && (_isStreaming || _isPaused)
                      ? LiveActionBar(
                          isPaused: _isPaused,
                          isTogglingPause: _isTogglingPause,
                          isTogglingStream: _isTogglingStream,
                          hasBattle: _activeBattleId != null && !_battleEnded,
                          // Após o fim: "Revanche" na barra de ações (sem cartão).
                          battleLabel:
                              (_rematchId != null &&
                                  (_activeBattleId == null || _battleEnded))
                              ? S.of(context).battleRematch
                              : null,
                          battleIcon:
                              (_rematchId != null &&
                                  (_activeBattleId == null || _battleEnded))
                              ? Icons.replay_rounded
                              : null,
                          onBattle:
                              (_rematchId != null &&
                                  (_activeBattleId == null || _battleEnded))
                              ? _requestRematch
                              : _link != null
                              ? _startBattleInLink
                              : () => _showBattleSheet(context),
                          coHostLabel: _link != null
                              ? S.of(context).linkDisconnect
                              : null,
                          coHostIcon: _link != null
                              ? Icons.link_off_rounded
                              : null,
                          // Co-host desativado até existir mídia em tempo
                          // real (ver diagnóstico) — botão escondido.
                          onCoHost: _link != null
                              ? _confirmDisconnect
                              : (_linkEnabled && _activeBattleId == null)
                              ? () => _showLinkSheet(context)
                              : null,
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
    this.avatarUrl,
    this.durationSeconds,
    this.isLink = false,
    this.withBattle = false,
  });

  final bool isLink;
  final bool withBattle;
  final String fromName;
  final String? avatarUrl;
  final int? durationSeconds;

  /// Segundos até o convite expirar (relógio do servidor, `expires_at`).
  final int totalSeconds;
  final S l10n;

  @override
  State<_BattleInviteDialog> createState() => _BattleInviteDialogState();
}

class _BattleInviteDialogState extends State<_BattleInviteDialog> {
  late final DateTime _deadline = DateTime.now().add(
    Duration(seconds: widget.totalSeconds),
  );
  late int _remaining = widget.totalSeconds;
  Timer? _tick;

  /// Evita 2 toques (aceitar/recusar) → 2 `pop` (o 2º fecharia outra rota).
  bool _answered = false;

  void _answer(bool accepted) {
    if (_answered) return;
    _answered = true;
    _tick?.cancel();
    Navigator.of(context).pop(accepted);
  }

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final left = _deadline.difference(DateTime.now()).inSeconds;
      setState(() => _remaining = left < 0 ? 0 : left);
      if (left <= 0) {
        _answer(false); // expirou: conta como recusa
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
    final l10n = widget.l10n;
    final progress = (_remaining / widget.totalSeconds).clamp(0.0, 1.0);
    final minutes = widget.durationSeconds == null
        ? null
        : (widget.durationSeconds! / 60).round().clamp(1, 999);
    return AlertDialog(
      backgroundColor: AppColors.slate,
      title: Row(
        children: [
          if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.avatarUrl!),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.sports_kabaddi,
                color: AppColors.braweBlueBright,
              ),
            ),
          Expanded(
            child: Text(
              widget.isLink
                  ? l10n.linkInviteReceived(widget.fromName)
                  : l10n.battleInviteReceived(widget.fromName),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isLink && widget.withBattle) ...[
            Text(
              l10n.linkInviteWithBattle,
              style: const TextStyle(
                color: AppColors.braweOrange,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (minutes != null) ...[
            Text(
              '${l10n.battleDurationLabel}: ${l10n.battleDurationMinutes(minutes)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.braweBlueBright,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.battleInviteExpiresIn(_remaining),
            style: TextStyle(
              color: _remaining > 15 ? Colors.white38 : AppColors.braweOrange,
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _answered ? null : () => _answer(false),
          child: Text(
            l10n.battleDecline,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          onPressed: _answered ? null : () => _answer(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.braweBlueBright,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.battleAccept),
        ),
      ],
    );
  }
}

class _OutgoingInvite {
  const _OutgoingInvite({
    required this.battleId,
    required this.opponentName,
    required this.expiresAt,
    this.isLink = false,
  });

  /// `true`: convite de CONEXÃO (`battleId` guarda o `link_id`).
  final bool isLink;

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
        border: Border.all(color: AppColors.braweBlue.withValues(alpha: 0.6)),
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
              S
                  .of(context)
                  .battleWaitingAccept(widget.invite.opponentName, remaining),
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
            child: Text(
              S.of(context).battleCancel,
              style: const TextStyle(
                color: AppColors.braweOrange,
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
    this.battleChatTop,
    required this.tickerBuilder,
    this.banner,
    this.input,
    this.actionBar,
  });

  /// Em batalha: Y onde começa a região do chat (nada sobe sobre o vídeo).
  final double? battleChatTop;
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
    final battleFree = battleChatTop == null
        ? 0.0
        : size.height - battleChatTop! - below - bottomInset - 40;
    final tickerMax = battleChatTop != null
        ? battleFree.clamp(0.0, 220.0)
        : typing
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
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
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
              const Icon(
                Icons.pause_circle_filled_rounded,
                color: AppColors.braweOrange,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                s.broadcasterPausedTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.broadcasterPausedHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
            ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                s.broadcasterResumeButton,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
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
        border: Border.all(
          color: Colors.white.withValues(alpha: live ? 0.3 : 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          live
              ? const Icon(Icons.sensors_rounded, color: Colors.white, size: 22)
              : const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live ? s.broadcasterBackLive : s.broadcasterResumingTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (!live)
                  Text(
                    s.broadcasterResumingHint,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
