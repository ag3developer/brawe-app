/// Utilidades de mídia compartilhadas por TODAS as telas (feed, perfil,
/// chat, post aberto). Antes cada tela tinha sua própria regra de "é vídeo"
/// (5 versões diferentes) e algumas não tiravam a `?query` do link — o vídeo
/// virava imagem quebrada ou sumia.
library;

const _videoExts = ['.mp4', '.mov', '.webm', '.m4v', '.m3u8'];

/// `true` se o link aponta para um vídeo (ignora maiúsculas e `?query`).
bool isVideoUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  var u = url.toLowerCase();
  final q = u.indexOf('?');
  if (q >= 0) u = u.substring(0, q);
  final h = u.indexOf('#');
  if (h >= 0) u = u.substring(0, h);
  return _videoExts.any(u.endsWith);
}

/// Decide se o post é vídeo: usa `media_type` do servidor quando vier,
/// senão a extensão do link.
bool isVideoMedia({String? mediaType, String? url}) {
  if (mediaType == 'video') return true;
  if (mediaType == 'image') return false;
  return isVideoUrl(url);
}

/// Proporção (largura/altura) já descoberta de cada mídia, por link.
/// Posts antigos não trazem o tamanho do servidor: na 1ª vez que a mídia
/// carrega guardamos aqui, e nas próximas o espaço já nasce certo (sem
/// "esticar e voltar" ao rolar).
class MediaAspectCache {
  MediaAspectCache._();
  static final Map<String, double> _map = {};

  static double? get(String? url) => url == null ? null : _map[_key(url)];

  static void put(String? url, double aspect) {
    if (url == null || aspect.isNaN || aspect <= 0) return;
    if (_map.length > 600) _map.remove(_map.keys.first);
    _map[_key(url)] = aspect;
  }

  static String _key(String url) {
    final q = url.indexOf('?');
    return q >= 0 ? url.substring(0, q) : url;
  }
}

/// Proporção do QUADRO no feed (padrão Instagram): vertical vira 4:5
/// (recorte suave), horizontal aparece inteiro até 1.91:1.
double feedFrameAspect(double? mediaAspect) {
  final a = mediaAspect ?? 4 / 5;
  return a.clamp(4 / 5, 1.91).toDouble();
}
