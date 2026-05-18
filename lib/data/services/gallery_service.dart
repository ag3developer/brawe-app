import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'gallery_service.g.dart';

@riverpod
GalleryService galleryService(Ref ref) {
  return GalleryService(ref.watch(liveDioProvider));
}

class GalleryService {
  final Dio _dio;
  GalleryService(this._dio);

  Future<Map<String, dynamic>> getMyGallery() async {
    final r = await _dio.get('/gallery/me');
    return Map<String, dynamic>.from(r.data['data'] ?? r.data);
  }

  Future<Map<String, dynamic>> getUserGallery(String userId) async {
    final r = await _dio.get('/gallery/$userId');
    return Map<String, dynamic>.from(r.data['data'] ?? r.data);
  }

  Future<Map<String, dynamic>> uploadPhoto(String filePath,
      {String? caption}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (caption != null && caption.isNotEmpty) 'caption': caption,
    });
    final r = await _dio.post(
      '/gallery/photo',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Map<String, dynamic>.from(r.data['data'] ?? r.data);
  }

  Future<Map<String, dynamic>> uploadVideo(String filePath,
      {String? caption}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (caption != null && caption.isNotEmpty) 'caption': caption,
    });
    final r = await _dio.post(
      '/gallery/video',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Map<String, dynamic>.from(r.data['data'] ?? r.data);
  }

  Future<void> deleteMedia(String mediaId) async {
    await _dio.delete('/gallery/$mediaId');
  }

  Future<void> updateMedia(String mediaId, {String? caption}) async {
    await _dio.put('/gallery/$mediaId', data: {
      if (caption != null) 'caption': caption,
    });
  }

  Future<void> reorder(String mediaType, List<String> mediaIds) async {
    await _dio.put('/gallery/reorder/$mediaType', data: {
      'media_ids': mediaIds,
    });
  }

  Future<void> registerView(String mediaId) async {
    await _dio.post('/gallery/$mediaId/view');
  }

  Future<Map<String, dynamic>> toggleLike(String mediaId) async {
    final r = await _dio.post('/gallery/$mediaId/like');
    return Map<String, dynamic>.from(r.data['data'] ?? r.data);
  }
}
