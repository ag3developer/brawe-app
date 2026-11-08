// Brawe Ads — encaixe de anúncios em qualquer lista (Para você, Seguindo, feed, lives, explorar).
// Busca anúncios conforme a lista cresce (1 a cada N itens; N vem do servidor) e monta a lista mista.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/ads_repository.dart';
import '../../domain/models/ad_models.dart';

/// Item da lista mista: conteúdo normal ou anúncio.
sealed class Slot<T> {
  const Slot();
}

class ContentSlot<T> extends Slot<T> {
  const ContentSlot(this.item, this.index);
  final T item;

  /// posição do item na lista original (sem anúncios)
  final int index;
}

class AdSlot<T> extends Slot<T> {
  const AdSlot(this.ad);
  final FeedAd ad;
}

class AdSlotLoader extends ChangeNotifier {
  AdSlotLoader(this._repo, this.placement, {int defaultEvery = 7})
    : every = defaultEvery;

  final AdsRepository _repo;
  final String placement;
  final List<FeedAd> _ads = [];
  int every;
  bool _busy = false;
  bool _exhausted = false;
  int _asked = 0;

  List<FeedAd> get ads => List.unmodifiable(_ads);

  /// Garante anúncios suficientes para [itemCount] itens (no máximo 15 pedidos por tela).
  Future<void> ensure(int itemCount) async {
    final needed = itemCount ~/ every + 1;
    if (_busy || _exhausted || _ads.length >= needed || _asked >= 15) return;
    _busy = true;
    try {
      final want = (needed - _ads.length).clamp(1, 5);
      _asked += want;
      final r = await _repo.serve(
        placement,
        count: want,
        exclude: _ads.map((a) => a.adId).toList(),
      );
      if (r.every > 1) every = r.every;
      if (r.items.isEmpty) {
        _exhausted = true;
      } else {
        _ads.addAll(r.items.where((n) => !_ads.any((a) => a.token == n.token)));
        notifyListeners();
      }
    } finally {
      _busy = false;
    }
  }

  /// Recomeça (ao puxar para atualizar o feed).
  void reset() {
    _ads.clear();
    _exhausted = false;
    _asked = 0;
    notifyListeners();
  }

  /// Monta a lista mista: 1 anúncio depois de cada [every] itens. [skip] tira anúncios ocultados.
  List<Slot<T>> mix<T>(List<T> items, {bool Function(FeedAd ad)? skip}) {
    final out = <Slot<T>>[];
    var a = 0;
    for (var i = 0; i < items.length; i++) {
      out.add(ContentSlot<T>(items[i], i));
      if ((i + 1) % every == 0) {
        while (a < _ads.length && (skip?.call(_ads[a]) ?? false)) {
          a++;
        }
        if (a < _ads.length) out.add(AdSlot<T>(_ads[a++]));
      }
    }
    // Lista curta (ou fim da lista): se sobraram pelo menos 3 itens depois do último anúncio,
    // o próximo entra no fim — senão quem tem poucos vídeos nunca veria anúncio.
    if (items.length % every >= 3) {
      while (a < _ads.length && (skip?.call(_ads[a]) ?? false)) {
        a++;
      }
      if (a < _ads.length) out.add(AdSlot<T>(_ads[a]));
    }
    return out;
  }
}

/// Carregador por espaço que vive enquanto o app está aberto (feed de posts, lives, explorar).
final adLoaderProvider = Provider.family<AdSlotLoader, String>((
  ref,
  placement,
) {
  final l = AdSlotLoader(ref.read(adsRepositoryProvider), placement);
  ref.onDispose(l.dispose);
  return l;
});
