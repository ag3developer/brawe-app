import 'package:flutter/material.dart';

/// Renderiza uma waveform de barras a partir de amostras reais
/// [0.0..1.0] (vindas de `Sound.waveformUrl` via `WaveformRepository`).
///
/// Reutilizado por [SoundPlayerBottomSheet] (progresso de reprodução) e
/// pela tela de trim de áudio (seleção de trecho) — ambos precisam do
/// MESMO desenho visual da faixa, só com overlays diferentes (progresso
/// vs. seleção de intervalo).
///
/// Se [samples] for `null`/vazio, usa um padrão fixo neutro (nunca quebra
/// a UI por falta de waveform real — apenas fica visualmente genérico).
class WaveformView extends StatelessWidget {
  const WaveformView({
    super.key,
    required this.samples,
    this.progress = 0,
    this.rangeStart = 0.0,
    this.rangeEnd = 1.0,
    this.activeColor = const Color(0xFFE11D48),
    required this.inactiveColor,
    this.dimOutsideRangeColor,
    this.height = 48,
    this.barCount = 60,
  });

  /// Amostras reais [0.0..1.0] da faixa (200 pontos vindos do backend, ou
  /// `null` para usar o fallback neutro).
  final List<double>? samples;

  /// Progresso de reprodução atual [0.0..1.0] — barras antes deste ponto
  /// (dentro do range) ficam com [activeColor].
  final double progress;

  /// Início/fim do trecho selecionável [0.0..1.0] (relativo à duração
  /// TOTAL da faixa). Fora deste intervalo as barras ficam esmaecidas
  /// ([dimOutsideRangeColor]) — usado pela tela de trim.
  final double rangeStart;
  final double rangeEnd;

  final Color activeColor;
  final Color inactiveColor;

  /// Cor das barras fora do intervalo selecionado. `null` = não esmaece
  /// (usa [inactiveColor] uniformemente — caso do player simples sem trim).
  final Color? dimOutsideRangeColor;

  final double height;
  final int barCount;

  static const List<double> _fallbackPattern = [
    0.3, 0.5, 0.8, 0.6, 0.4, 0.9, 0.7, 0.5, 0.3, 0.6,
    0.8, 1.0, 0.7, 0.4, 0.6, 0.5, 0.8, 0.9, 0.6, 0.3,
    0.5, 0.7, 1.0, 0.8, 0.6, 0.4, 0.7, 0.9, 0.5, 0.3,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _WaveformPainter(
          samples: (samples == null || samples!.isEmpty)
              ? _fallbackPattern
              : samples!,
          progress: progress,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          dimOutsideRangeColor: dimOutsideRangeColor,
          barCount: barCount,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.samples,
    required this.progress,
    required this.rangeStart,
    required this.rangeEnd,
    required this.activeColor,
    required this.inactiveColor,
    required this.dimOutsideRangeColor,
    required this.barCount,
  });

  final List<double> samples;
  final double progress;
  final double rangeStart;
  final double rangeEnd;
  final Color activeColor;
  final Color inactiveColor;
  final Color? dimOutsideRangeColor;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    final barW = size.width / (barCount * 1.6);
    final gap = barW * 0.6;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final x = i * (barW + gap);
      final t = x / size.width; // posição relativa [0..1] na faixa toda
      final sampleIdx = (t * samples.length).floor().clamp(
            0,
            samples.length - 1,
          );
      final amplitude = samples[sampleIdx].clamp(0.05, 1.0);
      final h = (amplitude * centerY).clamp(2.0, centerY);

      final insideRange = t >= rangeStart && t <= rangeEnd;
      final isActive = insideRange && t <= progress;

      Color color;
      if (!insideRange && dimOutsideRangeColor != null) {
        color = dimOutsideRangeColor!;
      } else if (isActive) {
        color = activeColor;
      } else {
        color = inactiveColor;
      }

      final paint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barW;
      canvas.drawLine(
        Offset(x + barW / 2, centerY - h),
        Offset(x + barW / 2, centerY + h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.rangeStart != rangeStart ||
      oldDelegate.rangeEnd != rangeEnd ||
      oldDelegate.samples != samples;
}
