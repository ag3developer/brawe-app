import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/battle_assets.dart';
import '../services/gift_effect_cache.dart';
import '../services/sfx_player.dart';

/// Manifesto de mídia da batalha (Batalha v3, §19.2), dirigido pelo servidor.
///
/// - `GET /live/battle/assets` é baixado quando o `assets_version` do evento
///   (contagem/início/REST) difere do que está em cache;
/// - o JSON fica no disco (sobrevive a reinício do app);
/// - os arquivos referenciados (Lottie, imagens, sons) são baixados pelo
///   [GiftEffectCache] (nome = hash da URL) durante a contagem;
/// - NADA aqui bloqueia a batalha: qualquer falha deixa o estado como está e
///   a UI usa o desenho/texto padrão embutido.
final battleAssetsProvider =
    NotifierProvider<BattleAssetsNotifier, BattleManifest?>(
      BattleAssetsNotifier.new,
    );

class BattleAssetsNotifier extends Notifier<BattleManifest?> {
  static const _fileName = 'battle_assets_manifest.json';

  /// Sem versão no evento (servidor antigo): reconsulta no máximo a cada tanto.
  static const _staleAfter = Duration(minutes: 10);
  static const _retryAfter = Duration(seconds: 20);

  Future<void>? _disk;
  Future<void>? _inFlight;
  DateTime? _lastTry;
  DateTime? _lastOk;

  @override
  BattleManifest? build() {
    _disk = _loadDisk();
    return null;
  }

  Future<File> _file() async {
    final base = await getApplicationSupportDirectory();
    return File('${base.path}/$_fileName');
  }

  Future<void> _loadDisk() async {
    try {
      final f = await _file();
      if (!f.existsSync()) return;
      final m = BattleManifest.tryParse(jsonDecode(await f.readAsString()));
      if (m != null && ref.mounted && state == null) state = m;
    } catch (e) {
      debugPrint('[BATTLE-ASSETS] cache ilegível: $e');
    }
  }

  /// Garante o manifesto na versão [serverVersion] (ou o mais recente quando
  /// `null`) e baixa os arquivos. Nunca lança e nunca precisa ser aguardada.
  Future<void> ensure(int? serverVersion) {
    // Em série: uma chamada com versão nova nunca é engolida por outra em
    // andamento.
    final prev = _inFlight ?? Future<void>.value();
    late final Future<void> next;
    next = prev.then((_) => _ensure(serverVersion)).whenComplete(() {
      if (identical(_inFlight, next)) _inFlight = null;
    });
    return _inFlight = next;
  }

  Future<void> _ensure(int? serverVersion) async {
    try {
      await _disk;
      if (!ref.mounted) return;
      final cur = state;
      final now = DateTime.now();
      var needFetch = cur == null;
      if (cur != null) {
        if (serverVersion != null) {
          needFetch = serverVersion != cur.version;
        } else {
          needFetch = _lastOk == null || now.difference(_lastOk!) > _staleAfter;
        }
      }
      if (needFetch &&
          _lastTry != null &&
          now.difference(_lastTry!) < _retryAfter) {
        needFetch = false;
      }
      if (needFetch) await _fetch();
      if (!ref.mounted) return;
      await _prefetchMedia(state);
    } catch (e) {
      debugPrint('[BATTLE-ASSETS] falha: $e');
    }
  }

  Future<void> _fetch() async {
    _lastTry = DateTime.now();
    final res = await ref
        .read(liveDioProvider)
        .get<dynamic>('/live/battle/assets');
    final m = BattleManifest.tryParse(res.data);
    if (m == null || !ref.mounted) return;
    _lastOk = DateTime.now();
    state = m;
    try {
      final f = await _file();
      await f.writeAsString(jsonEncode(res.data));
    } catch (_) {}
  }

  Future<void> _prefetchMedia(BattleManifest? m) async {
    if (m == null) return;
    final urls = m.mediaUrls;
    if (urls.isEmpty) return;
    await GiftEffectCache.instance.prefetch(urls);
    final sounds = <String>{
      for (final x in m.moments.values) ?x.soundUrl,
      for (final e in m.barEffects) ?e.soundUrl,
    };
    for (final s in sounds) {
      unawaited(SfxPlayer.instance.preload(s));
    }
  }
}
