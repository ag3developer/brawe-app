// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hashtag_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Posts que contêm uma #hashtag específica (tela de resultados ao tocar
/// numa hashtag no feed/comentários).

@ProviderFor(HashtagPostsViewModel)
final hashtagPostsViewModelProvider = HashtagPostsViewModelFamily._();

/// Posts que contêm uma #hashtag específica (tela de resultados ao tocar
/// numa hashtag no feed/comentários).
final class HashtagPostsViewModelProvider
    extends $AsyncNotifierProvider<HashtagPostsViewModel, List<Post>> {
  /// Posts que contêm uma #hashtag específica (tela de resultados ao tocar
  /// numa hashtag no feed/comentários).
  HashtagPostsViewModelProvider._({
    required HashtagPostsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hashtagPostsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hashtagPostsViewModelHash();

  @override
  String toString() {
    return r'hashtagPostsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HashtagPostsViewModel create() => HashtagPostsViewModel();

  @override
  bool operator ==(Object other) {
    return other is HashtagPostsViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hashtagPostsViewModelHash() =>
    r'ae68d6e3f0b08ea0f3a6025342f72b8d34164000';

/// Posts que contêm uma #hashtag específica (tela de resultados ao tocar
/// numa hashtag no feed/comentários).

final class HashtagPostsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          HashtagPostsViewModel,
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>,
          String
        > {
  HashtagPostsViewModelFamily._()
    : super(
        retry: null,
        name: r'hashtagPostsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Posts que contêm uma #hashtag específica (tela de resultados ao tocar
  /// numa hashtag no feed/comentários).

  HashtagPostsViewModelProvider call(String tag) =>
      HashtagPostsViewModelProvider._(argument: tag, from: this);

  @override
  String toString() => r'hashtagPostsViewModelProvider';
}

/// Posts que contêm uma #hashtag específica (tela de resultados ao tocar
/// numa hashtag no feed/comentários).

abstract class _$HashtagPostsViewModel extends $AsyncNotifier<List<Post>> {
  late final _$args = ref.$arg as String;
  String get tag => _$args;

  FutureOr<List<Post>> build(String tag);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Post>>, List<Post>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Post>>, List<Post>>,
              AsyncValue<List<Post>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
