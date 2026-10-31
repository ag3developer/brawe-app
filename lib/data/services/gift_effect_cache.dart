import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/media_headers.dart';

/// Guarda no aparelho os arquivos de efeito dos presentes (vídeo VAP .mp4,
/// Lottie .json e som), baixados do CDN.
///
/// O efeito só toca se o arquivo JÁ estiver aqui: baixar na hora em que o
/// presente chega atrasaria a animação (pior ainda no 4G). Por isso o
/// overlay chama [prefetch] com o catálogo ao entrar na live, e um presente
/// cujo arquivo ainda não chegou usa o efeito padrão (imagem + brilho).
///
/// Nome do arquivo = hash da URL: trocar a animação no painel gera URL nova
/// e o app baixa de novo sozinho.
class GiftEffectCache {
  GiftEffectCache._();
  static final GiftEffectCache instance = GiftEffectCache._();

  String? _dirPath;
  final Map<String, Future<File?>> _inFlight = {};

  Future<String> _dir() async {
    final cached = _dirPath;
    if (cached != null) return cached;
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/gift_effects');
    await dir.create(recursive: true);
    return _dirPath = dir.path;
  }

  /// FNV-1a 64 bits — estável entre execuções (String.hashCode não é).
  static String _hash(String s) {
    var h = 0xcbf29ce484222325;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return h.toUnsigned(64).toRadixString(16);
  }

  static String _ext(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot < 0 || path.length - dot > 6) return '';
    return path.substring(dot);
  }

  File _fileFor(String dir, String url) =>
      File('$dir/${_hash(url)}${_ext(url)}');

  /// Arquivo já baixado, ou null. Síncrono — usado na hora de exibir.
  File? cachedFile(String? url) {
    final dir = _dirPath;
    if (dir == null || url == null || url.isEmpty) return null;
    final f = _fileFor(dir, url);
    return f.existsSync() && f.lengthSync() > 0 ? f : null;
  }

  /// Baixa (uma vez só, mesmo com chamadas simultâneas) e devolve o arquivo.
  Future<File?> fetch(String url) {
    return _inFlight[url] ??= _download(
      url,
    ).whenComplete(() => _inFlight.remove(url));
  }

  Future<File?> _download(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;
    final dir = await _dir();
    final file = _fileFor(dir, url);
    if (file.existsSync() && file.lengthSync() > 0) return file;
    final part = File('${file.path}.part');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final req = await client.getUrl(uri);
      mediaHeadersFor(url).forEach(req.headers.set);
      final res = await req.close();
      if (res.statusCode != HttpStatus.ok) {
        await res.drain<void>();
        return null;
      }
      await res.pipe(part.openWrite());
      await part.rename(file.path);
      return file;
    } catch (e) {
      debugPrint('[GIFT-FX] falha ao baixar $url: $e');
      if (part.existsSync()) part.deleteSync();
      return null;
    } finally {
      client.close();
    }
  }

  /// Baixa em sequência (sem disputar banda com o vídeo da live).
  Future<void> prefetch(Iterable<String?> urls) async {
    await _dir();
    for (final url in urls.whereType<String>().toSet()) {
      if (url.isEmpty || cachedFile(url) != null) continue;
      await fetch(url);
    }
  }
}
