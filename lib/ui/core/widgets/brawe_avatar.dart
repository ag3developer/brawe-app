// ============================================================================
// BRAWE AVATAR — Widget reutilizável de avatar com cache + skeleton
// ============================================================================
// Substitui o padrão `CircleAvatar(backgroundImage: NetworkImage(url))`
// usado em ~14 lugares no app por uma versão profissional com:
//
//   1. Cache em disco (cached_network_image) — segunda visualização é
//      instantânea, não há "loading" ao reabrir uma tela.
//   2. Skeleton sutil durante o load — substitui o placeholder feio
//      "letra inicial gigante" que aparecia em telas inteiras (e até no
//      fullscreen do StoryViewer) enquanto a mídia baixava.
//   3. Fallback determinístico de cor — quando NÃO há URL ou ela falha,
//      mostra a inicial sobre uma cor derivada do nome (estilo Slack/
//      Google), em vez do cinza genérico que parecia bug.
//   4. Tap opcional — abre callback (perfil, etc.).
//
// Filosofia: a inicial só aparece quando REALMENTE não temos imagem,
// nunca como "loading state".
// ============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BraweAvatar extends StatelessWidget {
  /// URL do avatar; quando null/vazia, exibe o fallback de inicial.
  final String? avatarUrl;

  /// Nome do usuário (para gerar a inicial e a cor do fallback).
  /// Pode ser nome completo, username ou ambos — usamos o primeiro
  /// caractere alfabético encontrado.
  final String displayName;

  /// Diâmetro total do avatar em pixels lógicos.
  final double size;

  /// Tamanho da fonte da inicial; quando null, calcula como `size * 0.42`.
  final double? fontSize;

  /// Cor da borda; quando null, sem borda.
  final Color? borderColor;

  /// Espessura da borda (só usada se borderColor != null).
  final double borderWidth;

  /// Callback opcional de tap.
  final VoidCallback? onTap;

  /// Quando `true`, mantém o widget renderizado mesmo após erro
  /// (não some — mostra a inicial). Default `true`.
  final bool fallbackOnError;

  const BraweAvatar({
    super.key,
    required this.avatarUrl,
    required this.displayName,
    this.size = 40,
    this.fontSize,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
    this.fallbackOnError = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    final initial = BraweAvatar.initialFor(displayName);
    final bgColor = BraweAvatar.colorFor(displayName);

    final inner = ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: hasUrl
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                // Decodifica no tamanho exibido (não no tamanho do arquivo).
                memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
                fadeInDuration: const Duration(milliseconds: 180),
                fadeOutDuration: const Duration(milliseconds: 80),
                placeholder: (_, _) =>
                    _Skeleton(size: size, baseColor: bgColor),
                errorWidget: (_, _, _) => fallbackOnError
                    ? _InitialFallback(
                        initial: initial,
                        size: size,
                        bgColor: bgColor,
                        fontSize: fontSize ?? size * 0.42,
                      )
                    : const SizedBox.shrink(),
              )
            : _InitialFallback(
                initial: initial,
                size: size,
                bgColor: bgColor,
                fontSize: fontSize ?? size * 0.42,
              ),
      ),
    );

    Widget content = inner;
    if (borderColor != null && borderWidth > 0) {
      content = Container(
        width: size + borderWidth * 2,
        height: size + borderWidth * 2,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
        child: inner,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  /// Devolve a primeira letra "humana" do nome, em maiúscula. Ignora
  /// emojis e símbolos no início (ex.: "🎮 Jose" → "J").
  ///
  /// Público: usado pelo BraweStoryMedia para fallback de erro.
  static String initialFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    for (final r in trimmed.runes) {
      final ch = String.fromCharCode(r);
      if (RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(ch)) return ch.toUpperCase();
    }
    return trimmed.characters.first.toUpperCase();
  }

  /// Gera uma cor estável a partir do nome (mesma entrada → mesma cor).
  /// Estilo Google/Slack — paleta saturada e legível em texto branco.
  ///
  /// Público: reutilizado por outros widgets (story media backdrop, etc.).
  static Color colorFor(String name) {
    if (name.isEmpty) return _palette[0];
    var hash = 0;
    for (final cu in name.codeUnits) {
      hash = (hash * 31 + cu) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }

  // Paleta cuidadosamente escolhida: bom contraste com texto branco,
  // visualmente distinguível ao lado de outras cores da paleta.
  static const _palette = <Color>[
    Color(0xFF6366F1), // indigo
    Color(0xFFEC4899), // pink
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFF06B6D4), // cyan
    Color(0xFF8B5CF6), // violet
    Color(0xFFEF4444), // red
    Color(0xFF3B82F6), // blue
    Color(0xFFF97316), // orange
    Color(0xFF14B8A6), // teal
  ];
}

class _InitialFallback extends StatelessWidget {
  final String initial;
  final double size;
  final Color bgColor;
  final double fontSize;

  const _InitialFallback({
    required this.initial,
    required this.size,
    required this.bgColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Pequeno gradiente para dar profundidade — evita o look "flat" do
    // CircleAvatar tradicional.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, Color.lerp(bgColor, Colors.black, 0.15)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

/// Skeleton suave (gradiente animado em loop) para o estado de loading.
/// Usa a cor derivada do nome como base, então ainda é "personalizado"
/// mas sem a letra gritante.
class _Skeleton extends StatefulWidget {
  final double size;
  final Color baseColor;

  const _Skeleton({required this.size, required this.baseColor});

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Color.lerp(widget.baseColor, Colors.black, 0.55)!;
    final highlight = Color.lerp(widget.baseColor, Colors.black, 0.35)!;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1 + _ctrl.value * 2, 0),
              end: Alignment(1 + _ctrl.value * 2, 0),
            ),
          ),
        );
      },
    );
  }
}
