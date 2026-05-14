import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
import '../model/post_dto.dart';

part 'post_service.g.dart';

@riverpod
PostService postService(Ref ref) {
  return PostService(ref.watch(liveDioProvider));
}

class PostService {
  final Dio _dio;

  PostService(this._dio);

  Future<PostFeedResponseDto> getFeed({int limit = 20, int offset = 0}) async {
    final response = await _dio.get(
      '/posts/feed',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostFeedResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> likePost(String postId) async {
    await _dio.post('/posts/$postId/like');
  }

  Future<void> unlikePost(String postId) async {
    await _dio.delete('/posts/$postId/like');
  }

  Future<void> incrementView(String postId) async {
    await _dio.post('/posts/$postId/view');
  }

  Future<PostFeedResponseDto> getUserPosts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/posts/user/$userId',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostFeedResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createPost({
    required String content,
    String? imageUrl,
    String? audience, // mantido por compat — ignorado pelo backend atual
  }) async {
    await _dio.post('/posts', data: {
      'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
    });
  }

  /// Upload de imagem para post.
  /// Backend: POST /posts/upload-image (multipart, field "file")
  /// Retorno: { success, url, mime_type, size }
  Future<String> uploadMedia(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/posts/upload-image', data: formData);
    final data = response.data as Map<String, dynamic>;
    return data['url']?.toString() ?? '';
  }
}
