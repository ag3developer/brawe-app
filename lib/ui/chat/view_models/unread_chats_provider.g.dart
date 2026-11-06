// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_chats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Conversas com mensagens não lidas (fonte do badge da aba Chat).
///
/// Verdade do servidor (`GET /messages/unread-count` → `conversation_ids`, sem
/// silenciadas) carregada no start/login/resume e a cada 60s; entre cargas, o
/// socket (`message_notification`) adiciona e a leitura remove.

@ProviderFor(UnreadChats)
final unreadChatsProvider = UnreadChatsProvider._();

/// Conversas com mensagens não lidas (fonte do badge da aba Chat).
///
/// Verdade do servidor (`GET /messages/unread-count` → `conversation_ids`, sem
/// silenciadas) carregada no start/login/resume e a cada 60s; entre cargas, o
/// socket (`message_notification`) adiciona e a leitura remove.
final class UnreadChatsProvider
    extends $NotifierProvider<UnreadChats, Set<String>> {
  /// Conversas com mensagens não lidas (fonte do badge da aba Chat).
  ///
  /// Verdade do servidor (`GET /messages/unread-count` → `conversation_ids`, sem
  /// silenciadas) carregada no start/login/resume e a cada 60s; entre cargas, o
  /// socket (`message_notification`) adiciona e a leitura remove.
  UnreadChatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadChatsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadChatsHash();

  @$internal
  @override
  UnreadChats create() => UnreadChats();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$unreadChatsHash() => r'a8f9f313f08c596441838ca08d721cf95cedd361';

/// Conversas com mensagens não lidas (fonte do badge da aba Chat).
///
/// Verdade do servidor (`GET /messages/unread-count` → `conversation_ids`, sem
/// silenciadas) carregada no start/login/resume e a cada 60s; entre cargas, o
/// socket (`message_notification`) adiciona e a leitura remove.

abstract class _$UnreadChats extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
