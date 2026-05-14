// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quests_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questsRepository)
final questsRepositoryProvider = QuestsRepositoryProvider._();

final class QuestsRepositoryProvider
    extends
        $FunctionalProvider<
          QuestsRepository,
          QuestsRepository,
          QuestsRepository
        >
    with $Provider<QuestsRepository> {
  QuestsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questsRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuestsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuestsRepository create(Ref ref) {
    return questsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestsRepository>(value),
    );
  }
}

String _$questsRepositoryHash() => r'971775333e657a6ed54306d0fd5cfea395a18549';
