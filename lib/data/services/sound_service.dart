import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'sound_service.g.dart';

@riverpod
SoundHttpService soundHttpService(Ref ref) =>
    SoundHttpService(ref.watch(liveDioProvider));

/// HTTP client para o módulo Brawe Sounds.
/// Base: [AppConstants.connectApiV1Url] + /sounds
class SoundHttpService {
  final Dio _dio;
  SoundHttpService(this._dio);

  // ── Artista ──────────────────────────────────────────────────────────────

  /// Cria ou atualiza o perfil de artista do usuário autenticado.
  Future<Map<String, dynamic>> registerArtist({
    required String artistName,
    String? bio,
    List<String> genres = const [],
    String? countryCode,
    String? city,
    String? spotifyUrl,
    String? appleMusicUrl,
    String? musicLink,
  }) async {
    final body = <String, dynamic>{'artist_name': artistName, 'genres': genres};
    if (bio != null && bio.trim().isNotEmpty) body['bio'] = bio.trim();
    if (countryCode != null) body['country_code'] = countryCode;
    if (city != null && city.trim().isNotEmpty) body['city'] = city.trim();
    if (spotifyUrl != null && spotifyUrl.trim().isNotEmpty) {
      body['spotify_url'] = spotifyUrl.trim();
    }
    if (appleMusicUrl != null && appleMusicUrl.trim().isNotEmpty) {
      body['apple_music_url'] = appleMusicUrl.trim();
    }
    if (musicLink != null && musicLink.trim().isNotEmpty) {
      body.addAll(musicLinkFields(musicLink.trim()));
    }

    final response = await _dio.post('/sounds/artist/register', data: body);
    return _unwrap(response.data);
  }

  /// Retorna o perfil de artista do usuário autenticado.
  Future<Map<String, dynamic>> getMyArtistProfile() async {
    final response = await _dio.get('/sounds/artist/me');
    return _unwrap(response.data);
  }

  /// Perfil público de um artista por ID.
  Future<Map<String, dynamic>> getArtistProfile(String artistId) async {
    final response = await _dio.get('/sounds/artist/$artistId');
    return _unwrap(response.data);
  }

  // ── Catálogo ─────────────────────────────────────────────────────────────

  /// Catálogo paginado de músicas aprovadas.
  Future<Map<String, dynamic>> getCatalog({
    int page = 1,
    int limit = 20,
    String? genre,
    String? mood,
    String? search,
    String? artistId,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (genre != null) params['genre'] = genre;
    if (mood != null) params['mood'] = mood;
    if (artistId != null) params['artist_id'] = artistId;
    if (search != null && search.trim().isNotEmpty) {
      params['q'] = search.trim();
    }
    final response = await _dio.get('/sounds/catalog', queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  /// Top músicas da semana (Redis-cached no backend).
  Future<List<Map<String, dynamic>>> getTrending({
    String period = 'week',
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/sounds/trending',
      queryParameters: {'period': period, 'limit': limit},
    );
    final data = response.data;
    // Resposta: { period, items: [...] }
    final items = (data is Map ? data['items'] : data) as List?;
    return (items ?? []).cast<Map<String, dynamic>>();
  }

  /// Busca por título ou nome de artista.
  Future<List<Map<String, dynamic>>> search(
    String query, {
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/sounds/search',
      queryParameters: {'q': query.trim(), 'limit': limit},
    );
    final data = response.data;
    final items =
        (data is Map ? data['items'] ?? data['results'] : data) as List?;
    return (items ?? []).cast<Map<String, dynamic>>();
  }

  /// Detalhe de uma música.
  Future<Map<String, dynamic>> getSound(String soundId) async {
    final response = await _dio.get('/sounds/$soundId');
    return _unwrap(response.data);
  }

  // ── Interações ────────────────────────────────────────────────────────────

  /// Registra play (fire-and-forget: ignora erros silenciosamente).
  Future<void> registerPlay(String soundId, {String source = 'catalog'}) async {
    try {
      await _dio.post('/sounds/$soundId/play', data: {'source': source});
    } catch (_) {}
  }

  /// Salva uma música para o usuário.
  Future<void> saveSound(String soundId) async {
    await _dio.post('/sounds/$soundId/save');
  }

  /// Remove música salva.
  Future<void> unsaveSound(String soundId) async {
    await _dio.delete('/sounds/$soundId/save');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is! Map<String, dynamic>) return {};
    final inner = raw['data'] ?? raw['artist'] ?? raw['sound'];
    if (inner is Map<String, dynamic>) return inner;
    return raw;
  }
}

/// Link único "da sua música": grava no campo da plataforma certa e limpa os
/// outros (Spotify, Apple Music, YouTube; qualquer outro vai em extra_links.music).
Map<String, dynamic> musicLinkFields(String raw) {
  final url = raw.startsWith('http') ? raw : 'https://$raw';
  final u = url.toLowerCase();
  String? field;
  if (u.contains('spotify.com')) {
    field = 'spotify_url';
  } else if (u.contains('music.apple.com')) {
    field = 'apple_music_url';
  } else if (u.contains('youtube.com') || u.contains('youtu.be')) {
    field = 'youtube_url';
  }
  return {
    'spotify_url': field == 'spotify_url' ? url : null,
    'apple_music_url': field == 'apple_music_url' ? url : null,
    'youtube_url': field == 'youtube_url' ? url : null,
    'extra_links': field == null ? {'music': url} : <String, String>{},
  };
}

/// O link de música já salvo no perfil de artista (o primeiro que existir).
String musicLinkFrom(Map<String, dynamic> data) {
  for (final k in const ['spotify_url', 'apple_music_url', 'youtube_url']) {
    final v = data[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  final extra = data['extra_links'];
  if (extra is Map && extra['music'] is String) return extra['music'] as String;
  return '';
}
