// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_gifters_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TopGiftersViewModel)
final topGiftersViewModelProvider = TopGiftersViewModelFamily._();

final class TopGiftersViewModelProvider
    extends $AsyncNotifierProvider<TopGiftersViewModel, List<Gifter>> {
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
    r'faa053852fa4a7a15cb19e7b5ee69e55c3482cca';

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

  TopGiftersViewModelProvider call(String roomId) =>
      TopGiftersViewModelProvider._(argument: roomId, from: this);

  @override
  String toString() => r'topGiftersViewModelProvider';
}

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
