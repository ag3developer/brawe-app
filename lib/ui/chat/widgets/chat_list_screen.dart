import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/conversation.dart';
import '../view_models/chat_list_view_model.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatListViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading && state.conversations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.conversations.isEmpty
              ? _buildEmptyState()
              : _buildConversationList(context, ref, state.conversations),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white24,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation with someone!',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(
    BuildContext context,
    WidgetRef ref,
    List<Conversation> conversations,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(chatListViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return _ConversationTile(
            conversation: conversation,
            onTap: () => context.push('/chat/${conversation.id}'),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white24,
        backgroundImage: conversation.participantAvatarUrl != null
            ? NetworkImage(conversation.participantAvatarUrl!)
            : null,
        child: conversation.participantAvatarUrl == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        conversation.participantName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: conversation.lastMessage != null
          ? Text(
              conversation.lastMessage!.content,
              style: const TextStyle(color: Colors.white54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.updatedAt),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          if (conversation.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6E4DFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
