import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;

import 'gift_effect_cache.dart';

/// Motor de áudio curto (SFX). Implementações: [SoloudSfxBackend] (baixa
/// latência) e [JustAudioSfxBackend] (caminho antigo, usado de reserva).
abstract class SfxBackend {
  /// Prepara o motor; `false` se não for possível neste aparelho.
  Future<bool> init();

  /// Carrega [file] e devolve um identificador opaco (ou `null` se falhar).
  Future<Object?> load(File file);

  Future<void> play(Object source);
}

class SoloudSfxBackend implements SfxBackend {
  @override
  Future<bool> init() async {
    try {
      await SoLoud.instance.init();
      return SoLoud.instance.isInitialized;
    } catch (e) {
      debugPrint('[SFX] flutter_soloud indisponível: $e');
      return false;
    }
  }

  @override
  Future<Object?> load(File file) async {
    try {
      return await SoLoud.instance.loadFile(file.path);
    } catch (e) {
      debugPrint('[SFX] soloud não carregou ${file.path}: $e');
      return null;
    }
  }

  @override
  Future<void> play(Object source) async {
    await SoLoud.instance.play(source as AudioSource);
  }
}

/// Caminho anterior: um `AudioPlayer` por som, descartado ao terminar.
class JustAudioSfxBackend implements SfxBackend {
  @override
  Future<bool> init() async => true;

  @override
  Future<Object?> load(File file) async => file;

  @override
  Future<void> play(Object source) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath((source as File).path);
      await player.play();
    } finally {
      await player.dispose();
    }
  }
}

/// SFX dos degraus de combo e dos presentes.
///
/// Tenta o flutter_soloud; se a inicialização falhar usa o just_audio. Os
/// sons são baixados pelo [GiftEffectCache] e carregados sob demanda
/// ([preload] aquece antes do primeiro uso). Nunca lança exceção.
class SfxPlayer {
  SfxPlayer({
    SfxBackend? primary,
    SfxBackend? fallback,
    Future<File?> Function(String url)? resolveFile,
  }) : _primary = primary ?? SoloudSfxBackend(),
       _fallback = fallback ?? JustAudioSfxBackend(),
       _resolveFile = resolveFile ?? _defaultResolve;

  static final SfxPlayer instance = SfxPlayer();

  final SfxBackend _primary;
  final SfxBackend _fallback;
  final Future<File?> Function(String url) _resolveFile;

  SfxBackend? _active;
  Future<SfxBackend>? _initializing;
  final Map<String, Future<Object?>> _loaded = {};

  /// Backend em uso (após a 1ª chamada); útil em testes e diagnóstico.
  SfxBackend? get activeBackend => _active;

  static Future<File?> _defaultResolve(String url) async {
    final cached = GiftEffectCache.instance.cachedFile(url);
    if (cached != null) return cached;
    return GiftEffectCache.instance
        .fetch(url)
        .timeout(const Duration(seconds: 3), onTimeout: () => null);
  }

  Future<SfxBackend> _backend() {
    return _initializing ??= () async {
      var ok = false;
      try {
        ok = await _primary.init();
      } catch (_) {}
      _active = ok ? _primary : _fallback;
      if (!ok) await _fallback.init();
      return _active!;
    }();
  }

  /// Baixa e carrega [url] para tocar sem espera depois.
  Future<void> preload(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final backend = await _backend();
      await _source(backend, url);
    } catch (e) {
      debugPrint('[SFX] preload falhou: $e');
    }
  }

  Future<Object?> _source(SfxBackend backend, String url) {
    return _loaded[url] ??= () async {
      final file = await _resolveFile(url);
      if (file == null) return null;
      return backend.load(file);
    }().then((v) {
      // Não guarda falha: tenta de novo na próxima vez.
      if (v == null) _loaded.remove(url);
      return v;
    });
  }

  /// Toca [url] (silêncio se o arquivo não estiver disponível).
  Future<void> play(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final backend = await _backend();
      final src = await _source(backend, url);
      if (src == null) return;
      try {
        await backend.play(src);
      } catch (e) {
        // Falha em tempo de execução no soloud: troca para o caminho antigo.
        if (backend == _primary) {
          debugPrint('[SFX] soloud falhou ao tocar, usando just_audio: $e');
          _active = _fallback;
          _initializing = Future.value(_fallback);
          _loaded.clear();
          final file = await _resolveFile(url);
          if (file != null) await _fallback.play(file);
        }
      }
    } catch (e) {
      debugPrint('[SFX] falhou: $e');
    }
  }
}
