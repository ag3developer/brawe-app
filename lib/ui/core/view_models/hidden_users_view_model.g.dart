// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_users_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Listas de bloqueados/ocultados. O servidor já filtra os feeds; isto serve
/// para o que chega por socket e para esconder na hora, sem esperar recarga.

@ProviderFor(HiddenUsers)
final hiddenUsersProvider = HiddenUsersProvider._();

/// Listas de bloqueados/ocultados. O servidor já filtra os feeds; isto serve
/// para o que chega por socket e para esconder na hora, sem esperar recarga.
final class HiddenUsersProvider
    extends $AsyncNotifierProvider<HiddenUsers, HiddenUsersState> {
  /// Listas de bloqueados/ocultados. O servidor já filtra os feeds; isto serve
  /// para o que chega por socket e para esconder na hora, sem esperar recarga.
  HiddenUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenUsersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenUsersHash();

  @$internal
  @override
  HiddenUsers create() => HiddenUsers();
}

String _$hiddenUsersHash() => r'3b9adfc41f25bb6335bde125579af7c70c56b842';

/// Listas de bloqueados/ocultados. O servidor já filtra os feeds; isto serve
/// para o que chega por socket e para esconder na hora, sem esperar recarga.

abstract class _$HiddenUsers extends $AsyncNotifier<HiddenUsersState> {
  FutureOr<HiddenUsersState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<HiddenUsersState>, HiddenUsersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HiddenUsersState>, HiddenUsersState>,
              AsyncValue<HiddenUsersState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
