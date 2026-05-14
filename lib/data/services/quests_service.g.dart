// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quests_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questsService)
final questsServiceProvider = QuestsServiceProvider._();

final class QuestsServiceProvider
    extends $FunctionalProvider<QuestsService, QuestsService, QuestsService>
    with $Provider<QuestsService> {
  QuestsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questsServiceHash();

  @$internal
  @override
  $ProviderElement<QuestsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuestsService create(Ref ref) {
    return questsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestsService>(value),
    );
  }
}

String _$questsServiceHash() => r'34015841cf8b369e7905865c4f1e2971414e018c';
