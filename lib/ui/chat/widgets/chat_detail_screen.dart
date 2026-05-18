import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/user.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/chat_detail_view_model.dart';
import '../view_models/presence_provider.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post.dart';

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
  final _picker = ImagePicker();
  bool _isTyping = false;
  bool _hasText = false;
  bool _viewOnce = false;
  ChatMessage? _replyingTo;

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

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;
      final localViewOnce = _viewOnce;
      setState(() => _viewOnce = false);
      await ref
          .read(chatDetailViewModelProvider(widget.conversationId).notifier)
          .sendImage(filePath: picked.path, viewOnce: localViewOnce);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao escolher imagem: $e')),
      );
    }
  }

  void _send() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    final reply = _replyingTo;
    ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .sendMessage(text, replyTo: reply);
    _messageCtrl.clear();
    _isTyping = false;
    if (_replyingTo != null) setState(() => _replyingTo = null);
    _scrollToBottom();
  }

  void _setReply(ChatMessage m) {
    setState(() => _replyingTo = m);
  }

  void _clearReply() {
    setState(() => _replyingTo = null);
  }

  void _onReact(ChatMessage m, String emoji) {
    ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .reactToMessage(m.id, emoji);
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(chatDetailViewModelProvider(widget.conversationId));

    if (state.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      appBar: _AppBar(
        name: widget.participantName,
        avatarUrl: widget.participantAvatarUrl,
        participantId: widget.participantId,
        isTyping: state.isTyping,
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/chat'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E0B1F),
              Color(0xFF080A12),
            ],
          ),
        ),
        child: Column(
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
                    conversationId: widget.conversationId,
                    messages: state.messages,
                    scrollController: _scrollCtrl,
                    avatarUrl: widget.participantAvatarUrl,
                    isLoadingMore: state.isLoadingMore,
                    onReply: _setReply,
                    onReact: _onReact,
                  ),
          ),
          _Composer(
              controller: _messageCtrl,
              hasText: _hasText,
              isSending: state.isSending,
              viewOnce: _viewOnce,
              replyingTo: _replyingTo,
              onClearReply: _clearReply,
              onToggleViewOnce: () => setState(() => _viewOnce = !_viewOnce),
              onChanged: _onTextChanged,
              onSend: _send,
              onPickImage: _pickAndSendImage,
            ),
          ],
        ),
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
      statusText = 'digitando';
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
              Container(
                padding: EdgeInsets.all(isOnline ? 2 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isOnline
                      ? const LinearGradient(
                          colors: [
                            AppColors.electricPurple,
                            AppColors.coolCyan,
                          ],
                        )
                      : null,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.slate,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.nearBlack, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight:
                            isTyping ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    if (isTyping) ...[
                      const SizedBox(width: 4),
                      const _TypingDots(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _AppBarAction(
          icon: Icons.videocam_outlined,
          onTap: () {},
        ),
        _AppBarAction(
          icon: Icons.call_outlined,
          onTap: () {},
        ),
        _AppBarAction(
          icon: Icons.more_vert,
          onTap: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
      child: Material(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_c.value + i * 0.18) % 1.0;
            final v = (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.2),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.coolCyan
                      .withValues(alpha: 0.35 + v * 0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.coolCyan.withValues(alpha: 0.4 * v),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _MessageList extends ConsumerWidget {
  const _MessageList({
    required this.conversationId,
    required this.messages,
    required this.scrollController,
    required this.avatarUrl,
    required this.onReply,
    required this.onReact,
    this.isLoadingMore = false,
  });
  final String conversationId;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String? avatarUrl;
  final bool isLoadingMore;
  final void Function(ChatMessage) onReply;
  final void Function(ChatMessage, String) onReact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final myId = authState is AsyncData<User?> ? authState.value?.id : null;
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
        // Determine "isMe": optimistic (local-) or sender matches current user id.
        final isMe = m.id.startsWith('local-') ||
            (myId != null && m.senderId == myId) ||
            m.senderId == 'current-user';

        // Group: hide avatar if next message is from same sender.
        final next = i + 1 < items.length ? items[i + 1] : null;
        final isLastInGroup = next is! _MessageItem ||
            (next.message.senderId != m.senderId);

        return _MessageBubble(
          conversationId: conversationId,
          message: m,
          isMe: isMe,
          showAvatar: !isMe && isLastInGroup,
          avatarUrl: avatarUrl,
          onReply: onReply,
          onReact: onReact,
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.electricPurple.withValues(alpha: 0.18),
                AppColors.coolCyan.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricPurple.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _label(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({
    required this.conversationId,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.avatarUrl,
    required this.onReply,
    required this.onReact,
  });
  final String conversationId;
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final String? avatarUrl;
  final void Function(ChatMessage) onReply;
  final void Function(ChatMessage, String) onReact;

  bool get _isImage => message.messageType == 'image';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.read(chatDetailViewModelProvider(conversationId).notifier);

    // Live invite: card especial clicável (ignora bolha padrão).
    if (message.messageType == 'live_invite' && !message.isBurned) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                                size: 14, color: Colors.white54)
                            : null,
                      )
                    : null,
              ),
            Flexible(
              child: _LiveInviteCard(message: message, isMe: isMe),
            ),
          ],
        ),
      );
    }

    Widget content;
    if (message.isBurned) {
      content = _BurnedPlaceholder(isMe: isMe);
    } else if (_isImage) {
      content = _ImageBubbleContent(
        message: message,
        isMe: isMe,
        onTapViewOnce: () async {
          await _openImageFullScreen(context, message);
          if (message.isViewOnce && !isMe && !message.isBurned) {
            await notifier.burnMessage(message.id);
          }
        },
      );
    } else {
      content = _TextBubbleContent(message: message, isMe: isMe);
    }

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isMe && !_isImage && !message.isBurned
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.electricPurple,
                      AppColors.coolCyan,
                    ],
                  )
                : null,
            color: (!isMe || _isImage || message.isBurned)
                ? Colors.white.withValues(alpha: 0.06)
                : null,
            border: (!isMe || _isImage || message.isBurned)
                ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                : null,
            boxShadow: isMe && !_isImage && !message.isBurned
                ? [
                    BoxShadow(
                      color:
                          AppColors.electricPurple.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          padding: _isImage && !message.isBurned
              ? const EdgeInsets.all(3)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: content,
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey('bubble-${message.id}'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 10),
          child: child,
        ),
      ),
      child: Padding(
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
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageActions(context, notifier),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  bubble,
                  if (message.reactions.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: 4,
                        left: isMe ? 0 : 4,
                        right: isMe ? 4 : 0,
                      ),
                      child: _ReactionChips(
                        reactions: message.reactions,
                        onTap: (emoji) => onReact(message, emoji),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showMessageActions(BuildContext context, ChatDetailViewModel notifier) {
    if (message.id.startsWith('local-')) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Emoji reaction bar =====
            if (!message.isBurned)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(12, 14, 12, 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.electricPurple.withValues(alpha: 0.18),
                        AppColors.coolCyan.withValues(alpha: 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (final e in const ['❤️', '😂', '😮', '😢', '🔥', '👏'])
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            onReact(message, e);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(e,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pop(sheetCtx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            if (!message.isBurned)
              ListTile(
                leading: const Icon(Icons.reply, color: AppColors.coolCyan),
                title: const Text('Responder',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  onReply(message);
                },
              ),
            if (!message.isBurned && message.messageType == 'text')
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.white),
                title: const Text('Copiar',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.mutedRed),
              title: const Text('Apagar para mim',
                  style: TextStyle(color: AppColors.mutedRed)),
              onTap: () {
                Navigator.pop(sheetCtx);
                notifier.deleteMessage(message.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openImageFullScreen(
      BuildContext context, ChatMessage m) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageViewerPage(message: m),
      ),
    );
  }
}

// Regex p/ detectar link de post compartilhado: https://brawe.app/connect/p/<uuid>
final RegExp _kSharedPostRegex = RegExp(
  r'https?://brawe\.app/connect/p/([0-9a-fA-F-]{36})',
);

class _TextBubbleContent extends ConsumerWidget {
  const _TextBubbleContent({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = _kSharedPostRegex.firstMatch(message.content);
    final postId = match?.group(1);
    // Texto sem o URL do post (caption opcional acima do card)
    final caption = postId == null
        ? message.content
        : message.content.replaceFirst(match!.group(0)!, '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.replyTo != null) ...[
          _ReplyQuote(reply: message.replyTo!, isMe: isMe),
          const SizedBox(height: 6),
        ],
        if (caption.isNotEmpty)
          Text(
            caption,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.3),
          ),
        if (postId != null) ...[
          if (caption.isNotEmpty) const SizedBox(height: 6),
          _SharedPostPreview(postId: postId, isMe: isMe),
        ],
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
              if (message.isRead)
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [AppColors.coolCyan, AppColors.electricPurple],
                  ).createShader(r),
                  blendMode: BlendMode.srcIn,
                  child: const Icon(
                    Icons.done_all,
                    color: Colors.white,
                    size: 13,
                  ),
                )
              else
                Icon(
                  message.isPending ? Icons.access_time : Icons.done,
                  color: Colors.white70,
                  size: 12,
                ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ImageBubbleContent extends StatelessWidget {
  const _ImageBubbleContent({
    required this.message,
    required this.isMe,
    required this.onTapViewOnce,
  });
  final ChatMessage message;
  final bool isMe;
  final Future<void> Function() onTapViewOnce;

  bool get _alreadyViewed => message.viewedAt != null;
  bool get _isLocal => message.isPending && !message.content.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final blocked = message.isViewOnce && !isMe && _alreadyViewed;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GestureDetector(
        onTap: blocked ? null : onTapViewOnce,
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 280,
                minHeight: 140,
                minWidth: 200,
              ),
              child: _isLocal
                  ? Image.file(
                      File(message.content),
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: message.content,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.electricPurple,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white38,
                      ),
                    ),
            ),
            if (message.isViewOnce)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 12, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('Ver 1x',
                          style: TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            if (message.isPending)
              const Positioned(
                bottom: 6,
                right: 6,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BurnedPlaceholder extends StatelessWidget {
  const _BurnedPlaceholder({required this.isMe});
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.whatshot,
              size: 16, color: AppColors.coolGray),
          const SizedBox(width: 6),
          Text(
            isMe ? 'Foto vista por 1 vez' : 'Foto não está mais disponível',
            style: const TextStyle(
                color: AppColors.coolGray,
                fontStyle: FontStyle.italic,
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  const _ImageViewerPage({required this.message});
  final ChatMessage message;
  @override
  Widget build(BuildContext context) {
    final isLocal =
        message.isPending && !message.content.startsWith('http');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: message.isViewOnce
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department,
                      color: Colors.amber, size: 18),
                  SizedBox(width: 6),
                  Text('Visualização única',
                      style:
                          TextStyle(color: Colors.white, fontSize: 14)),
                ],
              )
            : null,
      ),
      body: Center(
        child: InteractiveViewer(
          child: isLocal
              ? Image.file(File(message.content))
              : CachedNetworkImage(
                  imageUrl: message.content,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const CircularProgressIndicator(
                      color: AppColors.electricPurple),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white38),
                ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.electricPurple.withValues(alpha: 0.30),
                  AppColors.coolCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: const Icon(
              Icons.waving_hand,
              color: Colors.white70,
              size: 56,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Diga olá 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Envie a primeira mensagem para começar a conversa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
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
    required this.viewOnce,
    required this.replyingTo,
    required this.onClearReply,
    required this.onToggleViewOnce,
    required this.onChanged,
    required this.onSend,
    required this.onPickImage,
  });

  final TextEditingController controller;
  final bool hasText;
  final bool isSending;
  final bool viewOnce;
  final ChatMessage? replyingTo;
  final VoidCallback onClearReply;
  final VoidCallback onToggleViewOnce;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final Future<void> Function(ImageSource source) onPickImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080A12),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Reply preview banner =====
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: replyingTo == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding:
                          const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(
                            10, 8, 6, 8),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 3,
                              height: 34,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.electricPurple,
                                    AppColors.coolCyan,
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Respondendo',
                                    style: TextStyle(
                                      color:
                                          AppColors.coolCyan,
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    replyingTo!.messageType ==
                                            'image'
                                        ? '📷 Foto'
                                        : replyingTo!.content,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white60,
                                  size: 18),
                              onPressed: onClearReply,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _IconRoundButton(
                icon: Icons.add,
                onTap: () => _showAttachSheet(context),
              ),
              const SizedBox(width: 4),
              _IconRoundButton(
                icon: viewOnce
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                tint: viewOnce ? Colors.amber : Colors.white,
                onTap: onToggleViewOnce,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: hasText
                          ? AppColors.electricPurple.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
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
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined,
                              color: AppColors.coolGray),
                          onPressed: () => _openEmojiPicker(ctx, controller),
                        ),
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
          ],
        ),
      ),
    );
  }

  void _showVoicePreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricPurple,
                      AppColors.coolCyan,
                    ],
                  ),
                ),
                child: const Icon(Icons.mic,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mensagem de voz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Em breve — gravação com waveform animado',
                style: TextStyle(
                    color: AppColors.coolGray, fontSize: 12),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                height: 48,
                child: _WaveformPreview(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricPurple,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(color: Colors.white),
                  ),
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
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _AttachOption(
                icon: Icons.photo,
                label: 'Galeria',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  onPickImage(ImageSource.gallery);
                },
              ),
              _AttachOption(
                icon: Icons.camera_alt,
                label: 'Câmera',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  onPickImage(ImageSource.camera);
                },
              ),
              _AttachOption(
                icon: Icons.mic,
                label: 'Áudio',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showVoicePreview(context);
                },
              ),
              const _AttachOption(icon: Icons.location_on, label: 'Local'),
              const _AttachOption(
                  icon: Icons.insert_drive_file, label: 'Arquivo'),
              const _AttachOption(
                  icon: Icons.card_giftcard, label: 'Mistério'),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconRoundButton extends StatelessWidget {
  const _IconRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tint = Colors.white,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color tint;

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
        child: Icon(icon, color: tint, size: 22),
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
  const _AttachOption({
    required this.icon,
    required this.label,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                style:
                    const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
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

// ---------------------------------------------------------------------------
// Shared post preview card (Instagram-like rich link preview inside DM)
// ---------------------------------------------------------------------------

/// Provider de busca de post para preview no chat (cacheado por postId).
final sharedPostPreviewProvider =
    FutureProvider.autoDispose.family<Post, String>((ref, postId) async {
  ref.keepAlive();
  final repo = ref.watch(postRepositoryProvider);
  return repo.getById(postId);
});

class _SharedPostPreview extends ConsumerWidget {
  const _SharedPostPreview({required this.postId, required this.isMe});
  final String postId;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPost = ref.watch(sharedPostPreviewProvider(postId));

    final bg = isMe
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.nearBlack.withValues(alpha: 0.55);
    final border =
        isMe ? Colors.white24 : Colors.white.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: () => _openPost(context),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: asyncPost.when(
          data: (post) => _buildLoaded(context, post),
          loading: () => _buildSkeleton(),
          error: (_, __) => _buildError(),
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: post.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.slate),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.slate,
                child: const Icon(Icons.broken_image,
                    color: AppColors.coolGray),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.slate,
                    backgroundImage: (post.author.avatarUrl != null &&
                            post.author.avatarUrl!.isNotEmpty)
                        ? NetworkImage(post.author.avatarUrl!)
                        : null,
                    child: (post.author.avatarUrl == null ||
                            post.author.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      post.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (post.author.isVerified) ...[
                    const SizedBox(width: 3),
                    const Icon(Icons.verified,
                        color: AppColors.coolCyan, size: 13),
                  ],
                ],
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.favorite_border,
                      size: 12, color: AppColors.coolGray),
                  const SizedBox(width: 3),
                  Text(
                    '${post.likesCount}',
                    style: const TextStyle(
                        color: AppColors.coolGray, fontSize: 11),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.mode_comment_outlined,
                      size: 12, color: AppColors.coolGray),
                  const SizedBox(width: 3),
                  Text(
                    '${post.commentsCount}',
                    style: const TextStyle(
                        color: AppColors.coolGray, fontSize: 11),
                  ),
                  const Spacer(),
                  const Text(
                    'Ver publicação',
                    style: TextStyle(
                      color: AppColors.coolCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(color: AppColors.slate),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 120, height: 10, color: AppColors.slate),
              const SizedBox(height: 6),
              Container(
                  width: double.infinity,
                  height: 10,
                  color: AppColors.slate),
              const SizedBox(height: 6),
              Container(
                  width: 80, height: 10, color: AppColors.slate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: const [
          Icon(Icons.link, size: 16, color: AppColors.coolGray),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Publicação indisponível',
              style: TextStyle(color: AppColors.coolGray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _openPost(BuildContext context) {
    // TODO: navegar para tela de detalhe do post quando rota existir.
    // Por enquanto apenas feedback visual.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrir publicação em breve'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _WaveformPreview extends StatefulWidget {
  const _WaveformPreview();
  @override
  State<_WaveformPreview> createState() => _WaveformPreviewState();
}

class _WaveformPreviewState extends State<_WaveformPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(28, (i) {
            final phase = (_c.value * 2 * 3.14159) + i * 0.32;
            final v = (0.45 + 0.55 * (0.5 + 0.5 * math.sin(phase)));
            return Container(
              width: 4,
              height: 48 * v,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.electricPurple,
                    AppColors.coolCyan,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

// ============================================================
// Reply quote inside bubble + reaction chips outside.
// ============================================================

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({required this.reply, required this.isMe});
  final ReplyPreview reply;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final preview = reply.isBurned
        ? '🔥 Mensagem queimada'
        : reply.messageType == 'image'
            ? '📷 Foto'
            : reply.content.isEmpty
                ? '...'
                : reply.content;
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white : AppColors.coolCyan,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Respondendo',
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.coolCyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isMe ? Colors.white70 : Colors.white60,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionChips extends StatelessWidget {
  const _ReactionChips({required this.reactions, required this.onTap});
  final Map<String, List<String>> reactions;
  final void Function(String emoji) onTap;

  @override
  Widget build(BuildContext context) {
    final entries = reactions.entries
        .where((e) => e.value.isNotEmpty)
        .toList(growable: false);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: entries.map((e) {
        final count = e.value.length;
        return GestureDetector(
          onTap: () => onTap(e.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricPurple.withValues(alpha: 0.22),
                  AppColors.coolCyan.withValues(alpha: 0.22),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 13)),
                if (count > 1) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}


// ===========================================================================
// Emoji Picker (lightweight, no external deps)
// ===========================================================================

void _openEmojiPicker(BuildContext context, TextEditingController controller) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0B0E1A),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EmojiPickerSheet(
      onPick: (emoji) => _insertEmoji(controller, emoji),
    ),
  );
}

void _insertEmoji(TextEditingController controller, String emoji) {
  final value = controller.value;
  final text = value.text;
  final selection = value.selection;
  final start = selection.isValid ? selection.start : text.length;
  final end = selection.isValid ? selection.end : text.length;
  final newText = text.replaceRange(start, end, emoji);
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + emoji.length),
  );
}

class _EmojiPickerSheet extends StatefulWidget {
  const _EmojiPickerSheet({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet> {
  int _tab = 0;

  static const Map<String, List<String>> _categories = {
    'Smileys': [
      '😀','��','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','��',
      '😇','🥰','😍','🤩','😘','😗','😚','😙','😋','😛','😜','🤪',
      '😝','🤑','🤗','🤭','🤫','🤔','🤐','😐','😑','😶','😏','😒',
      '🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤧',
      '🥵','🥶','🥴','😵','🤯','🤠','🥳','😎','🤓','🧐','😕','😟',
      '🙁','☹️','😮','😯','��','😳','🥺','😦','😧','😨','😰','😥',
      '😢','😭','😱','😖','😣','😞','😓','😩','😫','🥱','😤','😡',
      '😠','🤬','😈','👿','💀','☠️','💩','🤡','👹','👺','👻','👽',
    ],
    'Gestos': [
      '👋','🤚','🖐','✋','🖖','👌','🤏','✌️','🤞','🤟','🤘','🤙',
      '👈','👉','👆','🖕','👇','☝️','��','👎','✊','👊','🤛','🤜',
      '👏','🙌','👐','🤲','🤝','🙏','💅','🤳','💪','🦾','🦿','🦵',
      '🦶','👂','🦻','👃','🧠','🦷','🦴','👀','👁','👅','👄','💋',
    ],
    'Coração': [
      '❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❣️','💕',
      '💞','💓','💗','💖','💘','💝','💟','♥️','💌','💍','💐','🌹',
    ],
    'Animais': [
      '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮',
      '🐷','🐽','🐸','🐵','🙈','🙉','🙊','🐒','🐔','🐧','🐦','🐤',
      '🦆','🦅','🦉','🦇','🐺','🐗','🐴','🦄','🐝','🪱','🐛','🦋',
    ],
    'Comida': [
      '🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍈','🍒','🍑',
      '🥭','🍍','🥥','🥝','🍅','🍆','🥑','🥦','🥬','🥒','🌶','🫑',
      '🌽','🥕','🫒','🧄','🧅','🥔','🍠','🥐','��','🍞','🥖','🧀',
      '🍕','🍔','🍟','🌭','🥪','🌮','🌯','🥙','🧆','🍝','🍜','🍲',
    ],
    'Festa': [
      '🎉','🎊','🎈','🎂','🎁','🎀','🪅','🎆','🎇','✨','🎃','🎄',
      '🎋','🎍','🎎','🎏','🎐','🧧','🪔','🎌','🏆','🥇','🥈','🥉',
      '🏅','🎖','🏵','🎗','🎫','🎟','🎪','🎭','🎨','🎬','🎤','🎧',
    ],
    'Objetos': [
      '💎','🔥','��','💫','⭐','🌟','✨','⚡','☄️','🌈','☀️','🌙',
      '⛅','☁️','🌧','⛈','❄️','☃️','💧','🌊','🎵','🎶','💯','✅',
      '❌','⛔','🚫','💢','💬','💭','🗯','♨️','💤','🆗','🆒','🆕',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final tabs = _categories.keys.toList();
    final emojis = _categories[tabs[_tab]]!;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            // Tabs
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final selected = i == _tab;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(colors: [
                                AppColors.electricPurple,
                                AppColors.coolCyan,
                              ])
                            : null,
                        color: selected
                            ? null
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tabs[i],
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.coolGray,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: emojis.length,
                itemBuilder: (_, i) {
                  final e = emojis[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      widget.onPick(e);
                      // Don't close — allow picking multiple in a row.
                      HapticFeedback.selectionClick();
                    },
                    child: Center(
                      child: Text(e,
                          style: const TextStyle(fontSize: 26)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// Card de convite de live no chat: preview clicável que abre a live.
class _LiveInviteCard extends StatelessWidget {
  const _LiveInviteCard({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  Map<String, dynamic> _decode() {
    try {
      final raw = json.decode(message.content);
      if (raw is Map<String, dynamic>) return raw;
    } catch (_) {/* não é JSON válido */}
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final data = _decode();
    final title = (data['title'] as String?) ?? 'Live';
    final streamerName = (data['streamer_name'] as String?) ?? '';
    final streamerAvatar = data['streamer_avatar'] as String?;
    final thumb = data['thumbnail_url'] as String?;
    final note = (data['note'] as String?) ?? '';
    final slugOrId = (data['slug'] as String?) ??
        (data['room_id'] as String?) ??
        '';
    final status = (data['status'] as String?) ?? 'live';
    final isLive = status == 'live';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0F2E),
            Color(0xFF2D1B4D),
          ],
        ),
        border: Border.all(
          color: AppColors.electricPurple.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricPurple.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: slugOrId.isEmpty
              ? null
              : () => context.push('/live/$slugOrId'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Thumbnail / placeholder ───────────────────────────────
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumb != null && thumb.isNotEmpty)
                      Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: AppColors.deepBlue),
                      )
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.electricPurple,
                              AppColors.coolCyan,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.videocam_rounded,
                            color: Colors.white70,
                            size: 48,
                          ),
                        ),
                      ),
                    // overlay sutil para legibilidade
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    // LIVE badge
                    if (isLive)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.mutedRed,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mutedRed
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  color: Colors.white, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'AO VIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Play overlay
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Streamer + título ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.slate,
                          backgroundImage: (streamerAvatar != null &&
                                  streamerAvatar.isNotEmpty)
                              ? NetworkImage(streamerAvatar)
                              : null,
                          child: (streamerAvatar == null ||
                                  streamerAvatar.isEmpty)
                              ? const Icon(Icons.person,
                                  size: 14, color: Colors.white54)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            streamerName.isNotEmpty
                                ? streamerName
                                : 'Streamer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // CTA
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.coolCyan,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLive ? 'Toque para assistir' : 'Ver detalhes',
                          style: const TextStyle(
                            color: AppColors.coolCyan,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
