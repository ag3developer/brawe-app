import '../../../../../core/remote_config/remote_flags.dart';
import '../../../../../domain/models/live_viewer_event.dart';

/// Fila pura (sem widgets) dos efeitos de entrada de viewer.
///
/// Regras: um por vez (quem consome), nunca sobre um presente em cena,
/// descarta entradas antigas (> [maxAge]), ignora a própria entrada e
/// eventos sem efeito. O #1 do ranking passa na frente.
class EntranceEffectQueue {
  EntranceEffectQueue({
    Duration? maxAge,
    this.maxLength = 4,
    DateTime Function()? clock,
  }) : maxAge =
           maxAge ?? Duration(seconds: RemoteFlags.current.entranceStaleS),
       _clock = clock ?? DateTime.now;

  final Duration maxAge;
  final int maxLength;
  final DateTime Function() _clock;
  final List<QueuedEntrance> _items = [];

  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;

  /// Enfileira [e]; devolve `false` se a regra descartou o evento.
  bool add(LiveViewerEvent e, {Set<String?> ignoreUserIds = const {}}) {
    if (!e.joined || e.entry == null) return false;
    if (e.userId.isEmpty || ignoreUserIds.contains(e.userId)) return false;
    if (_items.any((i) => i.event.userId == e.userId)) return false;
    final item = QueuedEntrance(e, _clock());
    if (e.rankingPosition == 1) {
      _items.insert(0, item);
    } else {
      _items.add(item);
    }
    while (_items.length > maxLength) {
      _items.removeLast();
    }
    return true;
  }

  /// Próximo evento ainda fresco, ou `null` (fila vazia ou
  /// [giftPlaying]: um presente em cena tem prioridade — o evento fica).
  QueuedEntrance? next({bool giftPlaying = false}) {
    dropStale();
    if (giftPlaying || _items.isEmpty) return null;
    return _items.removeAt(0);
  }

  /// Remove o que passou de [maxAge] na fila.
  void dropStale() {
    final now = _clock();
    _items.removeWhere((i) => now.difference(i.at) > maxAge);
  }

  /// Já está velho (usado após esperar o download)?
  bool isStale(QueuedEntrance q) => _clock().difference(q.at) > maxAge;

  void clear() => _items.clear();
}

/// Evento na fila com o instante em que chegou.
class QueuedEntrance {
  QueuedEntrance(this.event, this.at);
  final LiveViewerEvent event;
  final DateTime at;
}
