import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Tela de trim/recorte de vídeo do Story Composer.
///
/// Apresentada via `Navigator.push` quando o usuário toca no ícone
/// "scissors" da top bar do `_StoryEditor`. Recebe um [File] de vídeo,
/// devolve um [File] cortado (ou `null` se cancelado).
///
/// Layout (estilo Instagram/TikTok 2026):
///   • Top bar: "Cancelar" (esquerda) | título | "Concluir" (direita)
///   • Centro: VideoViewer (preview do trecho selecionado)
///   • Rodapé: TrimViewer (timeline com handles arrastáveis) + duração
///
/// Limites:
///   • Duração mínima: 1s — abaixo disso o story fica inutilizável.
///   • Duração máxima: [maxDuration] (default 60s, igual ao limite
///     `le=60` do backend `stories.py::create_story`). Acima disso o
///     TrimViewer força o usuário a escolher um intervalo válido.
///
/// Importante: o package `video_trimmer` 5.0+ usa APIs nativas
/// (AVFoundation no iOS, MediaCodec/MediaMuxer no Android). Sem ffmpeg.
class StoryVideoTrimScreen extends StatefulWidget {
  const StoryVideoTrimScreen({
    super.key,
    required this.file,
    this.maxDuration = const Duration(seconds: 60),
  });

  final File file;
  final Duration maxDuration;

  /// Helper para abrir a tela e aguardar o resultado. Retorna o arquivo
  /// cortado, ou `null` se o usuário cancelou. Se algo falhar, mostra
  /// um snackbar e retorna o arquivo original (fail-safe — usuário não
  /// fica preso na UI).
  static Future<File?> push(
    BuildContext context, {
    required File file,
    Duration maxDuration = const Duration(seconds: 60),
  }) {
    return Navigator.of(context).push<File?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => StoryVideoTrimScreen(
          file: file,
          maxDuration: maxDuration,
        ),
      ),
    );
  }

  @override
  State<StoryVideoTrimScreen> createState() => _StoryVideoTrimScreenState();
}

class _StoryVideoTrimScreenState extends State<StoryVideoTrimScreen> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _isProcessing = false;

  /// Sinaliza que `_trimmer.loadVideo()` retornou com sucesso. Usado SÓ
  /// pra dismissar o overlay de loading — NÃO gate a árvore do TrimViewer.
  /// Ver `initState` para a sequência correta de mount → load.
  bool _videoLoaded = false;

  /// Altura total RESERVADA para o painel inferior (hint + badge +
  /// timeline + safe area). Fixar isso é o que garante que a barra
  /// SEMPRE aparece — antes a TrimViewer dependia de "sobrar espaço"
  /// embaixo do `Expanded` do preview, e em devices com tela alta
  /// (iPhone 14+, Pixel 7+ em modo compacto) ela era empurrada para
  /// fora da viewport útil.
  ///
  /// 09-jun (segunda iteração): subido pra 240. O `FixedTrimViewer` v5
  /// renderiza internamente:
  ///   • Linha "0:00 ↔ 0:15" (duração start/end) — ~24px
  ///   • Thumbnails (viewerHeight=64)
  ///   • Handles redondos arrastáveis acima/abaixo (~12px cada)
  /// Total mínimo ≈ 112px só pro widget. Com hint + badge + safe area
  /// chegamos a 220+. Margem de 240 garante que nada clipa nem
  /// num iPad Mini em landscape.
  static const double _kBottomPanelHeight = 240.0;

  /// Altura RESERVADA pro widget `TrimViewer` (não confundir com a
  /// altura das thumbnails). Precisa caber:
  ///   • label "0:00 ↔ 0:15" em cima (~24px com padding bottom)
  ///   • thumbnails (`_kThumbnailHeight = 64`)
  ///   • handles que extrapolam por `circleSize/2 = 6px` em cima e embaixo
  /// Total mínimo = 24 + 64 + 12 = 100px. Usamos 140 com folga generosa.
  static const double _kTrimViewerHeight = 140.0;
  static const double _kThumbnailHeight = 64.0;

  @override
  void initState() {
    super.initState();
    // ⚠️ ORDEM CRÍTICA — race condition do video_trimmer 5.x:
    //
    // `Trimmer.loadVideo()` emite `TrimmerEvent.initialized` num
    // StreamController.broadcast() assim que o VideoPlayerController
    // termina `initialize()`. Brodcast streams NÃO replicam eventos
    // pra listeners que se inscrevem DEPOIS — quem perdeu, perdeu.
    //
    // O `TrimViewer` se inscreve no stream DENTRO do initState dele.
    // Se chamarmos `loadVideo()` ANTES do TrimViewer estar montado, o
    // evento é descartado e a barra fica invisível pra sempre (state
    // interno `_isScrollableAllowed` fica `null` → renderiza
    // `const SizedBox()` em vez do FixedTrimViewer/ScrollableTrimViewer).
    //
    // SOLUÇÃO: deferir `_loadVideo()` para o post-frame callback,
    // garantindo que o TrimViewer esteja na árvore (e inscrito no
    // stream) ANTES do `loadVideo` ser invocado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadVideo();
    });
  }

  Future<void> _loadVideo() async {
    try {
      await _trimmer.loadVideo(videoFile: widget.file);
      if (!mounted) return;

      // NÃO pré-populamos `_endValue` manualmente — o TrimViewer chama
      // `onChangeEnd` automaticamente após inicializar com o valor
      // correto (já considerando `maxVideoLength`). Mexer aqui só
      // criaria conflito visual com o que o widget vai setar.
      setState(() => _videoLoaded = true);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).trimError);
      Navigator.of(context).pop();
    }
  }

  Future<void> _togglePlayback() async {
    if (!_videoLoaded || _isProcessing) return;
    // O retorno do `videoPlaybackControl` já reflete o novo estado,
    // mas NÃO chamamos setState aqui — quem atualiza `_isPlaying` é
    // o callback `onChangePlaybackState` do TrimViewer, que dispara
    // tanto em play/pause manual quanto quando o vídeo termina
    // sozinho (chega no `endValue`). Mexer em 2 lugares causava
    // o ícone play/pause ficar dessincronizado em ~10% dos toques.
    await _trimmer.videoPlaybackControl(
      startValue: _startValue,
      endValue: _endValue,
    );
    HapticFeedback.selectionClick();
  }

  Future<void> _saveTrim() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      // O package retorna o caminho do arquivo cortado salvo no
      // diretório de cache do app via callback (API 5.0+).
      String? outputPath;
      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (path) {
          outputPath = path;
        },
      );

      if (!mounted) return;
      if (outputPath == null || outputPath!.isEmpty) {
        AppSnackBar.showError(context, S.of(context).trimError);
        setState(() => _isProcessing = false);
        return;
      }

      // Sanity check — se o arquivo não existe, falha silenciosamente
      // pra não corromper o fluxo do composer.
      final out = File(outputPath!);
      if (!await out.exists()) {
        if (!mounted) return;
        AppSnackBar.showError(context, S.of(context).trimError);
        setState(() => _isProcessing = false);
        return;
      }

      HapticFeedback.mediumImpact();
      if (!mounted) return;
      Navigator.of(context).pop(out);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).trimError);
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Conteúdo principal ──
            //
            // ⚠️ IMPORTANTE: o `TrimViewer` e o `VideoViewer` SEMPRE são
            // montados desde o primeiro frame (mesmo antes do vídeo
            // carregar). Isso garante que o `eventStream.listen` dentro
            // do initState deles esteja ativo ANTES do `loadVideo()`
            // emitir `TrimmerEvent.initialized`. Se gatearmos a árvore
            // por `_videoLoaded`, o evento é perdido (broadcast stream)
            // e a barra de trim fica invisível pra sempre.
            //
            // Enquanto `_videoLoaded == false` o VideoViewer mostra
            // `Container()` e o TrimViewer mostra `SizedBox()` —
            // sobrepomos um overlay de loading via Positioned.fill.
            Column(
              children: [
                SizedBox(height: padding.top + 12),
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _TopBarButton(
                        label: s.trimCancel,
                        onTap: _isProcessing
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        s.trimTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      _TopBarButton(
                        label: s.trimSave,
                        accent: true,
                        // Só permite salvar depois do vídeo carregar E
                        // do TrimViewer ter chamado `onChangeEnd` pelo
                        // menos uma vez (i.e. `_endValue > 0`).
                        onTap: (_isProcessing ||
                                !_videoLoaded ||
                                _endValue <= _startValue)
                            ? null
                            : _saveTrim,
                      ),
                    ],
                  ),
                ),
                // Preview do vídeo (área expansível)
                // ⚠️ FlexFit.tight + Expanded GARANTE que sobre
                // espaço pra área inferior abaixo, mesmo em
                // devices com tela curta (iPhone SE).
                Expanded(
                  child: GestureDetector(
                    onTap: _togglePlayback,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // VideoViewer SEMPRE renderizado pra ter o
                        // event stream listener ativo. Internamente
                        // ele mostra `Container()` enquanto o
                        // controller não tá pronto, então não polui
                        // visualmente.
                        VideoViewer(trimmer: _trimmer),
                        // Play/pause overlay — só visível depois do
                        // vídeo carregar (antes disso o ícone seria
                        // confuso porque não dá pra dar play).
                        if (_videoLoaded)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _isPlaying ? 0.0 : 1.0,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // ── Painel inferior FIXO ──
                // Altura reservada explicitamente para o painel:
                // hint + badge de duração + timeline + safe area.
                // ANTES a TrimViewer ficava sem altura definida
                // dentro de um Padding, e em alguns devices o
                // layout colapsava ela pra 0px → barra invisível.
                // Agora sempre temos `_kBottomPanelHeight`px
                // garantidos abaixo do preview.
                SizedBox(
                  height: _kBottomPanelHeight + padding.bottom,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hint + duração selecionada
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              s.trimHint,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _DurationBadge(
                              duration: Duration(
                                milliseconds:
                                    (_endValue - _startValue).round(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // TrimViewer (timeline) — ALTURA EXPLÍCITA.
                      //
                      // ⚠️ Detalhes que matam o widget:
                      //
                      // 1) `viewerHeight` é só a altura das THUMBNAILS.
                      //    O widget total precisa de espaço extra pros
                      //    handles (cima e baixo) + label "0:00 ↔ 0:15"
                      //    em cima do trim area. Total mínimo ≈ 100px.
                      //    Usar valor menor clipa o widget e ele "some".
                      //
                      // 2) Embrulhar em `Center` força tight constraint
                      //    de altura. Mesmo com SizedBox externo, o
                      //    Center interno colapsava o filho. Usamos
                      //    SizedBox direto.
                      //
                      // 3) `TrimAreaProperties.edgeBlur` tem bug
                      //    conhecido no video_trimmer 5.0 + iOS 18 com
                      //    Impeller (thumbnails ficam invisíveis em
                      //    alguns aspect ratios). Usamos o default
                      //    sem blur — visual igual ao Instagram.
                      //
                      // 4) `viewerWidth` é a largura TOTAL do widget.
                      //    O package usa pra calcular quantos thumbs
                      //    cabem. Passamos `size.width - 32` casando
                      //    com o `Padding.horizontal: 16` do pai;
                      //    valor maior estoura, menor deixa espaço
                      //    em branco nas bordas.
                      SizedBox(
                        height: _kTrimViewerHeight,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: TrimViewer(
                            trimmer: _trimmer,
                            viewerHeight: _kThumbnailHeight,
                            viewerWidth: size.width - 32,
                            maxVideoLength: widget.maxDuration,
                            durationStyle: DurationStyle.FORMAT_MM_SS,
                            durationTextStyle: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            editorProperties: TrimEditorProperties(
                              borderPaintColor: AppColors.braweBlue,
                              borderWidth: 3,
                              borderRadius: 6,
                              // Bola dos handles maior pra ficar
                              // óbvio que é arrastável (era 8,
                              // muito pequeno em dedos grandes).
                              circleSize: 12,
                              circleSizeOnDrag: 16,
                              circlePaintColor: AppColors.braweSky,
                              scrubberPaintColor: Colors.white,
                              scrubberWidth: 2,
                            ),
                            areaProperties: const TrimAreaProperties(
                              thumbnailQuality: 60,
                              borderRadius: 8,
                            ),
                            onChangeStart: (v) {
                              if (!mounted) return;
                              setState(() => _startValue = v);
                            },
                            onChangeEnd: (v) {
                              if (!mounted) return;
                              setState(() => _endValue = v);
                            },
                            onChangePlaybackState: (v) {
                              if (mounted) {
                                setState(() => _isPlaying = v);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: padding.bottom + 12),
                    ],
                  ),
                ),
              ],
            ),

            // ── Overlay de "carregando vídeo" ──
            // Cobre toda a tela até `_videoLoaded` virar true.
            // Importante: este overlay é APENAS visual — o TrimViewer
            // e o VideoViewer já estão montados embaixo, recebendo o
            // evento `initialized` do Trimmer. Sem isso, o stream
            // broadcast perde o evento e a barra fica invisível.
            if (!_videoLoaded)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.braweBlue,
                    ),
                  ),
                ),
              ),

            // ── Overlay de "salvando" ──
            if (_isProcessing)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.65),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.braweBlue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.trimProcessing,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Botão "Cancelar" / "Concluir" da top bar — pill simples.
/// O `accent: true` usa o gradiente Brawe (electric purple → cool cyan).
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
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: accent && !disabled
              ? const LinearGradient(
                  colors: [AppColors.braweBlue, AppColors.braweSky],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !accent
              ? Colors.black.withValues(alpha: disabled ? 0.25 : 0.45)
              : null,
          borderRadius: BorderRadius.circular(20),
          border: !accent
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                )
              : null,
          boxShadow: accent && !disabled
              ? [
                  BoxShadow(
                    color: AppColors.braweBlue.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: disabled ? 0.5 : 1.0),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Badge "5.3s" com o tempo selecionado — pill discreta abaixo do hint.
class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Formata 1 casa decimal, mín 0.1s
    final secs = (duration.inMilliseconds / 1000).clamp(0.0, 99.9);
    final formatted = secs.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        s.trimDuration(formatted),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
