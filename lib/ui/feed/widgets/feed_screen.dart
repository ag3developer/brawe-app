// ignore_for_file: unused_element_parameter
import '../../core/view_models/hidden_users_view_model.dart';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../../core/text/link_preview_card.dart';
import '../../core/widgets/badge_count.dart';
import '../../core/widgets/brawe_logo.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/sound_preview.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../config/feature_flags.dart';
import '../../ads/boost/boost_preview.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/feedback_service.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../data/services/privacy_ux_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../chat/view_models/unread_count_provider.dart';
import '../../notifications/view_models/notifications_view_model.dart';
import '../../shared/widgets/sound_preview_chip.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../view_models/feed_view_model.dart';
import '../view_models/stories_view_model.dart';
import 'comments_sheet.dart';
import 'one_tap_repost.dart';
import 'post_image_viewer.dart';
import 'reactions_bar.dart';
import 'story_composer_screen.dart';
import 'share_to_chat_sheet.dart';
import 'stories_rail.dart';
import 'story_ring_avatar.dart';
import 'suggested_users_rail.dart';
import '../../../core/network/media_headers.dart';
import '../../core/widgets/report_sheet.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import 'package:brawe_app/core/media/media_utils.dart';
import 'post_location_widgets.dart';
import 'post_poll_card.dart';
import '../../../domain/models/ad_models.dart';
import '../../ads/ad_slots.dart';
import '../../ads/widgets/ad_actions.dart';
import '../../ads/widgets/sponsored_post_card.dart';

/// ─── Design Tokens ────────────────────────────────────────────────────────
/// O feed usa apenas tokens do tema (`context.colors.*`). O único valor
/// próprio é o vermelho do "curtir", que é semântico (coração) e não muda
/// com o tema.
class _FeedTokens {
  static const Color likeRed = Color(0xFFFF3B7E);
}

/// Offset (px) a partir do qual o header troca o wordmark pelo símbolo "B".
const double _kHeaderCollapseOffset = 48;

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  /// Um controller por aba — o header colapsa de acordo com a aba ativa.
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_syncCollapsed);
    for (final c in _scrollControllers) {
      c.addListener(_syncCollapsed);
    }
  }

  void _syncCollapsed() {
    final c = _scrollControllers[_tabController.index];
    final offset = c.hasClients ? c.offset : 0.0;
    final collapsed = offset > _kHeaderCollapseOffset;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
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
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sem FAB: o "+" central da HomeBottomNav já abre o menu de criação
    // (post, story, vídeo, live) — o FAB do feed era duplicado.
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header + abas fixos (sticky) acima da lista.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: context.colors.background,
                border: Border(
                  bottom: BorderSide(
                    color: _collapsed
                        ? context.colors.divider
                        : context.colors.divider.withValues(alpha: 0),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FeedHeader(
                    collapsed: _collapsed,
                    onSearch: () => context.push('/explore'),
                    onMessages: () => context.push('/chat'),
                    onNotifications: () => context.push('/notifications'),
                  ),
                  _FeedTabs(controller: _tabController),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeedTab(
                    tabType: FeedTabType.forYou,
                    scrollController: _scrollControllers[0],
                  ),
                  _FeedTab(
                    tabType: FeedTabType.following,
                    scrollController: _scrollControllers[1],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Header minimalista ───────────────────────────────────────────────────
/// No topo: wordmark "Brawe". Ao rolar: só o símbolo "B" (cross-fade 200ms).
/// À direita: busca, mensagens e notificações como ícones simples.
class _FeedHeader extends ConsumerWidget {
  const _FeedHeader({
    required this.collapsed,
    required this.onSearch,
    required this.onMessages,
    required this.onNotifications,
  });
  final bool collapsed;
  final VoidCallback onSearch;
  final VoidCallback onMessages;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Contadores reativos (reúsa os providers globais — sem contadores novos).
    final notifications =
        ref.watch(notificationsUnreadCountProvider).asData?.value ?? 0;
    final messages = ref.watch(unreadCountProvider);
    final s = S.of(context);

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 6),
        child: Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [...previous, ?current],
                ),
                child: collapsed
                    // O PNG do símbolo tem respiro (~53% visível): caixa de
                    // 44 ≈ marca de 24pt. Desloca para alinhar a marca
                    // visível com a margem de 16.
                    ? Transform.translate(
                        key: const ValueKey('symbol'),
                        offset: const Offset(-10, 0),
                        child: const BraweLogo(size: 44),
                      )
                    : const BraweLogo.wordmark(
                        key: ValueKey('wordmark'),
                        size: 24,
                      ),
              ),
            ),
            _HeaderIcon(
              icon: LucideIcons.search,
              tooltip: s.shareSearchHint,
              onTap: onSearch,
            ),
            _HeaderIcon(
              icon: LucideIcons.send,
              tooltip: s.chatListTitle,
              onTap: onMessages,
              count: messages,
            ),
            _HeaderIcon(
              icon: LucideIcons.bell,
              tooltip: s.notificationsTitle,
              onTap: onNotifications,
              count: notifications,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.count = 0,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  /// Quantidade de itens não lidos. `0` esconde o badge; `> 0` mostra a bolha
  /// numérica (até "9+").
  final int count;

  @override
  Widget build(BuildContext context) {
    final showBadge = BadgeCount.isVisible(count);
    return Semantics(
      button: true,
      label: tooltip,
      child: InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        radius: 22,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: context.colors.textPrimary, size: 24),
              if (showBadge)
                Positioned(
                  top: 5,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.accentPrimary,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: context.colors.background,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        BadgeCount.label(count),
                        style: TextStyle(
                          color: context.colors.textOnAccent,
                          fontSize: 9.5,
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

/// ─── Abas de texto (estilo Threads/TikTok) ───────────────────────────────
class _FeedTabs extends StatelessWidget {
  const _FeedTabs({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TabBar(
        controller: controller,
        onTap: (_) => HapticFeedback.selectionClick(),
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: _ShortUnderlineIndicator(
          color: context.colors.accentPrimary,
        ),
        labelColor: context.colors.textPrimary,
        unselectedLabelColor: context.colors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        tabs: [
          Tab(text: S.of(context).feedTabForYou),
          Tab(text: S.of(context).feedTabFollowing),
        ],
      ),
    );
  }
}

/// Sublinhado curto (20 × 2.5, arredondado) centralizado sob o rótulo.
class _ShortUnderlineIndicator extends Decoration {
  const _ShortUnderlineIndicator({required this.color});
  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ShortUnderlinePainter(color);
}

class _ShortUnderlinePainter extends BoxPainter {
  _ShortUnderlinePainter(this.color);
  final Color color;

  static const double _width = 20;
  static const double _height = 2.5;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    final rect = Rect.fromLTWH(
      offset.dx + (size.width - _width) / 2,
      offset.dy + size.height - _height - 3,
      _width,
      _height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(_height)),
      Paint()..color = color,
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
      color: context.colors.accentPrimary,
      backgroundColor: context.colors.surface,
      onRefresh: () async => onRefresh(),
      child: feedState.when(
        data: (posts) => CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            const SliverToBoxAdapter(child: StoriesRail()),
            SliverToBoxAdapter(
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: context.colors.divider,
              ),
            ),
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
              // Brawe Ads: 1 card patrocinado a cada N posts (só no Para você)
              ListenableBuilder(
                listenable: ref.watch(adLoaderProvider(AdPlacement.forYou)),
                builder: (context, _) {
                  final loader = ref.read(adLoaderProvider(AdPlacement.forYou));
                  if (!_isFollowing) loader.ensure(posts.length);
                  final hidden = ref.watch(hiddenAdsProvider);
                  final slots = _isFollowing
                      ? [
                          for (var i = 0; i < posts.length; i++)
                            ContentSlot(posts[i], i),
                        ]
                      : loader.mix(
                          posts,
                          skip: (ad) =>
                              hidden.contains(ad.adId) ||
                              hidden.contains('owner:${ad.advertiser?.id}'),
                        );
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final slot = slots[index];
                      if (slot case AdSlot(:final ad)) {
                        return SponsoredPostCard(
                          key: ValueKey('ad-${ad.token}'),
                          ad: ad,
                        );
                      }
                      final c = slot as ContentSlot;
                      if (!_isFollowing && c.index == 2) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PostCard(post: posts[c.index]),
                            const SuggestedUsersRail(),
                          ],
                        );
                      }
                      return PostCard(post: posts[c.index]);
                    }, childCount: slots.length),
                  );
                },
              ),
            ],
            // folga para a barra flutuante (o feed passa por trás do vidro)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
        loading: () => ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 24),
          itemCount: 4,
          itemBuilder: (_, _) => const _PostSkeleton(),
        ),
        error: (_, _) => _ErrorState(onRetry: onRefresh),
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
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(
                LucideIcons.sparkles,
                color: context.colors.accentPrimary,
                size: 32,
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
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.accentPrimary,
              foregroundColor: context.colors.textOnAccent,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
      builder: (_, _) {
        final t = _ctrl.value;
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(1 + t * 2, 0),
              colors: [
                context.colors.shimmerBase,
                context.colors.shimmerHighlight,
                context.colors.shimmerBase,
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 0.5),
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

  /// Estado otimista local (curtida/reação/repost). Permite que o card
  /// funcione sozinho em qualquer lugar (feed "Para você", "Seguindo",
  /// perfil, detalhe…) sem depender de o post existir no `feedViewModel`.
  /// É descartado quando o pai entrega um `post` novo (já sincronizado).
  Post? _local;

  Post get _post => _local ?? widget.post;

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
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) _local = null;
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  // ── Ações otimistas (independentes do feed) ─────────────────────────────

  /// Aplica [next] localmente e espelha os campos de interação nos feeds
  /// em memória (sem nova chamada à API).
  void _applyLocal(Post next) {
    if (!mounted) return;
    setState(() => _local = next);
    Post patch(Post p) => p.copyWith(
      userLiked: next.userLiked,
      likesCount: next.likesCount,
      userReactionType: next.userReactionType,
      userReposted: next.userReposted,
      repostsCount: next.repostsCount,
      commentsCount: next.commentsCount,
      commentsDisabled: next.commentsDisabled,
    );
    ref.read(feedViewModelProvider.notifier).patchPost(next.id, patch);
    ref.read(followingFeedViewModelProvider.notifier).patchPost(next.id, patch);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _toggleLike() async {
    final prev = _post;
    final liked = !prev.userLiked;
    _applyLocal(
      prev.copyWith(
        userLiked: liked,
        likesCount: liked
            ? prev.likesCount + 1
            : (prev.likesCount - 1).clamp(0, 1 << 30),
        userReactionType: liked ? prev.userReactionType : null,
      ),
    );
    try {
      await ref
          .read(postRepositoryProvider)
          .toggleLike(prev.id, prev.userLiked);
    } catch (_) {
      _applyLocal(prev);
      if (mounted) _showError(S.of(context).feedCannotLike);
    }
  }

  Future<void> _react(String reactionType) async {
    final prev = _post;
    _applyLocal(
      prev.copyWith(
        userLiked: true,
        userReactionType: reactionType,
        likesCount: prev.userLiked ? prev.likesCount : prev.likesCount + 1,
      ),
    );
    try {
      await ref.read(postRepositoryProvider).react(prev.id, reactionType);
    } catch (_) {
      _applyLocal(prev);
      if (mounted) _showError(S.of(context).feedCannotLike);
    }
  }

  /// Repost em um toque (com "Desfazer" no aviso). Tocar de novo desfaz.
  Future<void> _repost() => oneTapRepost(
    context: context,
    ref: ref,
    postId: _post.id,
    currentlyReposted: _post.userReposted,
    apply: (reposted) {
      if (!mounted) return;
      _applyLocal(
        _post.copyWith(
          userReposted: reposted,
          repostsCount: (_post.repostsCount + (reposted ? 1 : -1)).clamp(
            0,
            1 << 30,
          ),
        ),
      );
    },
  );

  void _doubleTapLike() {
    if (!_post.userLiked) _toggleLike();
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
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sharePost() async {
    ref.read(feedbackServiceProvider).share();
    final post = _post;
    await ShareToChatSheet.show(
      context,
      postId: post.id,
      postCaption: post.content,
      postImageUrl: post.imageUrl,
      authorName: post.author.name,
      authorId: post.author.id,
      isReposted: post.userReposted,
      onRepostChanged: (reposted) => _applyLocal(
        _post.copyWith(
          userReposted: reposted,
          repostsCount: (_post.repostsCount + (reposted ? 1 : -1)).clamp(
            0,
            1 << 30,
          ),
        ),
      ),
    );
  }

  void _openImageLightbox(BuildContext context, String imageUrl) {
    final post = _post;
    // Navigator raiz: cobre a barra de navegação e os sheets (comentários,
    // compartilhar) abrem por cima sem empilhar rotas do ShellRoute.
    Navigator.of(context, rootNavigator: true).push(
      postImageViewerRoute(
        PostImageViewer(
          imageUrl: imageUrl,
          postId: post.id,
          caption: post.content,
          authorName: post.author.name,
          authorUsername: post.author.username,
          authorAvatarUrl: post.author.avatarUrl,
          // Brawe Sound: preserva a música anexada ao abrir em fullscreen.
          sound: post.sound,
          soundVolume: post.soundVolume,
          initialLiked: post.userLiked,
          initialLikesCount: post.likesCount,
          commentsCount: post.commentsCount,
          onLikeChanged: (liked, count) =>
              _applyLocal(_post.copyWith(userLiked: liked, likesCount: count)),
          onCommentsCountChanged: (count) =>
              _applyLocal(_post.copyWith(commentsCount: count)),
        ),
      ),
    );
  }

  void _shareAsStory(String imageUrl) {
    // rootNavigator: o editor de story é tela cheia — cobre a barra de
    // navegação (antes abria dentro da aba e a nav ficava por cima).
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ForceDarkTheme(
          child: StoryComposerScreen(
            initialRemoteUrl: imageUrl,
            initialOriginPostId: _post.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final isVideo =
        post.imageUrl != null &&
        isVideoMedia(mediaType: post.mediaType, url: post.imageUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner "X repostou" — só aparece quando o item é fruto de
        // um repost de alguém (geralmente um usuário seguido).
        if (post.repostedBy != null) _RepostBanner(reposter: post.repostedBy!),
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            post.repostedBy != null ? 8 : 14,
            4,
            10,
          ),
          child: Row(
            children: [
              _AuthorAvatar(
                userId: post.author.id,
                avatarUrl: post.author.avatarUrl,
                name: post.author.name,
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
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.author.isVerified)
                          const VerifiedBadge(size: 15, gap: 4),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '@${post.author.username} · ${_timeAgo(context, post.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    if (post.location != null)
                      PostLocationRow(label: post.location!.label),
                  ],
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                icon: Icon(
                  LucideIcons.ellipsis,
                  color: context.colors.textSecondary,
                  size: 20,
                ),
                onPressed: () => _showPostOptions(context),
              ),
            ],
          ),
        ),

        // Brawe Sound: atribuição musical compacta, logo abaixo do header.
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
              post.imageUrl != null ? 10 : 6,
            ),
            child: BraweRichText(
              post.content,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),

        // Link preview card — mostra preview de URLs (og:image, título, etc)
        if (post.content.isNotEmpty)
          _buildLinkPreviewCard(context, post.content),

        // Enquete do post
        if (post.poll != null)
          PostPollCard(
            postId: post.id,
            poll: post.poll!,
            onChanged: (p) {
              if (mounted) setState(() => _local = _post.copyWith(poll: p));
            },
          ),

        // Mídia
        if (post.imageUrl != null)
          GestureDetector(
            onTap: () => isVideo
                ? context.push(
                    '/post/${post.id}/video?url=${Uri.encodeQueryComponent(post.imageUrl!)}',
                  )
                : _openImageLightbox(context, post.imageUrl!),
            onDoubleTap: _doubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Quadro com proporção FIXA desde o 1º frame (do servidor
                    // ou da memória) — antes nascia 4:5 e mudava quando a
                    // mídia carregava/saía da tela ("estica e volta").
                    child: isVideo
                        ? _FeedVideoTile(
                            // Versão leve (HLS do Bunny) quando existe; senão o original.
                            url: (post.hlsUrl?.isNotEmpty ?? false)
                                ? post.hlsUrl!
                                : post.imageUrl!,
                            posterUrl: post.coverUrl,
                            mediaAspect:
                                post.aspectRatio ??
                                MediaAspectCache.get(post.imageUrl),
                            cacheKey: post.imageUrl!,
                            postId: post.id,
                            sound: post.sound,
                            soundVolume: post.soundVolume,
                            originalAudioVolume: post.originalAudioVolume,
                          )
                        : _FeedPhoto(
                            url: post.imageUrl!,
                            mediaAspect:
                                post.aspectRatio ??
                                MediaAspectCache.get(post.imageUrl),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              // Decodifica na largura da tela, não na do arquivo.
                              memCacheWidth:
                                  (MediaQuery.sizeOf(context).width *
                                          MediaQuery.devicePixelRatioOf(
                                            context,
                                          ))
                                      .round(),
                              fadeInDuration: const Duration(milliseconds: 180),
                              placeholder: (ctx, _) => AspectRatio(
                                aspectRatio: 4 / 5,
                                child: Container(
                                  color: context.colors.surfaceHighest,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.colors.accentPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                height: 200,
                                color: context.colors.surfaceHighest,
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
                // Coração do duplo toque — desenhado SOBRE a mídia, por
                // isso branco fixo (antes usava textPrimary: preto no claro).
                if (_showHeart)
                  ScaleTransition(
                    scale: _heartScale,
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 104,
                      shadows: [Shadow(blurRadius: 24, color: Colors.black38)],
                    ),
                  ),
              ],
            ),
          ),

        // Action bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
          child: Row(
            children: [
              _LikeReactionPill(
                post: post,
                onTap: () {
                  ref.read(feedbackServiceProvider).like();
                  _toggleLike();
                },
                onPickReaction: (reaction) {
                  ref.read(feedbackServiceProvider).reaction();
                  _react(reaction.key);
                },
                onOpenLikers: () => context.push('/post/${post.id}/likes'),
              ),
              _ActionPill(
                icon: LucideIcons.messageCircle,
                label: _formatCount(post.commentsCount),
                color: context.colors.textSecondary,
                onTap: () {
                  ref.read(feedbackServiceProvider).share();
                  showModalBottomSheet(
                    useSafeArea: true,
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CommentsSheet(postId: post.id),
                  );
                },
              ),
              _ActionPill(
                icon: LucideIcons.repeat2,
                label: _formatCount(post.repostsCount),
                color: post.userReposted
                    ? context.colors.success
                    : context.colors.textSecondary,
                active: post.userReposted,
                onTap: _repost,
              ),
              // Enviar junto das interações (curtir · comentar · repostar · enviar)
              _IconAction(
                icon: LucideIcons.send,
                color: context.colors.textSecondary,
                onTap: _sharePost,
              ),
              const Spacer(),
              // Salvar: ação pessoal, sozinha à direita (padrão Instagram)
              _IconAction(
                icon: _saved ? Icons.bookmark_rounded : LucideIcons.bookmark,
                color: _saved
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
                onTap: _toggleSave,
              ),
            ],
          ),
        ),
        // Linha de views (estilo X) + "Impulsionar" do dono ao lado do desempenho.
        if (post.viewsCount > 0 || _canBoost(post))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 10, 10),
            child: Row(
              children: [
                if (post.viewsCount > 0) ...[
                  Icon(
                    LucideIcons.chartNoAxesColumn,
                    size: 13,
                    color: context.colors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    S
                        .of(context)
                        .feedViewsCount(
                          post.viewsCount,
                          _formatCount(post.viewsCount),
                        ),
                    style: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const Spacer(),
                if (_canBoost(post))
                  _BoostLink(
                    boosted: _isBoosted(post),
                    onTap: () => _openBoost(post),
                  ),
              ],
            ),
          )
        else
          const SizedBox(height: 8),
        // Separador hairline entre posts.
        Divider(height: 0.5, thickness: 0.5, color: context.colors.divider),
      ],
    );
  }

  bool _canBoost(Post post) =>
      kEnableMonetization &&
      (post.imageUrl ?? '').isNotEmpty &&
      ref.watch(authStateProvider).value?.id == post.author.id;

  bool _isBoosted(Post post) =>
      ref.watch(openBoostsProvider).value?.contains('post:${post.id}') ?? false;

  void _openBoost(Post post) {
    HapticFeedback.selectionClick();
    final video = post.mediaType == 'video' || isVideoUrl(post.imageUrl);
    context
        .push(
          '/ads/boost?type=post&id=${post.id}',
          extra: BoostPreviewData(
            name: post.author.name,
            avatarUrl: post.author.avatarUrl,
            imageUrl: video ? (post.coverUrl ?? post.imageUrl) : post.imageUrl,
            text: post.content,
            isVideo: video,
            verified: post.author.isVerified,
          ),
        )
        // volta do fluxo: atualiza o foguete (pode ter impulsionado agora)
        .then((_) => ref.invalidate(openBoostsProvider));
  }

  void _showPostOptions(BuildContext context) {
    HapticFeedback.selectionClick();
    final post = _post;
    final currentUserId = ref.read(authStateProvider).value?.id;
    final isOwn = currentUserId != null && currentUserId == post.author.id;
    final imageUrl = post.imageUrl;
    // "Compartilhar no story" só faz sentido com imagem (vídeo não é
    // suportado pelo composer a partir de URL remota).
    final canShareStory =
        imageUrl != null && imageUrl.isNotEmpty && !_isVideoUrl(imageUrl);

    showModalBottomSheet<void>(
      useSafeArea: true,
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // O sheet fecha a si mesmo (via o próprio context) antes de chamar a
      // ação — as ações usam o context/estado do card.
      builder: (_) => _PostOptionsSheet(
        isOwn: isOwn,
        canShareStory: canShareStory,
        onBoost: isOwn && kEnableMonetization && (imageUrl ?? '').isNotEmpty
            ? () => _openBoost(post)
            : null,
        onCopyLink: () async {
          await Clipboard.setData(
            ClipboardData(text: 'https://brawe.app/connect/p/${post.id}'),
          );
          if (!mounted) return;
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text(S.of(this.context).feedLinkCopied),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onShareStory: () {
          if (canShareStory) _shareAsStory(imageUrl);
        },
        onUnfollow: _unfollowAuthor,
        onBlock: _blockAuthor,
        onMute: _muteAuthor,
        onReport: _reportPost,
        onDelete: _deletePost,
        commentsDisabled: post.commentsDisabled,
        onToggleComments: _toggleComments,
      ),
    );
  }

  Future<void> _toggleComments() async {
    final disabled = !_post.commentsDisabled;
    try {
      final result = await ref
          .read(privacyUxServiceProvider)
          .setCommentsDisabled(_post.id, disabled);
      ref.invalidate(postCommentRulesProvider(_post.id));
      _applyLocal(_post.copyWith(commentsDisabled: result));
    } catch (_) {
      if (mounted) _showError(S.of(context).relActionError);
    }
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: ctx.colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: ctx.colors.textSecondary, height: 1.4),
        ),
        actions: [
          // IMPORTANTE: pop com o context do DIÁLOGO (`ctx`). O diálogo vive
          // no navigator raiz; o context do card pertence ao navigator do
          // ShellRoute — usar ele fechava a rota errada.
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
              confirmLabel,
              style: TextStyle(
                color: ctx.colors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost() async {
    final s = S.of(context);
    final confirmed = await _confirmDialog(
      title: s.feedDeletePostTitle,
      message: s.feedDeleteConfirm,
      confirmLabel: s.feedDelete,
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(feedViewModelProvider.notifier)
        .deletePost(_post.id);
    if (!mounted) return;
    // Recarrega a aba "Seguindo" para o post sumir de lá também.
    if (ok) ref.invalidate(followingFeedViewModelProvider);
    _showError(
      ok ? S.of(context).feedPostDeleted : S.of(context).feedPostDeleteError,
    );
  }

  Future<void> _unfollowAuthor() async {
    try {
      await ref.read(socialRepositoryProvider).unfollowUser(_post.author.id);
      if (!mounted) return;
      _showError(S.of(context).feedUnfollowed(_post.author.username));
      // A aba "Seguindo" não deve mais mostrar posts desse autor.
      ref.read(followingFeedViewModelProvider.notifier).refresh();
    } catch (_) {
      if (mounted) _showError(S.of(context).feedUnfollowError);
    }
  }

  /// Ocultar publicações: some dos meus feeds, sem a pessoa saber.
  Future<void> _muteAuthor() async {
    final author = _post.author;
    try {
      await ref.read(hiddenUsersProvider.notifier).mute(author.id);
      if (!mounted) return;
      _showError(S.of(context).relHiddenSnack(author.username));
    } catch (_) {
      if (mounted) _showError(S.of(context).relActionError);
    }
  }

  Future<void> _blockAuthor() async {
    final author = _post.author;
    final s = S.of(context);
    final confirmed = await _confirmDialog(
      title: s.feedBlockUserTitle,
      message: s.feedBlockConfirm(author.username),
      confirmLabel: s.feedBlock,
    );
    if (confirmed != true || !mounted) return;
    try {
      // Esconde a pessoa em todo o app na hora e recarrega os feeds.
      await ref
          .read(hiddenUsersProvider.notifier)
          .block(
            slug: author.username.isNotEmpty ? author.username : author.id,
            userId: author.id,
          );
      if (!mounted) return;
      _showError(S.of(context).feedBlocked(author.username));
    } catch (_) {
      if (mounted) _showError(S.of(context).feedBlockError);
    }
  }

  Future<void> _reportPost() async {
    // Valores aceitos por POST /messages/reports — não traduzir.
    final reason = await showModalBottomSheet<String>(
      useSafeArea: true,
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final s = S.of(sheetCtx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              const _ReportReasonHeader(),
              ReportChildSafetyTile(
                onTap: () => Navigator.pop(sheetCtx, kReportReasonChildSafety),
              ),
              _ReportReasonTile(reason: 'spam', label: s.feedReportSpam),
              _ReportReasonTile(
                reason: 'harassment',
                label: s.feedReportHarassment,
              ),
              _ReportReasonTile(
                reason: 'inappropriate',
                label: s.feedReportInappropriate,
              ),
              _ReportReasonTile(
                reason: 'impersonation',
                label: s.feedReportImpersonation,
              ),
              _ReportReasonTile(reason: 'other', label: s.feedReportOther),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (reason == null || !mounted) return;
    try {
      await ref
          .read(socialActionsServiceProvider)
          .report(targetType: 'post', targetId: _post.id, reason: reason);
      if (!mounted) return;
      _showError(S.of(context).feedReportSent);
    } catch (_) {
      if (mounted) _showError(S.of(context).feedReportError);
    }
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

/// ─── Banner discreto "X repostou" no topo do post.
class _RepostBanner extends StatelessWidget {
  const _RepostBanner({required this.reposter});
  final PostAuthor reposter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Alinha o texto com o nome do autor (avatar 42 + gap 12).
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: () => context.push('/profile/${reposter.id}'),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  LucideIcons.repeat2,
                  size: 13,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                S.of(context).feedRepostBanner(reposter.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
    required this.onTap,
  });
  final String userId;
  final String? avatarUrl;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se o autor tem stories ativos, o anel do story aparece no avatar.
    return StoryRingAvatar(
      userId: userId,
      avatarUrl: avatarUrl,
      fallbackText: name,
      radius: 21,
      backgroundColor: context.colors.surfaceHighest,
      onTapWithoutStories: onTap,
    );
  }
}

/// ─── Ação com contador — Comentar/Repostar ────────────────────────────────
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de like:
/// - Tap → toggle like
/// - Long-press → abre [showReactionsBar] flutuante
/// - Tap no número de curtidas → abre tela "Quem curtiu"
class _LikeReactionPill extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = post.userLiked;
    final hideCount = shouldHideLikeCount(
      ref,
      authorId: post.author.id,
      postHides: post.hideLikeCount,
    );
    // Detectar qual reação o usuário aplicou para exibir o emoji correto
    final reaction = liked
        ? BraweReaction.values.firstWhere(
            (r) => r.key == (post.userReactionType ?? 'like'),
            orElse: () => BraweReaction.like,
          )
        : null;
    final color = liked ? _FeedTokens.likeRed : context.colors.textSecondary;

    return Row(
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
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: reaction != null && reaction != BraweReaction.like
                ? Text(reaction.emoji, style: const TextStyle(fontSize: 18))
                : Icon(
                    liked ? Icons.favorite_rounded : LucideIcons.heart,
                    color: color,
                    size: 20,
                  ),
          ),
        ),
        if (hideCount)
          const SizedBox(width: 8)
        else
          InkWell(
            onTap: onOpenLikers,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 8, 8),
              child: Text(
                _fmt(post.likesCount),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: liked ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
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
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

/// ─── Menu "⋯" do post ─────────────────────────────────────────────────────
/// Ações neutras primeiro; destrutivas (vermelho) agrupadas no fim, após um
/// separador. Cada linha fecha o sheet e então executa a ação.
class _PostOptionsSheet extends StatelessWidget {
  const _PostOptionsSheet({
    required this.isOwn,
    required this.canShareStory,
    required this.onCopyLink,
    required this.onShareStory,
    required this.onUnfollow,
    required this.onBlock,
    required this.onMute,
    required this.onReport,
    required this.onDelete,
    this.onBoost,
    this.commentsDisabled = false,
    this.onToggleComments,
  });
  final bool commentsDisabled;
  final VoidCallback? onToggleComments;
  final VoidCallback? onBoost;
  final bool isOwn;
  final bool canShareStory;
  final VoidCallback onCopyLink;
  final VoidCallback onShareStory;
  final VoidCallback onUnfollow;
  final VoidCallback onBlock;
  final VoidCallback onMute;
  final VoidCallback onReport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final danger = context.colors.danger;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            if (onBoost != null)
              _SheetTile(
                icon: LucideIcons.rocket,
                label: s.postBoost,
                color: context.colors.accentPrimary,
                onTap: onBoost!,
              ),
            _SheetTile(
              icon: LucideIcons.link,
              label: s.feedCopyLink,
              onTap: onCopyLink,
            ),
            if (canShareStory)
              _SheetTile(
                icon: LucideIcons.circlePlus,
                label: s.feedShareAsStory,
                onTap: onShareStory,
              ),
            if (isOwn && onToggleComments != null)
              _SheetTile(
                icon: commentsDisabled
                    ? LucideIcons.messageCircle
                    : LucideIcons.messageCircleOff,
                label: commentsDisabled
                    ? s.privUxEnableComments
                    : s.privUxDisableComments,
                onTap: onToggleComments!,
              ),
            if (!isOwn)
              _SheetTile(
                icon: LucideIcons.userMinus,
                label: s.feedUnfollow,
                onTap: onUnfollow,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: context.colors.divider,
              ),
            ),
            if (isOwn)
              _SheetTile(
                icon: LucideIcons.trash2,
                label: s.feedDeletePost,
                color: danger,
                onTap: onDelete,
              )
            else ...[
              _SheetTile(
                icon: LucideIcons.eyeOff,
                label: s.relHidePosts,
                onTap: onMute,
              ),
              _SheetTile(
                icon: LucideIcons.ban,
                label: s.feedBlockUserTitle,
                color: danger,
                onTap: onBlock,
              ),
              _SheetTile(
                icon: LucideIcons.flag,
                label: s.feedReport,
                color: danger,
                onTap: onReport,
              ),
            ],
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
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Linha de sheet: ícone + rótulo. Fecha o sheet (com o próprio context)
/// e então executa [onTap].
class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Cor do ícone e do texto. `null` → `textPrimary`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.textPrimary;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: c,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
            const SizedBox(height: 4),
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

  /// Valor enviado à API (spam|harassment|inappropriate|impersonation|other).
  final String reason;
  final String label;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, reason),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: context.colors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vídeo inline no feed (Threads-style: autoplay muted, loop) ──────────────

bool _isVideoUrl(String url) => isVideoUrl(url);

class _FeedVideoTile extends ConsumerStatefulWidget {
  const _FeedVideoTile({
    required this.url,
    this.posterUrl,
    this.mediaAspect,
    required this.cacheKey,
    required this.postId,
    this.sound,
    this.soundVolume = 1.0,
    this.originalAudioVolume = 1.0,
  });

  final String postId;

  /// Música anexada ao post (Brawe Sound) — toca junto quando o som está
  /// ligado (antes só tocava na tela cheia).
  final SoundPreview? sound;
  final double soundVolume;
  final double originalAudioVolume;
  final String url;

  /// Proporção real da mídia (servidor ou memória). Null = desconhecida.
  final double? mediaAspect;

  /// Chave da memória de proporção (link original do post).
  final String cacheKey;

  /// Miniatura do vídeo (gerada pelo Bunny). Aparece até o vídeo tocar.
  final String? posterUrl;

  @override
  ConsumerState<_FeedVideoTile> createState() => _FeedVideoTileState();
}

/// Vídeo do feed no padrão Instagram/TikTok:
/// - só baixa quando o vídeo está chegando na tela (economiza 4G);
/// - só toca o que está ≥ 60% visível, e um por vez;
/// - ao sair da tela, pausa e libera o player (memória e banda).
class _FeedVideoTileState extends ConsumerState<_FeedVideoTile> {
  String get _owner => 'feed:${widget.postId}';

  /// Volume do áudio do VÍDEO com o som ligado (com música anexada o
  /// autor pode ter abaixado o áudio original).
  double get _videoVolume =>
      widget.sound != null ? widget.originalAudioVolume.clamp(0.0, 1.0) : 1.0;

  /// Música anexada: toca só com vídeo tocando E som ligado.
  void _syncMusic() {
    final sound = widget.sound;
    if (sound == null) return;
    final notifier = ref.read(soundPlayerViewModelProvider.notifier);
    final c = _ctrl;
    final shouldPlay =
        !_muted && c != null && _ready && c.value.isPlaying && _playing == this;
    if (shouldPlay) {
      if (!notifier.isOwner(_owner)) {
        notifier.play(
          sound.toPlayableSound(volume: widget.soundVolume),
          owner: _owner,
        );
      }
    } else if (notifier.isOwner(_owner)) {
      notifier.stop();
    }
  }

  /// O único vídeo tocando no feed.
  static _FeedVideoTileState? _playing;

  static const double _loadAt = 0.15; // começa a baixar
  static const double _playAt = 0.6; // começa a tocar

  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _error = false;
  bool _muted = true;
  bool _initializing = false;
  double _visible = 0;
  ScrollPosition? _scroll;

  /// Proporção real conhecida (servidor/memória ou descoberta ao tocar).
  /// O QUADRO usa [feedFrameAspect] dela e não muda mais depois.
  double? _mediaAspect;

  @override
  void initState() {
    super.initState();
    _mediaAspect = widget.mediaAspect;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pos = Scrollable.maybeOf(context)?.position;
    if (pos != _scroll) {
      _scroll?.removeListener(_onScroll);
      _scroll = pos;
      _scroll?.addListener(_onScroll);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  /// Fração do vídeo visível na tela (0–1), pela posição real do widget.
  double _visibleFraction() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return 0;
    final top = box.localToGlobal(Offset.zero).dy;
    final height = box.size.height;
    if (height <= 0) return 0;
    final screen = MediaQuery.sizeOf(context).height;
    final visible = (top + height).clamp(0.0, screen) - top.clamp(0.0, screen);
    return (visible / height).clamp(0.0, 1.0);
  }

  void _onScroll() {
    if (!mounted) return;
    final v = _visibleFraction();
    _visible = v;
    if (v >= _loadAt) {
      if (_ctrl == null && !_initializing && !_error) _init();
    } else if (v == 0) {
      _release();
      return;
    }
    final c = _ctrl;
    if (c == null || !_ready) return;
    if (v >= _playAt) {
      if (_playing != this) {
        _playing?._pause();
        _playing = this;
      }
      if (!c.value.isPlaying) c.play();
    } else {
      _pause();
    }
    _syncMusic();
  }

  void _pause() {
    final c = _ctrl;
    if (c != null && c.value.isPlaying) c.pause();
    if (_playing == this) _playing = null;
    _syncMusic();
  }

  /// Fora da tela: libera o player. Volta a carregar se a pessoa rolar de volta.
  void _release() {
    if (_playing == this) _playing = null;
    final c = _ctrl;
    if (c == null) return;
    _ctrl = null;
    if (mounted) setState(() => _ready = false);
    c.dispose();
    _syncMusic();
  }

  Future<void> _init() async {
    _initializing = true;
    final c = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: mediaHeadersFor(widget.url),
    );
    try {
      await c.initialize();
      if (!mounted || _visible == 0) {
        await c.dispose();
        return;
      }
      await c.setLooping(true);
      await c.setVolume(_muted ? 0 : _videoVolume);
      final real = c.value.aspectRatio;
      if (real > 0) MediaAspectCache.put(widget.cacheKey, real);
      setState(() {
        _ctrl = c;
        _ready = true;
        // Só ajusta se ainda não sabíamos (post antigo, 1ª vez).
        if (_mediaAspect == null && real > 0) _mediaAspect = real;
      });
      _onScroll(); // decide tocar ou não com a posição atual
    } catch (_) {
      await c.dispose();
      if (mounted) setState(() => _error = true);
    } finally {
      _initializing = false;
    }
  }

  @override
  void dispose() {
    _scroll?.removeListener(_onScroll);
    if (_playing == this) _playing = null;
    _ctrl?.dispose();
    if (widget.sound != null) {
      try {
        final n = ref.read(soundPlayerViewModelProvider.notifier);
        if (n.isOwner(_owner)) n.stop();
      } catch (_) {}
    }
    super.dispose();
  }

  void _toggleMute() {
    final c = _ctrl;
    if (c == null) return;
    setState(() => _muted = !_muted);
    c.setVolume(_muted ? 0 : _videoVolume);
    _syncMusic();
  }

  /// Miniatura (ou fundo neutro) enquanto o vídeo não toca.
  Widget _poster(BuildContext context, {bool loading = false}) {
    final poster = widget.posterUrl;
    return AspectRatio(
      aspectRatio: feedFrameAspect(_mediaAspect),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (poster != null && poster.isNotEmpty)
            CachedNetworkImage(
              memCacheWidth: context.decodeScreenPx,
              imageUrl: poster,
              httpHeaders: mediaHeadersFor(poster),
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, _) =>
                  ColoredBox(color: context.colors.surfaceElevated),
              errorWidget: (_, _, _) =>
                  ColoredBox(color: context.colors.surfaceElevated),
            )
          else
            ColoredBox(color: context.colors.surfaceElevated),
          Center(
            child: loading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.play_arrow_rounded,
                    size: 44,
                    color: Colors.white.withValues(alpha: 0.85),
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 8),
                    ],
                  ),
          ),
        ],
      ),
    );
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
      return _poster(context, loading: _initializing);
    }
    final c = _ctrl!;
    final frame = feedFrameAspect(_mediaAspect);
    final real = c.value.aspectRatio == 0 ? frame : c.value.aspectRatio;
    // Vídeo mais largo que o quadro (ex.: 16:9 num quadro 4:5 por falta de
    // dado): mostra inteiro com faixas; senão preenche (recorte suave).
    final fit = real > frame + 0.02 ? BoxFit.contain : BoxFit.cover;
    return AspectRatio(
      aspectRatio: frame,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (fit == BoxFit.contain) const ColoredBox(color: Colors.black),
          FittedBox(
            fit: fit,
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

/// Foto do feed com quadro de proporção fixa. Sem tamanho do servidor (post
/// antigo), descobre o tamanho da imagem UMA vez e guarda na memória.
class _FeedPhoto extends StatefulWidget {
  const _FeedPhoto({
    required this.url,
    required this.mediaAspect,
    required this.child,
  });
  final String url;
  final double? mediaAspect;
  final Widget child;

  @override
  State<_FeedPhoto> createState() => _FeedPhotoState();
}

class _FeedPhotoState extends State<_FeedPhoto> {
  double? _aspect;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _aspect = widget.mediaAspect;
    if (_aspect == null) _measure();
  }

  void _measure() {
    final stream = CachedNetworkImageProvider(
      widget.url,
    ).resolve(const ImageConfiguration());
    _listener = ImageStreamListener((info, _) {
      final w = info.image.width, h = info.image.height;
      if (w > 0 && h > 0) {
        final a = w / h;
        MediaAspectCache.put(widget.url, a);
        if (mounted && _aspect == null) setState(() => _aspect = a);
      }
      _stop();
    }, onError: (_, _) => _stop());
    _stream = stream..addListener(_listener!);
  }

  void _stop() {
    final l = _listener;
    if (l != null) _stream?.removeListener(l);
    _listener = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: feedFrameAspect(_aspect),
      child: SizedBox.expand(child: widget.child),
    );
  }
}

/// "🚀 Impulsionar" (ou "Impulsionado · ver resultados") na linha de visualizações — só nos meus posts.
class _BoostLink extends StatelessWidget {
  const _BoostLink({required this.boosted, required this.onTap});
  final bool boosted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final color = context.colors.accentPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.rocket, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              boosted ? s.postBoostedSeeResults : s.postBoost,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
