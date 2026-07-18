// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preview_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Busca (e cacheia em memória, por URL) o preview de um link para exibir
/// no `LinkPreviewCard`. Riverpod já cacheia o resultado por `url` — o
/// mesmo link repetido no feed não dispara múltiplos fetches.

@ProviderFor(linkPreview)
final linkPreviewProvider = LinkPreviewFamily._();

/// Busca (e cacheia em memória, por URL) o preview de um link para exibir
/// no `LinkPreviewCard`. Riverpod já cacheia o resultado por `url` — o
/// mesmo link repetido no feed não dispara múltiplos fetches.

final class LinkPreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<LinkPreview?>,
          LinkPreview?,
          FutureOr<LinkPreview?>
        >
    with $FutureModifier<LinkPreview?>, $FutureProvider<LinkPreview?> {
  /// Busca (e cacheia em memória, por URL) o preview de um link para exibir
  /// no `LinkPreviewCard`. Riverpod já cacheia o resultado por `url` — o
  /// mesmo link repetido no feed não dispara múltiplos fetches.
  LinkPreviewProvider._({
    required LinkPreviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'linkPreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$linkPreviewHash();

  @override
  String toString() {
    return r'linkPreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LinkPreview?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LinkPreview?> create(Ref ref) {
    final argument = this.argument as String;
    return linkPreview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkPreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkPreviewHash() => r'f641e33b13afa8397966e8be94fef92f2451ce87';

/// Busca (e cacheia em memória, por URL) o preview de um link para exibir
/// no `LinkPreviewCard`. Riverpod já cacheia o resultado por `url` — o
/// mesmo link repetido no feed não dispara múltiplos fetches.

final class LinkPreviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LinkPreview?>, String> {
  LinkPreviewFamily._()
    : super(
        retry: null,
        name: r'linkPreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Busca (e cacheia em memória, por URL) o preview de um link para exibir
  /// no `LinkPreviewCard`. Riverpod já cacheia o resultado por `url` — o
  /// mesmo link repetido no feed não dispara múltiplos fetches.

  LinkPreviewProvider call(String url) =>
      LinkPreviewProvider._(argument: url, from: this);

  @override
  String toString() => r'linkPreviewProvider';
}
