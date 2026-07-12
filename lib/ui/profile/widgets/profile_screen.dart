import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../creator/widgets/creator_tier_badge_for_user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/feature_flags.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/ui/follow_button.dart';
import '../../core/view_models/profile_view_model.dart';
import '../../notifications/view_models/notifications_view_model.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/providers/marketplace_providers.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/marketplace_models.dart' show Product;
import '../../../domain/models/profile.dart';
import 'profile_videos_grid.dart';
import '../../../domain/models/profile_state.dart';
import '../../../domain/models/social_stats.dart';
import '../../feed/widgets/create_post_sheet.dart';
import '../../feed/widgets/feed_screen.dart' show PostCard;
import 'profile_gallery_grid.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, SystemChrome, SystemUiMode;
import '../../../data/repositories/stories_repository.dart';
import '../../../domain/models/story.dart';
import '../../feed/widgets/story_viewer.dart';

/// Retorna um handle "real" para mostrar como @username.
/// Filtra valores vazios, IDs internos (ex.: BF-10006, AF-2023) e UUIDs.
String? _realHandle(String? raw) {
  if (raw == null) return null;
  final v = raw.trim();
  if (v.isEmpty) return null;
  // Padrão de display_id interno: 2 letras + hífen + dígitos (ex.: BF-10006)
  if (RegExp(r'^[A-Za-z]{1,3}-\d+$').hasMatch(v)) return null;
  // UUID
  if (RegExp(r'^[0-9a-fA-F]{8}-').hasMatch(v)) return null;
  return v;
}

/// Stories ativos de um usuário (vazio se não houver / 404).
final userStoriesProvider = FutureProvider.autoDispose
    .family<List<Story>, String>((ref, userId) async {
      final repo = ref.watch(storiesRepositoryProvider);
      try {
        return await repo.getUserStories(userId);
      } catch (_) {
        return const <Story>[];
      }
    });

void _openStoryViewer(
  BuildContext context,
  WidgetRef ref,
  List<Story> stories,
) {
  if (stories.isEmpty) return;
  // Abre no primeiro story não-visto, ou no primeiro caso todos vistos.
  final firstUnseen = stories.indexWhere((s) => !s.isSeen);
  final initial = firstUnseen >= 0 ? firstUnseen : 0;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // rootNavigator: true → cobre o BottomNavigationBar (ShellRoute)
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: true,
      fullscreenDialog: true,
      pageBuilder: (_, __, ___) => ForceDarkTheme(
        child: StoryViewer(
          stories: stories,
          initialIndex: initial,
          onStoryViewed: (storyId) {
            if (stories.isNotEmpty) {
              ref.invalidate(userStoriesProvider(stories.first.authorId));
            }
          },
        ),
      ),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
    ),
  );
}

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  // Abas: Posts, Vídeos, Galeria.
  // A Vitrine NUNCA fica lado a lado com posts/vídeos/galeria — ela abre
  // como página dedicada fullscreen (/shop/creator/:userId), estilo TikTok
  // Shop, acessível pelo ícone de loja no AppBar.
  int _tabCount = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider(widget.userId));
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final isMe = currentUserId == widget.userId;

    // Vitrine: só busca dados reais quando o usuário vê o PRÓPRIO perfil.
    // Gap de backend conhecido: ainda não há endpoint público de vitrine
    // por userId arbitrário — para outros perfis mantemos o empty state.
    // Usado apenas para decidir se mostramos o ícone de loja no AppBar e o
    // badge de parceiro — os produtos em si são exibidos na página dedicada
    // /shop/creator/:userId (ShopVitrinePage), nunca dentro das abas.
    final storefrontAsync = isMe
        ? ref.watch(myStorefrontProductsProvider)
        : const AsyncValue<List<Product>>.data(<Product>[]);
    final products = storefrontAsync.maybeWhen(
      data: (p) => p,
      orElse: () => const <Product>[],
    );

    final s = S.of(context);
    final tabs = <Tab>[
      Tab(
        icon: const Icon(Icons.article_outlined, size: 20),
        text: s.profileTabPosts,
      ),
      Tab(
        icon: const Icon(Icons.play_circle_outline, size: 20),
        text: s.profileTabVideos,
      ),
      Tab(
        icon: const Icon(Icons.grid_on_outlined, size: 20),
        text: s.profileTabGallery,
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: context.colors.background,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/home'),
            ),
            // No PRÓPRIO perfil não mostramos "@username" no título — é
            // redundante (o usuário já sabe quem é) e visualmente datado.
            // Em vez disso, o título fica vazio e o ícone de "adicionar
            // pessoa" (ver actions) assume esse espaço, abrindo a página
            // de Encontrar amigos. Em perfis de terceiros mantemos o
            // "@username" — útil para saber de quem é o perfil ao rolar.
            title: isMe
                ? null
                : profileState.profile.maybeWhen(
                    data: (p) {
                      final handle = _realHandle(p.username);
                      if (handle == null) return const SizedBox.shrink();
                      return Text(
                        '@$handle',
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
            actions: [
              if (isMe)
                IconButton(
                  icon: Icon(
                    LucideIcons.userPlus,
                    color: context.colors.textPrimary,
                    size: 22,
                  ),
                  tooltip: s.profileTooltipFindFriends,
                  onPressed: () => context.push('/find-friends'),
                ),
              if (products.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.storefront,
                    color: context.colors.textPrimary,
                  ),
                  tooltip: s.profileTooltipShop,
                  // Vitrine é sempre uma página dedicada fullscreen (estilo
                  // TikTok Shop) — nunca uma aba ao lado de posts/vídeos.
                  onPressed: () =>
                      context.push('/shop/creator/${widget.userId}'),
                ),
              if (isMe)
                IconButton(
                  icon: Icon(
                    Icons.emoji_events_outlined,
                    color: context.colors.textPrimary,
                  ),
                  tooltip: s.profileTooltipQuests,
                  onPressed: () => context.push('/quests'),
                ),
              if (isMe)
                Consumer(
                  builder: (context, ref, _) {
                    final unread =
                        ref
                            .watch(notificationsUnreadCountProvider)
                            .asData
                            ?.value ??
                        0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: context.colors.textPrimary,
                          ),
                          tooltip: s.profileTooltipNotifications,
                          onPressed: () => context.push('/notifications'),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 6,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : unread.toString(),
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              if (isMe && kEnableMonetization)
                IconButton(
                  icon: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: context.colors.textPrimary,
                  ),
                  tooltip: s.profileTooltipWallet,
                  onPressed: () => context.push('/wallet'),
                ),
              IconButton(
                icon: Icon(Icons.more_vert, color: context.colors.textPrimary),
                onPressed: () => _showOptions(context, isMe),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _ProfileHeader(
                  userId: widget.userId,
                  isMe: isMe,
                  profileState: profileState,
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.electricPurple,
                indicatorWeight: 2,
                labelColor: context.colors.textPrimary,
                unselectedLabelColor: context.colors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                tabs: tabs,
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () => ref
              .read(profileViewModelProvider(widget.userId).notifier)
              .refresh(),
          color: AppColors.electricPurple,
          child: TabBarView(
            controller: _tabController,
            children: [
              _PostsGrid(postsState: profileState.posts),
              ProfileVideosGrid(
                userId: widget.userId,
                isMe: isMe,
                postsState: profileState.posts,
              ),
              ProfileGalleryGrid(userId: widget.userId, isMe: isMe),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element, unused_field, unused_element_parameter
  Future<void> _openCreatePostSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostSheet(),
    );
    if (!mounted) return;
    // Atualiza posts para refletir a nova publicação na galeria.
    await ref.read(profileViewModelProvider(widget.userId).notifier).refresh();
  }

  // ---- Sprint 3: Share / Block / Report --------------------------------
  Future<void> _shareProfile(BuildContext context) async {
    final profile = ref
        .read(profileViewModelProvider(widget.userId))
        .profile
        .value;
    final handle = _realHandle(profile?.username) ?? widget.userId;
    final name = profile?.displayName ?? handle;
    final url = 'https://brawe.app/connect/u/$handle';
    final text = 'Confira $name no Brawe Connect: $url';
    try {
      // ignore: deprecated_member_use
      await Share.share(text, subject: name);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).profileShareFail)));
    }
  }

  Future<void> _copyProfileLink(BuildContext context) async {
    final profile = ref
        .read(profileViewModelProvider(widget.userId))
        .profile
        .value;
    final handle = _realHandle(profile?.username) ?? widget.userId;
    final url = 'https://brawe.app/connect/u/$handle';
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).profileLinkCopied)));
  }

  Future<void> _confirmBlock(BuildContext context) async {
    final profile = ref
        .read(profileViewModelProvider(widget.userId))
        .profile
        .value;
    final name = profile?.displayName ?? S.of(context).profileFallbackUser;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).profileBlockTitle),
        content: Text(S.of(ctx).profileBlockBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(ctx).profileBlockTitle),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final slug =
          _realHandle(
            ref
                .read(profileViewModelProvider(widget.userId))
                .profile
                .value
                ?.username,
          ) ??
          widget.userId;
      await ref.read(socialActionsServiceProvider).blockUser(slug);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).profileBlockedSuccess)),
      );
      if (context.canPop()) context.pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).profileBlockedError)),
      );
    }
  }

  void _showReportSheet(BuildContext context) {
    final s = S.of(context);
    final reasons = <(String, String)>[
      ('spam', s.profileReportReasonSpam),
      ('harassment', s.profileReportReasonHarassment),
      ('inappropriate', s.profileReportReasonInappropriate),
      ('impersonation', s.profileReportReasonImpersonation),
      ('other', s.profileReportReasonOther),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.profileReportQuestion,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            for (final r in reasons)
              ListTile(
                title: Text(
                  r.$2,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _submitReport(context, r.$1);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, String reason) async {
    try {
      await ref
          .read(socialActionsServiceProvider)
          .report(targetType: 'user', targetId: widget.userId, reason: reason);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).profileReportSent)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).profileReportError)));
    }
  }

  void _showOptions(BuildContext context, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final s = S.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (!isMe) ...[
                ListTile(
                  leading: Icon(
                    Icons.share_outlined,
                    color: context.colors.textPrimary,
                  ),
                  title: Text(
                    s.profileOptionShareProfile,
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _shareProfile(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.link, color: context.colors.textPrimary),
                  title: Text(
                    s.profileOptionCopyLink,
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _copyProfileLink(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.block, color: context.colors.textPrimary),
                  title: Text(
                    s.profileBlockTitle,
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmBlock(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.red),
                  title: Text(
                    s.profileOptionReport,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showReportSheet(context);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: Icon(
                    Icons.emoji_events_outlined,
                    color: context.colors.textPrimary,
                  ),
                  title: Text(
                    s.profileOptionDailyQuests,
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/quests');
                  },
                ),
                Divider(color: context.colors.divider, height: 1),
                ListTile(
                  leading: Icon(
                    Icons.workspace_premium_rounded,
                    color: context.colors.accentGold,
                  ),
                  title: Text(
                    s.creatorProgramTitle,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.textTertiary,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/creator/intro');
                  },
                ),
                Divider(color: context.colors.divider, height: 1),
                if (kEnableMonetization) ...[
                  ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: context.colors.textPrimary,
                    ),
                    title: Text(
                      s.profileOptionWallet,
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/wallet');
                    },
                  ),
                  Divider(color: context.colors.divider, height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.show_chart_rounded,
                      color: context.colors.textPrimary,
                    ),
                    title: Text(
                      s.earningsTitle,
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/earnings');
                    },
                  ),
                  Divider(color: context.colors.divider, height: 1),
                ],
                ListTile(
                  leading: Icon(
                    Icons.notifications_outlined,
                    color: context.colors.textPrimary,
                  ),
                  title: Text(
                    s.profileOptionNotifications,
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/notifications');
                  },
                ),
                Divider(color: context.colors.divider, height: 1),
                ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    color: context.colors.textPrimary,
                  ),
                  title: Text(
                    s.profileOptionSettings,
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/settings');
                  },
                ),
                Divider(color: context.colors.divider, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.mutedRed,
                  ),
                  title: Text(
                    s.profileOptionLogout,
                    style: const TextStyle(
                      color: AppColors.mutedRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmLogout(context);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          S.of(ctx).profileLogoutTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          S.of(ctx).profileLogoutBody,
          style: TextStyle(color: context.colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: Text(S.of(ctx).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedRed),
            child: Text(
              S.of(ctx).profileLogoutConfirm,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      // O redirect global do router cuida de mandar pra /welcome.
    }
  }
}

// ── HEADER ──────────────────────────────────────────────────────────────────
class _ProfileHeader extends ConsumerWidget {
  final String userId;
  final bool isMe;
  final ProfileState profileState;

  const _ProfileHeader({
    required this.userId,
    required this.isMe,
    required this.profileState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionUser = ref.watch(authStateProvider).value;
    final fallbackProfile = (isMe && sessionUser != null)
        ? Profile(
            id: sessionUser.id,
            displayName: sessionUser.name,
            // Não usamos displayId (ex.: BF-10006) como username — é um ID
            // interno, não um handle público.
            username: null,
            avatarUrl: sessionUser.avatarUrl,
          )
        : null;

    return profileState.profile.when(
      data: (profile) => _buildFull(context, ref, profile),
      loading: () => fallbackProfile != null
          ? _buildFull(context, ref, fallbackProfile)
          : const _HeaderSkeleton(),
      error: (_, __) => fallbackProfile != null
          ? _buildFull(context, ref, fallbackProfile)
          : _HeaderError(
              onRetry: () =>
                  ref.read(profileViewModelProvider(userId).notifier).refresh(),
            ),
    );
  }

  Widget _buildFull(BuildContext context, WidgetRef ref, Profile profile) {
    final stats = profileState.stats.asData?.value;
    final joinedAt = _parseJoinDate(ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Banner / Capa ──────────────────────────────────────────────
        Builder(
          builder: (context) {
            final storiesAsync = ref.watch(userStoriesProvider(userId));
            final stories = storiesAsync.asData?.value ?? const <Story>[];
            final hasStories = stories.isNotEmpty;
            final hasUnviewed = stories.any((s) => !s.isSeen);
            return _BannerSection(
              bannerUrl: profile.bannerUrl,
              avatarUrl: profile.avatarUrl,
              initials: _initialsFor(profile),
              isMe: isMe,
              onEditProfile: () => context.push('/edit-profile'),
              onSettings: () => context.push('/settings'),
              hasStories: hasStories,
              hasUnviewedStories: hasUnviewed,
              onAvatarTap: hasStories
                  ? () => _openStoryViewer(context, ref, stories)
                  : null,
            );
          },
        ),

        // Espaço reservado para o avatar sobreposto (Positioned bottom: -48)
        // + espaçamento até o nome, evitando que o nome se sobreponha à foto.
        const SizedBox(height: 60),

        // ── Nome + verificado ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.displayName ??
                          profile.username ??
                          S.of(context).profileUserFallback,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      color: AppColors.electricPurple,
                      size: 20,
                    ),
                  ],
                  CreatorTierBadgeForUser(userId: profile.id, size: 18),
                ],
              ),
              const SizedBox(height: 2),
              // ── @username + data de entrada na mesma linha ────────────
              Row(
                children: [
                  if (_realHandle(profile.username) != null)
                    Text(
                      '@${_realHandle(profile.username)}',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  if (_realHandle(profile.username) != null && joinedAt != null)
                    Text(
                      '  ·  ',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  if (joinedAt != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: context.colors.textSecondary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          joinedAt,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // ── Stats compactos (inline, sem card) ────────────────────
              if (stats != null) ...[
                const SizedBox(height: 10),
                _CompactStats(stats: stats, userId: userId),
              ],

              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  profile.bio!,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],

              // ── Links sociais ────────────────────────────────────────
              if (profile.socialLinks != null &&
                  profile.socialLinks!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _SocialLinks(links: profile.socialLinks!),
              ],

              const SizedBox(height: 14),

              // ── Ações ──────────────────────────────────────────────────
              // Quando isMe == true, _buildActions retorna SizedBox.shrink()
              // (a ação "Editar" virou ícone flutuante no banner).
              // Nota: o badge "Parceiro verificado" NÃO aparece aqui — ele
              // pertence à página dedicada da vitrine (ShopVitrinePage),
              // nunca ao perfil social (nem para o próprio usuário, nem
              // para visitantes).
              _buildActions(context, ref, profile),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Profile profile) {
    // No perfil próprio, NÃO renderizamos botão na área de conteúdo —
    // a ação "Editar perfil" virou um ícone flutuante (pencil) no canto
    // superior direito do banner (ver _BannerSection). Isso deixa o
    // perfil mais limpo, alinhado com Instagram/X.
    if (isMe) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(child: FollowButton(userId: userId)),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _openConversation(context, ref, profile),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: context.colors.textPrimary,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    S.of(context).profileMessageButton,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openConversation(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    // Mostra um spinner discreto enquanto resolve/cria a conversa.
    final messenger = ScaffoldMessenger.of(context);
    try {
      final convId = await ref
          .read(chatRepositoryProvider)
          .startConversation(participantId: profile.id);
      if (!context.mounted) return;
      context.push(
        '/chat/$convId',
        extra: {
          'participantName':
              profile.displayName ??
              profile.username ??
              S.of(context).profileChatFallback,
          'participantAvatarUrl': profile.avatarUrl,
          'participantId': profile.id,
        },
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(S.of(context).profileOpenConversationError(e))),
      );
    }
  }

  String? _parseJoinDate(WidgetRef ref) {
    final user = ref.read(authStateProvider).value;
    if (user == null) return null;
    try {
      final dt = DateTime.parse(user.createdAt);
      const months = [
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ];
      return '${months[dt.month - 1]}. de ${dt.year}';
    } catch (_) {
      return null;
    }
  }

  String _initialsFor(Profile profile) {
    final source = profile.displayName ?? profile.username ?? userId;
    final parts = source
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

// ── Banner + Avatar sobrepostos ──────────────────────────────────────────────
class _BannerSection extends StatelessWidget {
  const _BannerSection({
    required this.bannerUrl,
    required this.avatarUrl,
    required this.initials,
    required this.isMe,
    required this.onEditProfile,
    required this.onSettings,
    this.hasStories = false,
    this.hasUnviewedStories = false,
    this.onAvatarTap,
  });
  final String? bannerUrl;
  final String? avatarUrl;
  final String initials;
  final bool isMe;
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final bool hasStories;
  final bool hasUnviewedStories;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final hasBanner = bannerUrl != null && bannerUrl!.isNotEmpty;
    // Sem banner: usamos uma faixa baixa só para acomodar o avatar sobreposto.
    final bannerHeight = hasBanner ? 160.0 : 70.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner (ou faixa neutra quando não há imagem)
        Container(
          height: bannerHeight,
          width: double.infinity,
          color: context.colors.background,
          child: hasBanner
              ? CachedNetworkImage(
                  imageUrl: bannerUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                )
              : null,
        ),

        // ── Botão flutuante "Editar perfil" (apenas no perfil próprio) ──
        // Estilo Instagram/X: ícone discreto no canto superior direito do
        // banner, com glassmorphism leve. Substitui o antigo botão outlined
        // grande que ficava abaixo da bio.
        if (isMe)
          Positioned(
            top: 12,
            right: 12,
            child: _BannerActionChip(
              icon: Icons.edit_outlined,
              tooltip: S.of(context).profileEditTooltip,
              onTap: onEditProfile,
            ),
          ),

        // Avatar com anel (gradiente quando há stories não vistos,
        // cinza quando já foram vistos, neutro quando não há stories)
        Positioned(
          left: 16,
          bottom: -48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasUnviewedStories
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFE040FB),
                              Color(0xFFFF6B35),
                              Color(0xFF7C4DFF),
                            ],
                          )
                        : null,
                    color: hasUnviewedStories
                        ? null
                        : hasStories
                        ? Colors.white24
                        : Colors.transparent,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.background,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 86,
                        height: 86,
                        child: _Avatar(url: avatarUrl, initials: initials),
                      ),
                    ),
                  ),
                ),
              ),
              // Indicador online
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.background,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Chip de ação flutuante no banner (ex.: "Editar perfil") ─────────────────
/// Botão circular discreto com glassmorphism, posicionado sobre o banner.
/// Substitui o antigo botão outlined grande que poluía a área de conteúdo.
class _BannerActionChip extends StatelessWidget {
  const _BannerActionChip({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: context.colors.textPrimary, size: 18),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}

// ── Compact Stats (inline, sem card) ─────────────────────────────────────────
class _CompactStats extends StatelessWidget {
  const _CompactStats({required this.stats, required this.userId});
  final SocialStats stats;
  final String userId;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Wrap(
      spacing: 18,
      runSpacing: 4,
      children: [
        _InlineStat(
          value: _fmt(stats.followersCount),
          label: s.profileFollowers,
          valueColor: AppColors.electricPurple,
          onTap: () => context.push('/follows/$userId?tab=followers'),
        ),
        _InlineStat(
          value: _fmt(stats.followingCount),
          label: s.profileFollowing,
          onTap: () => context.push('/follows/$userId?tab=following'),
        ),
        _InlineStat(value: _fmt(stats.totalViews), label: s.profileViews),
      ],
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.value,
    required this.label,
    this.valueColor,
    this.onTap,
  });
  final String value;
  final String label;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? context.colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
      ],
    );
    if (onTap == null) return row;
    return GestureDetector(onTap: onTap, child: row);
  }
}

// ── Stats Card ────────────────────────────────────────────────────────────────
// ignore: unused_element, unused_field, unused_element_parameter
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats, required this.userId});
  final SocialStats stats;
  final String userId;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.surfaceHighest.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatsCol(
            value: _fmt(stats.followersCount),
            label: s.profileStatFollowers,
            valueColor: AppColors.electricPurple,
            onTap: () => context.push('/follows/$userId?tab=followers'),
          ),
          _Divider(),
          _StatsCol(
            value: _fmt(stats.followingCount),
            label: s.profileStatFollowing,
            onTap: () => context.push('/follows/$userId?tab=following'),
          ),
          _Divider(),
          _Divider(),
          _StatsCol(value: _fmt(stats.totalViews), label: s.profileStatViews),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 28,
    color: context.colors.surfaceHighest.withValues(alpha: 0.08),
  );
}

class _StatsCol extends StatelessWidget {
  const _StatsCol({
    required this.value,
    required this.label,
    this.valueColor = Colors.white,
    this.onTap,
  });
  final String value;
  final String label;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final col = Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
        ),
      ],
    );
    if (onTap == null) return col;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: col,
      ),
    );
  }
}

// ── Links Sociais ─────────────────────────────────────────────────────────────
class _SocialLinks extends StatelessWidget {
  const _SocialLinks({required this.links});
  final Map<String, String> links;

  // Paleta nativa: usamos `Icons.public` (globo Material) para website e
  // `Icons.mail_outline` para email — ambos nativos do sistema, sem FA.
  // Para as marcas (Instagram, X, YouTube, etc.) usamos FontAwesomeIcons
  // que entrega o logotipo oficial mais reconhecível.
  static final Map<String, _SocialLinkStyle> _config = {
    'website': _SocialLinkStyle(
      color: const Color(0xFF1A1428),
      border: const Color(0xFFB39DDB),
      label: 'Website',
      icon: Icons.public,
      isNative: true,
    ),
    'site': _SocialLinkStyle(
      color: const Color(0xFF1A1428),
      border: const Color(0xFFB39DDB),
      label: 'Site',
      icon: Icons.public,
      isNative: true,
    ),
    'email': _SocialLinkStyle(
      color: const Color(0xFF2A2010),
      border: const Color(0xFFFFB74D),
      label: 'Email',
      icon: Icons.mail_outline,
      isNative: true,
    ),
    'instagram': _SocialLinkStyle(
      color: const Color(0xFF2A1020),
      border: const Color(0xFFE1306C),
      label: 'Instagram',
      icon: FontAwesomeIcons.instagram,
    ),
    'twitter': _SocialLinkStyle(
      color: const Color(0xFF0E0E0E),
      border: const Color(0xFFFFFFFF),
      label: 'X',
      icon: FontAwesomeIcons.xTwitter,
    ),
    'x': _SocialLinkStyle(
      color: const Color(0xFF0E0E0E),
      border: const Color(0xFFFFFFFF),
      label: 'X',
      icon: FontAwesomeIcons.xTwitter,
    ),
    'youtube': _SocialLinkStyle(
      color: const Color(0xFF2A0A0A),
      border: const Color(0xFFFF0000),
      label: 'YouTube',
      icon: FontAwesomeIcons.youtube,
    ),
    'tiktok': _SocialLinkStyle(
      color: const Color(0xFF1A1A1A),
      border: const Color(0xFFFFFFFF),
      label: 'TikTok',
      icon: FontAwesomeIcons.tiktok,
    ),
    'telegram': _SocialLinkStyle(
      color: const Color(0xFF0A1A2A),
      border: const Color(0xFF2AABEE),
      label: 'Telegram',
      icon: FontAwesomeIcons.telegram,
    ),
    'whatsapp': _SocialLinkStyle(
      color: const Color(0xFF0A3A1A),
      border: const Color(0xFF25D366),
      label: 'WhatsApp',
      icon: FontAwesomeIcons.whatsapp,
    ),
    'twitch': _SocialLinkStyle(
      color: const Color(0xFF1A0A2A),
      border: const Color(0xFF9146FF),
      label: 'Twitch',
      icon: FontAwesomeIcons.twitch,
    ),
    'kick': _SocialLinkStyle(
      color: const Color(0xFF0A2A14),
      border: const Color(0xFF53FC18),
      label: 'Kick',
      icon: Icons.sports_esports,
      isNative: true,
    ),
    'spotify': _SocialLinkStyle(
      color: const Color(0xFF0A1F0E),
      border: const Color(0xFF1DB954),
      label: 'Spotify',
      icon: FontAwesomeIcons.spotify,
    ),
    'linkedin': _SocialLinkStyle(
      color: const Color(0xFF0A1F2A),
      border: const Color(0xFF0A66C2),
      label: 'LinkedIn',
      icon: FontAwesomeIcons.linkedinIn,
    ),
    'github': _SocialLinkStyle(
      color: const Color(0xFF14141A),
      border: const Color(0xFFCCCCCC),
      label: 'GitHub',
      icon: FontAwesomeIcons.github,
    ),
    'threads': _SocialLinkStyle(
      color: const Color(0xFF14141A),
      border: const Color(0xFFFFFFFF),
      label: 'Threads',
      icon: FontAwesomeIcons.threads,
    ),
    'snapchat': _SocialLinkStyle(
      color: const Color(0xFF2A2A0A),
      border: const Color(0xFFFFFC00),
      label: 'Snapchat',
      icon: FontAwesomeIcons.snapchat,
    ),
    'discord': _SocialLinkStyle(
      color: const Color(0xFF14142A),
      border: const Color(0xFF5865F2),
      label: 'Discord',
      icon: FontAwesomeIcons.discord,
    ),
    'facebook': _SocialLinkStyle(
      color: const Color(0xFF0A1A3A),
      border: const Color(0xFF1877F2),
      label: 'Facebook',
      icon: FontAwesomeIcons.facebook,
    ),
  };

  /// Estilo neutro para chaves desconhecidas ou links customizados sem ícone:
  /// usa globo Material (Icons.public) — comportamento de link de site externo.
  static _SocialLinkStyle _fallbackStyle(String label) => _SocialLinkStyle(
    color: const Color(0xFF1A1A2E),
    border: const Color(0xFFB39DDB),
    label: label,
    icon: Icons.public,
    isNative: true,
  );

  @override
  Widget build(BuildContext context) {
    // Filtra a chave especial "_custom" (lista JSON de links customizados)
    final socials = links.entries
        .where((e) => e.key != '_custom' && e.value.trim().isNotEmpty)
        .toList();
    final custom = _parseCustomLinks(links['_custom']);

    if (socials.isEmpty && custom.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...socials.map((e) {
          final key = e.key.toLowerCase();
          final style = _config[key] ?? _fallbackStyle(e.key);
          return _SocialPill(network: key, style: style, url: e.value);
        }),
        ...custom.map((c) {
          final style = _SocialLinkStyle(
            color: const Color(0xFF1A1A2E),
            border: const Color(0xFFB39DDB),
            label: c.title,
            icon: _customIconFor(c.icon),
            isNative: true,
          );
          return _SocialPill(network: 'website', style: style, url: c.url);
        }),
      ],
    );
  }
}

class _SocialLinkStyle {
  final Color color;
  final Color border;
  final String label;
  // Object aceita tanto IconData (Material) quanto FaIconData (FontAwesome 11+),
  // já que FaIconData não implementa mais IconData a partir da versão 11.0.0.
  final Object icon;

  /// `true` → renderiza com `Icon()` (Material); `false` → renderiza com `FaIcon()`.
  final bool isNative;
  const _SocialLinkStyle({
    required this.color,
    required this.border,
    required this.label,
    required this.icon,
    this.isNative = false,
  });
}

class _CustomLink {
  final String title;
  final String url;
  final String icon;
  const _CustomLink({
    required this.title,
    required this.url,
    required this.icon,
  });
}

List<_CustomLink> _parseCustomLinks(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (m) => _CustomLink(
            title: (m['title'] ?? '').toString().trim(),
            url: (m['url'] ?? '').toString().trim(),
            icon: (m['icon'] ?? 'Globe').toString(),
          ),
        )
        .where((c) => c.url.isNotEmpty)
        .toList();
  } catch (_) {
    return const [];
  }
}

/// Paleta de ícones para custom links — espelha a paleta do web
/// (`CUSTOM_ICON_PALETTE`). Usa Material Icons (nativos).
IconData _customIconFor(String name) {
  switch (name) {
    case 'ShoppingBag':
      return Icons.shopping_bag_outlined;
    case 'Briefcase':
      return Icons.work_outline;
    case 'Heart':
      return Icons.favorite_border;
    case 'Star':
      return Icons.star_outline;
    case 'Music':
      return Icons.music_note_outlined;
    case 'Book':
      return Icons.menu_book_outlined;
    case 'Coffee':
      return Icons.local_cafe_outlined;
    case 'Award':
      return Icons.emoji_events_outlined;
    case 'Zap':
      return Icons.flash_on_outlined;
    case 'Mic':
      return Icons.mic_none_outlined;
    case 'Tv':
      return Icons.tv_outlined;
    case 'Calendar':
      return Icons.calendar_today_outlined;
    case 'Mail':
      return Icons.mail_outline;
    case 'Phone':
      return Icons.phone_outlined;
    case 'MessageSquare':
      return Icons.chat_bubble_outline;
    case 'MessageCircle':
      return Icons.chat_outlined;
    case 'DollarSign':
      return Icons.attach_money_outlined;
    case 'CreditCard':
      return Icons.credit_card_outlined;
    case 'LinkIcon':
      return Icons.link_rounded;
    case 'Globe':
    default:
      return Icons.public;
  }
}

/// Resolve o valor salvo no perfil (handle/@user/URL) em uma URL utilizável
/// para a rede social informada e abre no app nativo.
Future<void> _launchSocial(String network, String raw) async {
  final value = raw.trim();
  if (value.isEmpty) return;

  final lower = value.toLowerCase();
  final isUrl = lower.startsWith('http://') || lower.startsWith('https://');
  final handle = value.startsWith('@') ? value.substring(1) : value;

  String url;
  if (isUrl) {
    url = value;
  } else if (lower.startsWith('mailto:')) {
    url = value;
  } else {
    switch (network.toLowerCase()) {
      case 'instagram':
        url = 'https://instagram.com/$handle';
        break;
      case 'tiktok':
        url = 'https://www.tiktok.com/@$handle';
        break;
      case 'twitter':
      case 'x':
        url = 'https://x.com/$handle';
        break;
      case 'youtube':
        url = 'https://youtube.com/@$handle';
        break;
      case 'twitch':
        url = 'https://twitch.tv/$handle';
        break;
      case 'telegram':
        final clean = handle.replaceFirst(RegExp(r'^t\.me/'), '');
        url = 'https://t.me/$clean';
        break;
      case 'whatsapp':
        final digits = handle.replaceAll(RegExp(r'[^0-9]'), '');
        final msg = Uri.encodeComponent('Oi, vim pelo Brawe!');
        url = 'https://wa.me/$digits?text=$msg';
        break;
      case 'email':
        url = 'mailto:$handle';
        break;
      case 'facebook':
        url = 'https://facebook.com/$handle';
        break;
      case 'kick':
        url = 'https://kick.com/$handle';
        break;
      case 'spotify':
        url = 'https://open.spotify.com/user/$handle';
        break;
      case 'linkedin':
        url = 'https://linkedin.com/in/$handle';
        break;
      case 'github':
        url = 'https://github.com/$handle';
        break;
      case 'threads':
        url = 'https://www.threads.net/@$handle';
        break;
      case 'snapchat':
        url = 'https://snapchat.com/add/$handle';
        break;
      case 'discord':
        url =
            handle.startsWith('discord.gg/') ||
                handle.startsWith('discord.com/')
            ? 'https://$handle'
            : 'https://discord.com/users/$handle';
        break;
      case 'website':
      case 'site':
      default:
        url = handle.contains('.') ? 'https://$handle' : 'https://$handle';
    }
  }

  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({
    required this.network,
    required this.style,
    required this.url,
  });
  final String network;
  final _SocialLinkStyle style;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Para marcas com cor branca/quase branca (X, TikTok, Threads), no tema
    // claro o branco fica invisível — usamos textPrimary como fallback.
    final brand = style.border;
    final brandLuma = brand.computeLuminance();
    final fg = (isLight && brandLuma > 0.7) ? colors.textPrimary : brand;

    // Fundo do pill: tint suave da marca sobre a superfície elevada, em vez
    // do hex escuro fixo. Mantém legibilidade em ambos os temas.
    final bg = Color.alphaBlend(
      brand.withValues(alpha: isLight ? 0.10 : 0.18),
      colors.surfaceElevated,
    );

    return GestureDetector(
      onTap: () => _launchSocial(network, url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fg.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (style.isNative)
              Icon(style.icon as IconData, color: fg, size: 14)
            else
              FaIcon(style.icon as FaIconData, color: fg, size: 14),
            const SizedBox(width: 6),
            Text(
              style.label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar com cache + fade-in + fallback de iniciais ───────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.initials});
  final String? url;
  final String initials;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _AvatarFallback(initials: initials);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      // Cache por 7 dias, mas sempre revalida se a URL mudou
      cacheKey: url,
      placeholder: (_, __) => Container(
        color: context.colors.surfaceElevated,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.electricPurple,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // Força remoção do cache corrompido para que a próxima tentativa
        // faça download fresco.
        CachedNetworkImage.evictFromCache(url);
        return _AvatarFallback(initials: initials);
      },
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.electricPurple, AppColors.softViolet],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

// ── Skeleton enquanto carrega ───────────────────────────────────────────────
class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar({double w = 120, double h = 14}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: context.colors.surfaceHighest.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 102,
            height: 102,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.surfaceHighest.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 14),
          bar(w: 160, h: 18),
          const SizedBox(height: 8),
          bar(w: 100, h: 12),
        ],
      ),
    );
  }
}

// ── Erro com retry ──────────────────────────────────────────────────────────
class _HeaderError extends StatelessWidget {
  const _HeaderError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.mutedRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.mutedRed.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.mutedRed,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).profileLoadError,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).profileLoadErrorHint,
            style: TextStyle(
              color: context.colors.textSecondary.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh_rounded,
              size: 18,
              color: context.colors.textPrimary,
            ),
            label: Text(
              S.of(context).profileRetry,
              style: TextStyle(color: context.colors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: context.colors.surfaceHighest.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ── POSTS LIST (estilo Twitter/X — feed completo) ───────────────────────────
class _PostsGrid extends StatelessWidget {
  final AsyncValue<List<Post>> postsState;
  const _PostsGrid({required this.postsState});

  @override
  Widget build(BuildContext context) {
    return postsState.when(
      data: (posts) {
        // Aba "Posts" mostra apenas publicações textuais (sem mídia).
        // Posts com foto vão para "Galeria" e posts com vídeo vão para "Vídeos".
        bool _isVideo(String? url) {
          if (url == null || url.isEmpty) return false;
          final l = url.toLowerCase();
          return l.endsWith('.mp4') ||
              l.endsWith('.mov') ||
              l.endsWith('.webm') ||
              l.endsWith('.m4v');
        }

        final textual = posts
            .where(
              (p) =>
                  (p.imageUrl == null || p.imageUrl!.isEmpty) &&
                  !_isVideo(p.imageUrl),
            )
            .toList();

        if (textual.isEmpty) {
          return _EmptyState(
            icon: Icons.article_outlined,
            message: S.of(context).profileNoTextPosts,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          itemCount: textual.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.white10, height: 1),
          itemBuilder: (context, index) => PostCard(post: textual[index]),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.electricPurple),
      ),
      error: (_, __) => _EmptyState(
        icon: Icons.error_outline,
        message: S.of(context).profilePostsLoadError,
      ),
    );
  }
}

// ── LIVES GRID ──────────────────────────────────────────────────────────────
// ignore: unused_element, unused_field, unused_element_parameter
class _LivesGrid extends StatelessWidget {
  final AsyncValue<List<LiveRoom>> livesState;
  const _LivesGrid({required this.livesState});

  @override
  Widget build(BuildContext context) {
    return livesState.when(
      data: (lives) {
        if (lives.isEmpty) {
          return _EmptyState(
            icon: Icons.live_tv_outlined,
            message: S.of(context).profileNoLives,
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 0.75,
          ),
          itemCount: lives.length,
          itemBuilder: (context, index) {
            final live = lives[index];
            return Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                image: live.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(live.thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mutedRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        S.of(context).profileLiveBadge,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (live.thumbnailUrl == null)
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: context.colors.border,
                        size: 32,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.electricPurple),
      ),
      error: (_, __) => _EmptyState(
        icon: Icons.error_outline,
        message: S.of(context).profileLivesLoadError,
      ),
    );
  }
}

// ── GALERIA (grid estilo Instagram com fotos/vídeos publicados) ─────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 56,
            color: context.colors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── SLIVER DELEGATE ─────────────────────────────────────────────────────────
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: context.colors.background, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    // Precisa reconstruir quando a TabBar muda (ex.: troca de tema altera
    // as cores do label/indicator) — senão o header persistente fica com
    // a cor de fundo "presa" no tema anterior (bug do fundo branco no
    // tema claro sobre conteúdo escuro).
    return oldDelegate._tabBar != _tabBar;
  }
}
