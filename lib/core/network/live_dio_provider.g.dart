// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveDio)
final liveDioProvider = LiveDioProvider._();

final class LiveDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  LiveDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return liveDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$liveDioHash() => r'6ff518c8217a1275ea429e91e378d4ba5493c1e4';
