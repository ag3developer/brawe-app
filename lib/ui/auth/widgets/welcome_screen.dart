import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/brawe_logo.dart';
import 'common/auth_action_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;

  // 8 ícones (antes 12) distribuídos em 2 anéis concêntricos com
  // espaçamento angular uniforme (2π/4 por anel, intercalados) — evita o
  // aglomerado visual que existia antes (ícones muito próximos entre si).
  // Anel interno: maior, mais lento, mais opaco (primeiro plano).
  // Anel externo: menor, mais rápido, mais sutil (profundidade/parallax).
  // Cada ícone usa uma cor da paleta de marca (accentPrimary/Secondary/
  // Pink/Gold) em vez de uma única cor sólida — ecoa o gradiente do "B".
  static const _icons = [
    // Anel interno (raio 0.30) — 4 ícones a 90° um do outro.
    _FloatingIconData(
      icon: Icons.videocam_rounded,
      angle: 0.0,
      radius: 0.30,
      size: 20,
      speed: 0.55,
      opacity: 0.8,
      colorSlot: 0,
    ),
    _FloatingIconData(
      icon: Icons.favorite_rounded,
      angle: math.pi / 2,
      radius: 0.30,
      size: 18,
      speed: 0.55,
      opacity: 0.75,
      colorSlot: 1,
    ),
    _FloatingIconData(
      icon: Icons.live_tv_rounded,
      angle: math.pi,
      radius: 0.30,
      size: 20,
      speed: 0.55,
      opacity: 0.8,
      colorSlot: 2,
    ),
    _FloatingIconData(
      icon: Icons.music_note_rounded,
      angle: 3 * math.pi / 2,
      radius: 0.30,
      size: 18,
      speed: 0.55,
      opacity: 0.75,
      colorSlot: 3,
    ),
    // Anel externo (raio 0.46) — 4 ícones, deslocados 45° do anel interno.
    _FloatingIconData(
      icon: Icons.chat_bubble_rounded,
      angle: math.pi / 4,
      radius: 0.46,
      size: 15,
      speed: 0.85,
      opacity: 0.55,
      colorSlot: 1,
    ),
    _FloatingIconData(
      icon: Icons.star_rounded,
      angle: 3 * math.pi / 4,
      radius: 0.46,
      size: 14,
      speed: 0.85,
      opacity: 0.5,
      colorSlot: 2,
    ),
    _FloatingIconData(
      icon: Icons.photo_camera_rounded,
      angle: 5 * math.pi / 4,
      radius: 0.46,
      size: 16,
      speed: 0.85,
      opacity: 0.55,
      colorSlot: 3,
    ),
    _FloatingIconData(
      icon: Icons.people_alt_rounded,
      angle: 7 * math.pi / 4,
      radius: 0.46,
      size: 15,
      speed: 0.85,
      opacity: 0.5,
      colorSlot: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  /// Mapeia `colorSlot` (0-3) para a paleta de marca — os ícones passam a
  /// variar entre roxo/ciano/rosa/dourado, ecoando o gradiente do "B" em
  /// vez de usar uma única cor sólida (antes: `colors.accentPrimary` fixo).
  Color _iconColor(BraweColors colors, int slot) {
    switch (slot) {
      case 1:
        return colors.accentSecondary;
      case 2:
        return colors.accentPink;
      case 3:
        return colors.accentGold;
      default:
        return colors.accentPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = MediaQuery.of(context).size;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Ícones orbitando ─────────────────────────────────────────
          // Achatamento vertical reduzido (0.42, antes 0.55) para manter a
          // órbita mais compacta e não sobrepor a tagline abaixo do logo.
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              return Stack(
                children: _icons.map((data) {
                  final angle =
                      data.angle +
                      _orbitController.value * 2 * math.pi * data.speed;
                  // Raio adaptado ao tamanho da tela
                  final r = size.shortestSide * data.radius;
                  final cx = size.width / 2 + math.cos(angle) * r;
                  final cy = size.height * 0.40 + math.sin(angle) * r * 0.42;

                  // Pulso sutil de opacidade
                  final pulse =
                      0.6 +
                      0.4 *
                          math.sin(
                            _orbitController.value * 2 * math.pi * 2 +
                                data.angle,
                          );

                  return Positioned(
                    left: cx - data.size / 2,
                    top: cy - data.size / 2,
                    child: Opacity(
                      opacity: (data.opacity * pulse).clamp(0.0, 1.0),
                      child: Icon(
                        data.icon,
                        size: data.size.toDouble(),
                        color: _iconColor(colors, data.colorSlot),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // ── Glow central sutil ────────────────────────────────────────
          Positioned(
            left: size.width / 2 - 160,
            top: size.height * 0.42 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.accentPrimary.withValues(alpha: 0.12),
                    colors.accentPrimary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── Logo + conteúdo central ──────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      // Logo no centro vertical
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo — widget de marca reutilizável
                            // (mesmo ícone/gradiente usado em todo o app).
                            const BraweLogo(iconSize: 140, showTagline: false),
                            const SizedBox(height: 16),
                            // Tagline "efeito de digitação": escreve cada
                            // palavra/frase separadamente (apaga entre uma
                            // e outra) e, na última passada, digita a frase
                            // completa e mantém — dá um toque "vivo"/tech
                            // à tela sem depender de texto hardcoded (usa
                            // a mesma chave i18n `welcomeTagline`, dividida
                            // em runtime pelos pontos ".").
                            _TypewriterTagline(
                              text: s.welcomeTagline,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                              cursorColor: colors.accentPrimary,
                            ),
                          ],
                        ),
                      ),

                      // ── Botões na base ─────────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthActionButton(
                            label: s.welcomeCreateAccount,
                            onPressed: () => context.push('/signup'),
                          ),
                          const SizedBox(height: 12),
                          _OutlineBtn(
                            label: s.welcomeAlreadyHaveAccount,
                            onTap: () => context.push('/login'),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Text(
                              s.welcomeAcceptTerms,
                              style: TextStyle(
                                color: colors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botão outline limpo ───────────────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dados de cada ícone flutuante ─────────────────────────────────────────────
class _FloatingIconData {
  const _FloatingIconData({
    required this.icon,
    required this.angle,
    required this.radius,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.colorSlot,
  });
  final IconData icon;
  final double angle; // ângulo inicial em radianos
  final double radius; // fração da shortestSide
  final int size;
  final double speed; // multiplicador de velocidade orbital
  final double opacity;

  /// Índice (0-3) na paleta de marca — ver `_WelcomeScreenState._iconColor`.
  /// Substitui a cor sólida única antiga, alinhando os ícones ao gradiente
  /// multicolor do logo "B" em vez de um roxo monocromático.
  final int colorSlot;
}

// ── Tagline com efeito "máquina de escrever" ──────────────────────────────
//
// Recebe a frase completa (ex.: "Conecte. Transmita. Cresça.") já traduzida
// via i18n e a divide em segmentos pelo separador "." (sem hardcode de
// texto — funciona em PT/ES/EN, cada um com número de frases que quiser).
// Ciclo:
//   1. Digita o 1º segmento, pausa, apaga.
//   2. Digita o 2º segmento, pausa, apaga. (...para cada segmento restante)
//   3. Na última rodada, digita a frase inteira (todos os segmentos juntos,
//      com pontuação) e mantém fixa — não apaga mais.
// Cursor "|" piscando ao final do texto enquanto anima, some no estado final.
class _TypewriterTagline extends StatefulWidget {
  const _TypewriterTagline({
    required this.text,
    required this.style,
    required this.cursorColor,
  });

  final String text;
  final TextStyle style;
  final Color cursorColor;

  @override
  State<_TypewriterTagline> createState() => _TypewriterTaglineState();
}

class _TypewriterTaglineState extends State<_TypewriterTagline>
    with SingleTickerProviderStateMixin {
  late final List<String> _segments;
  late final AnimationController _cursorBlink;

  Timer? _typeTimer;
  String _displayed = '';
  int _segmentIndex = 0;
  bool _finished = false;

  static const _typeSpeed = Duration(milliseconds: 45);
  static const _eraseSpeed = Duration(milliseconds: 28);
  static const _holdAfterType = Duration(milliseconds: 900);
  static const _holdAfterErase = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    // Divide em frases pelo ponto, remove vazios e devolve o "." em cada uma
    // (ex.: "Conecte. Transmita. Cresça." → ["Conecte.", "Transmita.",
    // "Cresça."]) — funciona para qualquer idioma sem hardcode.
    _segments = widget.text
        .split('.')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => '$s.')
        .toList();
    if (_segments.isEmpty) _segments.add(widget.text);

    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _scheduleNextChar();
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorBlink.dispose();
    super.dispose();
  }

  /// Frase-alvo da rodada atual: cada segmento individual, e na última
  /// rodada a junção de todos os segmentos com espaço entre eles.
  String get _currentTarget {
    final isLastRound = _segmentIndex >= _segments.length;
    return isLastRound ? _segments.join(' ') : _segments[_segmentIndex];
  }

  void _scheduleNextChar() {
    if (!mounted) return;
    final target = _currentTarget;
    final isLastRound = _segmentIndex >= _segments.length;

    if (_displayed.length < target.length) {
      // Ainda digitando o segmento atual.
      _typeTimer = Timer(_typeSpeed, () {
        if (!mounted) return;
        setState(() => _displayed = target.substring(0, _displayed.length + 1));
        _scheduleNextChar();
      });
      return;
    }

    // Terminou de digitar o segmento inteiro.
    if (isLastRound) {
      // Última rodada (frase completa) — mantém fixo, sem apagar.
      setState(() => _finished = true);
      _cursorBlink.stop();
      return;
    }

    // Pausa com o segmento completo visível, depois começa a apagar.
    _typeTimer = Timer(_holdAfterType, () {
      if (!mounted) return;
      _eraseCurrentSegment();
    });
  }

  void _eraseCurrentSegment() {
    if (!mounted) return;
    if (_displayed.isNotEmpty) {
      _typeTimer = Timer(_eraseSpeed, () {
        if (!mounted) return;
        setState(
          () => _displayed = _displayed.substring(0, _displayed.length - 1),
        );
        _eraseCurrentSegment();
      });
      return;
    }
    // Terminou de apagar — avança para o próximo segmento (ou rodada final).
    _typeTimer = Timer(_holdAfterErase, () {
      if (!mounted) return;
      setState(() => _segmentIndex++);
      _scheduleNextChar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: _displayed),
          if (!_finished)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: FadeTransition(
                opacity: _cursorBlink,
                child: Container(
                  width: 2,
                  height: (widget.style.fontSize ?? 15) * 0.9,
                  margin: const EdgeInsets.only(left: 2),
                  color: widget.cursorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
