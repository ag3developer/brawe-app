// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waveform_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Busca e cacheia (em memória, por processo) o array de amplitudes
/// [0.0..1.0] gerado pelo backend (`sound_service.py::generate_waveform`)
/// e hospedado como JSON em `Sound.waveformUrl`.
///
/// IMPORTANTE: usa um [Dio] SEM interceptors de autenticação — a URL é um
/// objeto público em DO Spaces/R2 (não é a API da Brawe), então não deve
/// receber o header `Authorization: Bearer ...` do cliente autenticado.
///
/// Falhas (URL nula, 404, JSON malformado, timeout) devolvem `null` —
/// quem consome decide o fallback visual (barras genéricas), nunca lança.

@ProviderFor(waveformRepository)
final waveformRepositoryProvider = WaveformRepositoryProvider._();

/// Busca e cacheia (em memória, por processo) o array de amplitudes
/// [0.0..1.0] gerado pelo backend (`sound_service.py::generate_waveform`)
/// e hospedado como JSON em `Sound.waveformUrl`.
///
/// IMPORTANTE: usa um [Dio] SEM interceptors de autenticação — a URL é um
/// objeto público em DO Spaces/R2 (não é a API da Brawe), então não deve
/// receber o header `Authorization: Bearer ...` do cliente autenticado.
///
/// Falhas (URL nula, 404, JSON malformado, timeout) devolvem `null` —
/// quem consome decide o fallback visual (barras genéricas), nunca lança.

final class WaveformRepositoryProvider
    extends
        $FunctionalProvider<
          WaveformRepository,
          WaveformRepository,
          WaveformRepository
        >
    with $Provider<WaveformRepository> {
  /// Busca e cacheia (em memória, por processo) o array de amplitudes
  /// [0.0..1.0] gerado pelo backend (`sound_service.py::generate_waveform`)
  /// e hospedado como JSON em `Sound.waveformUrl`.
  ///
  /// IMPORTANTE: usa um [Dio] SEM interceptors de autenticação — a URL é um
  /// objeto público em DO Spaces/R2 (não é a API da Brawe), então não deve
  /// receber o header `Authorization: Bearer ...` do cliente autenticado.
  ///
  /// Falhas (URL nula, 404, JSON malformado, timeout) devolvem `null` —
  /// quem consome decide o fallback visual (barras genéricas), nunca lança.
  WaveformRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'waveformRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$waveformRepositoryHash();

  @$internal
  @override
  $ProviderElement<WaveformRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WaveformRepository create(Ref ref) {
    return waveformRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WaveformRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WaveformRepository>(value),
    );
  }
}

String _$waveformRepositoryHash() =>
    r'818669494bab90cc907791ba13771ac22c6a1fd9';
