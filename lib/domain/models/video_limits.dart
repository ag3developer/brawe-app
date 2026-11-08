/// Limites do vídeo de post. A fonte é o servidor (GET /posts/video-limits);
/// [fallback] só vale com servidor antigo ou sem rede na hora de abrir.
class VideoLimits {
  const VideoLimits({
    required this.maxBytes,
    required this.maxSeconds,
    required this.directUpload,
  });

  /// Padrão antigo (envio pela API: teto de 100 MB e 3 min no app).
  static const fallback = VideoLimits(
    maxBytes: 100 * 1024 * 1024,
    maxSeconds: 180,
    directUpload: false,
  );

  final int maxBytes;
  final int maxSeconds;
  final bool directUpload;

  Duration get maxDuration => Duration(seconds: maxSeconds);

  /// "500 MB" / "1,5 GB" (vírgula decimal; o app é pt-BR primeiro).
  static String formatBytes(int bytes) {
    const mb = 1024 * 1024;
    if (bytes >= 1024 * mb) {
      final v = bytes / (1024 * mb);
      return '${_trim(v)} GB';
    }
    return '${(bytes / mb).round()} MB';
  }

  static String _trim(double v) {
    final t = v.toStringAsFixed(1);
    return (t.endsWith('.0') ? t.substring(0, t.length - 2) : t).replaceAll(
      '.',
      ',',
    );
  }

  /// "10 min" / "45 s".
  static String formatDuration(int seconds) {
    if (seconds >= 60) {
      final m = (seconds / 60).round();
      return '$m min';
    }
    return '$seconds s';
  }

  String get maxBytesLabel => formatBytes(maxBytes);
  String get maxDurationLabel => formatDuration(maxSeconds);
}
