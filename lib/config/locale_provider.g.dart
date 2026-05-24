// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controla o idioma do app. Persiste em SharedPreferences (instant boot)
/// e expõe o Locale atual para o MaterialApp.
///
/// Idiomas suportados: pt_BR, es, en

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Controla o idioma do app. Persiste em SharedPreferences (instant boot)
/// e expõe o Locale atual para o MaterialApp.
///
/// Idiomas suportados: pt_BR, es, en
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, Locale> {
  /// Controla o idioma do app. Persiste em SharedPreferences (instant boot)
  /// e expõe o Locale atual para o MaterialApp.
  ///
  /// Idiomas suportados: pt_BR, es, en
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$localeControllerHash() => r'3b244a7461e650d88da962bc191cafa029369581';

/// Controla o idioma do app. Persiste em SharedPreferences (instant boot)
/// e expõe o Locale atual para o MaterialApp.
///
/// Idiomas suportados: pt_BR, es, en

abstract class _$LocaleController extends $Notifier<Locale> {
  Locale build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Locale, Locale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale, Locale>,
              Locale,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
