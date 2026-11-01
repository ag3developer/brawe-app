import '../../../../../core/remote_config/remote_flags.dart';
import '../../../../../domain/models/combo_tier.dart';

/// Fila pura dos degraus de combo em mídia (Lottie/VAP).
///
/// Prioridade menor que a dos presentes (quem consome só tira da fila sem
/// presente em cena), descarta itens com mais de [maxAge] (6 s por contrato)
/// e mantém no máximo [maxLength]. O mais novo de um mesmo combo substitui o
/// anterior ainda na fila (degrau maior vale mais).
class ComboTierQueue {
  ComboTierQueue({
    Duration? maxAge,
    this.maxLength = 3,
    DateTime Function()? clock,
  }) : maxAge =
           maxAge ?? Duration(seconds: RemoteFlags.current.comboTierStaleS),
       _clock = clock ?? DateTime.now;

  final Duration maxAge;
  final int maxLength;
  final DateTime Function() _clock;
  final List<QueuedTier> _items = [];

  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;

  void add(ComboTierEvent e) {
    _items.removeWhere((i) => i.event.comboKey == e.comboKey && i.event.at < e.at);
    _items.add(QueuedTier(e, _clock()));
    while (_items.length > maxLength) {
      _items.removeAt(0);
    }
  }

  /// Próximo item fresco, ou `null` (vazia, ou [giftPlaying]: o presente
  /// tem prioridade e o item espera — até envelhecer).
  QueuedTier? next({bool giftPlaying = false}) {
    dropStale();
    if (giftPlaying || _items.isEmpty) return null;
    return _items.removeAt(0);
  }

  void dropStale() {
    final now = _clock();
    _items.removeWhere((i) => now.difference(i.at) > maxAge);
  }

  bool isStale(QueuedTier q) => _clock().difference(q.at) > maxAge;

  void clear() => _items.clear();
}

class QueuedTier {
  QueuedTier(this.event, this.at);
  final ComboTierEvent event;
  final DateTime at;
}
