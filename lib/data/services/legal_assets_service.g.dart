// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_assets_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Carrega arquivos markdown de `assets/legal/`.
///
/// Convenção: `creator_terms_<lang>.md` com fallback para `en`.

@ProviderFor(legalAssetsService)
final legalAssetsServiceProvider = LegalAssetsServiceProvider._();

/// Carrega arquivos markdown de `assets/legal/`.
///
/// Convenção: `creator_terms_<lang>.md` com fallback para `en`.

final class LegalAssetsServiceProvider
    extends
        $FunctionalProvider<
          LegalAssetsService,
          LegalAssetsService,
          LegalAssetsService
        >
    with $Provider<LegalAssetsService> {
  /// Carrega arquivos markdown de `assets/legal/`.
  ///
  /// Convenção: `creator_terms_<lang>.md` com fallback para `en`.
  LegalAssetsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legalAssetsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legalAssetsServiceHash();

  @$internal
  @override
  $ProviderElement<LegalAssetsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LegalAssetsService create(Ref ref) {
    return legalAssetsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LegalAssetsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LegalAssetsService>(value),
    );
  }
}

String _$legalAssetsServiceHash() =>
    r'903480021e96e26544e13b8d15a60dbd141cdd0a';
