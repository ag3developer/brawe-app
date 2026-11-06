/// Modelos de GIF (GIPHY via proxy do servidor Connect).
/// Nada é re-hospedado: guardamos id + url + largura/altura.
library;

int _toInt(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

/// GIF anexado a um comentário ou mensagem: `{id, url, width, height}`.
class GifAttachment {
  const GifAttachment({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  final String id;
  final String url;
  final int width;
  final int height;

  /// null quando faltam dados (cliente tolera payload ruim em vez de quebrar).
  static GifAttachment? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final url = raw['url']?.toString() ?? '';
    final w = _toInt(raw['width']);
    final h = _toInt(raw['height']);
    if (url.isEmpty || w <= 0 || h <= 0) return null;
    return GifAttachment(id: raw['id']?.toString() ?? '', url: url, width: w, height: h);
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'width': width, 'height': height};

  double get aspectRatio => width / height;

  @override
  bool operator ==(Object other) =>
      other is GifAttachment && other.id == id && other.url == url && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(id, url, width, height);
}

/// Item da grade do seletor (preview leve + GIF completo).
class GifItem {
  const GifItem({
    required this.id,
    required this.title,
    required this.previewUrl,
    required this.url,
    required this.width,
    required this.height,
  });

  final String id;
  final String title;
  final String previewUrl;
  final String url;
  final int width;
  final int height;

  static GifItem? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final url = raw['url']?.toString() ?? '';
    final preview = raw['preview_url']?.toString() ?? '';
    final w = _toInt(raw['width']);
    final h = _toInt(raw['height']);
    if (url.isEmpty || w <= 0 || h <= 0) return null;
    return GifItem(
      id: raw['id']?.toString() ?? '',
      title: raw['title']?.toString() ?? '',
      previewUrl: preview.isEmpty ? url : preview,
      url: url,
      width: w,
      height: h,
    );
  }

  GifAttachment toAttachment() => GifAttachment(id: id, url: url, width: width, height: height);
}

/// Página de resultados; `nextOffset == null` = acabou.
class GifPage {
  const GifPage({required this.items, this.nextOffset});

  final List<GifItem> items;
  final int? nextOffset;

  factory GifPage.fromJson(Object? json) {
    if (json is! Map) return const GifPage(items: []);
    final raw = json['items'];
    final items = raw is List ? raw.map(GifItem.tryParse).whereType<GifItem>().toList() : <GifItem>[];
    final next = json['next_offset'];
    return GifPage(items: items, nextOffset: next is num ? next.toInt() : null);
  }
}
