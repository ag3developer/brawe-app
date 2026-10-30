/// Cabeçalhos para buscar mídia de CDNs que protegem por "referer".
///
/// A biblioteca de vídeos do Bunny Stream só entrega para pedidos que dizem
/// vir do site da Brawe (bloqueia referer vazio). Navegadores mandam isso
/// sozinhos; o app não, e sem o cabeçalho o vídeo HLS e a miniatura voltam
/// 403. Para qualquer outro host não envia nada.
const String _braweReferer = 'https://brawe.app/';

Map<String, String> mediaHeadersFor(String? url) {
  if (url == null || url.isEmpty) return const {};
  final host = Uri.tryParse(url)?.host ?? '';
  if (host.endsWith('.b-cdn.net')) {
    return const {'Referer': _braweReferer};
  }
  return const {};
}
