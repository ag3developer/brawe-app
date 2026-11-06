// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quests_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuestsViewModel)
final questsViewModelProvider = QuestsViewModelProvider._();

final class QuestsViewModelProvider
    extends $AsyncNotifierProvider<QuestsViewModel, QuestsData> {
  QuestsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questsViewModelHash();

  @$internal
  @override
  QuestsViewModel create() => QuestsViewModel();
}

String _$questsViewModelHash() => r'c89d7ab3ff0389ab2b7b00a4a4eef6a707689fa4';

abstract class _$QuestsViewModel extends $AsyncNotifier<QuestsData> {
  FutureOr<QuestsData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<QuestsData>, QuestsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuestsData>, QuestsData>,
              AsyncValue<QuestsData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
