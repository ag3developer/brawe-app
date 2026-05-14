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
    _tabController = TabController(length: 2, vsync: this);
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
      (_, __) {
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

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mensagens',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar mensagens...',
                    hintStyle: TextStyle(color: AppColors.coolGray.withValues(alpha: 0.6)),
                    prefixIcon: const Icon(Icons.search, color: AppColors.coolGray, size: 20),
                    filled: true,
                    fillColor: AppColors.slate,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.electricPurple,
                unselectedLabelColor: AppColors.coolGray,
                indicatorColor: AppColors.electricPurple,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Todas'),
                  Tab(text: 'Não lidas'),
                ],
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
                  onRefresh: () async =>
                      ref.read(chatListViewModelProvider.notifier).refresh(),
                ),
                _ConversationList(
                  conversations: filtered.where((c) => c.unreadCount > 0).toList(),
                  onRefresh: () async =>
                      ref.read(chatListViewModelProvider.notifier).refresh(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.electricPurple,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.conversations,
    required this.onRefresh,
  });

  final List<Conversation> conversations;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 56, color: AppColors.coolGray.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text(
              'Sem conversas',
              style: TextStyle(color: AppColors.coolGray, fontSize: 16),
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
        separatorBuilder: (_, __) => Divider(
          color: AppColors.slate.withValues(alpha: 0.5),
          height: 1,
          indent: 80,
        ),
        itemBuilder: (context, index) {
          return _ConversationTile(conversation: conversations[index]);
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

    return InkWell(
      onTap: () => context.push(
        '/chat/${conversation.id}',
        extra: {
          'participantName': conversation.participantName,
          'participantAvatarUrl': conversation.participantAvatarUrl,
          'participantId': conversation.participantId,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: conversation.participantAvatarUrl != null
                      ? NetworkImage(conversation.participantAvatarUrl!)
                      : null,
                  backgroundColor: AppColors.slate,
                  child: conversation.participantAvatarUrl == null
                      ? Text(
                          conversation.participantName[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
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
                            color: AppColors.nearBlack, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
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
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.updatedAt),
                        style: TextStyle(
                          color: conversation.unreadCount > 0
                              ? AppColors.electricPurple
                              : AppColors.coolGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.content ?? 'Iniciar conversa',
                          style: TextStyle(
                            color: conversation.unreadCount > 0
                                ? Colors.white70
                                : AppColors.coolGray,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.electricPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
    );
  }
}
