import 'package:flutter/material.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

/// Onde o componente [ContentSoundAttribution] está sendo exibido.
///
/// Não muda a lógica de playback (isso é responsabilidade de quem usa o
/// componente), apenas ajusta pequenos detalhes visuais/comportamentais
/// específicos de cada superfície (ex.: contraste sobre mídia em Story/Reel
/// vs. fundo sólido de card no feed).
enum ContentSoundSurface { story, reel, video, feedPost, postDetail }

/// Linha compacta de atribuição musical — o ÚNICO componente para exibir
/// "qual música está tocando neste conteúdo" em toda a Brawe.
///
/// Usado em: Stories, Reels, vídeos, posts de imagem/vídeo com música.
/// Substitui qualquer card grande/fixo de música (ex.: o antigo
/// `_StorySoundIndicator` do `story_viewer.dart` e a implementação anterior
/// de `SoundPreviewChip`).
///
/// Design: uma única linha (`♪ Título · Artista`), sem card, sem fundo
/// sólido pesado, sem borda grossa. Sobre mídia (Story/Reel/vídeo), usa
/// sombra de texto sutil para legibilidade em vez de um scrim opaco.
///
/// A animação de "tocando" (3 barras verticais) é minimalista e respeita
/// `MediaQuery.disableAnimations` (reduz para ícone estático).
class ContentSoundAttribution extends StatefulWidget {
  const ContentSoundAttribution({
    super.key,
    required this.trackId,
    required this.title,
    this.artistName,
    this.coverUrl,
    this.isPlaying = false,
    this.isOriginalAudio = false,
    this.isUnavailable = false,
    this.onTap,
    this.compact = true,
    this.textColor,
    this.maxWidth,
    this.contentType = ContentSoundSurface.feedPost,
  });

  /// ID da faixa do Brawe Sounds (ou do post/story, quando `isOriginalAudio`).
  /// Usado apenas para permitir que o parent identifique/logue a origem —
  /// o componente não faz nenhuma chamada de rede com ele.
  final String trackId;

  /// Título da faixa. Quando [isOriginalAudio] é `true`, este campo é
  /// ignorado na exibição (usa-se a string localizada "Áudio original").
  final String title;

  /// Nome do artista (ou do autor do conteúdo, quando áudio original).
  /// `null`/vazio omite o "· Artista" sem quebrar o layout.
  final String? artistName;

  /// Capa da faixa (opcional). Ausente = ícone de nota musical.
  final String? coverUrl;

  /// Se a música está tocando AGORA (controla a animação/estado visual).
  /// A fonte da verdade do playback é sempre externa (ex.:
  /// `SoundPlayerViewModel`) — este widget é puramente apresentacional.
  final bool isPlaying;

  /// `true` quando o conteúdo usa o áudio original do próprio vídeo/story
  /// (sem faixa do Brawe Sounds anexada). Exibe "Áudio original" em vez de
  /// título/artista, e desabilita o tap (não há página de faixa pra abrir).
  final bool isOriginalAudio;

  /// `true` quando a faixa foi removida/bloqueada/desativada no backend.
  /// Mostra "Música indisponível" e desabilita o tap — nunca tenta
  /// reproduzir uma URL inválida.
  final bool isUnavailable;

  /// Callback ao tocar na linha (abre a página/bottom sheet da faixa).
  /// `null` quando [isOriginalAudio] ou [isUnavailable] são `true`, ou
  /// quando o parent explicitamente não quer permitir navegação.
  final VoidCallback? onTap;

  /// Reservado para variantes futuras mais densas (ex.: com waveform).
  /// Por ora sempre compacto — mantido para não travar a API pública.
  final bool compact;

  /// Cor do texto/ícone. `null` usa `context.colors.textPrimary` (tema) —
  /// EXCETO em [ContentSoundSurface.story]/[reel]/[video], onde o padrão
  /// é branco com sombra (a mídia de fundo é imprevisível, precisa de
  /// contraste garantido independente do tema claro/escuro do app).
  final Color? textColor;

  /// Largura máxima do texto (título+artista). `null` deixa o layout pai
  /// decidir via `Flexible`/`Expanded`.
  final double? maxWidth;

  /// Onde esse componente está sendo renderizado — ajusta pequenos
  /// detalhes de contraste (ver [textColor]).
  final ContentSoundSurface contentType;

  @override
  State<ContentSoundAttribution> createState() =>
      _ContentSoundAttributionState();
}

class _ContentSoundAttributionState extends State<ContentSoundAttribution>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  bool get _shouldAnimate =>
      widget.isPlaying && !widget.isUnavailable && !widget.isOriginalAudio;

  /// Cria/inicia ou para o controller com base em [_shouldAnimate] e na
  /// preferência de redução de movimento do sistema. Chamado a cada
  /// `build()` (barato — só toca o controller se o estado realmente mudou)
  /// para nunca ficar dessincronizado quando o playback muda ou quando o
  /// usuário alterna a configuração de acessibilidade em tempo real.
  void _syncController(bool reduceMotion) {
    if (!_shouldAnimate || reduceMotion) {
      _pulseController?.stop();
      return;
    }
    _pulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (!_pulseController!.isAnimating) {
      _pulseController!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  bool get _isOnMedia =>
      widget.contentType == ContentSoundSurface.story ||
      widget.contentType == ContentSoundSurface.reel ||
      widget.contentType == ContentSoundSurface.video;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // Mantém o AnimationController sincronizado com o estado atual
    // (play/pause/unavailable) e a preferência de acessibilidade — feito
    // aqui (não em initState) porque MediaQuery só está disponível com
    // o BuildContext já inserido na árvore.
    _syncController(reduceMotion);
    final canTap =
        widget.onTap != null &&
        !widget.isUnavailable &&
        !widget.isOriginalAudio;

    final Color fg =
        widget.textColor ??
        (_isOnMedia ? Colors.white : context.colors.textPrimary);

    final label = widget.isUnavailable
        ? s.contentSoundUnavailable
        : widget.isOriginalAudio
        ? (widget.artistName != null && widget.artistName!.trim().isNotEmpty)
              ? s.contentSoundByArtist(
                  s.contentSoundOriginalAudio,
                  widget.artistName!,
                )
              : s.contentSoundOriginalAudio
        : (widget.artistName != null && widget.artistName!.trim().isNotEmpty)
        ? s.contentSoundByArtist(widget.title, widget.artistName!)
        : widget.title;

    final iconColor = widget.isUnavailable ? fg.withValues(alpha: 0.55) : fg;

    final shadows = _isOnMedia
        ? const [Shadow(color: Colors.black54, blurRadius: 6)]
        : null;

    final semanticsLabel = widget.isUnavailable
        ? s.contentSoundUnavailable
        : widget.isOriginalAudio
        ? label
        : widget.isPlaying
        ? '${s.contentSoundNowPlaying}: $label'
        : label;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SoundGlyph(
          isPlaying: widget.isPlaying && !reduceMotion,
          isUnavailable: widget.isUnavailable,
          color: iconColor,
          controller: _pulseController,
        ),
        const SizedBox(width: 5),
        // `Flexible` (não `ConstrainedBox` fixo): permite que o texto
        // encolha até o espaço real disponível no pai, evitando overflow
        // quando o `Row` está em um contexto mais estreito que
        // `widget.maxWidth`. Quando `widget.maxWidth` é informado, ele
        // ainda funciona como um TETO (via `ConstrainedBox` interno).
        Flexible(
          child: ConstrainedBox(
            constraints: widget.maxWidth != null
                ? BoxConstraints(maxWidth: widget.maxWidth!)
                : const BoxConstraints(),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                shadows: shadows,
              ),
            ),
          ),
        ),
      ],
    );

    return Semantics(
      label: semanticsLabel,
      button: canTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canTap ? widget.onTap : null,
        child: Container(
          // Área mínima de toque acessível (~32px de altura) sem
          // parecer um "botão" grande — apenas padding suficiente.
          constraints: const BoxConstraints(minHeight: 28),
          padding: const EdgeInsets.symmetric(vertical: 2),
          alignment: Alignment.centerLeft,
          child: row,
        ),
      ),
    );
  }
}

/// Ícone/animação compacta: nota musical estática, OU 3 barrinhas
/// verticais pulsando quando tocando (análogo a um equalizador minimalista,
/// sem parecer chamativo/"cassino"). Ícone único (não copia glifos
/// exclusivos de terceiros).
class _SoundGlyph extends StatelessWidget {
  const _SoundGlyph({
    required this.isPlaying,
    required this.isUnavailable,
    required this.color,
    required this.controller,
  });

  final bool isPlaying;
  final bool isUnavailable;
  final Color color;
  final AnimationController? controller;

  static const double _size = 15;

  @override
  Widget build(BuildContext context) {
    if (isUnavailable) {
      return Icon(Icons.music_off_rounded, size: _size, color: color);
    }
    if (!isPlaying || controller == null) {
      return Icon(Icons.music_note_rounded, size: _size, color: color);
    }
    return SizedBox(
      width: _size,
      height: _size,
      child: AnimatedBuilder(
        animation: controller!,
        builder: (context, _) => CustomPaint(
          painter: _EqualizerPainter(t: controller!.value, color: color),
        ),
      ),
    );
  }
}

/// Pintor leve (sem alocações por frame) de 3 barras verticais com alturas
/// defasadas — dá a sensação de equalizador sem CustomPainter pesado nem
/// dependência de pacote de animação/lottie.
class _EqualizerPainter extends CustomPainter {
  const _EqualizerPainter({required this.t, required this.color});
  final double
  t; // 0.0 – 1.0 (vai e volta via controller.repeat(reverse: true))
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // 3 barras com fases diferentes para não pulsarem em sincronia perfeita
    // (visual mais orgânico, menos "robótico").
    const phases = [0.0, 0.33, 0.66];
    final barWidth = size.width / 3;
    for (var i = 0; i < 3; i++) {
      final phase = (t + phases[i]) % 1.0;
      // Curva triangular simples (sem depender de Curves para evitar
      // overshoot visual) — altura oscila entre 35% e 100% do disponível.
      final wave = (phase < 0.5) ? phase * 2 : (1 - phase) * 2;
      final heightFraction = 0.35 + wave * 0.65;
      final barHeight = size.height * heightFraction;
      final dx = barWidth * i + barWidth / 2;
      canvas.drawLine(
        Offset(dx, size.height - barHeight),
        Offset(dx, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
