import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/story_active_status.dart';
import '../repositories/stories_repository.dart';

/// Agregador de batch para `POST /stories/active-status`.
///
/// Em vez de cada avatar fazer 1 request, os widgets pedem o status
/// de um `userId` via [storyActiveStatusProvider] e este coordenador
/// agrupa todos os pedidos pendentes em uma janela curta (debounce)
/// e dispara UMA chamada HTTP só.
///
/// Características:
/// - Janela de batch: ~80ms (ajustável).
/// - TTL de cache: 60s. Depois disso, novos pedidos disparam refetch.
/// - Falha silenciosa: em erro, o status fica `empty` (sem anel).
/// - Dedup automático: se o status já está em cache válido, é retornado
///   imediatamente sem entrar no buffer.
class _StoryActiveStatusBatcher {
  _StoryActiveStatusBatcher(this._ref);

  final Ref _ref;

  static const Duration _batchWindow = Duration(milliseconds: 80);
  static const Duration _cacheTtl = Duration(seconds: 60);
  static const int _maxBatch = 180; // backend aceita até 200

  /// Cache `userId → (status, fetchedAt)`.
  final Map<String, _CacheEntry> _cache = {};

  /// Conjuntos de IDs aguardando envio na próxima janela.
  final Set<String> _pending = {};

  /// Listeners (um por `userId` solicitado) que serão notificados ao
  /// completar o batch — usado pelo provider família para reconstruir
  /// somente quem se importa.
  final Map<String, List<Completer<StoryActiveStatus>>> _waiters = {};

  Timer? _timer;

  /// Versão monotonicamente crescente — incrementada a cada flush.
  /// O provider família observa essa versão para reconstruir quando
  /// o batcher tem novos resultados.
  int get version => _version;
  int _version = 0;

  /// Retorna o status atual em cache (ou `null` se ainda não buscado /
  /// cache expirado). NÃO dispara fetch.
  StoryActiveStatus? peek(String userId) {
    final entry = _cache[userId];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt) > _cacheTtl) return null;
    return entry.status;
  }

  /// Agenda fetch (se necessário) e devolve o status quando disponível.
  /// Se já houver cache válido, completa imediatamente.
  Future<StoryActiveStatus> request(String userId) {
    final cached = peek(userId);
    if (cached != null) return Future.value(cached);

    final completer = Completer<StoryActiveStatus>();
    _waiters.putIfAbsent(userId, () => []).add(completer);
    _pending.add(userId);

    // Se o buffer encheu, dispara imediatamente.
    if (_pending.length >= _maxBatch) {
      _flush();
    } else {
      _timer ??= Timer(_batchWindow, _flush);
    }
    return completer.future;
  }

  /// Invalida o cache (ex.: após o usuário ver um story).
  void invalidate(String userId) {
    _cache.remove(userId);
  }

  void invalidateAll() {
    _cache.clear();
  }

  Future<void> _flush() async {
    _timer?.cancel();
    _timer = null;
    if (_pending.isEmpty) return;

    final batch = _pending.toList(growable: false);
    _pending.clear();

    final repo = _ref.read(storiesRepositoryProvider);
    final result = await repo.getActiveStatusBatch(batch);

    final now = DateTime.now();
    for (final id in batch) {
      final status = result[id] ?? StoryActiveStatus.empty;
      _cache[id] = _CacheEntry(status, now);
      final ws = _waiters.remove(id);
      if (ws != null) {
        for (final c in ws) {
          if (!c.isCompleted) c.complete(status);
        }
      }
    }
    _version++;
  }
}

class _CacheEntry {
  _CacheEntry(this.status, this.fetchedAt);
  final StoryActiveStatus status;
  final DateTime fetchedAt;
}

/// Coordenador singleton — mantido vivo enquanto o app rodar.
final storyActiveStatusBatcherProvider =
    Provider<_StoryActiveStatusBatcher>((ref) {
  return _StoryActiveStatusBatcher(ref);
});

/// Status de stories ativos para um único `userId`.
///
/// Uso típico em um `ConsumerWidget`:
/// ```dart
/// final status = ref.watch(storyActiveStatusProvider(userId)).valueOrNull
///     ?? StoryActiveStatus.empty;
/// ```
///
/// Dispara o pedido de forma **agrupada** com outros avatares na mesma
/// janela (~80ms). Resultado é cacheado por 60s.
final storyActiveStatusProvider = FutureProvider.autoDispose
    .family<StoryActiveStatus, String>((ref, userId) async {
  if (userId.isEmpty) return StoryActiveStatus.empty;
  final batcher = ref.watch(storyActiveStatusBatcherProvider);
  // Cache hit instantâneo
  final cached = batcher.peek(userId);
  if (cached != null) return cached;
  return batcher.request(userId);
});

/// Helper para invalidar o status de um usuário (ex.: depois que o
/// usuário atual abriu o viewer e marcou stories como vistos).
void invalidateStoryActiveStatus(WidgetRef ref, String userId) {
  ref.read(storyActiveStatusBatcherProvider).invalidate(userId);
  ref.invalidate(storyActiveStatusProvider(userId));
}
