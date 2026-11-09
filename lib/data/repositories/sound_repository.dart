import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/sound.dart';
import '../services/sound_service.dart';

part 'sound_repository.g.dart';

@riverpod
SoundRepository soundRepository(Ref ref) =>
    SoundRepository(ref.watch(soundHttpServiceProvider));

class SoundRepository {
  final SoundHttpService _service;
  SoundRepository(this._service);

  // ── Artista ──────────────────────────────────────────────────────────────

  /// Cria ou atualiza o perfil de artista. Retorna o perfil atualizado.
  Future<SoundArtist> registerArtist({
    required String artistName,
    String? bio,
    List<String> genres = const [],
    String? countryCode,
    String? city,
    String? spotifyUrl,
    String? appleMusicUrl,
    String? musicLink,
  }) async {
    try {
      final data = await _service.registerArtist(
        artistName: artistName,
        bio: bio,
        genres: genres,
        countryCode: countryCode,
        city: city,
        spotifyUrl: spotifyUrl,
        appleMusicUrl: appleMusicUrl,
        musicLink: musicLink,
      );
      return SoundArtist.fromJson(data);
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Retorna o perfil de artista do usuário autenticado.
  /// Lança [Failure.network] se o usuário não for artista (404).
  Future<SoundArtist?> getMyArtistProfile() async {
    try {
      final data = await _service.getMyArtistProfile();
      return SoundArtist.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _map(e);
    } catch (_) {
      return null;
    }
  }

  /// Perfil público de um artista por ID.
  Future<SoundArtist?> getArtistProfile(String artistId) async {
    try {
      final data = await _service.getArtistProfile(artistId);
      return SoundArtist.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _map(e);
    } catch (_) {
      return null;
    }
  }

  // ── Catálogo ─────────────────────────────────────────────────────────────

  Future<SoundCatalog> getCatalog({
    int page = 1,
    int limit = 20,
    String? genre,
    String? mood,
    String? search,
    String? artistId,
  }) async {
    try {
      final data = await _service.getCatalog(
        page: page,
        limit: limit,
        genre: genre,
        mood: mood,
        search: search,
        artistId: artistId,
      );
      return SoundCatalog.fromJson(data);
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<List<Sound>> getTrending({
    String period = 'week',
    int limit = 20,
  }) async {
    try {
      final list = await _service.getTrending(period: period, limit: limit);
      return list.map((e) => Sound.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<List<Sound>> search(String query, {int limit = 20}) async {
    try {
      final list = await _service.search(query, limit: limit);
      return list.map((e) => Sound.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<Sound?> getSound(String soundId) async {
    try {
      final data = await _service.getSound(soundId);
      return Sound.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _map(e);
    } catch (_) {
      return null;
    }
  }

  // ── Interações ────────────────────────────────────────────────────────────

  Future<void> registerPlay(String soundId, {String source = 'catalog'}) =>
      _service.registerPlay(soundId, source: source);

  Future<void> saveSound(String soundId) async {
    try {
      await _service.saveSound(soundId);
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> unsaveSound(String soundId) async {
    try {
      await _service.unsaveSound(soundId);
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Failure _map(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401 || code == 403) return const Failure.unauthorized();
    if (code != null && code >= 500) return const Failure.server();
    return const Failure.network();
  }
}
