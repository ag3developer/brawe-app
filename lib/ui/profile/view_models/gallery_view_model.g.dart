// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GalleryViewModel)
final galleryViewModelProvider = GalleryViewModelFamily._();

final class GalleryViewModelProvider
    extends $AsyncNotifierProvider<GalleryViewModel, GalleryData> {
  GalleryViewModelProvider._({
    required GalleryViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'galleryViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$galleryViewModelHash();

  @override
  String toString() {
    return r'galleryViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GalleryViewModel create() => GalleryViewModel();

  @override
  bool operator ==(Object other) {
    return other is GalleryViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$galleryViewModelHash() => r'3235d64aec68af5d5af159f2ec32d3977f1c0bb6';

final class GalleryViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          GalleryViewModel,
          AsyncValue<GalleryData>,
          GalleryData,
          FutureOr<GalleryData>,
          String
        > {
  GalleryViewModelFamily._()
    : super(
        retry: null,
        name: r'galleryViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GalleryViewModelProvider call(String userId) =>
      GalleryViewModelProvider._(argument: userId, from: this);

  @override
  String toString() => r'galleryViewModelProvider';
}

abstract class _$GalleryViewModel extends $AsyncNotifier<GalleryData> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<GalleryData> build(String userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GalleryData>, GalleryData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GalleryData>, GalleryData>,
              AsyncValue<GalleryData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
