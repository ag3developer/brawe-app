// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cityLocationService)
final cityLocationServiceProvider = CityLocationServiceProvider._();

final class CityLocationServiceProvider
    extends
        $FunctionalProvider<
          CityLocationService,
          CityLocationService,
          CityLocationService
        >
    with $Provider<CityLocationService> {
  CityLocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cityLocationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cityLocationServiceHash();

  @$internal
  @override
  $ProviderElement<CityLocationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CityLocationService create(Ref ref) {
    return cityLocationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CityLocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CityLocationService>(value),
    );
  }
}

String _$cityLocationServiceHash() =>
    r'd8004206d449fa7b2d2c114c5051fd99f6a619c2';
