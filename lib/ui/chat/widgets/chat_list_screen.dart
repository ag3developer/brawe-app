import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_colors.dart';
import '../../../domain/models/conversation.dart';
import '../view_models/chat_list_view_model.dart';
import '../view_models/presence_provider.dart';

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
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final showArchived = _tabController.index == 2;
    final current = ref.read(chatListViewModelProvider).showArchived;
    if (current != showArchived) {
      ref
          .read(chatListViewModelProvider.notifier)
          .toggleArchived(showArchived);
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
            .where((c) => c.participantName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    final totalUnread = conversations.fold<int>(
        0, (sum, c) => sum + c.unreadCount);

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        toolbarHeight: 64,
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Colors.white, AppColors.coolCyan],
              ).createShader(b),
              child: const Text(
                'Mensagens',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            if (totalUnread > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppColors.electricPurple,
                    AppColors.coolCyan,
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.electricPurple.withValues(alpha: 0.55),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  '$totalUnread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.electricPurple.withValues(alpha: 0.20),
                    AppColors.coolCyan.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.electricPurple.withValues(alpha: 0.45),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {},
                tooltip: 'Nova mensagem',
              ),
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
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.electricPurple.withValues(alpha: 0.10),
                        AppColors.coolCyan.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar conversas, pessoas…',
                      hintStyle: TextStyle(
                        color: AppColors.coolGray.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.coolGray, size: 20),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.coolGray, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                      filled: false,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
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
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.coolGray,
                  indicatorPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: -8),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [
                      AppColors.electricPurple,
                      AppColors.coolCyan,
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricPurple
                            .withValues(alpha: 0.45),
                        blurRadius: 10,
                      ),
                    ],
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
                  tabs: const [
                    Tab(text: 'Todas'),
                    Tab(text: 'Não lidas'),
                    Tab(text: 'Arquivadas'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: chatState.isLoading && conversations.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.electricPurple),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _ConversationList(
                  conversations: filtered,
                  showArchivedActions: false,
                  onRefresh: () async =>
                      ref.read(chatListViewModelProvider.notifier).refresh(),
                ),
                _ConversationList(
                  conversations: filtered.where((c) => c.unreadCount > 0).toList(),
                  showArchivedActions: false,
                  onRefresh: () async =>
                      ref.read(chatListViewModelProvider.notifier).refresh(),
                ),
                _ConversationList(
                  conversations: filtered,
                  showArchivedActions: true,
                  onRefresh: () async =>
                      ref.read(chatListViewModelProvider.notifier).refresh(),
                ),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.electricPurple, AppColors.coolCyan],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricPurple.withValues(alpha: 0.55),
              blurRadius: 22,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: 'Nova conversa',
          child: const Icon(Icons.add_comment_outlined,
              color: Colors.white, size: 24),
        ),
      ),
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
                gradient: RadialGradient(
                  colors: [
                    AppColors.electricPurple.withValues(alpha: 0.30),
                    AppColors.electricPurple.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: const Icon(Icons.forum_outlined,
                  size: 56, color: Colors.white70),
            ),
            const SizedBox(height: 18),
            const Text(
              'Comece uma conversa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Suas mensagens com creators, amigos e brawers vão aparecer aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.coolGray.withValues(alpha: 0.85),
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
      color: AppColors.electricPurple,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(presenceCacheProvider);
    final isOnline = presence[conversation.participantId]?.isOnline ??
        conversation.isOnline;
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
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: hasUnread
                  ? AppColors.electricPurple.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.02),
              border: Border.all(
                color: hasUnread
                    ? AppColors.electricPurple.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasUnread
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.electricPurple,
                                  AppColors.coolCyan,
                                ],
                              )
                            : null,
                      ),
                      padding: EdgeInsets.all(hasUnread ? 2.2 : 0),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.slate,
                        backgroundImage:
                            conversation.participantAvatarUrl != null
                                ? NetworkImage(
                                    conversation.participantAvatarUrl!)
                                : null,
                        child: conversation.participantAvatarUrl == null
                            ? Text(
                                conversation.participantName.isNotEmpty
                                    ? conversation.participantName[0]
                                        .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.nearBlack,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent
                                    .withValues(alpha: 0.55),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.participantName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: hasUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(conversation.updatedAt),
                            style: TextStyle(
                              color: hasUnread
                                  ? AppColors.coolCyan
                                  : AppColors.coolGray,
                              fontSize: 11,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage?.content ??
                                  'Toque para conversar',
                              style: TextStyle(
                                color: hasUnread
                                    ? Colors.white
                                    : AppColors.coolGray,
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
                              constraints:
                                  const BoxConstraints(minWidth: 22),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  AppColors.electricPurple,
                                  AppColors.coolCyan,
                                ]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.electricPurple
                                        .withValues(alpha: 0.55),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                conversation.unreadCount > 99
                                    ? '99+'
                                    : '${conversation.unreadCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
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
            ? Colors.blueGrey.shade700
            : AppColors.electricPurple.withValues(alpha: 0.8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Icon(archivedMode ? Icons.unarchive : Icons.archive,
                color: Colors.white),
            const SizedBox(width: 8),
            Text(archivedMode ? 'Desarquivar' : 'Arquivar',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: AppColors.mutedRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Apagar', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) return true;
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.slate,
                title: const Text('Apagar conversa?',
                    style: TextStyle(color: Colors.white)),
                content: const Text(
                    'A conversa será apagada apenas para você.',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Apagar',
                        style: TextStyle(color: AppColors.mutedRed)),
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
