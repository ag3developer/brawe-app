// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatListViewModel)
final chatListViewModelProvider = ChatListViewModelProvider._();

final class ChatListViewModelProvider
    extends $NotifierProvider<ChatListViewModel, ChatListState> {
  ChatListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatListViewModelHash();

  @$internal
  @override
  ChatListViewModel create() => ChatListViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatListState>(value),
    );
  }
}

String _$chatListViewModelHash() => r'796b33dbae9dd755d833b194d83919c2ee2ab020';

abstract class _$ChatListViewModel extends $Notifier<ChatListState> {
  ChatListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatListState, ChatListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatListState, ChatListState>,
              ChatListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
