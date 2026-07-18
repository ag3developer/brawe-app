import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'link_preview_service.g.dart';

@riverpod
LinkPreviewService linkPreviewService(Ref ref) {
  return LinkPreviewService(ref.watch(liveDioProvider));
}

/// Metadados de preview (Open Graph/Twitter Card) de uma URL externa,
/// buscados via `GET /posts/unfurl?url=...` — mesmo card que aparece ao
/// colar um link no Twitter/Instagram/WhatsApp.
class LinkPreview {
  final String url;
  final String? title;
  final String? description;
  final String? image;
  final String? siteName;
  final String domain;

  const LinkPreview({
    required this.url,
    this.title,
    this.description,
    this.image,
    this.siteName,
    required this.domain,
  });

  /// Se não veio nenhum metadado útil (site indisponível, sem OG tags),
  /// não vale a pena renderizar um card vazio.
  bool get hasContent =>
      (title != null && title!.isNotEmpty) ||
      (image != null && image!.isNotEmpty);

  factory LinkPreview.fromJson(Map<String, dynamic> json) => LinkPreview(
    url: json['url'] as String,
    title: json['title'] as String?,
    description: json['description'] as String?,
    image: json['image'] as String?,
    siteName: json['site_name'] as String?,
    domain: json['domain'] as String,
  );
}

class LinkPreviewService {
  final Dio _dio;

  LinkPreviewService(this._dio);

  Future<LinkPreview?> unfurl(String url) async {
    try {
      final response = await _dio.get(
        '/posts/unfurl',
        queryParameters: {'url': url},
      );
      return LinkPreview.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      // Falha aberta: sem preview, o link ainda funciona normalmente
      // (BraweRichText já deixa ele clicável independentemente disso).
      return null;
    }
  }
}
