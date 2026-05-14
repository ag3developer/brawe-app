import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/conversation.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/chat_detail_view_model.dart';
import '../view_models/presence_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;
  final String? participantId;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
    this.participantId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageCtrl.addListener(() {
      final has = _messageCtrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _scrollCtrl.addListener(_onScroll);
    // Inscreve presença do participante (se conhecido).
    if (widget.participantId != null && widget.participantId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(presenceCacheProvider.notifier)
            .watch(widget.participantId!);
      });
    }
  }

  void _onScroll() {
    // ListView normal (não reversed) → topo é offset mínimo.
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels <=
        _scrollCtrl.position.minScrollExtent + 80) {
      ref
          .read(chatDetailViewModelProvider(widget.conversationId).notifier)
          .loadOlderMessages();
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _onTextChanged(String value) {
    final vm = ref.read(
        chatDetailViewModelProvider(widget.conversationId).notifier);
    if (value.isNotEmpty && !_isTyping) {
      _isTyping = true;
      vm.onTyping();
    } else if (value.isEmpty && _isTyping) {
      _isTyping = false;
      vm.onTypingStopped();
    }
  }

  void _send() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .sendMessage(text);
    _messageCtrl.clear();
    _isTyping = false;
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(chatDetailViewModelProvider(widget.conversationId));

    if (state.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: _AppBar(
        name: widget.participantName,
        avatarUrl: widget.participantAvatarUrl,
        participantId: widget.participantId,
        isTyping: state.isTyping,
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/chat'),
      ),
      body: Column(
        children: [
          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              color: AppColors.mutedRed.withValues(alpha: 0.15),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                    color: AppColors.mutedRed, fontSize: 12),
              ),
            ),
          Expanded(
            child: state.messages.isEmpty
                ? const _EmptyState()
                : _MessageList(
                    messages: state.messages,
                    scrollController: _scrollCtrl,
                    avatarUrl: widget.participantAvatarUrl,
                    isLoadingMore: state.isLoadingMore,
                  ),
          ),
          _Composer(
            controller: _messageCtrl,
            hasText: _hasText,
            isSending: state.isSending,
            onChanged: _onTextChanged,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.name,
    required this.avatarUrl,
    required this.participantId,
    required this.isTyping,
    required this.onBack,
  });
  final String name;
  final String? avatarUrl;
  final String? participantId;
  final bool isTyping;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(presenceCacheProvider);
    final p = participantId == null ? null : presence[participantId!];
    final isOnline = p?.isOnline ?? false;
    final lastSeen = p?.lastSeen;

    String statusText;
    Color statusColor;
    if (isTyping) {
      statusText = 'digitando…';
      statusColor = AppColors.coolCyan;
    } else if (isOnline) {
      statusText = 'Online';
      statusColor = Colors.greenAccent.shade400;
    } else if (lastSeen != null) {
      statusText = 'visto ${_relative(lastSeen)}';
      statusColor = AppColors.coolGray;
    } else {
      statusText = 'Offline';
      statusColor = AppColors.coolGray;
    }

    return AppBar(
      backgroundColor: AppColors.nearBlack,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.slate,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(name[0],
                        style: const TextStyle(color: Colors.white))
                    : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.nearBlack, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.scrollController,
    required this.avatarUrl,
    this.isLoadingMore = false,
  });
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String? avatarUrl;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    // Build flat list with date separators.
    final items = <_ChatItem>[];
    DateTime? lastDate;
    for (final m in messages) {
      final d = DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
      if (lastDate == null || d != lastDate) {
        items.add(_DateSeparatorItem(d));
        lastDate = d;
      }
      items.add(_MessageItem(m));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (_, idx) {
        if (isLoadingMore && idx == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.electricPurple,
                ),
              ),
            ),
          );
        }
        final i = isLoadingMore ? idx - 1 : idx;
        final item = items[i];
        if (item is _DateSeparatorItem) {
          return _DateSeparator(date: item.date);
        }
        final mItem = item as _MessageItem;
        final m = mItem.message;
        // Determine "isMe": pending local- or empty senderId or 'current-user'
        final isMe = m.id.startsWith('local-') ||
            m.senderId == 'current-user' ||
            m.senderId.isEmpty;

        // Group: hide avatar if next message is from same sender.
        final next = i + 1 < items.length ? items[i + 1] : null;
        final isLastInGroup = next is! _MessageItem ||
            (next.message.senderId != m.senderId);

        return _MessageBubble(
          message: m,
          isMe: isMe,
          showAvatar: !isMe && isLastInGroup,
          avatarUrl: avatarUrl,
        );
      },
    );
  }
}

abstract class _ChatItem {
  const _ChatItem();
}

class _DateSeparatorItem extends _ChatItem {
  const _DateSeparatorItem(this.date);
  final DateTime date;
}

class _MessageItem extends _ChatItem {
  const _MessageItem(this.message);
  final ChatMessage message;
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});
  final DateTime date;

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Hoje';
    if (date == yesterday) return 'Ontem';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _label(),
            style: const TextStyle(color: AppColors.coolGray, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.avatarUrl,
  });
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                colors: [AppColors.electricPurple, AppColors.softViolet],
              )
            : null,
        color: isMe ? null : AppColors.slate,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.3),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: isMe ? Colors.white70 : AppColors.coolGray,
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  message.isPending
                      ? Icons.access_time
                      : message.isRead
                          ? Icons.done_all
                          : Icons.done,
                  color: message.isRead
                      ? AppColors.coolCyan
                      : Colors.white70,
                  size: 12,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            SizedBox(
              width: 32,
              child: showAvatar
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.slate,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 14)
                          : null,
                    )
                  : const SizedBox.shrink(),
            ),
          if (!isMe) const SizedBox(width: 6),
          Flexible(child: bubble),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waving_hand, color: Colors.white24, size: 56),
          SizedBox(height: 14),
          Text('Diga olá! 👋',
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 4),
          Text('Envie a primeira mensagem para começar',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hasText,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool hasText;
  final bool isSending;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.nearBlack,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _IconRoundButton(
                icon: Icons.add,
                onTap: () => _showAttachSheet(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.slate,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onChanged: onChanged,
                          minLines: 1,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Mensagem',
                            hintStyle: TextStyle(color: AppColors.coolGray),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 11),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined,
                            color: AppColors.coolGray),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: hasText
                    ? _SendButton(
                        key: const ValueKey('send'),
                        onTap: isSending ? null : onSend,
                        loading: isSending,
                      )
                    : _IconRoundButton(
                        key: const ValueKey('mic'),
                        icon: Icons.mic,
                        onTap: () {},
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _AttachOption(icon: Icons.photo, label: 'Galeria'),
              _AttachOption(icon: Icons.camera_alt, label: 'Câmera'),
              _AttachOption(icon: Icons.mic, label: 'Áudio'),
              _AttachOption(icon: Icons.location_on, label: 'Local'),
              _AttachOption(icon: Icons.insert_drive_file, label: 'Arquivo'),
              _AttachOption(icon: Icons.card_giftcard, label: 'Mistério'),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconRoundButton extends StatelessWidget {
  const _IconRoundButton({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: AppColors.slate,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({super.key, required this.onTap, required this.loading});
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.electricPurple, AppColors.coolCyan],
          ),
          shape: BoxShape.circle,
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send, color: Colors.white, size: 20),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.nearBlack,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.electricPurple, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}


String _relative(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return 'há ${diff.inMinutes}m';
  if (diff.inDays < 1) return 'há ${diff.inHours}h';
  if (diff.inDays < 7) return 'há ${diff.inDays}d';
  return '${dt.day}/${dt.month}';
}
