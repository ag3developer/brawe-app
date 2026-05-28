// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_gifters_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 🏆 Top‑gifters do MVP (pódio 1‑2‑3 no header da live).
///
/// Em tempo real: ao receber um novo `gift_received` via Socket.IO, aplicamos
/// um *patch otimista* (soma direto no ranking local sem ida ao backend) e
/// agendamos um refetch de fundo a cada 8s para reconciliar com o servidor
/// (ranking real considera `is_processed` + agregação por `sender_id`).

@ProviderFor(TopGiftersViewModel)
final topGiftersViewModelProvider = TopGiftersViewModelFamily._();

/// 🏆 Top‑gifters do MVP (pódio 1‑2‑3 no header da live).
///
/// Em tempo real: ao receber um novo `gift_received` via Socket.IO, aplicamos
/// um *patch otimista* (soma direto no ranking local sem ida ao backend) e
/// agendamos um refetch de fundo a cada 8s para reconciliar com o servidor
/// (ranking real considera `is_processed` + agregação por `sender_id`).
final class TopGiftersViewModelProvider
    extends $AsyncNotifierProvider<TopGiftersViewModel, List<Gifter>> {
  /// 🏆 Top‑gifters do MVP (pódio 1‑2‑3 no header da live).
  ///
  /// Em tempo real: ao receber um novo `gift_received` via Socket.IO, aplicamos
  /// um *patch otimista* (soma direto no ranking local sem ida ao backend) e
  /// agendamos um refetch de fundo a cada 8s para reconciliar com o servidor
  /// (ranking real considera `is_processed` + agregação por `sender_id`).
  TopGiftersViewModelProvider._({
    required TopGiftersViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'topGiftersViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topGiftersViewModelHash();

  @override
  String toString() {
    return r'topGiftersViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TopGiftersViewModel create() => TopGiftersViewModel();

  @override
  bool operator ==(Object other) {
    return other is TopGiftersViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topGiftersViewModelHash() =>
    r'1ea82f74291a9785820ffa7e109fa34bec5063ad';

/// 🏆 Top‑gifters do MVP (pódio 1‑2‑3 no header da live).
///
/// Em tempo real: ao receber um novo `gift_received` via Socket.IO, aplicamos
/// um *patch otimista* (soma direto no ranking local sem ida ao backend) e
/// agendamos um refetch de fundo a cada 8s para reconciliar com o servidor
/// (ranking real considera `is_processed` + agregação por `sender_id`).

final class TopGiftersViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          TopGiftersViewModel,
          AsyncValue<List<Gifter>>,
          List<Gifter>,
          FutureOr<List<Gifter>>,
          String
        > {
  TopGiftersViewModelFamily._()
    : super(
        retry: null,
        name: r'topGiftersViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 🏆 Top‑gifters do MVP (pódio 1‑2‑3 no header da live).
  ///
  /// Em tempo real: ao receber um novo `gift_received` via Socket.IO, aplicamos
  /// um *patch otimista* (soma direto no ranking local sem ida ao backend) e
  /// agendamos um refetch de fundo a cada 8s para reconciliar com o servidor
  /// (ranking real considera `is_processed` + agregação por `sender_id`).

  TopGiftersViewModelProvider call(String roomId) =>
      TopGiftersViewModelProvider._(argument: roomId, from: this);

  @override
  String toString() => r'topGiftersViewModelProvider';
}

/// 🏆 Top‑gifters do MVP (pódio 1‑2‑3 no header da live).
///
/// Em tempo real: ao receber um novo `gift_received` via Socket.IO, aplicamos
/// um *patch otimista* (soma direto no ranking local sem ida ao backend) e
/// agendamos um refetch de fundo a cada 8s para reconciliar com o servidor
/// (ranking real considera `is_processed` + agregação por `sender_id`).

abstract class _$TopGiftersViewModel extends $AsyncNotifier<List<Gifter>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  FutureOr<List<Gifter>> build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Gifter>>, List<Gifter>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Gifter>>, List<Gifter>>,
              AsyncValue<List<Gifter>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
