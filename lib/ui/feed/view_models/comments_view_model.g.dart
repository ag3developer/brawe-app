// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentsViewModel)
final commentsViewModelProvider = CommentsViewModelFamily._();

final class CommentsViewModelProvider
    extends $AsyncNotifierProvider<CommentsViewModel, List<PostComment>> {
  CommentsViewModelProvider._({
    required CommentsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentsViewModelHash();

  @override
  String toString() {
    return r'commentsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentsViewModel create() => CommentsViewModel();

  @override
  bool operator ==(Object other) {
    return other is CommentsViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsViewModelHash() => r'cf618cd831bebe45befb800c9e3bbeb7b0634348';

final class CommentsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CommentsViewModel,
          AsyncValue<List<PostComment>>,
          List<PostComment>,
          FutureOr<List<PostComment>>,
          String
        > {
  CommentsViewModelFamily._()
    : super(
        retry: null,
        name: r'commentsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentsViewModelProvider call(String postId) =>
      CommentsViewModelProvider._(argument: postId, from: this);

  @override
  String toString() => r'commentsViewModelProvider';
}

abstract class _$CommentsViewModel extends $AsyncNotifier<List<PostComment>> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  FutureOr<List<PostComment>> build(String postId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PostComment>>, List<PostComment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PostComment>>, List<PostComment>>,
              AsyncValue<List<PostComment>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
