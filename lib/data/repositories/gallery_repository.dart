import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/gallery_media.dart';
import '../services/gallery_service.dart';

part 'gallery_repository.g.dart';

@riverpod
GalleryRepository galleryRepository(Ref ref) {
  return GalleryRepository(ref.watch(galleryServiceProvider));
}

class GalleryRepository {
  final GalleryService _service;
  GalleryRepository(this._service);

  Future<GalleryData> getMyGallery() async {
    try {
      return GalleryData.fromJson(await _service.getMyGallery());
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<GalleryData> getUserGallery(String userId) async {
    try {
      return GalleryData.fromJson(await _service.getUserGallery(userId));
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<GalleryMedia> uploadPhoto(String filePath, {String? caption}) async {
    try {
      return GalleryMedia.fromJson(
          await _service.uploadPhoto(filePath, caption: caption));
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<GalleryMedia> uploadVideo(String filePath, {String? caption}) async {
    try {
      return GalleryMedia.fromJson(
          await _service.uploadVideo(filePath, caption: caption));
    } on DioException catch (e) {
      throw _map(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> deleteMedia(String mediaId) async {
    try {
      await _service.deleteMedia(mediaId);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> toggleLike(String mediaId) async {
    try {
      await _service.toggleLike(mediaId);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> registerView(String mediaId) async {
    try {
      await _service.registerView(mediaId);
    } catch (_) {
      // view tracking não-crítico
    }
  }

  Failure _map(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401 || code == 403) return const Failure.unauthorized();
    if (code != null && code >= 500) return const Failure.server();
    return const Failure.network();
  }
}
