import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../domain/models/gif_item.dart';
import '../../../domain/models/post_comment.dart';

part 'comments_view_model.g.dart';

@riverpod
class CommentsViewModel extends _$CommentsViewModel {
  /// Ordenação atual: `top` (mais relevantes) ou `recent` (mais recentes).
  String _sort = 'top';
  String get sort => _sort;

  @override
  Future<List<PostComment>> build(String postId) async {
    return ref.read(commentRepositoryProvider).getComments(postId, sort: _sort);
  }

  /// Troca a ordenação e recarrega a lista. Servidor antigo ignora o
  /// parâmetro (a lista volta na ordem de sempre).
  Future<void> setSort(String sort) async {
    if (sort == _sort) return;
    _sort = sort;
    state = const AsyncLoading<List<PostComment>>();
    final next = await AsyncValue.guard(
      () =>
          ref.read(commentRepositoryProvider).getComments(postId, sort: _sort),
    );
    if (!ref.mounted) return;
    state = next;
  }

  Future<void> addComment(
    String content, {
    String? parentId,
    GifAttachment? gif,
  }) async {
    final repo = ref.read(commentRepositoryProvider);
    final newComment = await repo.addComment(
      postId,
      content,
      parentId: parentId,
      gif: gif,
    );
    final current = state.value ?? [];
    if (parentId == null) {
      state = AsyncData([newComment, ...current]);
    } else {
      state = AsyncData(
        current
            .map(
              (c) => c.id == parentId
                  ? c.copyWith(replies: [...c.replies, newComment])
                  : c,
            )
            .toList(),
      );
    }
  }

  /// Apaga um comentário (ou resposta) meu. Remove da lista na hora e
  /// devolve se deu certo (se falhar, a lista volta como estava).
  Future<bool> deleteComment(PostComment comment) async {
    final before = state.value;
    if (before == null) return false;
    state = AsyncData([
      for (final c in before)
        if (c.id != comment.id)
          c.copyWith(
            replies: [
              for (final r in c.replies)
                if (r.id != comment.id) r,
            ],
          ),
    ]);
    try {
      await ref
          .read(commentRepositoryProvider)
          .deleteComment(postId, comment.id);
      return true;
    } catch (_) {
      if (ref.mounted) state = AsyncData(before);
      return false;
    }
  }

  Future<void> toggleLike(PostComment comment) async {
    // Otimista: o coração muda na hora; se o servidor falhar, volta.
    final before = state.value;
    _applyLike(comment);
    try {
      await ref
          .read(commentRepositoryProvider)
          .toggleLike(comment.id, comment.userLiked);
    } catch (_) {
      if (before != null && ref.mounted) state = AsyncData(before);
    }
  }

  PostComment _flip(PostComment c, PostComment target) => c.copyWith(
    likesCount: target.userLiked ? c.likesCount - 1 : c.likesCount + 1,
    userLiked: !target.userLiked,
  );

  void _applyLike(PostComment comment) {
    final list = state.value;
    if (list == null) return;
    state = AsyncData([
      for (final c in list)
        if (c.id == comment.id)
          _flip(c, comment)
        else
          c.copyWith(
            replies: [
              for (final r in c.replies)
                r.id == comment.id ? _flip(r, comment) : r,
            ],
          ),
    ]);
  }
}
