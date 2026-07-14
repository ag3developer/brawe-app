import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'waveform_repository.g.dart';

/// Busca e cacheia (em memória, por processo) o array de amplitudes
/// [0.0..1.0] gerado pelo backend (`sound_service.py::generate_waveform`)
/// e hospedado como JSON em `Sound.waveformUrl`.
///
/// IMPORTANTE: usa um [Dio] SEM interceptors de autenticação — a URL é um
/// objeto público em DO Spaces/R2 (não é a API da Brawe), então não deve
/// receber o header `Authorization: Bearer ...` do cliente autenticado.
///
/// Falhas (URL nula, 404, JSON malformado, timeout) devolvem `null` —
/// quem consome decide o fallback visual (barras genéricas), nunca lança.
@riverpod
WaveformRepository waveformRepository(Ref ref) => WaveformRepository();

class WaveformRepository {
  static final Dio _publicDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  final Map<String, List<double>> _cache = {};

  /// Retorna as amostras de waveform para [url], ou `null` em caso de
  /// falha/ausência. Resultado é cacheado em memória por URL — chamadas
  /// repetidas (ex.: reabrir o mesmo bottom sheet) não refazem a request.
  Future<List<double>?> getWaveform(String? url) async {
    if (url == null || url.isEmpty) return null;
    final cached = _cache[url];
    if (cached != null) return cached;

    try {
      final response = await _publicDio.get<dynamic>(url);
      final data = response.data;
      final List<dynamic> raw;
      if (data is List) {
        raw = data;
      } else if (data is Map && data['samples'] is List) {
        raw = data['samples'] as List;
      } else {
        return null;
      }
      final samples = raw
          .map((e) => (e as num).toDouble().clamp(0.0, 1.0))
          .toList(growable: false);
      if (samples.isEmpty) return null;
      _cache[url] = samples;
      return samples;
    } catch (_) {
      return null;
    }
  }
}
