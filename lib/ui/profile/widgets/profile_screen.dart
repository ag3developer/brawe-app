import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../config/feature_flags.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/ui/follow_button.dart';
import '../../core/view_models/profile_view_model.dart';
import '../../notifications/view_models/notifications_view_model.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/post.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/profile_state.dart';
import '../../../domain/models/social_stats.dart';
import '../../feed/widgets/create_post_sheet.dart';
import '../../feed/widgets/feed_screen.dart' show PostCard;
import 'profile_gallery_grid.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
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
final userStoriesProvider =
    FutureProvider.autoDispose.family<List<Story>, String>((ref, userId) async {
  final repo = ref.watch(storiesRepositoryProvider);
  try {
    return await repo.getUserStories(userId);
  } catch (_) {
    return const <Story>[];
  }
});

void _openStoryViewer(BuildContext context, WidgetRef ref, List<Story> stories) {
  if (stories.isEmpty) return;
  // Abre no primeiro story não-visto, ou no primeiro caso todos vistos.
  final firstUnseen = stories.indexWhere((s) => !s.isSeen);
  final initial = firstUnseen >= 0 ? firstUnseen : 0;
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ForceDarkTheme(
        child: StoryViewer(
          stories: stories,
          initialIndex: initial,
          onStoryViewed: (storyId) {
            // Invalida o cache de stories desse usuário ao terminar.
            if (stories.isNotEmpty) {
              ref.invalidate(userStoriesProvider(stories.first.authorId));
            }
          },
        ),
      ),
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
  List<Product> _products = [];
  bool _isSeller = false;
  // Abas base: Posts, Galeria, Lives. +1 se for vendedor (Loja).
  int _tabCount = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // Loja desativada na v1.0 enquanto IAP não estiver implementado.
    if (!kEnableMonetization) return;
    try {
      final products = await ref
          .read(productRepositoryProvider)
          .getUserProducts(widget.userId);
      if (!mounted) return;
      final isSeller = products.isNotEmpty;
      final newCount = isSeller ? 4 : 3;
      setState(() {
        _products = products;
        _isSeller = isSeller;
        if (_tabCount != newCount) {
          _tabCount = newCount;
          _tabController?.dispose();
          _tabController = TabController(length: _tabCount, vsync: this);
        }
      });
    } catch (_) {
      // Mantém _isSeller = false e _products = [] silenciosamente
    }
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
    final products = _products;

    final tabs = <Tab>[
      const Tab(icon: Icon(Icons.article_outlined, size: 20), text: 'Posts'),
      const Tab(icon: Icon(Icons.grid_on_outlined, size: 20), text: 'Galeria'),
      const Tab(icon: Icon(Icons.live_tv_outlined, size: 20), text: 'Lives'),
      if (_isSeller)
        const Tab(
            icon: Icon(Icons.shopping_bag_outlined, size: 20), text: 'Loja'),
    ];

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: AppColors.nearBlack,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: profileState.profile.maybeWhen(
              data: (p) {
                final handle = _realHandle(p.username);
                if (handle == null) return const SizedBox.shrink();
                return Text(
                  '@$handle',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            actions: [
              if (_isSeller)
                IconButton(
                  icon: const Icon(Icons.storefront, color: Colors.white),
                  tooltip: 'Loja',
                  onPressed: () => _tabController?.animateTo(3),
                ),
              if (isMe)
                IconButton(
                  icon: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white,
                  ),
                  tooltip: 'Quests',
                  onPressed: () => context.push('/quests'),
                ),
              if (isMe)
                Consumer(
                  builder: (context, ref, _) {
                    final unread = ref
                            .watch(notificationsUnreadCountProvider)
                            .asData
                            ?.value ??
                        0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                          tooltip: 'Notificacoes',
                          onPressed: () => context.push('/notifications'),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 6,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : unread.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                  ),
                  tooltip: 'Carteira',
                  onPressed: () => context.push('/wallet'),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
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
                  isSeller: _isSeller,
                  productsCount: products.length,
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
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.coolGray,
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
              ProfileGalleryGrid(userId: widget.userId, isMe: isMe),
              _LivesGrid(livesState: profileState.lives),
              if (_isSeller) _ProductsGrid(products: products),
            ],
          ),
        ),
      ),
    );
  }

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
    final profile = ref.read(profileViewModelProvider(widget.userId)).profile.value;
    final handle = _realHandle(profile?.username) ?? widget.userId;
    final name = profile?.displayName ?? handle;
    final url = 'https://brawe.app/connect/u/$handle';
    final text = 'Confira $name no Brawe Connect: $url';
    try {
      // ignore: deprecated_member_use
      await Share.share(text, subject: name);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar.')),
      );
    }
  }

  Future<void> _copyProfileLink(BuildContext context) async {
    final profile = ref.read(profileViewModelProvider(widget.userId)).profile.value;
    final handle = _realHandle(profile?.username) ?? widget.userId;
    final url = 'https://brawe.app/connect/u/$handle';
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copiado para a área de transferência')),
    );
  }

  Future<void> _confirmBlock(BuildContext context) async {
    final profile = ref.read(profileViewModelProvider(widget.userId)).profile.value;
    final name = profile?.displayName ?? 'este usuário';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bloquear'),
        content: Text(
          'Tem certeza que deseja bloquear $name? Vocês não poderão mais '
          'trocar mensagens nem ver conteúdo um do outro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final slug = _realHandle(
              ref.read(profileViewModelProvider(widget.userId)).profile.value?.username) ??
          widget.userId;
      await ref.read(socialActionsServiceProvider).blockUser(slug);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário bloqueado.')),
      );
      if (context.canPop()) context.pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao bloquear. Tente novamente.')),
      );
    }
  }

  void _showReportSheet(BuildContext context) {
    final reasons = const [
      ('spam', 'Spam'),
      ('harassment', 'Assédio ou bullying'),
      ('inappropriate', 'Conteúdo impróprio'),
      ('impersonation', 'Falsa identidade'),
      ('other', 'Outro motivo'),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Por que está denunciando?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            for (final r in reasons)
              ListTile(
                title: Text(r.$2, style: const TextStyle(color: Colors.white)),
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
      await ref.read(socialActionsServiceProvider).report(
            targetType: 'user',
            targetId: widget.userId,
            reason: reason,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denúncia enviada. Obrigado.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao denunciar. Tente novamente.')),
      );
    }
  }

    void _showOptions(BuildContext context, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!isMe) ...[
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text('Compartilhar perfil',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _shareProfile(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.white),
                title: const Text('Copiar link',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _copyProfileLink(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.white),
                title: const Text('Bloquear',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmBlock(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text('Denunciar',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showReportSheet(context);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.emoji_events_outlined,
                    color: Colors.white),
                title: const Text('Quests diárias',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/quests');
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              if (kEnableMonetization) ...[
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white),
                  title: const Text('Carteira',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/wallet');
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
              ],
              ListTile(
                leading: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                title: const Text('Notificacoes',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/notifications');
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined,
                    color: Colors.white),
                title: const Text('Configurações',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/settings');
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              ListTile(
                leading: const Icon(Icons.logout_rounded,
                    color: AppColors.mutedRed),
                title: const Text(
                  'Sair da conta',
                  style: TextStyle(
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
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slate,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Sair da conta?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Você precisará entrar novamente para acessar sua arena.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mutedRed,
            ),
            child: const Text(
              'Sair',
              style: TextStyle(fontWeight: FontWeight.w700),
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
  final bool isSeller;
  final int productsCount;
  final ProfileState profileState;

  const _ProfileHeader({
    required this.userId,
    required this.isMe,
    required this.isSeller,
    required this.productsCount,
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
              onRetry: () => ref
                  .read(profileViewModelProvider(userId).notifier)
                  .refresh(),
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
        Builder(builder: (context) {
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
        }),

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
                      profile.displayName ?? profile.username ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified,
                        color: AppColors.electricPurple, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              if (_realHandle(profile.username) != null)
                Text(
                  '@${_realHandle(profile.username)}',
                  style: const TextStyle(
                      color: AppColors.coolGray, fontSize: 14),
                ),
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  profile.bio!,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.4),
                ),
              ],

              // ── Links sociais ────────────────────────────────────────
              if (profile.socialLinks != null &&
                  profile.socialLinks!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SocialLinks(links: profile.socialLinks!),
              ],

              const SizedBox(height: 16),

              // ── Stats card ───────────────────────────────────────────
              if (stats != null) _StatsCard(stats: stats, userId: userId),
              if (stats == null) const SizedBox(height: 8),

              // ── Data de entrada ───────────────────────────────────────
              if (joinedAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.coolGray, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Entrou em $joinedAt',
                      style: const TextStyle(
                          color: AppColors.coolGray, fontSize: 13),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // ── Ações ──────────────────────────────────────────────────
              _buildActions(context),

              if (isSeller) ...[
                const SizedBox(height: 12),
                _SellerBadge(productsCount: productsCount),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (isMe) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/edit-profile'),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Editar Perfil',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: FollowButton(userId: userId)),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/chat'),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined,
                      color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Mensagem',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _parseJoinDate(WidgetRef ref) {
    final user = ref.read(authStateProvider).value;
    if (user == null) return null;
    try {
      final dt = DateTime.parse(user.createdAt);
      const months = [
        'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
        'jul', 'ago', 'set', 'out', 'nov', 'dez'
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
          color: AppColors.nearBlack,
          child: hasBanner
              ? CachedNetworkImage(
                  imageUrl: bannerUrl!,
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.nearBlack,
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
                        color: AppColors.nearBlack, width: 2),
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

// ── Stats Card ────────────────────────────────────────────────────────────────
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatsCol(
            value: _fmt(stats.followersCount),
            label: 'Seguidores',
            valueColor: AppColors.electricPurple,
            onTap: () => context.push('/follows/$userId?tab=followers'),
          ),
          _Divider(),
          _StatsCol(
            value: _fmt(stats.followingCount),
            label: 'Seguindo',
            onTap: () => context.push('/follows/$userId?tab=following'),
          ),
          _Divider(),
          _StatsCol(value: _fmt(stats.livesCount), label: 'Lives'),
          _Divider(),
          _StatsCol(value: _fmt(stats.totalLikes), label: 'Views'),
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
        color: Colors.white.withValues(alpha: 0.08),
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
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppColors.coolGray, fontSize: 11)),
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
    'website':   _SocialLinkStyle(color: const Color(0xFF1A1428), border: const Color(0xFFB39DDB), label: 'Website',   icon: Icons.public,                 isNative: true),
    'site':      _SocialLinkStyle(color: const Color(0xFF1A1428), border: const Color(0xFFB39DDB), label: 'Site',      icon: Icons.public,                 isNative: true),
    'email':     _SocialLinkStyle(color: const Color(0xFF2A2010), border: const Color(0xFFFFB74D), label: 'Email',     icon: Icons.mail_outline,           isNative: true),
    'instagram': _SocialLinkStyle(color: const Color(0xFF2A1020), border: const Color(0xFFE1306C), label: 'Instagram', icon: FontAwesomeIcons.instagram),
    'twitter':   _SocialLinkStyle(color: const Color(0xFF0E0E0E), border: const Color(0xFFFFFFFF), label: 'X',         icon: FontAwesomeIcons.xTwitter),
    'x':         _SocialLinkStyle(color: const Color(0xFF0E0E0E), border: const Color(0xFFFFFFFF), label: 'X',         icon: FontAwesomeIcons.xTwitter),
    'youtube':   _SocialLinkStyle(color: const Color(0xFF2A0A0A), border: const Color(0xFFFF0000), label: 'YouTube',   icon: FontAwesomeIcons.youtube),
    'tiktok':    _SocialLinkStyle(color: const Color(0xFF1A1A1A), border: const Color(0xFFFFFFFF), label: 'TikTok',    icon: FontAwesomeIcons.tiktok),
    'telegram':  _SocialLinkStyle(color: const Color(0xFF0A1A2A), border: const Color(0xFF2AABEE), label: 'Telegram',  icon: FontAwesomeIcons.telegram),
    'whatsapp':  _SocialLinkStyle(color: const Color(0xFF0A3A1A), border: const Color(0xFF25D366), label: 'WhatsApp',  icon: FontAwesomeIcons.whatsapp),
    'twitch':    _SocialLinkStyle(color: const Color(0xFF1A0A2A), border: const Color(0xFF9146FF), label: 'Twitch',    icon: FontAwesomeIcons.twitch),
    'kick':      _SocialLinkStyle(color: const Color(0xFF0A2A14), border: const Color(0xFF53FC18), label: 'Kick',      icon: Icons.sports_esports,         isNative: true),
    'spotify':   _SocialLinkStyle(color: const Color(0xFF0A1F0E), border: const Color(0xFF1DB954), label: 'Spotify',   icon: FontAwesomeIcons.spotify),
    'linkedin':  _SocialLinkStyle(color: const Color(0xFF0A1F2A), border: const Color(0xFF0A66C2), label: 'LinkedIn',  icon: FontAwesomeIcons.linkedinIn),
    'github':    _SocialLinkStyle(color: const Color(0xFF14141A), border: const Color(0xFFCCCCCC), label: 'GitHub',    icon: FontAwesomeIcons.github),
    'threads':   _SocialLinkStyle(color: const Color(0xFF14141A), border: const Color(0xFFFFFFFF), label: 'Threads',   icon: FontAwesomeIcons.threads),
    'snapchat':  _SocialLinkStyle(color: const Color(0xFF2A2A0A), border: const Color(0xFFFFFC00), label: 'Snapchat',  icon: FontAwesomeIcons.snapchat),
    'discord':   _SocialLinkStyle(color: const Color(0xFF14142A), border: const Color(0xFF5865F2), label: 'Discord',   icon: FontAwesomeIcons.discord),
    'facebook':  _SocialLinkStyle(color: const Color(0xFF0A1A3A), border: const Color(0xFF1877F2), label: 'Facebook',  icon: FontAwesomeIcons.facebook),
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
  final IconData icon;
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
  const _CustomLink({required this.title, required this.url, required this.icon});
}

List<_CustomLink> _parseCustomLinks(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((m) => _CustomLink(
              title: (m['title'] ?? '').toString().trim(),
              url: (m['url'] ?? '').toString().trim(),
              icon: (m['icon'] ?? 'Globe').toString(),
            ))
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
    case 'ShoppingBag':    return Icons.shopping_bag_outlined;
    case 'Briefcase':      return Icons.work_outline;
    case 'Heart':          return Icons.favorite_border;
    case 'Star':           return Icons.star_outline;
    case 'Music':          return Icons.music_note_outlined;
    case 'Book':           return Icons.menu_book_outlined;
    case 'Coffee':         return Icons.local_cafe_outlined;
    case 'Award':          return Icons.emoji_events_outlined;
    case 'Zap':            return Icons.flash_on_outlined;
    case 'Mic':            return Icons.mic_none_outlined;
    case 'Tv':             return Icons.tv_outlined;
    case 'Calendar':       return Icons.calendar_today_outlined;
    case 'Mail':           return Icons.mail_outline;
    case 'Phone':          return Icons.phone_outlined;
    case 'MessageSquare':  return Icons.chat_bubble_outline;
    case 'MessageCircle':  return Icons.chat_outlined;
    case 'DollarSign':     return Icons.attach_money_outlined;
    case 'CreditCard':     return Icons.credit_card_outlined;
    case 'LinkIcon':       return Icons.link_rounded;
    case 'Globe':
    default:               return Icons.public;
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
        url = handle.startsWith('discord.gg/') || handle.startsWith('discord.com/')
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
  const _SocialPill({required this.network, required this.style, required this.url});
  final String network;
  final _SocialLinkStyle style;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchSocial(network, url),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: style.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (style.isNative)
              Icon(style.icon, color: style.border, size: 14)
            else
              FaIcon(style.icon, color: style.border, size: 14),
            const SizedBox(width: 6),
            Text(
              style.label,
              style: TextStyle(
                color: style.border,
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
        color: AppColors.slate,
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
        style: const TextStyle(
          color: Colors.white,
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
            color: Colors.white.withValues(alpha: 0.06),
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
              color: Colors.white.withValues(alpha: 0.05),
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
          const Text(
            'Não foi possível carregar o perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verifique sua conexão e tente novamente.',
            style: TextStyle(
              color: AppColors.coolGray.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded,
                size: 18, color: Colors.white),
            label: const Text(
              'Tentar novamente',
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerBadge extends StatelessWidget {
  final int productsCount;
  const _SellerBadge({required this.productsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9500).withValues(alpha: 0.2),
            AppColors.electricPurple.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9500).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Color(0xFFFF9500), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendedor verificado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Confira a vitrine de produtos',
                  style: TextStyle(color: AppColors.coolGray, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$productsCount itens',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
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
        // Posts com foto/vídeo ficam na aba "Galeria".
        final textual = posts
            .where((p) => (p.imageUrl == null || p.imageUrl!.isEmpty))
            .toList();

        if (textual.isEmpty) {
          return const _EmptyState(
            icon: Icons.article_outlined,
            message: 'Nenhum post de texto ainda',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: 4, bottom: 80),
          itemCount: textual.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.white10, height: 1),
          itemBuilder: (context, index) => PostCard(post: textual[index]),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.electricPurple),
      ),
      error: (_, __) => const _EmptyState(
        icon: Icons.error_outline,
        message: 'Erro ao carregar posts',
      ),
    );
  }
}

// ── LIVES GRID ──────────────────────────────────────────────────────────────
class _LivesGrid extends StatelessWidget {
  final AsyncValue<List<LiveRoom>> livesState;
  const _LivesGrid({required this.livesState});

  @override
  Widget build(BuildContext context) {
    return livesState.when(
      data: (lives) {
        if (lives.isEmpty) {
          return const _EmptyState(
            icon: Icons.live_tv_outlined,
            message: 'Nenhuma live ainda',
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
                color: AppColors.slate,
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
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mutedRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (live.thumbnailUrl == null)
                    const Center(
                      child: Icon(Icons.play_circle_outline,
                          color: Colors.white24, size: 32),
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
      error: (_, __) => const _EmptyState(
        icon: Icons.error_outline,
        message: 'Erro ao carregar lives',
      ),
    );
  }
}

// ── VITRINE DE PRODUTOS ─────────────────────────────────────────────────────
class _ProductsGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _EmptyState(
        icon: Icons.shopping_bag_outlined,
        message: 'Loja vazia',
      );
    }

    final featured = products.where((p) => p.isFeatured).toList();
    final others = products.where((p) => !p.isFeatured).toList();

    return CustomScrollView(
      slivers: [
        if (featured.isNotEmpty) ...[
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: Color(0xFFFF9500), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Destaques',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: featured.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: 160,
                    child: _ProductCard(product: featured[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Todos os produtos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ProductCard(product: others[i]),
              childCount: others.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openProductSheet(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.nearBlack,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.coolGray),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mutedRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  if (product.isSoldOut)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: const Text(
                        'ESGOTADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else if (product.isLowStock)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Últimas ${product.stock}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.coolCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          'R\$ ${product.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.coolGray,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.soldCount} vendidos',
                    style: const TextStyle(
                      color: AppColors.coolGray,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProductSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(product: product),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final Product product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.nearBlack),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.coolCyan,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${product.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.coolGray,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.mutedRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        product.isSoldOut
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                        color: product.isSoldOut
                            ? AppColors.mutedRed
                            : Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.isSoldOut
                            ? 'Esgotado'
                            : product.isLowStock
                                ? 'Apenas ${product.stock} restantes'
                                : '${product.stock} em estoque',
                        style: TextStyle(
                          color: product.isSoldOut
                              ? AppColors.mutedRed
                              : Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${product.soldCount} vendidos',
                        style: const TextStyle(
                            color: AppColors.coolGray, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sobre o produto',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Produto exclusivo da loja oficial. Envio em até 3 dias úteis. '
                    'Garantia de 30 dias e troca grátis.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: product.isSoldOut
                        ? null
                        : () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🛒 Adicionado ao carrinho!'),
                                backgroundColor: AppColors.electricPurple,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricPurple,
                      disabledBackgroundColor: AppColors.slate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      product.isSoldOut
                          ? Icons.block
                          : Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      product.isSoldOut ? 'Indisponível' : 'Comprar agora',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
          Icon(icon, size: 56, color: AppColors.coolGray.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.coolGray, fontSize: 14)),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.nearBlack, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
