// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_gift_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SendGiftViewModel)
final sendGiftViewModelProvider = SendGiftViewModelProvider._();

final class SendGiftViewModelProvider
    extends $NotifierProvider<SendGiftViewModel, AsyncValue<void>> {
  SendGiftViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendGiftViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendGiftViewModelHash();

  @$internal
  @override
  SendGiftViewModel create() => SendGiftViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$sendGiftViewModelHash() => r'dc642324d0c54120d9b06e1dfe2451d2734a6311';

abstract class _$SendGiftViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
