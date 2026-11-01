import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../data/repositories/post_repository.dart';
import '../../../../../data/repositories/social_repository.dart';
import '../../../../../data/services/feedback_service.dart';
import '../../../../../domain/models/feed_item.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/force_dark_theme.dart';
import '../../../../feed/widgets/comments_sheet.dart';
import '../../../../feed/widgets/share_to_chat_sheet.dart';
import '../../../../feed/widgets/reactions_bar.dart';
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
  late bool _reposted;
  late int _repostsCount;
  bool _busyFollow = false;
  bool _busyRepost = false;

  bool get _isPost =>
      widget.item is VideoFeedItem || widget.item is PhotoPostFeedItem;

  @override
  void initState() {
    super.initState();
    _liked = widget.item.userLiked;
    _likesCount = widget.item.likesCount;
    _following = widget.item.userFollowingAuthor;
    _reposted = widget.item.userReposted;
    _repostsCount = widget.item.sharesCount;
  }

  /// Repostar / desfazer (toque longo no compartilhar). Otimista: marca na
  /// hora e reverte se a API falhar. Um novo toque longo desfaz o repost.
  Future<void> _toggleRepost() async {
    if (_busyRepost) return;
    _busyRepost = true;
    final was = _reposted;
    ref.read(feedbackServiceProvider).repost();
    setState(() {
      _reposted = !was;
      _repostsCount = (_repostsCount + (was ? -1 : 1)).clamp(0, 1 << 30);
    });
    try {
      await ref.read(postRepositoryProvider).toggleRepost(widget.item.id, was);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            was ? S.of(context).feedRepostUndone : S.of(context).feedReposted,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reposted = was;
        _repostsCount = (_repostsCount + (was ? 1 : -1)).clamp(0, 1 << 30);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).feedCannotShare)),
      );
    } finally {
      _busyRepost = false;
    }
  }

  Future<void> _onLike() async {
    // Feedback tátil + sonoro imediato (UX TikTok/Instagram).
    ref.read(feedbackServiceProvider).like();

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
      await ref
          .read(postRepositoryProvider)
          .toggleLike(widget.item.id, prevLiked);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _liked = prevLiked;
        _likesCount = prevCount;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedCannotLike)));
    }
  }

  void _onComment() {
    if (!_isPost) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedUseLiveChat)));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ForceDarkTheme(child: CommentsSheet(postId: widget.item.id)),
    );
  }

  Future<void> _onShare() async {
    ref.read(feedbackServiceProvider).share();
    // Posts: tela "Compartilhar" do app — enviar para pessoas (DM com
    // prévia do post), Stories e outros apps. Lives seguem no share do
    // sistema (o convite in-app de live é feito pelo streamer).
    final item = widget.item;
    if (item is VideoFeedItem || item is PhotoPostFeedItem) {
      final media = switch (item) {
        VideoFeedItem() => item.videoUrl,
        PhotoPostFeedItem() => item.imageUrl,
        _ => null,
      };
      final preview = switch (item) {
        VideoFeedItem() => item.thumbnailUrl,
        PhotoPostFeedItem() => item.imageUrl,
        _ => null,
      };
      await ShareToChatSheet.show(
        context,
        postId: item.id,
        postCaption: item.caption,
        postImageUrl: preview,
        authorName: item.author.name,
        storyMediaUrl: media,
        isReposted: _reposted,
        onRepostChanged: (reposted) {
          if (!mounted) return;
          setState(() {
            _reposted = reposted;
            _repostsCount =
                (_repostsCount + (reposted ? 1 : -1)).clamp(0, 1 << 30);
          });
        },
      );
      return;
    }
    // URL canônica para o app abrir (deep link). Posts: /post/:id, lives: /live/:id.
    // Ambas estão registradas no router e no intent-filter do AndroidManifest.
    final url = _isPost
        ? 'https://brawe.app/post/${widget.item.id}'
        : 'https://brawe.app/live/${widget.item.id}';
    final caption = widget.item.caption.isNotEmpty
        ? widget.item.caption
        : S.of(context).shareCheckBraweConnect;
    try {
      // ignore: deprecated_member_use
      await Share.share('$caption\n\n$url');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedCannotShare)));
    }
  }

  Future<void> _onFollow() async {
    if (_busyFollow) return;
    final authorId = widget.item.author.id;
    if (authorId.isEmpty) return;
    ref.read(feedbackServiceProvider).follow();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedCannotFollow)));
    } finally {
      if (mounted) setState(() => _busyFollow = false);
    }
  }

  void _onProfile() {
    final authorId = widget.item.author.id;
    if (authorId.isEmpty) return;
    context.push('/profile/$authorId');
  }

  Future<void> _onReact(String reactionType) async {
    if (!_isPost) return;
    // Optimistic: marca como liked se ainda não estava.
    if (!_liked) {
      setState(() {
        _liked = true;
        _likesCount += 1;
      });
    }
    try {
      await ref
          .read(postRepositoryProvider)
          .react(widget.item.id, reactionType);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedCannotLike)));
    }
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
      onProfile: _onProfile,
      onLikeLongPress: _isPost
          ? () async {
              ref.read(feedbackServiceProvider).reaction();
              // Mostra o reactions bar centrado horizontalmente, à direita
              // (onde está o rail).
              final size = MediaQuery.of(context).size;
              final picked = await showReactionsBar(
                context,
                globalPosition: Offset(size.width - 56, size.height * 0.55),
              );
              if (picked != null) _onReact(picked.key);
            }
          : null,
      onLikeCountTap: _isPost
          ? () => context.push('/post/${widget.item.id}/likes')
          : null,
      onShareLongPress: _isPost ? _toggleRepost : null,
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
        sharesCount: _repostsCount,
        userLiked: _liked,
        userFollowingAuthor: _following,
        caption: i.caption,
        viewsCount: i.viewsCount,
        userReposted: _reposted,
        videoUrl: i.videoUrl,
        hlsUrl: i.hlsUrl,
        thumbnailUrl: i.thumbnailUrl,
        duration: i.duration,
        sound: i.sound,
        soundVolume: i.soundVolume,
        originalAudioVolume: i.originalAudioVolume,
      ),
      PhotoPostFeedItem() => PhotoPostFeedItem(
        id: i.id,
        author: i.author,
        likesCount: _likesCount,
        commentsCount: i.commentsCount,
        sharesCount: _repostsCount,
        userLiked: _liked,
        userFollowingAuthor: _following,
        caption: i.caption,
        viewsCount: i.viewsCount,
        userReposted: _reposted,
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
