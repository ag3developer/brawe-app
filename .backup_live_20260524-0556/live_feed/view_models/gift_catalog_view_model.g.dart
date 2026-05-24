// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_catalog_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GiftCatalogViewModel)
final giftCatalogViewModelProvider = GiftCatalogViewModelProvider._();

final class GiftCatalogViewModelProvider
    extends $AsyncNotifierProvider<GiftCatalogViewModel, List<GiftTier>> {
  GiftCatalogViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftCatalogViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftCatalogViewModelHash();

  @$internal
  @override
  GiftCatalogViewModel create() => GiftCatalogViewModel();
}

String _$giftCatalogViewModelHash() =>
    r'cc9ecfae0ee0b5a79bf6afc759e8098dcb0c9c81';

abstract class _$GiftCatalogViewModel extends $AsyncNotifier<List<GiftTier>> {
  FutureOr<List<GiftTier>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<GiftTier>>, List<GiftTier>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GiftTier>>, List<GiftTier>>,
              AsyncValue<List<GiftTier>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
