import 'dart:math' as math;

/// Matemática pura da linha do tempo do seletor de capa (testável sem UI).
class VideoCoverTimeline {
  const VideoCoverTimeline({required this.durationMs});

  final int durationMs;

  static const int minTiles = 4;
  static const int maxTiles = 14;

  /// Quantidade de miniaturas para preencher [width] com tiles de
  /// [tileWidth], limitada para não gerar dezenas de frames.
  static int tileCountFor(double width, double tileWidth) {
    if (width <= 0 || tileWidth <= 0) return minTiles;
    return (width / tileWidth).ceil().clamp(minTiles, maxTiles);
  }

  /// Instantes (ms) das [count] miniaturas, uniformemente distribuídas pela
  /// duração: cada uma amostra o CENTRO da sua faixa, então cobre vídeos
  /// curtos e longos sem repetir o primeiro quadro (preto) nem o último.
  List<int> thumbTimes(int count) {
    if (count <= 0 || durationMs <= 0) return const [];
    final last = math.max(0, durationMs - 1);
    return [
      for (var i = 0; i < count; i++)
        ((durationMs * (i + 0.5) / count).round()).clamp(0, last),
    ];
  }

  /// Fração 0..1 do eixo → instante em ms (sempre dentro do vídeo).
  int timeForFraction(double fraction) {
    final last = math.max(0, durationMs - 1);
    return (durationMs * fraction.clamp(0.0, 1.0)).round().clamp(0, last);
  }

  /// Posição horizontal [dx] numa faixa de [width] → fração 0..1.
  static double fractionForDx(double dx, double width) {
    if (width <= 0) return 0;
    return (dx / width).clamp(0.0, 1.0);
  }

  /// Índice da miniatura mais próxima de [fraction].
  static int nearestTile(double fraction, int count) {
    if (count <= 0) return 0;
    return (fraction.clamp(0.0, 1.0) * count).floor().clamp(0, count - 1);
  }

  /// "mm:ss".
  static String format(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
