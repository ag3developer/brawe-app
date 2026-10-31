import 'dart:async';
import '../../core/view_models/hidden_users_view_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../domain/models/sound_preview.dart';
import '../../../domain/models/story.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../../core/widgets/brawe_story_media.dart';
import '../../profile/widgets/profile_screen.dart' show userStoriesProvider;
import '../../shared/widgets/content_sound_attribution.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sound_player_bottom_sheet.dart';
import '../view_models/stories_view_model.dart';
import 'story_gift_sheet.dart';
import 'gift_flight_overlay.dart';
import '../../../core/network/media_headers.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  // Brawe Sound: `true` quando a música anexada falhou ao carregar (URL
  // inválida, faixa removida, etc). O story NUNCA quebra por isso — apenas
  // mostra "Música indisponível" no lugar do título/artista e não tenta
  // reproduzir novamente.
  bool _soundUnavailable = false;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();

  /// `true` quando o story foi pausado automaticamente pelo lifecycle do
  /// app (background/inativo) — distingue de uma pausa manual do usuário
  /// (long-press), que NUNCA deve ser retomada automaticamente ao voltar.
  bool _pausedByLifecycle = false;

  /// Timer periódico (throttled) que corrige o drift entre vídeo (master
  /// clock) e música anexada em stories de vídeo. Nunca faz seek por
  /// frame — apenas a cada [_driftCheckInterval].
  Timer? _syncTimer;
  static const _driftCheckInterval = Duration(milliseconds: 600);
  static const _driftThreshold = Duration(milliseconds: 300);

  /// Incrementado a cada `_startStory()` — permite que callbacks
  /// assíncronos (aguardando a música ficar pronta) detectem que o story
  /// mudou (ou o viewer foi fechado) enquanto esperavam, e abortem sem
  /// aplicar efeitos em um story que não é mais o atual.
  int _storySession = 0;

  static const _imageDuration = Duration(seconds: 5);

  /// Offset base (px) da área inferior de overlays (legenda, música,
  /// "ver post original"). Elementos adicionais empilham a partir daqui.
  static const _kStoryBottomBase = 80.0;

  Story get _story => widget.stories[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _startStory();
    _notifyViewed();
  }

  /// Pausa vídeo/animação/música quando o app sai de foreground (troca de
  /// app, tela de bloqueio, notification shade) e retoma ao voltar —
  /// sem isso a música do Brawe Sound continuava tocando "às escuras" com
  /// o app em background (lacuna de lifecycle apontada no relatório de
  /// áudio). Nunca retoma automaticamente uma pausa MANUAL do usuário.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (!_paused) {
          _pausedByLifecycle = true;
          _pause();
        }
        break;
      case AppLifecycleState.resumed:
        if (_pausedByLifecycle) {
          _pausedByLifecycle = false;
          _resume();
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Invalida qualquer callback assíncrono pendente de `_startStory()`
    // (ex.: aguardando a música ficar pronta) — ao retomar de um `await`,
    // esses callbacks checam `_storySession` e abortam se ele mudou.
    _storySession++;
    _timer?.cancel();
    _syncTimer?.cancel();
    _progressController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    _replyFocus.dispose();
    // Brawe Sound: para a música ao sair do viewer (não deve continuar
    // tocando em background depois que o usuário fecha a tela). `stop()`
    // incrementa a geração do player IMEDIATAMENTE e de forma SÍNCRONA
    // — qualquer `play()` de uma chamada anterior ainda em andamento é
    // invalidado nesse instante, mesmo que a limpeza completa do
    // `AudioPlayer` (assíncrona) termine depois. `dispose()` precisa
    // permanecer síncrono, por isso a limpeza completa é fire-and-forget
    // com timeout de segurança.
    unawaited(
      ref
          .read(soundPlayerViewModelProvider.notifier)
          .stop()
          .timeout(const Duration(seconds: 2))
          .catchError((_) {}),
    );
    super.dispose();
  }

  void _notifyViewed() {
    if (_currentIndex < 0 || _currentIndex >= widget.stories.length) return;
    final storyId = widget.stories[_currentIndex].id;
    // Callback do parent (UI cache).
    widget.onStoryViewed?.call(storyId);
    // Persiste no backend (fire-and-forget; ignora falhas silenciosamente).
    // Backend não conta view do próprio autor, então é seguro chamar sempre.
    ref
        .read(storiesRepositoryProvider)
        .markAsViewed(storyId)
        .catchError((_) {});
  }

  Future<void> _startStory() async {
    // Sessão desta chamada — usada para abortar callbacks assíncronos
    // (espera pela música, drift timer) caso o story mude ou o viewer
    // seja fechado antes deles terminarem.
    final session = ++_storySession;

    _timer?.cancel();
    _syncTimer?.cancel();
    await _videoController?.dispose();
    _videoController = null;
    _progressController.reset();
    _paused = false;
    _pausedByLifecycle = false;
    _soundUnavailable = false;

    // Brawe Sound: para a música do story anterior ANTES de iniciar o
    // próximo — e AGUARDA a limpeza completar (agora `stop()` é
    // assíncrono). Sem esse `await`, o `play()` da faixa deste story
    // podia começar enquanto o `stop()` do story anterior ainda estava
    // finalizando, e o `AudioPlayer` antigo "vencia" a corrida, deixando
    // uma faixa errada (ou nenhuma) tocando — a causa raiz do Bug #2.
    await ref.read(soundPlayerViewModelProvider.notifier).stop();
    if (!mounted || session != _storySession) return;

    final story = _story;
    final owner = 'story:${story.id}';

    if (story.isVideo && story.mediaUrl.isNotEmpty) {
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(story.playbackUrl),
        httpHeaders: mediaHeadersFor(story.playbackUrl),
      );
      _videoController = ctrl;
      try {
        await ctrl.initialize();
        if (!mounted || session != _storySession) return;
        // Quando há música do Brawe Sounds anexada, o áudio ORIGINAL do
        // vídeo respeita `originalAudioVolume` (definido pelo autor ao
        // publicar) em vez de tocar sempre a 100% — evita que o áudio
        // nativo do vídeo compita com a música escolhida.
        final baseVolume = story.sound != null
            ? story.originalAudioVolume.clamp(0.0, 1.0)
            : 1.0;
        await ctrl.setVolume(_muted ? 0 : baseVolume);
        final duration = ctrl.value.duration > Duration.zero
            ? ctrl.value.duration
            : _imageDuration;
        _progressController.duration = duration;

        // Story de VÍDEO: o vídeo é o master clock (requisito da Fase B).
        // Inicia vídeo + barra de progresso + timer juntos; a música (se
        // houver) é anexada em paralelo e mantida em sincronia por um
        // timer de correção de drift com throttle — nunca por seek a
        // cada frame.
        await ctrl.play();
        if (!mounted || session != _storySession) return;
        _progressController.forward();
        _timer = Timer(duration, _nextStory);
        setState(() {});

        if (story.sound != null) {
          unawaited(
            _playStorySoundIfPresent(
              story.sound,
              owner: owner,
              session: session,
            ),
          );
          _startDriftCorrection(session: session, owner: owner);
        }
      } catch (_) {
        if (!mounted || session != _storySession) return;
        _progressController.duration = _imageDuration;
        _progressController.forward();
        _timer = Timer(_imageDuration, _nextStory);
      }
    } else {
      // Story de IMAGEM: sem master clock externo — aguarda a música
      // ficar pronta (ou falhar/expirar o teto de espera) ANTES de
      // iniciar a barra de progresso, para que ambas comecem "juntas"
      // (requisito da Fase B; corrige o drift inicial do Bug #1).
      if (story.sound != null) {
        await _playStorySoundIfPresent(
          story.sound,
          owner: owner,
          session: session,
          awaitReady: true,
        );
      }
      if (!mounted || session != _storySession) return;
      _progressController.duration = _imageDuration;
      _progressController.forward();
      _timer = Timer(_imageDuration, _nextStory);
    }

    // 🚀 Pré-cache do próximo story em background — quando o usuário
    // avançar, a próxima mídia já estará no cache (ou pelo menos com
    // DNS+TLS aquecidos para vídeo). Best-effort, ignora falhas.
    _precacheNeighbors();
  }

  /// Toca a música do Brawe Sounds anexada ao story (se houver),
  /// respeitando o estado atual de mute. O player já recorta o trecho
  /// exato (`trim_start_ms`/`trim_end_ms`) escolhido para ESTE story —
  /// ver `SoundPreviewPlayback.toPlayableSound()`.
  ///
  /// Se [awaitReady] for `true`, espera o player sair de `loading` (até
  /// [_kSoundReadyTimeout]) antes de retornar — usado nos stories de
  /// IMAGEM para iniciar a animação de progresso em sincronia com o
  /// início real do áudio (Fase B). Stories de VÍDEO não usam
  /// `awaitReady` — o vídeo já é o master clock e não pode esperar a
  /// rede da música.
  ///
  /// Nunca deixa uma falha de áudio (URL inválida, faixa removida, etc)
  /// derrubar o story: qualquer erro apenas marca [_soundUnavailable]
  /// para a UI mostrar "Música indisponível" no lugar do título/artista.
  static const _kSoundReadyTimeout = Duration(seconds: 3);
  static const _kSoundReadyPollInterval = Duration(milliseconds: 40);

  Future<void> _playStorySoundIfPresent(
    SoundPreview? sound, {
    required String owner,
    required int session,
    bool awaitReady = false,
  }) async {
    if (sound == null) return;
    final notifier = ref.read(soundPlayerViewModelProvider.notifier);
    try {
      await notifier.play(
        sound.toPlayableSound(volume: _story.soundVolume),
        owner: owner,
      );
      if (!mounted || session != _storySession) return;

      if (awaitReady) {
        var waited = Duration.zero;
        while (waited < _kSoundReadyTimeout) {
          if (!mounted || session != _storySession) return;
          final status = ref.read(soundPlayerViewModelProvider).status;
          if (status == SoundPlayerStatus.playing ||
              status == SoundPlayerStatus.error) {
            break;
          }
          await Future.delayed(_kSoundReadyPollInterval);
          waited += _kSoundReadyPollInterval;
        }
      }

      if (!mounted || session != _storySession) return;
      final status = ref.read(soundPlayerViewModelProvider).status;
      if (status == SoundPlayerStatus.error) {
        if (mounted) setState(() => _soundUnavailable = true);
        return;
      }
      if (_muted) await notifier.setVolume(0);
    } catch (_) {
      if (!mounted || session != _storySession) return;
      setState(() => _soundUnavailable = true);
    }
  }

  /// Inicia o timer de correção de drift (throttled) para stories de
  /// VÍDEO com música anexada: o vídeo é o master clock, e a música é
  /// periodicamente comparada e corrigida via `seek()` se o desvio
  /// exceder [_driftThreshold]. NUNCA faz seek a cada frame — apenas a
  /// cada [_driftCheckInterval].
  void _startDriftCorrection({required int session, required String owner}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_driftCheckInterval, (_) {
      if (!mounted || session != _storySession) {
        _syncTimer?.cancel();
        return;
      }
      if (_paused) return;
      final videoCtrl = _videoController;
      if (videoCtrl == null || !videoCtrl.value.isInitialized) return;

      final notifier = ref.read(soundPlayerViewModelProvider.notifier);
      final playerState = ref.read(soundPlayerViewModelProvider);
      if (playerState.sound == null || !playerState.isPlaying) return;
      // Só corrige se ainda formos o dono legítimo do player — evita
      // interferir se outra tela assumiu o player nesse meio tempo.
      if (!notifier.isOwner(owner)) return;
      final musicDurationMs = playerState.duration.inMilliseconds;
      if (musicDurationMs <= 0) return;

      final videoPos = videoCtrl.value.position;
      final audioPos = playerState.position;
      final drift = videoPos - audioPos;
      if (drift.abs() > _driftThreshold) {
        final progress = (videoPos.inMilliseconds / musicDurationMs).clamp(
          0.0,
          1.0,
        );
        notifier.seek(progress);
      }
    });
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
          unawaited(StoryMediaPrecache.warmUpVideo(s.playbackUrl));
        } else if (mounted) {
          unawaited(StoryMediaPrecache.precacheStoryImage(context, s.mediaUrl));
        }
        // Pré-carrega a camada de textos para aparecer junto com a mídia.
        if (mounted && s.overlayUrl != null && s.overlayUrl!.isNotEmpty) {
          unawaited(
            StoryMediaPrecache.precacheStoryImage(context, s.overlayUrl!),
          );
        }
      }
    }
  }

  void _pause() {
    if (_paused) return;
    _paused = true;
    _timer?.cancel();
    _syncTimer?.cancel();
    _progressController.stop();
    _videoController?.pause();
    if (_story.sound != null) {
      ref.read(soundPlayerViewModelProvider.notifier).pause();
    }
  }

  void _resume() {
    if (!_paused) return;
    _paused = false;
    final session = _storySession;
    final owner = 'story:${_story.id}';
    final notifier = ref.read(soundPlayerViewModelProvider.notifier);
    final playerState = ref.read(soundPlayerViewModelProvider);

    // Fase B: usa a posição REAL do áudio (quando disponível e ainda
    // somos o dono legítimo do player) em vez do valor da animação —
    // evita que o tempo restante calculado derive do progress bar, que
    // pode já estar dessincronizado da música.
    Duration remaining;
    final total = _progressController.duration ?? _imageDuration;
    if (_story.sound != null &&
        playerState.sound?.id == _story.sound!.id &&
        notifier.isOwner(owner) &&
        playerState.duration > Duration.zero) {
      remaining = playerState.duration - playerState.position;
      if (remaining.isNegative) remaining = Duration.zero;
    } else {
      remaining = total * (1 - _progressController.value);
    }

    _progressController.forward();
    _videoController?.play();
    _timer = Timer(remaining, _nextStory);
    if (_story.sound != null) {
      notifier.play(
        _story.sound!.toPlayableSound(volume: _story.soundVolume),
        owner: owner,
      );
      if (_videoController != null) {
        _startDriftCorrection(session: session, owner: owner);
      }
    }
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
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: Text(
                      S.of(sheetCtx).viewerDeleteStory,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: () => Navigator.pop(sheetCtx, 'delete'),
                  )
                else ...[
                  ListTile(
                    leading: Icon(
                      Icons.person_off_outlined,
                      color: sheetCtx.colors.textPrimary,
                    ),
                    title: Text(
                      S.of(sheetCtx).viewerUnfollow,
                      style: TextStyle(color: sheetCtx.colors.textPrimary),
                    ),
                    onTap: () => Navigator.pop(sheetCtx, 'unfollow'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.block,
                      color: sheetCtx.colors.textPrimary,
                    ),
                    title: Text(
                      S.of(sheetCtx).viewerBlockUser,
                      style: TextStyle(color: sheetCtx.colors.textPrimary),
                    ),
                    onTap: () => Navigator.pop(sheetCtx, 'block'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: Colors.red),
                    title: Text(
                      S.of(sheetCtx).viewerReport,
                      style: const TextStyle(color: Colors.red),
                    ),
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
        title: Text(
          S.of(context).viewerDeleteStory,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          S.of(context).viewerDeleteConfirm,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              S.of(context).viewerCancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              S.of(context).viewerDelete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      _resume();
      return;
    }
    try {
      await ref.read(storiesViewModelProvider.notifier).deleteStory(_story.id);
      // Invalida também o cache do anel de stories do perfil — sem isso o
      // anel colorido continua aparecendo e o usuário acha que "não deletou".
      ref.invalidate(userStoriesProvider(_story.authorId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).viewerStoryDeleted)));
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
        SnackBar(
          content: Text(S.of(context).viewerUnfollowed(_story.authorUsername)),
        ),
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
        title: Text(
          S.of(ctx).viewerBlockUser,
          style: TextStyle(color: ctx.colors.textPrimary),
        ),
        content: Text(
          S.of(ctx).viewerBlockConfirm(_story.authorUsername),
          style: TextStyle(color: ctx.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              S.of(ctx).viewerCancel,
              style: TextStyle(color: ctx.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(ctx).viewerBlock,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      _resume();
      return;
    }
    try {
      await ref.read(hiddenUsersProvider.notifier).block(
            slug: _story.authorUsername.isNotEmpty
                ? _story.authorUsername
                : _story.authorId,
            userId: _story.authorId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).viewerBlocked(_story.authorUsername)),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _resume();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).viewerBlockError)));
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
                    child: Text(
                      S.of(sheetCtx).viewerReportPrompt,
                      style: TextStyle(
                        color: sheetCtx.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                _reasonTile(sheetCtx, 'spam', S.of(sheetCtx).viewerReportSpam),
                _reasonTile(
                  sheetCtx,
                  'harassment',
                  S.of(sheetCtx).viewerReportHarassment,
                ),
                _reasonTile(
                  sheetCtx,
                  'inappropriate',
                  S.of(sheetCtx).viewerReportInappropriate,
                ),
                _reasonTile(
                  sheetCtx,
                  'impersonation',
                  S.of(sheetCtx).viewerReportImpersonation,
                ),
                _reasonTile(
                  sheetCtx,
                  'other',
                  S.of(sheetCtx).viewerReportOther,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
    if (reason == null) return;
    try {
      await ref
          .read(socialActionsServiceProvider)
          .report(targetType: 'story', targetId: _story.id, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).viewerReportSent)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).viewerReportError)));
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
              // ── Quadro 9:16 (padrão Instagram atual) ──────────────────
              // O story fica num quadro 9:16 com cantos arredondados a
              // partir do topo; em celulares altos sobra espaço embaixo
              // para a barra de resposta. Antes a mídia era "cover" na tela
              // inteira (19.5:9) e as laterais eram cortadas — texto que o
              // autor pôs perto da borda no editor (canvas 9:16) sumia.
              // Agora o que o autor vê no editor é o que o espectador vê.
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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

                            // Camada de textos do editor (PNG transparente 9:16). Usa o
                            // MESMO enquadramento da mídia (caixa 9:16 em BoxFit.cover)
                            // para o texto cair exatamente onde o autor colocou.
                            if (story.overlayUrl != null &&
                                story.overlayUrl!.isNotEmpty)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: ClipRect(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: 1080,
                                        height: 1920,
                                        child: Image.network(
                                          cacheWidth: context.decodeScreenPx,
                                          story.overlayUrl!,
                                          fit: BoxFit.fill,
                                          gaplessPlayback: true,
                                          errorBuilder: (_, _, _) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.black45,
                    ],
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: SizedBox(
                                    height: 3,
                                    child: i < _currentIndex
                                        ? Container(color: Colors.white)
                                        : i == _currentIndex
                                        ? AnimatedBuilder(
                                            animation: _progressController,
                                            builder: (_, _) =>
                                                LinearProgressIndicator(
                                                  value:
                                                      _progressController.value,
                                                  backgroundColor:
                                                      Colors.white30,
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
                                            color: AppColors.braweBlue,
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
                                    // Brawe Sound: atribuição musical
                                    // compacta, logo abaixo do nome+horário
                                    // do autor (padrão contextual — NÃO é
                                    // mais um card separado na parte
                                    // inferior da tela, perto dos
                                    // comentários/visualizações).
                                    if (story.sound != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: ContentSoundAttribution(
                                          trackId: story.sound!.id,
                                          title: story.sound!.title,
                                          artistName: story.sound!.artistName,
                                          coverUrl: story.sound!.coverUrl,
                                          isPlaying:
                                              !_paused &&
                                              !_muted &&
                                              !_soundUnavailable,
                                          isUnavailable: _soundUnavailable,
                                          contentType:
                                              ContentSoundSurface.story,
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.55,
                                          onTap: () =>
                                              _openSoundDetails(story.sound!),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (story.isVideo)
                                IconButton(
                                  icon: Icon(
                                    _muted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleMute,
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                onPressed: _openMenu,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
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

              // Brawe Sound: a atribuição musical NÃO fica mais aqui.
              // Ela foi movida para o header, abaixo do nome+horário do
              // autor (ver Row do avatar acima) — é uma informação
              // contextual da publicação, não um card separado perto da
              // reply bar/comentários. Ver `ContentSoundAttribution`.
              if (story.caption != null)
                Positioned(
                  bottom: _kStoryBottomBase,
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

              // Chip "Ver post original" quando o story é um repost.
              // Empilha acima da legenda quando ambos existem.
              if (story.originPostId != null && story.originPostId!.isNotEmpty)
                Positioned(
                  bottom: _kStoryBottomBase + (story.caption != null ? 40 : 0),
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // Fecha o viewer e abre o post original (rota
                      // /post/:postId). Antes só fechava o story.
                      final router = GoRouter.of(context);
                      final postId = story.originPostId!;
                      Navigator.of(context).maybePop();
                      router.push('/post/$postId');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: Colors.white,
                          ),
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
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      8 + MediaQuery.of(context).viewInsets.bottom,
                    ),
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
    // Ao desmutar, restaura o volume ORIGINAL configurado para este
    // story (não sempre 1.0) — mantém a mixagem autor-definida entre
    // áudio nativo do vídeo e a música anexada.
    final baseVolume = _story.sound != null
        ? _story.originalAudioVolume.clamp(0.0, 1.0)
        : 1.0;
    _videoController?.setVolume(_muted ? 0 : baseVolume);
    // Brawe Sound: o mute do vídeo também silencia a música anexada —
    // mesma semântica do Instagram/TikTok (um único controle de áudio).
    if (_story.sound != null) {
      ref
          .read(soundPlayerViewModelProvider.notifier)
          .setVolume(_muted ? 0 : _story.soundVolume.clamp(0.0, 1.0));
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).viewerReplySent)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).viewerReplyError)));
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

  /// Abre a página/bottom sheet da faixa (reutiliza `SoundPlayerBottomSheet`
  /// já existente — não cria uma segunda tela duplicada). Pausa o story
  /// enquanto o sheet está aberto e retoma ao fechar, mesmo padrão de
  /// `_openViewers`/`_openMenu`.
  Future<void> _openSoundDetails(SoundPreview sound) async {
    _pause();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoundPlayerBottomSheet(sound: sound.toPlayableSound()),
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
                  cursorColor: AppColors.braweBlue,
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
        _StoryActionChip(icon: Icons.card_giftcard, onTap: _openGiftSheet),
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
                colors: [AppColors.braweBlue, AppColors.braweSky],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.braweBlue.withValues(alpha: 0.45),
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
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
        slug: result.giftSlug,
        tier: result.giftTier,
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
        backgroundColor: AppColors.braweBlue.withValues(alpha: 0.92),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                S
                    .of(context)
                    .viewerGiftSent(
                      result.giftName,
                      result.quantity,
                      result.totalCredits,
                    ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
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
  ConsumerState<_StoryViewersSheet> createState() => _StoryViewersSheetState();
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
                const Icon(Icons.visibility, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _loading
                      ? S.of(context).viewerLoading
                      : S.of(context).viewerViewsCount(_total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.braweBlue,
                    ),
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
                                v.name.isNotEmpty ? v.name : v.username,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (v.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: AppColors.braweBlue,
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '@${v.username} · ${_relative(context, v.viewedAt)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: v.reaction != null && v.reaction!.isNotEmpty
                            ? Text(
                                v.reaction!,
                                style: const TextStyle(fontSize: 20),
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
