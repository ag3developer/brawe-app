// ignore_for_file: unused_element_parameter
import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../core/themes/brawe_colors.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../../core/text/link_preview_card.dart';
import '../../core/widgets/badge_count.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../../core/widgets/brawe_logo.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/sound_preview.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/feedback_service.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../chat/view_models/unread_count_provider.dart';
import '../../notifications/view_models/notifications_view_model.dart';
import '../../shared/widgets/sound_preview_chip.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../view_models/feed_view_model.dart';
import '../view_models/stories_view_model.dart';
import 'comments_sheet.dart';
import 'create_post_sheet.dart';
import 'reactions_bar.dart';
import 'story_composer_screen.dart';
import 'share_to_chat_sheet.dart';
import 'stories_rail.dart';
import 'story_ring_avatar.dart';
import 'suggested_users_rail.dart';

/// ─── Design Tokens ────────────────────────────────────────────────────────
/// Paleta dedicada ao redesign 2026: dark mais profundo, accents premium,
/// gradientes consistentes com o web.
// ignore_for_file: unused_field
class _FeedTokens {
  static const Color bg = Color(0xFF07070C);
  static const Color surface = Color(0xFF101019);
  static const Color surfaceHi = Color(0xFF181826);
  static const Color outline = Color(0x1AFFFFFF); // white 10%
  static const Color outlineSoft = Color(0x0DFFFFFF); // white 5%

  static const Color textHi = Color(0xFFF5F5FA);
  static const Color textMd = Color(0xFFB4B4C7);
  static const Color textLo = Color(0xFF7A7A92);

  static const Color likeRed = Color(0xFFFF3B7E);
  static const Color saveGold = Color(0xFFFFC857);
  static const Color repostGreen = Color(0xFF22D39A);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFFF59E0B)],
  );

  static const LinearGradient verifiedRing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
  );
}

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      final off = _scrollController.offset.clamp(0.0, 80.0);
      if ((off - _scrollOffset).abs() > 1) {
        setState(() => _scrollOffset = off);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(storiesViewModelProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openCreatePost() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blur = (_scrollOffset / 80) * 24;
    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Aurora background — gradient orbs leves
          const _AuroraBackdrop(),

          // Conteúdo
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _GlassTopBar(
                  blur: blur,
                  onSearch: () => context.push('/explore'),
                  onMessages: () => context.push('/chat'),
                  onNotifications: () => context.push('/notifications'),
                ),
                _PillTabBar(controller: _tabController),
                const SizedBox(height: 4),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _FeedTab(
                        tabType: FeedTabType.forYou,
                        scrollController: _scrollController,
                      ),
                      _FeedTab(
                        tabType: FeedTabType.following,
                        scrollController: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _GradientFab(onTap: _openCreatePost),
    );
  }
}

/// ─── Aurora Backdrop ──────────────────────────────────────────────────────
class _AuroraBackdrop extends StatelessWidget {
  const _AuroraBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _Orb(
              color: const Color(0xFFA855F7).withValues(alpha: 0.22),
              size: 320,
            ),
          ),
          Positioned(
            top: 60,
            right: -100,
            child: _Orb(
              color: const Color(0xFFEC4899).withValues(alpha: 0.18),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -150,
            left: 40,
            child: _Orb(
              color: const Color(0xFF3BB8FF).withValues(alpha: 0.12),
              size: 360,
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// ─── Top Bar (glass + blur on scroll) ─────────────────────────────────────
class _GlassTopBar extends ConsumerWidget {
  const _GlassTopBar({
    required this.blur,
    required this.onSearch,
    required this.onMessages,
    required this.onNotifications,
  });
  final double blur;
  final VoidCallback onSearch;
  final VoidCallback onMessages;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Contadores reativos (reúsa os providers globais — sem contadores novos).
    final notifications =
        ref.watch(notificationsUnreadCountProvider).asData?.value ?? 0;
    final messages = ref.watch(unreadCountProvider);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
          decoration: BoxDecoration(
            color: context.colors.background.withValues(
              alpha: blur > 4 ? 0.55 : 0.0,
            ),
            border: Border(
              bottom: BorderSide(
                color: context.colors.border.withValues(
                  alpha: blur > 4 ? 1 : 0,
                ),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              const BraweLogo(iconSize: 44),
              const Spacer(),
              _IconChip(icon: LucideIcons.search, onTap: onSearch),
              const SizedBox(width: 6),
              _IconChip(
                icon: LucideIcons.send,
                onTap: onMessages,
                count: messages,
              ),
              const SizedBox(width: 6),
              _IconChip(
                icon: LucideIcons.bell,
                onTap: onNotifications,
                count: notifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap, this.count = 0});
  final IconData icon;
  final VoidCallback onTap;

  /// Quantidade de itens não lidos. `0` esconde o badge; `> 0` mostra a bolha
  /// numérica (até "9+"). Substitui o antigo `badge` booleano hardcoded.
  final int count;

  @override
  Widget build(BuildContext context) {
    final showBadge = BadgeCount.isVisible(count);
    final label = BadgeCount.label(count);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: context.colors.textPrimary, size: 20),
              if (showBadge)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: _FeedTokens.brandGradient,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.colors.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── Pill Tabs ────────────────────────────────────────────────────────────
class _PillTabBar extends StatelessWidget {
  const _PillTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: TabBar(
          controller: controller,
          onTap: (_) => HapticFeedback.selectionClick(),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: _FeedTokens.brandGradient,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: context.colors.textPrimary,
          unselectedLabelColor: context.colors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
          tabs: [
            Tab(text: S.of(context).feedTabForYou),
            Tab(text: S.of(context).feedTabFollowing),
          ],
        ),
      ),
    );
  }
}

/// ─── Gradient FAB ─────────────────────────────────────────────────────────
class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _FeedTokens.brandGradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

enum FeedTabType { forYou, following }

class _FeedTab extends ConsumerWidget {
  const _FeedTab({required this.tabType, this.scrollController});
  final FeedTabType tabType;
  final ScrollController? scrollController;

  bool get _isFollowing => tabType == FeedTabType.following;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = _isFollowing
        ? ref.watch(followingFeedViewModelProvider)
        : ref.watch(feedViewModelProvider);

    void onRefresh() => _isFollowing
        ? ref.read(followingFeedViewModelProvider.notifier).refresh()
        : ref.read(feedViewModelProvider.notifier).refresh();

    return RefreshIndicator(
      color: const Color(0xFFA855F7),
      backgroundColor: context.colors.surface,
      onRefresh: () async => onRefresh(),
      child: feedState.when(
        data: (posts) => CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 6)),
            const SliverToBoxAdapter(child: StoriesRail()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _isFollowing
                    ? const _EmptyFollowingFeed()
                    : const _EmptyFeed(),
              )
            else ...[
              // "Para Você": sugestões intercaladas no feed
              if (!_isFollowing && posts.length < 3)
                const SliverToBoxAdapter(child: SuggestedUsersRail()),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (!_isFollowing && index == 2) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PostCard(post: posts[index]),
                        const SuggestedUsersRail(),
                      ],
                    );
                  }
                  return PostCard(post: posts[index]);
                }, childCount: posts.length),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
        loading: () => ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 80),
          itemCount: 4,
          itemBuilder: (_, __) => const _PostSkeleton(),
        ),
        error: (_, __) => _ErrorState(onRetry: onRefresh),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: _FeedTokens.brandGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: context.colors.textPrimary,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              S.of(context).feedEmptyQuietTitle,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).feedEmptyQuietSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFollowingFeed extends StatelessWidget {
  const _EmptyFollowingFeed();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: context.colors.textSecondary,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              S.of(context).feedEmptyFollowingTitle,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).feedEmptyFollowingSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            // Mostra sugestões de quem seguir
            const SuggestedUsersRail(),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.wifi_off_rounded,
          color: context.colors.textTertiary,
          size: 52,
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            S.of(context).feedOfflineTitle,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            S.of(context).feedOfflineSubtitle,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: _FeedTokens.brandGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: context.colors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                S.of(context).feedRetry,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ─── Skeleton Loader ──────────────────────────────────────────────────────
class _PostSkeleton extends StatefulWidget {
  const _PostSkeleton();
  @override
  State<_PostSkeleton> createState() => _PostSkeletonState();
}

class _PostSkeletonState extends State<_PostSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _block(double w, double h, {double r = 8}) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(1 + t * 2, 0),
              colors: const [
                Color(0xFF181826),
                Color(0xFF242438),
                Color(0xFF181826),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _block(44, 44, r: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(120, 12),
                  const SizedBox(height: 6),
                  _block(70, 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _block(double.infinity, 14),
          const SizedBox(height: 6),
          _block(220, 14),
          const SizedBox(height: 12),
          _block(double.infinity, 220, r: 16),
        ],
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────────

class PostCard extends ConsumerStatefulWidget {
  const PostCard({super.key, required this.post});
  final Post post;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 25),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartController);

    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showHeart = false);
        _heartController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _doubleTapLike() {
    if (!widget.post.userLiked) {
      ref.read(feedViewModelProvider.notifier).toggleLike(widget.post.id);
    }
    setState(() => _showHeart = true);
    ref.read(feedbackServiceProvider).like();
    _heartController.forward();
  }

  void _toggleSave() {
    ref.read(feedbackServiceProvider).follow();
    setState(() => _saved = !_saved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _saved ? S.of(context).feedSaved : S.of(context).feedUnsaved,
        ),
        backgroundColor: context.colors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sharePost() async {
    ref.read(feedbackServiceProvider).share();
    final post = widget.post;
    await ShareToChatSheet.show(
      context,
      postId: post.id,
      postCaption: post.content,
      postImageUrl: post.imageUrl,
      authorName: post.author.name,
    );
  }

  void _openImageLightbox(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => _ImageLightbox(
          imageUrl: imageUrl,
          heroTag: 'post-image-${widget.post.id}',
          postId: widget.post.id,
          caption: widget.post.content,
          authorName: widget.post.author.name,
          authorUsername: widget.post.author.username,
          authorAvatarUrl: widget.post.author.avatarUrl,
          // Brawe Sound: Fase C — preserva a música anexada ao abrir a
          // imagem em fullscreen (antes o lightbox não recebia nenhum
          // dado musical e a faixa nunca era iniciada).
          sound: widget.post.sound,
          soundVolume: widget.post.soundVolume,
        ),
      ),
    );
  }

  void _shareAsStory(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => StoryComposerScreen(
          initialRemoteUrl: imageUrl,
          initialOriginPostId: widget.post.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      color: context.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner "X repostou" — só aparece quando o item é fruto de
          // um repost de alguém (geralmente um usuário seguido).
          if (post.repostedBy != null)
            _RepostBanner(reposter: post.repostedBy!),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AuthorAvatar(
                  userId: post.author.id,
                  avatarUrl: post.author.avatarUrl,
                  name: post.author.name,
                  isVerified: post.author.isVerified,
                  onTap: () => context.push('/profile/${post.author.id}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.author.name,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                letterSpacing: -0.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.author.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFFA855F7),
                              size: 15,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '@${post.author.username} · ${_timeAgo(context, post.createdAt)}',
                        style: TextStyle(
                          color: context.colors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: context.colors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
          ),

          // Brawe Sound: atribuição musical compacta, logo abaixo do
          // header (nome do autor) — informação contextual da publicação,
          // não um card separado. Mesmo componente/posicionamento usado
          // nos Stories (ver `ContentSoundAttribution`).
          if (post.sound != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SoundPreviewChip(
                  sound: post.sound!,
                  volume: post.soundVolume,
                ),
              ),
            ),

          // Content text
          if (post.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                post.imageUrl != null ? 0 : 14,
              ),
              child: BraweRichText(
                post.content,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                  letterSpacing: -0.1,
                ),
              ),
            ),

          // Link preview card — mostra preview de URLs (og:image, título, etc)
          if (post.content.isNotEmpty)
            _buildLinkPreviewCard(context, post.content),

          // Image — estilo Threads: full-bleed, sem cantos arredondados
          if (post.imageUrl != null)
            GestureDetector(
              onTap: () => _isVideoUrl(post.imageUrl!)
                  ? context.push(
                      '/post/${post.id}/video?url=${Uri.encodeQueryComponent(post.imageUrl!)}',
                    )
                  : _openImageLightbox(context, post.imageUrl!),
              onDoubleTap: _doubleTapLike,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.width * 1.25,
                        ),
                        child: _isVideoUrl(post.imageUrl!)
                            ? _FeedVideoTile(url: post.imageUrl!)
                            : CachedNetworkImage(
                                imageUrl: post.imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(
                                  milliseconds: 180,
                                ),
                                placeholder: (ctx, _) => AspectRatio(
                                  aspectRatio: 4 / 5,
                                  child: Container(
                                    color: context.colors.surfaceElevated,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFA855F7),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: 200,
                                  color: context.colors.surfaceElevated,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: context.colors.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (_showHeart)
                    ScaleTransition(
                      scale: _heartScale,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _FeedTokens.likeRed.withValues(alpha: 0.6),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: context.colors.textPrimary,
                          size: 110,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Row(
              children: [
                _LikeReactionPill(
                  post: post,
                  onTap: () {
                    ref.read(feedbackServiceProvider).like();
                    ref
                        .read(feedViewModelProvider.notifier)
                        .toggleLike(post.id);
                  },
                  onPickReaction: (reaction) async {
                    ref.read(feedbackServiceProvider).reaction();
                    try {
                      await ref
                          .read(feedViewModelProvider.notifier)
                          .reactToPost(post.id, reaction.key);
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).feedCannotLike)),
                      );
                    }
                  },
                  onOpenLikers: () {
                    context.push('/post/${post.id}/likes');
                  },
                ),
                _ActionPill(
                  icon: Icons.mode_comment_outlined,
                  label: _formatCount(post.commentsCount),
                  color: context.colors.textSecondary,
                  onTap: () {
                    ref.read(feedbackServiceProvider).share();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentsSheet(postId: post.id),
                    );
                  },
                ),
                _ActionPill(
                  icon: Icons.repeat_rounded,
                  label: _formatCount(post.repostsCount),
                  color: post.userReposted
                      ? _FeedTokens.repostGreen
                      : context.colors.textSecondary,
                  active: post.userReposted,
                  activeBg: _FeedTokens.repostGreen.withValues(alpha: 0.14),
                  onTap: () => _confirmRepost(context, post),
                ),
                const Spacer(),
                _IconAction(
                  icon: _saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _saved
                      ? _FeedTokens.saveGold
                      : context.colors.textSecondary,
                  onTap: _toggleSave,
                ),
                const SizedBox(width: 4),
                _IconAction(
                  icon: Icons.send_rounded,
                  color: context.colors.textSecondary,
                  onTap: _sharePost,
                ),
              ],
            ),
          ),
          // Linha de views — discreta, estilo Twitter/X.
          if (post.viewsCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 14,
                    color: context.colors.textSecondary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.viewsCount == 1
                        ? '1 visualização'
                        : '${_formatCount(post.viewsCount)} visualizações',
                    style: TextStyle(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          // Divider estilo Threads
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: context.colors.border,
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    HapticFeedback.selectionClick();
    final post = widget.post;
    final currentUserId = ref.read(authStateProvider).value?.id;
    final isOwn = currentUserId != null && currentUserId == post.author.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PostOptionsSheet(
        isOwn: isOwn,
        hasImage: post.imageUrl != null && post.imageUrl!.isNotEmpty,
        onCopyLink: () async {
          Navigator.pop(context);
          await Clipboard.setData(
            ClipboardData(text: 'https://brawe.app/connect/p/${post.id}'),
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).feedLinkCopied)));
        },
        onShareStory: () {
          Navigator.pop(context);
          if (post.imageUrl != null) _shareAsStory(post.imageUrl!);
        },
        onUnfollow: () {
          Navigator.pop(context);
          _unfollowAuthor();
        },
        onBlock: () {
          Navigator.pop(context);
          _blockAuthor();
        },
        onReport: () {
          Navigator.pop(context);
          _reportPost();
        },
        onDelete: () {
          Navigator.pop(context);
          _deletePost();
        },
      ),
    );
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        title: Text(
          S.of(ctx).feedDeletePostTitle,
          style: TextStyle(color: ctx.colors.textPrimary),
        ),
        content: Text(
          S.of(ctx).feedDeleteConfirm,
          style: TextStyle(color: ctx.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              S.of(ctx).feedCancel,
              style: TextStyle(color: ctx.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(ctx).feedDelete,
              style: const TextStyle(color: Color(0xFFFF3B7E)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(feedViewModelProvider.notifier)
        .deletePost(widget.post.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? S.of(context).feedPostDeleted
              : S.of(context).feedPostDeleteError,
        ),
      ),
    );
  }

  Future<void> _unfollowAuthor() async {
    try {
      await ref
          .read(socialRepositoryProvider)
          .unfollowUser(widget.post.author.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).feedUnfollowed(widget.post.author.username),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedUnfollowError)));
    }
  }

  Future<void> _blockAuthor() async {
    final author = widget.post.author;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.surfaceElevated,
        title: Text(
          S.of(context).feedBlockUserTitle,
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: Text(
          S.of(context).feedBlockConfirm(author.username),
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              S.of(context).feedCancel,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).feedBlock,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(socialActionsServiceProvider)
          .blockUser(author.username.isNotEmpty ? author.username : author.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).feedBlocked(author.username))),
      );
      ref.read(feedViewModelProvider.notifier).refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedBlockError)));
    }
  }

  Future<void> _reportPost() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const _ReportReasonHeader(),
            _ReportReasonTile(
              reason: 'spam',
              label: S.of(sheetCtx).feedReportSpam,
            ),
            _ReportReasonTile(
              reason: 'harassment',
              label: S.of(sheetCtx).feedReportHarassment,
            ),
            _ReportReasonTile(
              reason: 'inappropriate',
              label: S.of(sheetCtx).feedReportInappropriate,
            ),
            _ReportReasonTile(
              reason: 'impersonation',
              label: S.of(sheetCtx).feedReportImpersonation,
            ),
            _ReportReasonTile(
              reason: 'other',
              label: S.of(sheetCtx).feedReportOther,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (reason == null) return;
    try {
      await ref
          .read(socialActionsServiceProvider)
          .report(targetType: 'post', targetId: widget.post.id, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedReportSent)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).feedReportError)));
    }
  }

  void _confirmRepost(BuildContext context, Post post) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  post.userReposted
                      ? S.of(context).feedRepostUndoConfirm
                      : S.of(context).feedRepostConfirm,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _SheetTile(
              icon: Icons.repeat_rounded,
              iconColor: _FeedTokens.repostGreen,
              iconBg: _FeedTokens.repostGreen.withValues(alpha: 0.18),
              label: post.userReposted
                  ? S.of(context).feedRepostUndo
                  : S.of(context).feedRepost,
              onTap: () async {
                Navigator.pop(context);
                ref.read(feedbackServiceProvider).repost();
                try {
                  await ref
                      .read(feedViewModelProvider.notifier)
                      .toggleRepost(post.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        post.userReposted
                            ? S.of(context).feedRepostUndo
                            : S.of(context).feedReposted,
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).feedCannotShare)),
                  );
                }
              },
            ),
            _SheetTile(
              icon: Icons.send_rounded,
              iconColor: context.colors.textPrimary,
              iconBg: Colors.white12,
              label: S.of(context).shareToFollowers,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ShareToChatSheet(
                    postId: post.id,
                    postCaption: post.content,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _timeAgo(BuildContext context, DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return S.of(context).feedTimeNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 30) return '${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Build link preview card para URLs encontradas no conteúdo do post
  Widget _buildLinkPreviewCard(BuildContext context, String content) {
    final url = BraweRichText.firstUrl(content);
    if (url == null) return const SizedBox.shrink();
    return LinkPreviewCard(url: url);
  }
}

/// ─── Banner discreto exibido no topo do card quando o post aparece no feed
/// como resultado de um repost de alguém seguido.
class _RepostBanner extends StatelessWidget {
  const _RepostBanner({required this.reposter});
  final PostAuthor reposter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: GestureDetector(
        onTap: () => context.push('/profile/${reposter.id}'),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Icon(
              Icons.repeat_rounded,
              size: 14,
              color: _FeedTokens.repostGreen.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                S.of(context).feedRepostBanner(reposter.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorAvatar extends ConsumerWidget {
  const _AuthorAvatar({
    required this.userId,
    required this.avatarUrl,
    required this.name,
    required this.isVerified,
    required this.onTap,
  });
  final String userId;
  final String? avatarUrl;
  final String name;
  final bool isVerified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se o autor tem stories ativos, o anel do story PRECEDE o de "verified".
    // Caso contrário, mantemos o visual antigo (anel de verificado / borda).
    return StoryRingAvatar(
      userId: userId,
      avatarUrl: avatarUrl,
      fallbackText: name,
      radius: 21,
      backgroundColor: context.colors.surfaceElevated,
      onTapWithoutStories: onTap,
    );
  }
}

/// ─── Action pill (com contador) — Like/Comment/Repost ─────────────────────
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.onLongPress,
    this.active = false,
    this.activeBg,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool active;
  final Color? activeBg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: active ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 19),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pílula composta para o botão de like:
/// - Tap → toggle like
/// - Long-press → abre [showReactionsBar] flutuante
/// - Tap no número de curtidas → abre tela "Quem curtiu"
class _LikeReactionPill extends StatelessWidget {
  const _LikeReactionPill({
    required this.post,
    required this.onTap,
    required this.onPickReaction,
    required this.onOpenLikers,
  });
  final Post post;
  final VoidCallback onTap;
  final ValueChanged<BraweReaction> onPickReaction;
  final VoidCallback onOpenLikers;

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final liked = post.userLiked;
    // Detectar qual reação o usuário aplicou para exibir o emoji correto
    final reaction = liked
        ? BraweReaction.values.firstWhere(
            (r) => r.key == (post.userReactionType ?? 'like'),
            orElse: () => BraweReaction.like,
          )
        : null;
    final color = liked ? _FeedTokens.likeRed : context.colors.textSecondary;
    final activeBg = _FeedTokens.likeRed.withValues(alpha: 0.14);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: liked ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              onLongPressStart: (d) async {
                HapticFeedback.mediumImpact();
                final picked = await showReactionsBar(
                  context,
                  globalPosition: d.globalPosition,
                );
                if (picked != null) onPickReaction(picked);
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: reaction != null && reaction != BraweReaction.like
                    ? Text(reaction.emoji, style: const TextStyle(fontSize: 17))
                    : Icon(
                        liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: color,
                        size: 19,
                      ),
              ),
            ),
            InkWell(
              onTap: onOpenLikers,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                child: Text(
                  _fmt(post.likesCount),
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: liked ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 21),
        ),
      ),
    );
  }
}

/// ─── Post Options Bottom Sheet (modernizado) ──────────────────────────────
class _PostOptionsSheet extends StatelessWidget {
  const _PostOptionsSheet({
    required this.isOwn,
    required this.hasImage,
    required this.onCopyLink,
    required this.onShareStory,
    required this.onUnfollow,
    required this.onBlock,
    required this.onReport,
    required this.onDelete,
  });
  final bool isOwn;
  final bool hasImage;
  final VoidCallback onCopyLink;
  final VoidCallback onShareStory;
  final VoidCallback onUnfollow;
  final VoidCallback onBlock;
  final VoidCallback onReport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 4),
            _SheetTile(
              icon: Icons.link_rounded,
              iconColor: const Color(0xFFA855F7),
              iconBg: const Color(0xFFA855F7).withValues(alpha: 0.18),
              label: S.of(context).feedCopyLink,
              onTap: onCopyLink,
            ),
            if (hasImage)
              _SheetTile(
                icon: Icons.auto_stories_rounded,
                iconColor: const Color(0xFFEC4899),
                iconBg: const Color(0xFFEC4899).withValues(alpha: 0.18),
                label: S.of(context).feedShareAsStory,
                onTap: onShareStory,
              ),
            if (!isOwn)
              _SheetTile(
                icon: Icons.person_remove_rounded,
                iconColor: const Color(0xFFFFC857),
                iconBg: const Color(0xFFFFC857).withValues(alpha: 0.16),
                label: S.of(context).feedUnfollow,
                onTap: onUnfollow,
              ),
            if (!isOwn)
              _SheetTile(
                icon: Icons.block_rounded,
                iconColor: context.colors.textPrimary,
                iconBg: context.colors.surfaceHighest,
                label: S.of(context).feedBlockUserTitle,
                onTap: onBlock,
              ),
            if (!isOwn)
              _SheetTile(
                icon: Icons.flag_rounded,
                iconColor: _FeedTokens.likeRed,
                iconBg: _FeedTokens.likeRed.withValues(alpha: 0.16),
                label: S.of(context).feedReport,
                destructive: true,
                onTap: onReport,
              ),
            if (isOwn)
              _SheetTile(
                icon: Icons.delete_outline_rounded,
                iconColor: _FeedTokens.likeRed,
                iconBg: _FeedTokens.likeRed.withValues(alpha: 0.16),
                label: S.of(context).feedDeletePost,
                destructive: true,
                onTap: onDelete,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: destructive
                        ? _FeedTokens.likeRed
                        : context.colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.border,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportReasonHeader extends StatelessWidget {
  const _ReportReasonHeader();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).feedReportTitle,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              S.of(context).feedReportPrompt,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportReasonTile extends StatelessWidget {
  const _ReportReasonTile({required this.reason, required this.label});
  final String reason;
  final String label;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: TextStyle(color: context.colors.textPrimary)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.colors.textTertiary,
      ),
      onTap: () => Navigator.pop(context, reason),
    );
  }
}

/// �� Lightbox fullscreen para imagens de posts (estilo Instagram).
class _ImageLightbox extends ConsumerStatefulWidget {
  const _ImageLightbox({
    required this.imageUrl,
    required this.heroTag,
    required this.postId,
    required this.caption,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.sound,
    this.soundVolume = 1.0,
  });

  final String imageUrl;
  final String heroTag;
  final String postId;
  final String caption;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;

  /// Brawe Sound: música anexada ao post (opcional) — iniciada junto com
  /// a imagem em fullscreen (Fase C do relatório de áudio).
  final SoundPreview? sound;
  final double soundVolume;

  @override
  ConsumerState<_ImageLightbox> createState() => _ImageLightboxState();
}

class _ImageLightboxState extends ConsumerState<_ImageLightbox>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  double _dragOffset = 0;
  bool _chromeVisible = true;
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;
  bool _showHeart = false;
  final TransformationController _zoomCtrl = TransformationController();

  /// `true` quando a música foi pausada automaticamente pelo lifecycle do
  /// app (background) — nunca retomada por uma pausa manual do usuário
  /// (aqui não há play/pause manual, mas o padrão é mantido por
  /// consistência com StoryViewer/VideoFullscreenScreen).
  bool _pausedByLifecycle = false;

  String get _owner => 'fullscreen:image:${widget.postId}';

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem<double>(tween: ConstantTween<double>(1.0), weight: 30),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_heartCtrl);

    _heartCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showHeart = false);
        _heartCtrl.reset();
      }
    });

    WidgetsBinding.instance.addObserver(this);
    // Brawe Sound (Fase C): inicia a música anexada junto com a imagem em
    // fullscreen — antes esta tela não recebia/não tocava nenhuma faixa.
    final sound = widget.sound;
    if (sound != null) {
      ref
          .read(soundPlayerViewModelProvider.notifier)
          .play(
            sound.toPlayableSound(volume: widget.soundVolume),
            owner: _owner,
          );
    }
  }

  /// Fase A: pausa a música quando o app sai de foreground e retoma ao
  /// voltar (sem isso a faixa continuava tocando com o app em background).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sound = widget.sound;
    if (sound == null) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        final playerState = ref.read(soundPlayerViewModelProvider);
        if (playerState.isPlaying) {
          _pausedByLifecycle = true;
          ref.read(soundPlayerViewModelProvider.notifier).pause();
        }
        break;
      case AppLifecycleState.resumed:
        if (_pausedByLifecycle) {
          _pausedByLifecycle = false;
          ref
              .read(soundPlayerViewModelProvider.notifier)
              .play(
                sound.toPlayableSound(volume: widget.soundVolume),
                owner: _owner,
              );
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartCtrl.dispose();
    _zoomCtrl.dispose();
    // Brawe Sound: para a música ao fechar a imagem em fullscreen — não
    // deve continuar tocando em background. `stop()` é assíncrono;
    // dispose() precisa continuar síncrono, por isso fire-and-forget com
    // timeout de segurança (mesmo padrão usado em StoryViewer/Fullscreen).
    if (widget.sound != null) {
      unawaited(
        ref
            .read(soundPlayerViewModelProvider.notifier)
            .stop()
            .timeout(const Duration(seconds: 2))
            .catchError((_) {}),
      );
    }
    super.dispose();
  }

  void _doubleTapLike() {
    HapticFeedback.mediumImpact();
    final vm = ref.read(feedViewModelProvider.notifier);
    final state = ref.read(feedViewModelProvider).value;
    final post = state?.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => state.first,
    );
    if (post != null && !post.userLiked) {
      vm.toggleLike(widget.postId);
    }
    setState(() => _showHeart = true);
    _heartCtrl.forward(from: 0);
  }

  bool get _isZoomed => _zoomCtrl.value.getMaxScaleOnAxis() > 1.05;

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedViewModelProvider).value;
    final post = feedState?.where((p) => p.id == widget.postId).firstOrNull;
    final userLiked = post?.userLiked ?? false;
    final likesCount = post?.likesCount ?? 0;
    final commentsCount = post?.commentsCount ?? 0;

    final opacity = (1.0 - (_dragOffset.abs() / 300)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacity),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _chromeVisible = !_chromeVisible),
                onDoubleTap: _doubleTapLike,
                onVerticalDragUpdate: _isZoomed
                    ? null
                    : (d) => setState(() => _dragOffset += d.delta.dy),
                onVerticalDragEnd: _isZoomed
                    ? null
                    : (_) {
                        if (_dragOffset.abs() > 100) {
                          Navigator.of(context).pop();
                        } else {
                          setState(() => _dragOffset = 0);
                        }
                      },
                child: InteractiveViewer(
                  transformationController: _zoomCtrl,
                  minScale: 1,
                  maxScale: 5,
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fadeInDuration: const Duration(milliseconds: 150),
                        placeholder: (_, __) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.broken_image_rounded,
                          color: context.colors.textTertiary,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_showHeart)
            IgnorePointer(
              child: Center(
                child: ScaleTransition(
                  scale: _heartScale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _FeedTokens.likeRed.withValues(alpha: 0.6),
                          blurRadius: 60,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: context.colors.textPrimary,
                      size: 160,
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _chromeVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: context.colors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    BraweAvatar(
                      avatarUrl: widget.authorAvatarUrl,
                      displayName: widget.authorName,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.authorName,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '@${widget.authorUsername}',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _chromeVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.caption.isNotEmpty)
                      Text(
                        widget.caption,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    if (widget.caption.isNotEmpty) const SizedBox(height: 12),
                    Row(
                      children: [
                        _LightboxAction(
                          icon: userLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          color: userLiked ? _FeedTokens.likeRed : Colors.white,
                          label: _formatLightboxCount(likesCount),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(feedViewModelProvider.notifier)
                                .toggleLike(widget.postId);
                          },
                        ),
                        const SizedBox(width: 22),
                        _LightboxAction(
                          icon: Icons.mode_comment_outlined,
                          color: context.colors.textPrimary,
                          label: _formatLightboxCount(commentsCount),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 22),
                        _LightboxAction(
                          icon: Icons.send_rounded,
                          color: context.colors.textPrimary,
                          label: S.of(context).feedSend,
                          onTap: () {
                            ShareToChatSheet.show(
                              context,
                              postId: widget.postId,
                              postCaption: widget.caption,
                              postImageUrl: widget.imageUrl,
                              authorName: widget.authorName,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatLightboxCount(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

class _LightboxAction extends StatelessWidget {
  const _LightboxAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vídeo inline no feed (Threads-style: autoplay muted, loop) ──────────────

bool _isVideoUrl(String url) {
  final u = url.toLowerCase().split('?').first;
  return u.endsWith('.mp4') ||
      u.endsWith('.mov') ||
      u.endsWith('.webm') ||
      u.endsWith('.m4v');
}

class _FeedVideoTile extends StatefulWidget {
  const _FeedVideoTile({required this.url});
  final String url;

  @override
  State<_FeedVideoTile> createState() => _FeedVideoTileState();
}

class _FeedVideoTileState extends State<_FeedVideoTile> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _error = false;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      c
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      setState(() {
        _ctrl = c;
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _toggleMute() {
    final c = _ctrl;
    if (c == null) return;
    setState(() => _muted = !_muted);
    c.setVolume(_muted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        height: 200,
        color: context.colors.surfaceElevated,
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: context.colors.textTertiary,
          ),
        ),
      );
    }
    if (!_ready || _ctrl == null) {
      return AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          color: context.colors.surfaceElevated,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFA855F7),
            ),
          ),
        ),
      );
    }
    final c = _ctrl!;
    final aspect = c.value.aspectRatio == 0 ? 9 / 16 : c.value.aspectRatio;
    return AspectRatio(
      aspectRatio: aspect.clamp(0.5, 1.91),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  // Mídia (vídeo) é o fundo: usar overlay escuro fixo
                  // independente do tema do app para garantir contraste.
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
