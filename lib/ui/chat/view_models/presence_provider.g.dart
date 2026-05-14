// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cache central de presença de usuários. Faz polling em batch a cada 30s
/// para todos os userIds atualmente "observados".

@ProviderFor(PresenceCache)
final presenceCacheProvider = PresenceCacheProvider._();

/// Cache central de presença de usuários. Faz polling em batch a cada 30s
/// para todos os userIds atualmente "observados".
final class PresenceCacheProvider
    extends $NotifierProvider<PresenceCache, Map<String, UserPresence>> {
  /// Cache central de presença de usuários. Faz polling em batch a cada 30s
  /// para todos os userIds atualmente "observados".
  PresenceCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presenceCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presenceCacheHash();

  @$internal
  @override
  PresenceCache create() => PresenceCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, UserPresence> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, UserPresence>>(value),
    );
  }
}

String _$presenceCacheHash() => r'86e661f691a5890c4b6e24211e95d66e4bf3714e';

/// Cache central de presença de usuários. Faz polling em batch a cada 30s
/// para todos os userIds atualmente "observados".

abstract class _$PresenceCache extends $Notifier<Map<String, UserPresence>> {
  Map<String, UserPresence> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, UserPresence>, Map<String, UserPresence>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, UserPresence>, Map<String, UserPresence>>,
              Map<String, UserPresence>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
