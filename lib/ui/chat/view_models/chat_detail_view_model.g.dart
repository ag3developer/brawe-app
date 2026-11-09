// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatDetailViewModel)
final chatDetailViewModelProvider = ChatDetailViewModelFamily._();

final class ChatDetailViewModelProvider
    extends $NotifierProvider<ChatDetailViewModel, ChatDetailState> {
  ChatDetailViewModelProvider._({
    required ChatDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatDetailViewModelHash();

  @override
  String toString() {
    return r'chatDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatDetailViewModel create() => ChatDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatDetailViewModelHash() =>
    r'475551eb1ec7dc509dff1d6f0d2ae76ec74ff32c';

final class ChatDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatDetailViewModel,
          ChatDetailState,
          ChatDetailState,
          ChatDetailState,
          String
        > {
  ChatDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'chatDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatDetailViewModelProvider call(String conversationId) =>
      ChatDetailViewModelProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'chatDetailViewModelProvider';
}

abstract class _$ChatDetailViewModel extends $Notifier<ChatDetailState> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  ChatDetailState build(String conversationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatDetailState, ChatDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatDetailState, ChatDetailState>,
              ChatDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
