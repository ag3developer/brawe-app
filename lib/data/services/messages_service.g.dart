// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(messagesService)
final messagesServiceProvider = MessagesServiceProvider._();

final class MessagesServiceProvider
    extends
        $FunctionalProvider<MessagesService, MessagesService, MessagesService>
    with $Provider<MessagesService> {
  MessagesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messagesServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messagesServiceHash();

  @$internal
  @override
  $ProviderElement<MessagesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MessagesService create(Ref ref) {
    return messagesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessagesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessagesService>(value),
    );
  }
}

String _$messagesServiceHash() => r'eae142b225413c7246d14c06b533b528133789b6';
