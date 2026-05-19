import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../data/repositories/post_repository.dart';
import '../../../../../data/repositories/social_repository.dart';
import '../../../../../domain/models/feed_item.dart';
import '../../../../feed/widgets/comments_sheet.dart';
import '../../action_rail.dart';

/// Wrapper que conecta o [ActionRail] aos repositórios reais.
///
/// - Like/Unlike: chama `postRepository.toggleLike` para posts (Video/Photo).
///   Para itens de live, o backend não tem endpoint de like ainda, então
///   aplicamos apenas feedback local (optimistic) sem persistir.
/// - Comment: abre [CommentsSheet] (somente para posts, lives não têm threads).
/// - Share: usa share_plus com link `https://brawe.app/connect/p/{id}`.
/// - Follow: chama `socialRepository.followUser/unfollowUser`.
/// - Profile: navega para `/profile/{authorId}`.
/// - Gift: gated por `kEnableMonetization` (v1.0 desativado → snackbar).
class FeedActionsRail extends ConsumerStatefulWidget {
  const FeedActionsRail({super.key, required this.item});
  final FeedItem item;

  @override
  ConsumerState<FeedActionsRail> createState() => _FeedActionsRailState();
}

class _FeedActionsRailState extends ConsumerState<FeedActionsRail> {
  late bool _liked;
  late int _likesCount;
  late bool _following;
  bool _busyFollow = false;

  bool get _isPost =>
      widget.item is VideoFeedItem || widget.item is PhotoPostFeedItem;

  @override
  void initState() {
    super.initState();
    _liked = widget.item.userLiked;
    _likesCount = widget.item.likesCount;
    _following = widget.item.userFollowingAuthor;
  }

  Future<void> _onLike() async {
    // Optimistic toggle.
    final prevLiked = _liked;
    final prevCount = _likesCount;
    setState(() {
      _liked = !_liked;
      _likesCount += _liked ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });

    if (!_isPost) return; // sem endpoint para lives

    try {
      await ref.read(postRepositoryProvider).toggleLike(widget.item.id, prevLiked);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _liked = prevLiked;
        _likesCount = prevCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível curtir. Tente novamente.')),
      );
    }
  }

  void _onComment() {
    if (!_isPost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use o chat ao vivo para conversar.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: widget.item.id),
    );
  }

  Future<void> _onShare() async {
    final base = _isPost ? 'p' : 'live';
    final url = 'https://brawe.app/connect/$base/${widget.item.id}';
    final caption = widget.item.caption.isNotEmpty
        ? widget.item.caption
        : 'Confira no Brawe Connect';
    try {
      // ignore: deprecated_member_use
      await Share.share('$caption\n\n$url');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar.')),
      );
    }
  }

  Future<void> _onFollow() async {
    if (_busyFollow) return;
    final authorId = widget.item.author.id;
    if (authorId.isEmpty) return;
    final prev = _following;
    setState(() {
      _following = !_following;
      _busyFollow = true;
    });
    try {
      final repo = ref.read(socialRepositoryProvider);
      if (prev) {
        await repo.unfollowUser(authorId);
      } else {
        await repo.followUser(authorId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _following = prev);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o follow.')),
      );
    } finally {
      if (mounted) setState(() => _busyFollow = false);
    }
  }

  void _onGift() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎁 Em breve!')),
    );
  }

  void _onProfile() {
    final authorId = widget.item.author.id;
    if (authorId.isEmpty) return;
    context.push('/profile/$authorId');
  }

  @override
  Widget build(BuildContext context) {
    // Reflete estado otimista no item passado para ActionRail.
    final liveItem = _itemWithLocalState();
    return ActionRail(
      item: liveItem,
      onLike: _onLike,
      onComment: _onComment,
      onShare: _onShare,
      onFollow: _onFollow,
      onGift: _onGift,
      onProfile: _onProfile,
    );
  }

  /// Devolve um item com `userLiked` + `likesCount` + `userFollowingAuthor`
  /// refletindo o estado local (optimistic). Como [FeedItem] é sealed e
  /// imutável, criamos uma cópia da variante concreta.
  FeedItem _itemWithLocalState() {
    final i = widget.item;
    return switch (i) {
      VideoFeedItem() => VideoFeedItem(
          id: i.id,
          author: i.author,
          likesCount: _likesCount,
          commentsCount: i.commentsCount,
          sharesCount: i.sharesCount,
          userLiked: _liked,
          userFollowingAuthor: _following,
          caption: i.caption,
          viewsCount: i.viewsCount,
          videoUrl: i.videoUrl,
          thumbnailUrl: i.thumbnailUrl,
          duration: i.duration,
        ),
      PhotoPostFeedItem() => PhotoPostFeedItem(
          id: i.id,
          author: i.author,
          likesCount: _likesCount,
          commentsCount: i.commentsCount,
          sharesCount: i.sharesCount,
          userLiked: _liked,
          userFollowingAuthor: _following,
          caption: i.caption,
          viewsCount: i.viewsCount,
          imageUrl: i.imageUrl,
          createdAt: i.createdAt,
        ),
      LiveChatItem() => LiveChatItem(
          id: i.id,
          author: i.author,
          likesCount: _likesCount,
          commentsCount: i.commentsCount,
          sharesCount: i.sharesCount,
          userLiked: _liked,
          userFollowingAuthor: _following,
          caption: i.caption,
          viewsCount: i.viewsCount,
          thumbnailUrl: i.thumbnailUrl,
          viewerCount: i.viewerCount,
          topic: i.topic,
          slug: i.slug,
          streamUrl: i.streamUrl,
        ),
      LiveCommerceItem() => LiveCommerceItem(
          id: i.id,
          author: i.author,
          likesCount: _likesCount,
          commentsCount: i.commentsCount,
          sharesCount: i.sharesCount,
          userLiked: _liked,
          userFollowingAuthor: _following,
          caption: i.caption,
          viewsCount: i.viewsCount,
          thumbnailUrl: i.thumbnailUrl,
          viewerCount: i.viewerCount,
          products: i.products,
          featuredProductId: i.featuredProductId,
          slug: i.slug,
          streamUrl: i.streamUrl,
        ),
      LiveBattleItem() => i, // Battle não muda
    };
  }
}
