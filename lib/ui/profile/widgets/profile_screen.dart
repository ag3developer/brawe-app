import 'dart:convert';
import '../../core/view_models/hidden_users_view_model.dart';
import '../../feed/widgets/share_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../creator/widgets/creator_tier_badge_for_user.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/feature_flags.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/view_models/follow_view_model.dart';
import '../../core/view_models/profile_view_model.dart';
import '../../notifications/view_models/notifications_view_model.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../data/services/privacy_ux_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/providers/marketplace_providers.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/marketplace_models.dart' show Product;
import '../../../domain/models/profile.dart';
import 'profile_videos_grid.dart';
import '../../../domain/models/profile_state.dart';
import '../../feed/widgets/feed_screen.dart' show PostCard;
import 'profile_gallery_grid.dart';
import 'profile_menu_widgets.dart';
import '../../creator/view_models/creator_network_view_model.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, SystemChrome, SystemUiMode, SystemUiOverlay;
import '../../../data/repositories/stories_repository.dart';
import '../../../domain/models/story.dart';
import '../../feed/widgets/story_viewer.dart';
import '../../chat/view_models/presence_provider.dart';
import '../view_models/profile_reposts_provider.dart';
import '../../../domain/models/user_award.dart';
import '../../live/shared/widgets/award_badge.dart';
import '../../core/widgets/report_sheet.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

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

Future<void> _openStoryViewer(
  BuildContext context,
  WidgetRef ref,
  List<Story> stories,
) async {
  if (stories.isEmpty) return;
  // Abre no primeiro story não-visto, ou no primeiro caso todos vistos.
  final firstUnseen = stories.indexWhere((s) => !s.isSeen);
  final initial = firstUnseen >= 0 ? firstUnseen : 0;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // rootNavigator: true → cobre o BottomNavigationBar (ShellRoute)
  await Navigator.of(context, rootNavigator: true).push(
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
  // Restaura as barras do sistema ao fechar o viewer. Sem isso, no Android
  // a status bar e a barra de navegação ficavam escondidas (immersiveSticky)
  // no perfil e no resto do app depois de ver um story pelo avatar.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );
}

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  /// Seção a destacar ao abrir (ex.: `awards`, vindo da notificação de prêmio).
  final String? section;

  const ProfileScreen({super.key, required this.userId, this.section});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // Abas (só ícones): grade · vídeos · textos · reposts · galeria.
  // A Vitrine NUNCA fica lado a lado com posts/vídeos/galeria — ela abre
  // como página dedicada fullscreen (/shop/creator/:userId), estilo TikTok
  // Shop, acessível pelo ícone de loja no AppBar.
  static const int _tabGrid = 0;
  static const int _tabTexts = 2;
  static const int _tabCount = 5;

  late final TabController _tabController;

  /// A aba inicial é escolhida uma única vez, quando os posts chegam.
  bool _autoTabDone = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    // O perfil pode ser aberto de dentro da live ("Ver perfil" / toque no
    // chat), que roda em immersiveSticky. Sem isto, no Android o perfil
    // abria SEM status bar e SEM barra de navegação. A live reaplica o
    // modo imersivo quando volta a ser a tela atual.
    if (defaultTargetPlatform == TargetPlatform.android) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
    // Posts já em cache: decide a aba logo no primeiro quadro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(profileViewModelProvider(widget.userId))
          .posts
          .whenData(_pickInitialTab);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Abre na aba que tem conteúdo: a grade primeiro; se a pessoa só tem
  /// posts de texto, vai direto para a aba de textos (antes o perfil abria
  /// numa aba vazia e parecia sem nada).
  void _pickInitialTab(List<Post> posts) {
    if (_autoTabDone) return;
    _autoTabDone = true;
    if (_tabController.index != _tabGrid) return; // pessoa já trocou de aba
    final hasMedia = posts.any((p) => (p.imageUrl ?? '').isNotEmpty);
    final hasText = posts.any((p) => (p.imageUrl ?? '').isEmpty);
    if (!hasMedia && hasText) _tabController.index = _tabTexts;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider(widget.userId));
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final isMe = currentUserId == widget.userId;
    final hidden =
        ref.watch(hiddenUsersProvider).value ?? const HiddenUsersState();

    ref.listen<AsyncValue<List<Post>>>(
      profileViewModelProvider(widget.userId).select((st) => st.posts),
      (_, next) => next.whenData(_pickInitialTab),
    );

    // Bloqueio (recíproco): nada do perfil aparece. Quem bloqueou pode desfazer.
    if (!isMe && hidden.isBlocked(widget.userId)) {
      return _BlockedProfileView(
        userId: widget.userId,
        blockedByMe: hidden.blockedByMe.contains(widget.userId),
      );
    }

    // Vitrine: busca a vitrine PÚBLICA do usuário visitado (`widget.userId`)
    // via endpoint sem autenticação — funciona tanto no próprio perfil
    // quanto no de terceiros. Usado apenas para decidir se mostramos o
    // ícone de loja no AppBar — os produtos em si são exibidos na página
    // dedicada /shop/creator/:userId (ShopVitrinePage), nunca nas abas.
    final storefrontAsync = ref.watch(
      storefrontProductsProvider(widget.userId),
    );
    final products = storefrontAsync.maybeWhen(
      data: (p) => p,
      orElse: () => const <Product>[],
    );

    final s = S.of(context);
    final colors = context.colors;
    // Conta privada que eu não sigo: só o cabeçalho + bloco de cadeado.
    final locked =
        !isMe &&
        !(ref.watch(userPrivacyProvider(widget.userId)).value?.canViewContent ??
            true);
    final tabs = <Tab>[
      _iconTab(LucideIcons.layoutGrid, s.profileTabGrid),
      _iconTab(LucideIcons.clapperboard, s.profileTabVideos),
      _iconTab(LucideIcons.textAlignStart, s.profileTabTexts),
      _iconTab(LucideIcons.repeat2, s.profileTabReposts),
      _iconTab(LucideIcons.images, s.profileTabGallery),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                backgroundColor: colors.background,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                ),
                // No PRÓPRIO perfil não mostramos "@username" no título — é
                // redundante. Em perfis de terceiros mantemos o "@username",
                // útil para saber de quem é o perfil ao rolar.
                title: isMe
                    ? null
                    : profileState.profile.maybeWhen(
                        data: (p) {
                          final handle = _realHandle(p.username);
                          if (handle == null) return const SizedBox.shrink();
                          return Text(
                            '@$handle',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
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
                        color: colors.textPrimary,
                        size: 22,
                      ),
                      tooltip: s.profileTooltipFindFriends,
                      onPressed: () => context.push('/find-friends'),
                    ),
                  if (products.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        LucideIcons.store,
                        color: colors.textPrimary,
                        size: 22,
                      ),
                      tooltip: s.profileTooltipShop,
                      // Vitrine é sempre uma página dedicada fullscreen (estilo
                      // TikTok Shop) — nunca uma aba ao lado de posts/vídeos.
                      onPressed: () =>
                          context.push('/shop/creator/${widget.userId}'),
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
                                LucideIcons.bell,
                                color: colors.textPrimary,
                                size: 22,
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
                                    color: colors.danger,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colors.background,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    unread > 99 ? '99+' : unread.toString(),
                                    style: TextStyle(
                                      color: colors.textOnAccent,
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
                  IconButton(
                    icon: Icon(
                      isMe ? LucideIcons.menu : LucideIcons.ellipsisVertical,
                      color: colors.textPrimary,
                      size: 22,
                    ),
                    onPressed: () => _showOptions(context, isMe),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  userId: widget.userId,
                  isMe: isMe,
                  profileState: profileState,
                  section: widget.section,
                  onShare: () => _shareProfile(context),
                ),
              ),
              if (!locked)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: colors.textPrimary,
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: colors.divider,
                      labelColor: colors.textPrimary,
                      unselectedLabelColor: colors.textTertiary,
                      splashFactory: NoSplash.splashFactory,
                      tabs: tabs,
                    ),
                    colors.background,
                  ),
                ),
            ],
            body: RefreshIndicator(
              onRefresh: () {
                ref.invalidate(profileRepostsProvider(widget.userId));
                return ref
                    .read(profileViewModelProvider(widget.userId).notifier)
                    .refresh();
              },
              color: colors.accentPrimary,
              child: locked
                  ? const _PrivateLockBlock()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        ProfileVideosGrid(
                          userId: widget.userId,
                          isMe: isMe,
                          postsState: profileState.posts,
                          videosOnly: false,
                        ),
                        ProfileVideosGrid(
                          userId: widget.userId,
                          isMe: isMe,
                          postsState: profileState.posts,
                        ),
                        _TextPostsList(
                          postsState: profileState.posts,
                          isMe: isMe,
                        ),
                        _RepostsList(userId: widget.userId, isMe: isMe),
                        ProfileGalleryGrid(userId: widget.userId, isMe: isMe),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Aba só com ícone; o nome fica para leitores de tela.
  Tab _iconTab(IconData icon, String label) => Tab(
    height: 46,
    child: Semantics(
      label: label,
      child: Tooltip(message: label, child: Icon(icon, size: 22)),
    ),
  );

  // ---- Sprint 3: Share / Block / Report --------------------------------
  Future<void> _shareProfile(BuildContext context) async {
    final profile = ref
        .read(profileViewModelProvider(widget.userId))
        .profile
        .value;
    final handle = _realHandle(profile?.username) ?? widget.userId;
    final name = profile?.displayName ?? handle;
    final url = 'https://brawe.app/connect/u/$handle';
    final text = S.of(context).profileShareText(name, url);
    if (!context.mounted) return;
    try {
      await ShareSheet.show(
        context,
        ShareTarget(kind: ShareKind.profile, url: url, shareText: text),
      );
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
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.danger,
              foregroundColor: context.colors.textOnAccent,
            ),
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
      await ref
          .read(hiddenUsersProvider.notifier)
          .block(slug: slug, userId: widget.userId);
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

  Future<void> _toggleMute(BuildContext context, bool muted) async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name =
        ref
            .read(profileViewModelProvider(widget.userId))
            .profile
            .value
            ?.username ??
        '';
    try {
      final notifier = ref.read(hiddenUsersProvider.notifier);
      if (muted) {
        await notifier.unmute(widget.userId);
      } else {
        await notifier.mute(widget.userId);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(muted ? s.relShownSnack(name) : s.relHiddenSnack(name)),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.relActionError)));
    }
  }

  Future<void> _toggleRestrict(BuildContext context, bool restricted) async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(privacyUxServiceProvider);
    if (!restricted) {
      // Primeira vez: explica o que acontece antes de restringir.
      var seen = false;
      try {
        final prefs = await SharedPreferences.getInstance();
        seen = prefs.getBool('priv_restrict_intro_seen') ?? false;
        if (!seen) {
          if (!context.mounted) return;
          final ok = await _showInfoSheet(
            context,
            icon: LucideIcons.userRoundMinus,
            title: s.privUxRestrictIntroTitle,
            body: s.privUxRestrictIntroBody,
            confirm: s.privUxRestrict,
            cancel: s.actionCancel,
          );
          if (ok != true) return;
          await prefs.setBool('priv_restrict_intro_seen', true);
        }
      } catch (_) {}
    }
    try {
      await service.setRestricted(widget.userId, !restricted);
      ref.invalidate(userPrivacyProvider(widget.userId));
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            restricted ? s.privUxUnrestrictedSnack : s.privUxRestrictedSnack,
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.relActionError)));
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
      useRootNavigator: true,
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
            ReportChildSafetyTile(
              onTap: () {
                Navigator.of(ctx).pop();
                _submitReport(context, kReportReasonChildSafety);
              },
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
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final s = S.of(ctx);
        // Fecha a folha e executa a ação com o context da tela.
        VoidCallback go(VoidCallback action) => () {
          Navigator.of(ctx).pop();
          action();
        };

        if (!isMe) {
          return ProfileMenuSheet(
            children: [
              ProfileMenuGroup(
                title: s.menuSectionProfile,
                items: [
                  ProfileMenuItem(
                    icon: LucideIcons.send,
                    color: context.colors.accentPrimary,
                    title: s.profileOptionShareProfile,
                    onTap: go(() => _shareProfile(context)),
                  ),
                  ProfileMenuItem(
                    icon: LucideIcons.link,
                    color: context.colors.accentSecondary,
                    title: s.profileOptionCopyLink,
                    showChevron: false,
                    onTap: go(() => _copyProfileLink(context)),
                  ),
                ],
              ),
              ProfileMenuGroup(
                title: s.menuSectionPrivacy,
                items: [
                  Consumer(
                    builder: (context, ref, _) {
                      final muted =
                          (ref.watch(hiddenUsersProvider).value ??
                                  const HiddenUsersState())
                              .muted
                              .contains(widget.userId);
                      return ProfileMenuItem(
                        icon: muted ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: context.colors.textSecondary,
                        title: muted ? s.relShowPosts : s.relHidePosts,
                        showChevron: false,
                        onTap: go(() => _toggleMute(context, muted)),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final restricted =
                          ref
                              .watch(userPrivacyProvider(widget.userId))
                              .value
                              ?.isRestricted ??
                          false;
                      return ProfileMenuItem(
                        icon: LucideIcons.userRoundMinus,
                        color: context.colors.textSecondary,
                        title: restricted ? s.privUxUnrestrict : s.privUxRestrict,
                        showChevron: false,
                        onTap: go(() => _toggleRestrict(context, restricted)),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: LucideIcons.ban,
                    color: context.colors.warning,
                    title: s.profileBlockTitle,
                    showChevron: false,
                    onTap: go(() => _confirmBlock(context)),
                  ),
                  ProfileMenuItem(
                    icon: LucideIcons.flag,
                    color: context.colors.danger,
                    title: s.profileOptionReport,
                    destructive: true,
                    onTap: go(() => _showReportSheet(context)),
                  ),
                ],
              ),
            ],
          );
        }

        return Consumer(
          builder: (ctx, ref, _) {
            final isCreator = ref.watch(myCreatorProfileProvider).value != null;
            return ProfileMenuSheet(
              children: [
                ProfileMenuGroup(
                  title: s.menuSectionProgress,
                  items: [
                    ProfileMenuItem(
                      icon: LucideIcons.trophy,
                      color: context.colors.accentGold,
                      title: s.profileOptionDailyQuests,
                      subtitle: s.menuQuestsSubtitle,
                      onTap: go(() => context.push('/quests')),
                    ),
                    ProfileMenuItem(
                      icon: LucideIcons.medal,
                      color: context.colors.accentSecondary,
                      title: s.gifterLevelTitle,
                      subtitle: s.menuLevelSubtitle,
                      onTap: go(() => context.push('/gifter-level')),
                    ),
                  ],
                ),
                if (kEnableMonetization)
                  ProfileMenuGroup(
                    title: s.menuSectionMoney,
                    items: [
                      ProfileMenuItem(
                        icon: LucideIcons.wallet,
                        color: context.colors.success,
                        title: s.profileOptionWallet,
                        subtitle: s.menuWalletSubtitle,
                        onTap: go(() => context.push('/wallet')),
                      ),
                    ],
                  ),
                ProfileMenuGroup(
                  title: s.menuSectionCreator,
                  items: [
                    ProfileMenuItem(
                      icon: LucideIcons.crown,
                      color: context.colors.accentGold,
                      title: isCreator
                          ? s.creatorDashboardTitle
                          : s.creatorProgramTitle,
                      subtitle: isCreator
                          ? s.menuCreatorSubtitleMember
                          : s.menuCreatorSubtitleJoin,
                      onTap: go(
                        () => context.push(
                          isCreator ? '/creator/dashboard' : '/creator/intro',
                        ),
                      ),
                    ),
                  ],
                ),
                ProfileMenuGroup(
                  title: s.menuSectionAccount,
                  items: [
                    ProfileMenuItem(
                      icon: LucideIcons.settings,
                      color: context.colors.textSecondary,
                      title: s.profileOptionSettings,
                      subtitle: s.menuSettingsSubtitle,
                      onTap: go(() => context.push('/settings')),
                    ),
                    ProfileMenuItem(
                      icon: LucideIcons.logOut,
                      color: context.colors.danger,
                      title: s.profileOptionLogout,
                      destructive: true,
                      onTap: go(() => _confirmLogout(context)),
                    ),
                  ],
                ),
              ],
            );
          },
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
            style: TextButton.styleFrom(
              foregroundColor: context.colors.textSecondary,
            ),
            child: Text(S.of(ctx).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
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
  final String? section;
  final VoidCallback onShare;

  const _ProfileHeader({
    required this.userId,
    required this.isMe,
    required this.profileState,
    required this.onShare,
    this.section,
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
    final colors = context.colors;
    final s = S.of(context);
    final stats = profileState.stats.asData?.value;
    final privacy =
        (!isMe ? ref.watch(userPrivacyProvider(userId)).value : null) ??
        const UserPrivacy();
    void openFollows(String tab) {
      if (!isMe && !privacy.canViewFollowLists) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(s.privUxFollowListsHidden)));
        return;
      }
      context.push('/follows/$userId?tab=$tab');
    }

    final postsCount = profileState.posts.asData?.value.length;
    final joinedAt = _joinDate(context, profile);
    final handle = _realHandle(profile.username);
    final bio = profile.bio?.trim() ?? '';

    final storiesAsync = ref.watch(userStoriesProvider(userId));
    final stories = storiesAsync.asData?.value ?? const <Story>[];
    final hasStories = stories.isNotEmpty;
    final hasUnviewed = stories.any((st) => !st.isSeen);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Banner / Capa + avatar sobreposto ─────────────────────────
        _BannerSection(
          userId: userId,
          bannerUrl: profile.bannerUrl,
          avatarUrl: profile.avatarUrl,
          initials: _initialsFor(profile),
          hasStories: hasStories,
          hasUnviewedStories: hasUnviewed,
          frameUrl: UserAward.mostPrestigious(
            profile.activeAwards.where((a) => a.frameUrl != null).toList(),
          )?.frameUrl,
          isLive: !isMe && profile.isLive,
          onAvatarTap:
              !isMe && profile.isLive && (profile.liveRoomId ?? '').isNotEmpty
              ? () => context.push('/live/${profile.liveRoomId}')
              : hasStories
              ? () => _openStoryViewer(context, ref, stories)
              : null,
        ),

        // ── Números ao lado do avatar: posts · seguidores · seguindo ───
        // O avatar (98 px) invade 48 px abaixo do banner; os números ocupam
        // o espaço à direita dele.
        SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 126, right: 16),
            child: Row(
              children: [
                _StatBlock(
                  value: postsCount == null ? '–' : _fmtCount(postsCount),
                  label: s.profileTabPosts,
                ),
                _StatBlock(
                  value: stats == null ? '–' : _fmtCount(stats.followersCount),
                  label: s.profileStatFollowers,
                  onTap: () => openFollows('followers'),
                ),
                _StatBlock(
                  value: stats == null ? '–' : _fmtCount(stats.followingCount),
                  label: s.profileStatFollowing,
                  onTap: () => openFollows('following'),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Nome + verificado ──────────────────────────────────
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.displayName ??
                          profile.username ??
                          s.profileUserFallback,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile.isVerified) const VerifiedBadge(size: 18, gap: 6),
                  CreatorTierBadgeForUser(userId: profile.id, size: 18),
                ],
              ),
              if (handle != null || joinedAt != null) ...[
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    if (handle != null)
                      Text(
                        '@$handle',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    if (joinedAt != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            color: colors.textTertiary,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            s.profileJoinedAt(joinedAt),
                            style: TextStyle(
                              color: colors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],

              if (bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bio,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],

              // ── Prêmios ativos ───────────────────────────────────────
              if (profile.activeAwards.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AwardsSection(
                  awards: profile.activeAwards,
                  highlight: section == 'awards',
                ),
              ],

              // ── Links sociais ────────────────────────────────────────
              if (profile.socialLinks != null &&
                  profile.socialLinks!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _SocialLinks(links: profile.socialLinks!),
              ],

              const SizedBox(height: 14),

              // Nota: o badge "Parceiro verificado" NÃO aparece aqui — ele
              // pertence à página dedicada da vitrine (ShopVitrinePage).
              _buildActions(context, ref, profile),
            ],
          ),
        ),
      ],
    );
  }

  ButtonStyle _primaryStyle(BuildContext context) => FilledButton.styleFrom(
    backgroundColor: context.colors.accentPrimary,
    foregroundColor: context.colors.textOnAccent,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );

  ButtonStyle _tonalStyle(BuildContext context) => FilledButton.styleFrom(
    backgroundColor: context.colors.surfaceHighest,
    foregroundColor: context.colors.textPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );

  Widget _buildActions(BuildContext context, WidgetRef ref, Profile profile) {
    final s = S.of(context);
    const height = 44.0;

    if (isMe) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: height,
              child: FilledButton(
                style: _tonalStyle(context),
                onPressed: () => context.push('/edit-profile'),
                child: Text(s.profileEditButton),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: height,
            height: height,
            child: Tooltip(
              message: s.actionShare,
              child: FilledButton(
                style: _tonalStyle(context).copyWith(
                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                ),
                onPressed: onShare,
                child: const Icon(LucideIcons.send, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    final followState = ref.watch(followViewModelProvider(userId));
    final isFollowing = followState.asData?.value ?? false;
    final requested =
        !isFollowing && ref.watch(followRequestedProvider(userId));
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: FilledButton(
              style: (isFollowing || requested)
                  ? _tonalStyle(context)
                  : _primaryStyle(context),
              onPressed: followState.isLoading
                  ? null
                  : requested
                  ? () => _confirmCancelRequest(context, ref)
                  : () => ref
                        .read(followViewModelProvider(userId).notifier)
                        .toggleFollow(),
              child: Text(
                isFollowing
                    ? s.actionUnfollow
                    : requested
                    ? s.privUxRequested
                    : s.actionFollow,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: height,
            child: FilledButton.icon(
              style: _tonalStyle(context),
              onPressed: () => _openConversation(context, ref, profile),
              icon: const Icon(LucideIcons.messageCircle, size: 18),
              label: Text(s.profileMessageButton),
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
    // Captura antes do await: o aviso aparece nesta tela.
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    final privacy = ref.read(userPrivacyProvider(userId)).value;
    if (privacy != null && !privacy.canMessage) {
      messenger.showSnackBar(SnackBar(content: Text(s.privUxMessagesNotAllowed)));
      return;
    }
    try {
      final convId = await ref
          .read(chatRepositoryProvider)
          .startConversation(participantId: profile.id);
      if (!context.mounted) return;
      context.push(
        '/chat/$convId',
        extra: {
          'participantName':
              profile.displayName ?? profile.username ?? s.profileChatFallback,
          'participantAvatarUrl': profile.avatarUrl,
          'participantId': profile.id,
        },
      );
    } catch (e) {
      final server = PrivacyApiError.messageFor(e, {'messages_not_allowed'});
      messenger.showSnackBar(
        SnackBar(content: Text(server ?? s.profileOpenConversationError(e))),
      );
    }
  }

  Future<void> _confirmCancelRequest(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _showInfoSheet(
      context,
      icon: LucideIcons.userRoundX,
      title: s.privUxCancelRequestTitle,
      body: s.privUxCancelRequestBody,
      confirm: s.privUxCancelRequestConfirm,
      cancel: s.privUxKeepRequest,
      destructive: true,
    );
    if (ok != true) return;
    try {
      await ref.read(privacyUxServiceProvider).cancelSentRequest(userId);
      ref.read(followRequestedProvider(userId).notifier).set(false);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.relActionError)));
    }
  }

  /// Mês e ano de entrada, já no idioma do app (ex.: "novembro de 2024").
  String? _joinDate(BuildContext context, Profile profile) {
    if (profile.createdAt == null || profile.createdAt!.isEmpty) return null;
    try {
      final dt = DateTime.parse(profile.createdAt!);
      return MaterialLocalizations.of(context).formatMonthYear(dt);
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

String _fmtCount(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return '$v';
}

// ── Banner + Avatar sobrepostos ──────────────────────────────────────────────
class _BannerSection extends ConsumerStatefulWidget {
  const _BannerSection({
    required this.userId,
    required this.bannerUrl,
    required this.avatarUrl,
    required this.initials,
    this.hasStories = false,
    this.hasUnviewedStories = false,
    this.onAvatarTap,
    this.frameUrl,
    this.isLive = false,
  });
  final String? frameUrl;

  /// Ao vivo agora: anel vermelho + selo "AO VIVO"; o toque abre a live.
  final bool isLive;
  final String userId;
  final String? bannerUrl;
  final String? avatarUrl;
  final String initials;
  final bool hasStories;
  final bool hasUnviewedStories;
  final VoidCallback? onAvatarTap;

  @override
  ConsumerState<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends ConsumerState<_BannerSection> {
  /// Guardado no initState: `ref` não pode ser usado no dispose (o widget
  /// já está desmontado → StateError "Using ref when unmounted").
  late final PresenceCache _presence;

  @override
  void initState() {
    super.initState();
    // Registrar userId para polling de presença
    _presence = ref.read(presenceCacheProvider.notifier);
    _presence.watch(widget.userId);
  }

  @override
  void didUpdateWidget(_BannerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _presence.unwatch(oldWidget.userId);
      _presence.watch(widget.userId);
    }
  }

  @override
  void dispose() {
    _presence.unwatch(widget.userId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bannerUrl = widget.bannerUrl;
    final avatarUrl = widget.avatarUrl;
    final hasStories = widget.hasStories;
    final hasUnviewedStories = widget.hasUnviewedStories;

    final hasBanner = bannerUrl != null && bannerUrl.isNotEmpty;
    // Sem banner: usamos uma faixa baixa só para acomodar o avatar sobreposto.
    final bannerHeight = hasBanner ? 150.0 : 70.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner (ou faixa neutra quando não há imagem)
        Container(
          height: bannerHeight,
          width: double.infinity,
          color: hasBanner ? colors.surfaceHighest : colors.background,
          child: hasBanner
              ? CachedNetworkImage(
                  memCacheWidth: context.decodeScreenPx,
                  imageUrl: bannerUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                )
              : null,
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
                onTap: widget.onAvatarTap,
                child: AvatarFrame(
                  size: 98,
                  overflow: 0.14,
                  frameUrl: widget.frameUrl,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: !widget.isLive && hasUnviewedStories
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppColors.brandGradient,
                            )
                          : null,
                      color: widget.isLive
                          ? AppColors.liveRed
                          : hasUnviewedStories
                          ? null
                          : hasStories
                          ? colors.border
                          : Colors.transparent,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.background,
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 86,
                          height: 86,
                          child: _Avatar(
                            url: avatarUrl,
                            initials: widget.initials,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // ── Indicador online (com dados reais do presenceCacheProvider) ──
              if (!widget.isLive) _OnlineIndicator(userId: widget.userId),
              // ── Selo AO VIVO na base da foto ──
              if (widget.isLive)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -6,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.liveRed,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: colors.background,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          S.of(context).liveBadge,
                          style: const TextStyle(
                            // Sobre o vermelho da live (cor fixa de marca).
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
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

// ── Número grande + rótulo pequeno (posts · seguidores · seguindo) ──────────
class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label, this.onTap});
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Semantics(
        button: onTap != null,
        label: '$value $label',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
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

// ── Links Sociais (chips neutros, sem cor de marca) ──────────────────────────
class _SocialLinks extends StatelessWidget {
  const _SocialLinks({required this.links});
  final Map<String, String> links;

  // Lucide não tem ícones de marca: usamos símbolos neutros por rede.
  static const Map<String, (IconData, String)> _config = {
    'website': (LucideIcons.globe, 'Website'),
    'site': (LucideIcons.globe, 'Site'),
    'email': (LucideIcons.mail, 'Email'),
    'instagram': (LucideIcons.camera, 'Instagram'),
    'twitter': (LucideIcons.atSign, 'X'),
    'x': (LucideIcons.atSign, 'X'),
    'youtube': (LucideIcons.circlePlay, 'YouTube'),
    'tiktok': (LucideIcons.music2, 'TikTok'),
    'telegram': (LucideIcons.send, 'Telegram'),
    'whatsapp': (LucideIcons.messageCircle, 'WhatsApp'),
    'twitch': (LucideIcons.tv, 'Twitch'),
    'kick': (LucideIcons.gamepad2, 'Kick'),
    'spotify': (LucideIcons.music, 'Spotify'),
    'linkedin': (LucideIcons.briefcase, 'LinkedIn'),
    'github': (LucideIcons.code, 'GitHub'),
    'threads': (LucideIcons.atSign, 'Threads'),
    'snapchat': (LucideIcons.camera, 'Snapchat'),
    'discord': (LucideIcons.messageSquare, 'Discord'),
    'facebook': (LucideIcons.users, 'Facebook'),
  };

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
          final cfg = _config[key] ?? (LucideIcons.globe, e.key);
          return _SocialPill(
            network: key,
            icon: cfg.$1,
            label: cfg.$2,
            url: e.value,
          );
        }),
        ...custom.map(
          (c) => _SocialPill(
            network: 'website',
            icon: _customIconFor(c.icon),
            label: c.title.isEmpty ? c.url : c.title,
            url: c.url,
          ),
        ),
      ],
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({
    required this.network,
    required this.icon,
    required this.label,
    required this.url,
  });
  final String network;
  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _launchSocial(network, url),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
/// (`CUSTOM_ICON_PALETTE`), em Lucide.
IconData _customIconFor(String name) {
  switch (name) {
    case 'ShoppingBag':
      return LucideIcons.shoppingBag;
    case 'Briefcase':
      return LucideIcons.briefcase;
    case 'Heart':
      return LucideIcons.heart;
    case 'Star':
      return LucideIcons.star;
    case 'Music':
      return LucideIcons.music;
    case 'Book':
      return LucideIcons.bookOpen;
    case 'Coffee':
      return LucideIcons.coffee;
    case 'Award':
      return LucideIcons.award;
    case 'Zap':
      return LucideIcons.zap;
    case 'Mic':
      return LucideIcons.mic;
    case 'Tv':
      return LucideIcons.tv;
    case 'Calendar':
      return LucideIcons.calendar;
    case 'Mail':
      return LucideIcons.mail;
    case 'Phone':
      return LucideIcons.phone;
    case 'MessageSquare':
      return LucideIcons.messageSquare;
    case 'MessageCircle':
      return LucideIcons.messageCircle;
    case 'DollarSign':
      return LucideIcons.dollarSign;
    case 'CreditCard':
      return LucideIcons.creditCard;
    case 'LinkIcon':
      return LucideIcons.link;
    case 'Globe':
    default:
      return LucideIcons.globe;
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
        final msg = Uri.encodeComponent('Oi, vim pela Brawe!');
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
      memCacheWidth: context.decodePx(160),
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      // Cache por 7 dias, mas sempre revalida se a URL mudou
      cacheKey: url,
      placeholder: (_, __) => Container(
        color: context.colors.surfaceElevated,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.accentPrimary,
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
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accentPrimary, colors.accentSecondary],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: colors.textOnAccent,
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
    final fill = context.colors.surfaceHighest;
    Widget bar({double w = 120, double h = 14}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 98,
            height: 98,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
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
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.cloudOff, color: colors.danger, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).profileLoadError,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).profileLoadErrorHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: Text(S.of(context).profileRetry),
              style: FilledButton.styleFrom(
                backgroundColor: colors.surfaceHighest,
                foregroundColor: colors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── POSTS DE TEXTO (lista, estilo feed) ─────────────────────────────────────
/// Posts sem mídia. Os que têm foto/vídeo aparecem na grade e em Vídeos.
class _TextPostsList extends StatelessWidget {
  final AsyncValue<List<Post>> postsState;
  final bool isMe;
  const _TextPostsList({required this.postsState, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return postsState.when(
      data: (all) {
        final posts = all
            .where((p) => (p.imageUrl ?? '').isEmpty)
            .toList(growable: false);
        if (posts.isEmpty) {
          return ProfileEmptyState(
            icon: LucideIcons.textAlignStart,
            title: isMe ? s.profileEmptyMeTexts : s.profileNoTextPosts,
            actionLabel: isMe ? s.profileEmptyMeAction : null,
            onAction: isMe ? () => showProfileCreatePost(context) : null,
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          itemCount: posts.length,
          separatorBuilder: (_, __) =>
              Divider(color: context.colors.divider, height: 1),
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: context.colors.accentPrimary),
      ),
      error: (_, __) => ProfileEmptyState(
        icon: LucideIcons.circleAlert,
        title: s.profilePostsLoadError,
      ),
    );
  }
}

// ── REPOSTS ─────────────────────────────────────────────────────────────────
/// Posts de outras pessoas que o usuário repostou, do mais recente ao mais
/// antigo. O cartão já mostra "Fulano repostou" acima do post original.
class _RepostsList extends ConsumerWidget {
  final String userId;
  final bool isMe;
  const _RepostsList({required this.userId, required this.isMe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    return ref
        .watch(profileRepostsProvider(userId))
        .when(
          data: (posts) {
            if (posts.isEmpty) {
              return ProfileEmptyState(
                icon: LucideIcons.repeat2,
                title: s.profileNoReposts,
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: posts.length,
              separatorBuilder: (_, __) =>
                  Divider(color: context.colors.divider, height: 1),
              itemBuilder: (context, index) => PostCard(post: posts[index]),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              color: context.colors.accentPrimary,
            ),
          ),
          error: (_, __) => ProfileEmptyState(
            icon: LucideIcons.circleAlert,
            title: s.profilePostsLoadError,
          ),
        );
  }
}

// ── SLIVER DELEGATE ─────────────────────────────────────────────────────────
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._background);
  final TabBar _tabBar;
  final Color _background;

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
    return Container(color: _background, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    // Precisa reconstruir quando a TabBar ou a cor mudam (troca de tema) —
    // senão o header persistente fica "preso" no tema anterior.
    return oldDelegate._tabBar != _tabBar ||
        oldDelegate._background != _background;
  }
}

// ── Indicador de Presença Online ─────────────────────────────────────────────
/// Widget que exibe um ponto verde no canto inferior direito do avatar
/// quando o usuário está online. Usa dados reais do presenceCacheProvider.
class _OnlineIndicator extends ConsumerWidget {
  const _OnlineIndicator({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(presenceCacheProvider);
    final userPresence = presence[userId];
    final isOnline = userPresence?.isOnline ?? false;
    // A pessoa desligou o status de atividade: nunca mostra o ponto verde.
    final showActivity =
        ref.watch(userPrivacyProvider(userId)).value?.showActivity ?? true;

    if (!isOnline || !showActivity) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 4,
      bottom: 4,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: context.colors.success,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.background, width: 2),
          boxShadow: [
            BoxShadow(
              color: context.colors.success.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

/// Perfil com bloqueio: "Você bloqueou" (com Desbloquear) ou indisponível.
class _BlockedProfileView extends ConsumerStatefulWidget {
  const _BlockedProfileView({required this.userId, required this.blockedByMe});

  final String userId;
  final bool blockedByMe;

  @override
  ConsumerState<_BlockedProfileView> createState() =>
      _BlockedProfileViewState();
}

class _BlockedProfileViewState extends ConsumerState<_BlockedProfileView> {
  bool _busy = false;

  Future<void> _unblock() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(hiddenUsersProvider.notifier)
          .unblock(slug: widget.userId, userId: widget.userId);
      ref.invalidate(profileViewModelProvider(widget.userId));
      messenger.showSnackBar(SnackBar(content: Text(s.profileUnblocked)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.relActionError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.colors.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.ban,
                size: 56,
                color: context.colors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.blockedByMe
                    ? s.profileBlockedState
                    : s.profileUnavailable,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.blockedByMe
                    ? s.profileBlockedStateHint
                    : s.profileUnavailableHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (widget.blockedByMe) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _busy ? null : _unblock,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(s.profileUnblock),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Prêmios ativos (chips com selo, nome e validade) ────────────────────────
class _AwardsSection extends StatefulWidget {
  const _AwardsSection({required this.awards, this.highlight = false});

  final List<UserAward> awards;
  final bool highlight;

  @override
  State<_AwardsSection> createState() => _AwardsSectionState();
}

class _AwardsSectionState extends State<_AwardsSection> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.highlight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _key.currentContext;
        if (ctx != null && mounted) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
            alignment: 0.2,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final awards = widget.awards.where((a) => !a.isExpired(now)).toList();
    if (awards.isEmpty) return const SizedBox.shrink();
    return Column(
      key: _key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.award, size: 15, color: colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              s.profileAwardsTitle,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in awards)
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width - 32,
                ),
                padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
                decoration: BoxDecoration(
                  color: awardColor(
                    a.badgeColor,
                  ).withValues(alpha: widget.highlight ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: awardColor(a.badgeColor).withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AwardBadge(award: a, height: 22),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.localizedLabel(lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (a.expiresAt != null)
                            Text(
                              s.profileAwardUntil(
                                MaterialLocalizations.of(
                                  context,
                                ).formatShortDate(a.expiresAt!),
                              ),
                              style: TextStyle(
                                color: colors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Folha simples de confirmação/explicação (ícone, título, texto, 2 botões).
Future<bool?> _showInfoSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  required String confirm,
  required String cancel,
  bool destructive = false,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.colors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final colors = ctx.colors;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceHighest,
                ),
                child: Icon(icon, color: colors.textPrimary, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: destructive
                        ? colors.danger
                        : colors.accentPrimary,
                    foregroundColor: colors.textOnAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(confirm),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    cancel,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Conta privada que eu não sigo: no lugar das abas e da grade.
class _PrivateLockBlock extends StatelessWidget {
  const _PrivateLockBlock();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.textPrimary, width: 2),
                  ),
                  child: Icon(
                    LucideIcons.lock,
                    color: colors.textPrimary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.privUxAccountPrivate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.privUxFollowToSee,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
