import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../domain/models/conversation.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/chat_list_view_model.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../view_models/presence_provider.dart';
import '../../feed/widgets/story_ring_avatar.dart';
import 'user_status_sheet.dart';
import 'rich/system_notice_bubble.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import '../utils/chat_error_text.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Atualiza conversas toda vez que o usuário entra na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(chatListViewModelProvider.notifier).refresh();
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final showArchived = _tabController.index == 2;
    final current = ref.read(chatListViewModelProvider).showArchived;
    if (current != showArchived) {
      ref.read(chatListViewModelProvider.notifier).toggleArchived(showArchived);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatListViewModelProvider);
    final conversations = chatState.conversations;

    // Registra presença para todos os participantes da lista.
    ref.listen<int>(
      chatListViewModelProvider.select((s) => s.conversations.length),
      (_, _) {
        final convs = ref.read(chatListViewModelProvider).conversations;
        ref
            .read(presenceCacheProvider.notifier)
            .watchAll(convs.map((c) => c.participantId));
      },
    );
    // Garante watch inicial em cada rebuild com conversas presentes.
    if (conversations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(presenceCacheProvider.notifier)
            .watchAll(conversations.map((c) => c.participantId));
      });
    }

    final filtered = _searchQuery.isEmpty
        ? conversations
        : conversations
              .where(
                (c) => c.participantName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    final totalUnread = conversations.fold<int>(
      0,
      (sum, c) => sum + c.unreadCount,
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        toolbarHeight: 64,
        title: Row(
          children: [
            Text(
              S.of(context).chatListTitle,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            if (totalUnread > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.accentPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalUnread',
                  style: TextStyle(
                    color: context.colors.textOnAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Status button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Consumer(
              builder: (context, ref, _) {
                final status = ref.watch(userStatusProvider);
                return GestureDetector(
                  onTap: () => showUserStatusSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: context.colors.surfaceHighest,
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status.localizedLabel(context),
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: context.colors.surfaceHighest,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: S.of(context).chatListSearchHint,
                      hintStyle: TextStyle(
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        color: context.colors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(
                                LucideIcons.x,
                                color: context.colors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TabBar(
                  controller: _tabController,
                  labelColor: context.colors.textOnAccent,
                  unselectedLabelColor: context.colors.textSecondary,
                  indicatorPadding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: -8,
                  ),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.colors.accentPrimary,
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(text: S.of(context).chatListTabAll),
                    Tab(text: S.of(context).chatListTabUnread),
                    Tab(text: S.of(context).chatListTabArchived),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: chatState.isLoading && conversations.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: context.colors.accentPrimary,
              ),
            )
          : Column(
              children: [
                if (chatState.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.danger.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.circleAlert,
                          color: context.colors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            chatErrorText(
                              S.of(context),
                              chatState.errorMessage!,
                            ),
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(chatListViewModelProvider.notifier)
                              .refresh(),
                          child: Text(
                            S.of(context).chatListRetry,
                            style: TextStyle(
                              color: context.colors.accentPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ConversationList(
                        conversations: filtered,
                        showArchivedActions: false,
                        onRefresh: () async => ref
                            .read(chatListViewModelProvider.notifier)
                            .refresh(),
                      ),
                      _ConversationList(
                        conversations: filtered
                            .where((c) => c.unreadCount > 0)
                            .toList(),
                        showArchivedActions: false,
                        onRefresh: () async => ref
                            .read(chatListViewModelProvider.notifier)
                            .refresh(),
                      ),
                      _ConversationList(
                        conversations: filtered,
                        showArchivedActions: true,
                        onRefresh: () async => ref
                            .read(chatListViewModelProvider.notifier)
                            .refresh(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.accentPrimary,
        ),
        child: FloatingActionButton(
          onPressed: () => context.go('/chat/new'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: S.of(context).chatListNewTooltip,
          child: Icon(
            LucideIcons.messageSquarePlus,
            color: context.colors.textOnAccent,
            size: 24,
          ),
        ),
      ),
      // bottomNavigationBar removido — HomeBottomNav gerenciado pelo ShellRoute
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.conversations,
    required this.onRefresh,
    this.showArchivedActions = false,
  });

  final List<Conversation> conversations;
  final Future<void> Function() onRefresh;
  final bool showArchivedActions;

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.surfaceHighest,
              ),
              child: Icon(
                LucideIcons.messagesSquare,
                size: 56,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              S.of(context).chatListEmptyTitle,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                S.of(context).chatListEmptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textSecondary.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: context.colors.accentPrimary,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: conversations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          return _SwipeableConversationTile(
            conversation: conversations[index],
            archivedMode: showArchivedActions,
          );
        },
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation});

  final Conversation conversation;

  String _formatTime(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return S.of(context).chatListTimeNow;
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(presenceCacheProvider);
    final isOnline =
        presence[conversation.participantId]?.isOnline ?? conversation.isOnline;
    final hasUnread = conversation.unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(
            '/chat/${conversation.id}',
            extra: {
              'participantName': conversation.participantName,
              'participantAvatarUrl': conversation.participantAvatarUrl,
              'participantId': conversation.participantId,
            },
          ),
          // Segurar: fixar no topo / silenciar.
          onLongPress: () => _showQuickActions(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                if (conversation.isSystem)
                  const BraweOfficialAvatar(radius: 26)
                else
                  StoryRingAvatar(
                    userId: conversation.participantId,
                    avatarUrl: conversation.participantAvatarUrl,
                    fallbackText: conversation.participantName,
                    radius: 26,
                    isOnline: isOnline,
                    showOnlineIndicator: true,
                    onTapWithoutStories: () => context.push(
                      '/chat/${conversation.id}',
                      extra: {
                        'participantName': conversation.participantName,
                        'participantAvatarUrl':
                            conversation.participantAvatarUrl,
                        'participantId': conversation.participantId,
                      },
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              conversation.participantName,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: hasUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.participantIsVerified ||
                              conversation.isSystem)
                            const VerifiedBadge(size: 14),
                          if (conversation.isMuted)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                LucideIcons.bellOff,
                                size: 14,
                                color: context.colors.textTertiary,
                              ),
                            ),
                          const Spacer(),
                          if (conversation.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                LucideIcons.pin,
                                size: 13,
                                color: context.colors.textTertiary,
                              ),
                            ),
                          Text(
                            _formatTime(context, conversation.updatedAt),
                            style: TextStyle(
                              color: context.colors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage?.content != null
                                  ? BraweRichText.humanize(
                                      conversation.lastMessage!.content,
                                      sharedPostLabel: S
                                          .of(context)
                                          .linkSharedPost,
                                    )
                                  : S.of(context).chatListTapToTalk,
                              style: TextStyle(
                                color: hasUnread
                                    ? context.colors.textPrimary
                                    : context.colors.textSecondary,
                                fontSize: 13,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              constraints: const BoxConstraints(minWidth: 22),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.accentPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                conversation.unreadCount > 99
                                    ? '99+'
                                    : '${conversation.unreadCount}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.colors.textOnAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final notifier = ref.read(chatListViewModelProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            if (!conversation.isSystem)
              ListTile(
                leading: Icon(
                  conversation.isPinned ? LucideIcons.pinOff : LucideIcons.pin,
                ),
                title: Text(conversation.isPinned ? s.chatUnpin : s.chatPin),
                onTap: () async {
                  Navigator.pop(ctx);
                  final v = await notifier.setPinned(
                    conversation.id,
                    !conversation.isPinned,
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        v == null
                            ? s.chatPinLimit
                            : (v ? s.chatPinnedToast : s.chatUnpinnedToast),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ListTile(
              leading: Icon(
                conversation.isMuted
                    ? LucideIcons.bellRing
                    : LucideIcons.bellOff,
              ),
              title: Text(
                conversation.isMuted ? s.chatUnmute : s.chatDetailMute,
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final v = await notifier.setMuted(
                  conversation.id,
                  !conversation.isMuted,
                );
                if (v == null) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(v ? s.chatMutedToast : s.chatUnmutedToast),
                    duration: const Duration(seconds: 1),
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
}

class _SwipeableConversationTile extends ConsumerWidget {
  const _SwipeableConversationTile({
    required this.conversation,
    required this.archivedMode,
  });
  final Conversation conversation;
  final bool archivedMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('conv-${conversation.id}'),
      background: Container(
        color: archivedMode
            ? context.colors.textTertiary
            : context.colors.accentPrimary.withValues(alpha: 0.8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Icon(
              archivedMode ? LucideIcons.archiveRestore : LucideIcons.archive,
              color: context.colors.textOnAccent,
            ),
            const SizedBox(width: 8),
            Text(
              archivedMode
                  ? S.of(context).chatListUnarchive
                  : S.of(context).chatListArchive,
              style: TextStyle(color: context.colors.textOnAccent),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: context.colors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              S.of(context).chatListDelete,
              style: TextStyle(color: context.colors.textOnAccent),
            ),
            const SizedBox(width: 8),
            Icon(LucideIcons.trash2, color: context.colors.textOnAccent),
          ],
        ),
      ),
      direction: conversation.isSystem
          ? DismissDirection.startToEnd
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) return true;
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: context.colors.surfaceElevated,
                title: Text(
                  S.of(context).chatListDeleteConfirmTitle,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                content: Text(
                  S.of(context).chatListDeleteConfirmBody,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      S.of(context).chatListCancel,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      S.of(context).chatListDelete,
                      style: TextStyle(color: context.colors.danger),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        final notifier = ref.read(chatListViewModelProvider.notifier);
        if (direction == DismissDirection.startToEnd) {
          if (archivedMode) {
            notifier.unarchive(conversation.id);
          } else {
            notifier.archive(conversation.id);
          }
        } else {
          notifier.deleteConversation(conversation.id);
        }
      },
      child: _ConversationTile(conversation: conversation),
    );
  }
}
