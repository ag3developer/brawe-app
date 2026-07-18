// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preview_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkPreviewService)
final linkPreviewServiceProvider = LinkPreviewServiceProvider._();

final class LinkPreviewServiceProvider
    extends
        $FunctionalProvider<
          LinkPreviewService,
          LinkPreviewService,
          LinkPreviewService
        >
    with $Provider<LinkPreviewService> {
  LinkPreviewServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkPreviewServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkPreviewServiceHash();

  @$internal
  @override
  $ProviderElement<LinkPreviewService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinkPreviewService create(Ref ref) {
    return linkPreviewService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkPreviewService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkPreviewService>(value),
    );
  }
}

String _$linkPreviewServiceHash() =>
    r'40ef9c029d5260e9470f597adae7990164d3e2b7';
