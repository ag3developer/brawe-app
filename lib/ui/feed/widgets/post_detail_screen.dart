import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import 'feed_screen.dart' show PostCard;
import 'comments_sheet.dart';

/// Tela que abre uma única publicação a partir de um deep link
/// (`https://brawe.app/post/:id` ou `https://brawe.app/connect/p/:id`).
///
/// Quando o usuário compartilha um post com um amigo (quest diária ou
/// botão de compartilhar do feed), o destinatário cai aqui ao tocar
/// no link — em vez de abrir a Home e perder a publicação.
///
/// Quando aberto via deep link de comentário/resposta/menção
/// (`/post/:id/comments`), [openComments] faz a folha de comentários abrir
/// automaticamente assim que o post termina de carregar.
class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.postId,
    this.openComments = false,
    this.highlightCommentId,
  });

  final String postId;

  /// Abre a [CommentsSheet] automaticamente após carregar o post.
  final bool openComments;

  /// Comentário a destacar dentro da folha de comentários (deep link).
  final String? highlightCommentId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late Future<Post> _future;
  bool _commentsOpened = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Post> _load() {
    return ref.read(postRepositoryProvider).getById(widget.postId);
  }

  void _retry() {
    setState(() => _future = _load());
  }

  /// Abre a folha de comentários uma única vez (após o post carregar).
  void _maybeOpenComments(Post post) {
    if (!widget.openComments || _commentsOpened) return;
    _commentsOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        useRootNavigator: true,
        useSafeArea: true,
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CommentsSheet(
          postId: post.id,
          highlightCommentId: widget.highlightCommentId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.postDetailTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: FutureBuilder<Post>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return _ErrorView(
              message: s.postDetailNotFound,
              onRetry: _retry,
              onHome: () => context.go('/home'),
            );
          }
          _maybeOpenComments(snap.data!);
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = _load());
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [PostCard(post: snap.data!)],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onHome,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: colors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onHome,
                child: Text(s.postDetailGoHome),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: onRetry, child: Text(s.walletTryAgain)),
            ],
          ),
        ],
      ),
    );
  }
}
