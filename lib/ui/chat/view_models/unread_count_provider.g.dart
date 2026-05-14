// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Total global de DMs não lidas. Faz polling a cada 60s e atualiza
/// sempre que chega uma `message_notification` via socket.

@ProviderFor(UnreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// Total global de DMs não lidas. Faz polling a cada 60s e atualiza
/// sempre que chega uma `message_notification` via socket.
final class UnreadCountProvider extends $NotifierProvider<UnreadCount, int> {
  /// Total global de DMs não lidas. Faz polling a cada 60s e atualiza
  /// sempre que chega uma `message_notification` via socket.
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  UnreadCount create() => UnreadCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadCountHash() => r'92a412d30bac4bc73a193d322c1540249cdc5e25';

/// Total global de DMs não lidas. Faz polling a cada 60s e atualiza
/// sempre que chega uma `message_notification` via socket.

abstract class _$UnreadCount extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
