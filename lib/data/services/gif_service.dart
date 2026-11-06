import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/gif_item.dart';

/// 503 `gifs_unavailable`: sem chave no servidor ou GIPHY fora do ar.
class GifsUnavailableException implements Exception {
  const GifsUnavailableException();
}

/// Qualquer outra falha (rede, 429, ...).
class GifsException implements Exception {
  const GifsException();
}

/// Proxy de GIFs do Connect: `/gifs/trending` e `/gifs/search`.
/// A chave do GIPHY fica só no servidor.
class GifService {
  GifService(this._dio);
  final Dio _dio;

  Future<GifPage> trending({int limit = 24, int offset = 0, String? lang}) =>
      _get('/gifs/trending', {'limit': limit, 'offset': offset, 'lang': ?lang});

  Future<GifPage> search(String q, {int limit = 24, int offset = 0, String? lang}) =>
      _get('/gifs/search', {'q': q, 'limit': limit, 'offset': offset, 'lang': ?lang});

  Future<GifPage> _get(String path, Map<String, dynamic> query) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return GifPage.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) throw const GifsUnavailableException();
      throw const GifsException();
    } catch (_) {
      throw const GifsException();
    }
  }
}

final gifServiceProvider = Provider<GifService>((ref) => GifService(ref.watch(liveDioProvider)));
