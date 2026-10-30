import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/repositories/waveform_repository.dart';
import '../../../domain/models/sound.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import 'waveform_view.dart';

/// Resultado devolvido por [SoundTrimScreen.push]: o trecho ESPECÍFICO
/// (em milissegundos, relativo ao início da faixa) escolhido pelo usuário
/// para anexar a ESTE conteúdo (post/story/Reel).
class SoundTrimResult {
  const SoundTrimResult({required this.trimStartMs, required this.trimEndMs});
  final int trimStartMs;
  final int trimEndMs;
}

/// Tela de seleção de trecho (trim) de uma música do Brawe Sounds.
///
/// Espelha o padrão visual/UX de `StoryVideoTrimScreen` (vídeo), mas para
/// ÁUDIO: usa a waveform REAL da faixa (`Sound.waveformUrl` via
/// `WaveformRepository`) como timeline arrastável, com um player próprio
/// (`AudioPlayer` isolado — NÃO usa o `SoundPlayerViewModel` global, para
/// não conflitar com outros players enquanto o usuário ainda está
/// editando/decidindo o trecho).
///
/// [maxDuration] é o teto de segurança do TIPO de conteúdo (imagem: 15s,
/// vídeo/Reel/story: até 60s) — mesmo valor validado no servidor via
/// `validate_trim_range()` (backend `sound_preview_service.py`). O usuário
/// nunca consegue selecionar um trecho maior que isso na UI, mas o
/// backend SEMPRE revalida (nunca confia só no cliente).
class SoundTrimScreen extends ConsumerStatefulWidget {
  const SoundTrimScreen({
    super.key,
    required this.sound,
    required this.maxDuration,
  });

  final Sound sound;
  final Duration maxDuration;

  /// Abre a tela e aguarda o resultado. Retorna `null` se o usuário
  /// cancelar.
  static Future<SoundTrimResult?> push(
    BuildContext context, {
    required Sound sound,
    required Duration maxDuration,
  }) {
    return Navigator.of(context).push<SoundTrimResult?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SoundTrimScreen(sound: sound, maxDuration: maxDuration),
      ),
    );
  }

  @override
  ConsumerState<SoundTrimScreen> createState() => _SoundTrimScreenState();
}

class _SoundTrimScreenState extends ConsumerState<SoundTrimScreen> {
  AudioPlayer? _player;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;

  List<double>? _waveform;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _position = Duration.zero;

  /// Início/fim do trecho selecionado, em ms — relativo ao início da
  /// faixa completa (0 = início da música).
  int _startMs = 0;
  int _endMs = 0;

  int get _totalMs => widget.sound.durationMs > 0
      ? widget.sound.durationMs
      : (widget.maxDuration.inMilliseconds * 2);

  @override
  void initState() {
    super.initState();
    // Sugestão inicial: usa o trim default da música (se houver e couber
    // no teto do contexto) ou os primeiros N segundos, o que for menor.
    final defaultEnd = widget.sound.trimEndMs ?? widget.sound.durationMs;
    final suggestedLength = (defaultEnd - widget.sound.trimStartMs).clamp(
      1000,
      widget.maxDuration.inMilliseconds,
    );
    _startMs = widget.sound.trimStartMs;
    _endMs = (_startMs + suggestedLength).clamp(_startMs + 1000, _totalMs);
    _loadWaveform();
    _initPlayer();
  }

  Future<void> _loadWaveform() async {
    final samples = await ref
        .read(waveformRepositoryProvider)
        .getWaveform(widget.sound.waveformUrl);
    if (mounted && samples != null) {
      setState(() => _waveform = samples);
    }
  }

  Future<void> _initPlayer() async {
    final player = AudioPlayer();
    _player = player;
    try {
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(widget.sound.audioUrl)),
      );
      _positionSub = player.positionStream.listen((p) {
        if (!mounted) return;
        setState(() => _position = p);
        // Loop manual dentro do trecho selecionado: quando a posição
        // ultrapassa `_endMs`, volta para `_startMs` — permite ao
        // usuário ouvir o trecho em preview contínuo sem sair dele.
        if (p.inMilliseconds >= _endMs && _isPlaying) {
          player.seek(Duration(milliseconds: _startMs));
        }
      });
      _stateSub = player.playerStateStream.listen((s) {
        if (!mounted) return;
        setState(() => _isPlaying = s.playing);
      });
      await player.seek(Duration(milliseconds: _startMs));
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final player = _player;
    if (player == null || _hasError) return;
    if (_isPlaying) {
      await player.pause();
    } else {
      // Sempre reinicia do começo do trecho ao dar play — comportamento
      // previsível ao ajustar as alças e testar de novo.
      final pos = player.position;
      if (pos.inMilliseconds < _startMs || pos.inMilliseconds >= _endMs) {
        await player.seek(Duration(milliseconds: _startMs));
      }
      await player.play();
    }
    HapticFeedback.selectionClick();
  }

  void _onRangeChanged(double startFraction, double endFraction) {
    final newStart = (startFraction * _totalMs).round();
    var newEnd = (endFraction * _totalMs).round();
    // Aplica o teto de duração do contexto (mesma regra do backend).
    final maxMs = widget.maxDuration.inMilliseconds;
    if (newEnd - newStart > maxMs) {
      newEnd = newStart + maxMs;
    }
    setState(() {
      _startMs = newStart;
      _endMs = newEnd;
    });
    _player?.seek(Duration(milliseconds: _startMs));
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
    ).pop(SoundTrimResult(trimStartMs: _startMs, trimEndMs: _endMs));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final selectedSeconds = ((_endMs - _startMs) / 1000).round();
    final maxSeconds = widget.maxDuration.inSeconds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _TopBarButton(
                    label: s.soundTrimCancel,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    s.soundTrimTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  _TopBarButton(
                    label: s.soundTrimSave,
                    accent: true,
                    onTap: (_isLoading || _hasError) ? null : _confirm,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Capa + título
            _SoundHeader(sound: widget.sound),

            const SizedBox(height: 24),

            // Play/pause
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mutedRed,
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
              ),
            ),

            const Spacer(),

            // Painel inferior: hint + duração + timeline de trim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Text(
                    s.soundTrimHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${s.soundTrimSelectedDuration(selectedSeconds)} · ${s.soundTrimMaxDuration(maxSeconds)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TrimTimeline(
                waveform: _waveform,
                totalMs: _totalMs,
                startMs: _startMs,
                endMs: _endMs,
                positionMs: _position.inMilliseconds,
                onRangeChanged: _onRangeChanged,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SoundHeader extends StatelessWidget {
  const _SoundHeader({required this.sound});
  final Sound sound;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 84,
            height: 84,
            child: sound.coverUrl != null
                ? Image.network(sound.coverUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.white12,
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          sound.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (sound.artist != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              sound.artist!.artistName,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Timeline arrastável com waveform real + duas alças (início/fim) +
/// indicador de posição de reprodução. Interação simplificada (drag
/// direto nas alças) — mais leve que depender de um package de terceiros
/// só para áudio, já que o `video_trimmer` é vídeo-only.
class _TrimTimeline extends StatelessWidget {
  const _TrimTimeline({
    required this.waveform,
    required this.totalMs,
    required this.startMs,
    required this.endMs,
    required this.positionMs,
    required this.onRangeChanged,
  });

  final List<double>? waveform;
  final int totalMs;
  final int startMs;
  final int endMs;
  final int positionMs;
  final void Function(double startFraction, double endFraction) onRangeChanged;

  static const double _handleWidth = 18.0;

  @override
  Widget build(BuildContext context) {
    final startFrac = totalMs > 0 ? startMs / totalMs : 0.0;
    final endFrac = totalMs > 0 ? endMs / totalMs : 1.0;
    final posFrac = totalMs > 0 ? positionMs / totalMs : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 64,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.06),
                    child: WaveformView(
                      samples: waveform,
                      progress: posFrac,
                      rangeStart: startFrac,
                      rangeEnd: endFrac,
                      activeColor: AppColors.mutedRed,
                      inactiveColor: Colors.white38,
                      dimOutsideRangeColor: Colors.white12,
                      height: 64,
                      barCount: 70,
                    ),
                  ),
                ),
              ),
              // Alça de início
              _Handle(
                left: (startFrac * width - _handleWidth / 2).clamp(
                  0.0,
                  width - _handleWidth,
                ),
                onDrag: (dx) {
                  final newFrac = ((startFrac * width + dx) / width).clamp(
                    0.0,
                    endFrac - 0.02,
                  );
                  onRangeChanged(newFrac, endFrac);
                },
              ),
              // Alça de fim
              _Handle(
                left: (endFrac * width - _handleWidth / 2).clamp(
                  0.0,
                  width - _handleWidth,
                ),
                onDrag: (dx) {
                  final newFrac = ((endFrac * width + dx) / width).clamp(
                    startFrac + 0.02,
                    1.0,
                  );
                  onRangeChanged(startFrac, newFrac);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.left, required this.onDrag});
  final double left;
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: Container(
          width: 18,
          decoration: BoxDecoration(
            color: AppColors.braweBlue,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.drag_indicator, color: Colors.white, size: 14),
          ),
        ),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.label,
    required this.onTap,
    this.accent = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: !enabled
              ? Colors.white38
              : (accent ? AppColors.mutedRed : Colors.white),
          fontSize: 15,
          fontWeight: accent ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
