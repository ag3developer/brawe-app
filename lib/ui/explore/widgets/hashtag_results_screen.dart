import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/brawe_colors.dart';
import '../../feed/widgets/feed_screen.dart' show PostCard;
import '../view_models/hashtag_view_model.dart';

/// Resultados de posts para uma #hashtag específica.
///
/// Acessada ao tocar em qualquer `#hashtag` clicável dentro de posts,
/// comentários ou mensagens (ver `BraweRichText`).
class HashtagResultsScreen extends ConsumerWidget {
  const HashtagResultsScreen({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(hashtagPostsViewModelProvider(tag));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(
          '#$tag',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: context.colors.accentPrimary,
        backgroundColor: context.colors.surface,
        onRefresh: () =>
            ref.read(hashtagPostsViewModelProvider(tag).notifier).refresh(),
        child: postsState.when(
          data: (posts) {
            if (posts.isEmpty) {
              return _EmptyHashtag(tag: tag);
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(top: 8, bottom: 110),
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(post: posts[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _EmptyHashtag(tag: tag, isError: true),
        ),
      ),
    );
  }
}

class _EmptyHashtag extends StatelessWidget {
  const _EmptyHashtag({required this.tag, this.isError = false});

  final String tag;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(
          isError ? Icons.cloud_off_rounded : Icons.tag_rounded,
          size: 56,
          color: context.colors.textSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          isError
              ? 'Não foi possível carregar os posts.'
              : 'Nenhum post encontrado para #$tag',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }
}
