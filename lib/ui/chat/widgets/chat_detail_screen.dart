import 'dart:async';
import '../../core/view_models/hidden_users_view_model.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/user.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/text/brawe_rich_text.dart';
import '../../../core/text/link_preview_card.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/chat_detail_view_model.dart';
import '../view_models/presence_provider.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post.dart';
import '../../feed/widgets/story_ring_avatar.dart';
import 'shared_post_sheet.dart';
import '../../core/widgets/report_sheet.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import '../view_models/chat_list_view_model.dart';
import '../utils/chat_error_text.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'rich/agency_invite_bubble.dart';
import 'rich/system_notice_bubble.dart';
import '../../../domain/models/system_notice.dart';
import 'rich/chat_rich_bubbles.dart';
import 'rich/chat_extra_sheets.dart';
import 'package:geolocator/geolocator.dart';
import '../../../domain/models/gif_item.dart';
import '../../shared/widgets/gif/gif_bubble.dart';
import '../../shared/widgets/gif/gif_picker_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:brawe_app/core/media/media_utils.dart';

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

  // Aberto por notificação (ou link) a rota só traz o id da conversa: nome,
  // foto e id da outra pessoa são buscados na lista de conversas.
  String? _resolvedName;
  String? _resolvedAvatarUrl;
  String? _resolvedParticipantId;

  String get _participantName => _resolvedName ?? widget.participantName;
  String? get _participantAvatarUrl =>
      _resolvedAvatarUrl ?? widget.participantAvatarUrl;
  String? get _participantId => _resolvedParticipantId ?? widget.participantId;

  /// Conversa oficial da Brawe (avisos do sistema): somente leitura.
  bool get _isSystem =>
      _participantId == kBraweSystemUserId ||
      ref
          .read(chatListViewModelProvider)
          .conversations
          .any((c) => c.id == widget.conversationId && c.isSystem);

  Future<void> _resolveParticipant() async {
    final repo = ref.read(chatRepositoryProvider);
    for (final archived in [false, true]) {
      try {
        final list = await repo.listConversations(
          limit: 100,
          archived: archived,
        );
        final match = list
            .where((c) => c.id == widget.conversationId)
            .firstOrNull;
        if (match == null) continue;
        if (!mounted) return;
        setState(() {
          _resolvedName = match.participantName;
          _resolvedAvatarUrl = match.participantAvatarUrl;
          _resolvedParticipantId = match.participantId;
        });
        ref.read(presenceCacheProvider.notifier).watch(match.participantId);
        return;
      } catch (_) {
        // Sem rede: mantém o cabeçalho genérico; as mensagens carregam igual.
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.participantId == null || widget.participantId!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resolveParticipant();
      });
    }
    _messageCtrl.addListener(() {
      final has = _messageCtrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _scrollCtrl.addListener(_onScroll);
    // Inscreve presença do participante (se conhecido).
    if (_participantId != null && _participantId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(presenceCacheProvider.notifier).watch(_participantId!);
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
      chatDetailViewModelProvider(widget.conversationId).notifier,
    );
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
        SnackBar(content: Text(S.of(context).chatDetailPickImageError(e))),
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

  Future<void> _sendGif(String gifUrl) async {
    // Send GIF as image message with the remote URL
    ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .sendMessage('gif:$gifUrl');
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

  Future<void> _blockUser() async {
    final participantId = _participantId;
    if (participantId == null || participantId.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceElevated,
        title: Text(
          S.of(context).chatDetailBlockTitle(_participantName),
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: Text(
          S.of(context).chatDetailBlockBody,
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              S.of(context).chatDetailCancel,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(context).chatDetailBlock,
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(hiddenUsersProvider.notifier)
          .block(slug: participantId, userId: participantId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).chatDetailBlocked(_participantName)),
          backgroundColor: context.colors.surfaceElevated,
        ),
      );
      context.go('/chat');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).chatDetailBlockError(e))),
      );
    }
  }

  void _showMoreMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: ctx.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: context.colors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (!_isSystem)
                _MoreMenuItem(
                  icon: LucideIcons.user,
                  label: S.of(context).chatDetailViewProfile,
                  onTap: () {
                    final pid = _participantId;
                    if (pid == null || pid.isEmpty) {
                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(context).chatDetailOpenProfileError,
                          ),
                          backgroundColor: context.colors.surfaceElevated,
                        ),
                      );
                      return;
                    }
                    // IMPORTANTE: `/chat/:id` é uma rota FORA da ShellRoute
                    // (fullscreen) e `/profile/:id` está DENTRO da ShellRoute.
                    // Usar `push` daqui criaria uma segunda Shell no stack
                    // com a mesma LocalKey da primeira, disparando o assert
                    // `!keyReservation.contains(key)` no Navigator.
                    // Usar `go` substitui a rota atual — sem conflito de keys.
                    final router = GoRouter.of(context);
                    Navigator.pop(sheetCtx);
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (!mounted) return;
                      router.go('/profile/$pid');
                    });
                  },
                ),
              // Silenciar / Fixar / Buscar — estado vem da lista de conversas.
              Builder(
                builder: (_) {
                  final conv = ref
                      .read(chatListViewModelProvider)
                      .conversations
                      .where((c) => c.id == widget.conversationId)
                      .firstOrNull;
                  final muted = conv?.isMuted ?? false;
                  final pinned = conv?.isPinned ?? false;
                  final s = S.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MoreMenuItem(
                        icon: LucideIcons.search,
                        label: s.chatDetailSearchInChat,
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          showChatSearchSheet(
                            context,
                            conversationId: widget.conversationId,
                          );
                        },
                      ),
                      _MoreMenuItem(
                        icon: muted
                            ? LucideIcons.bellRing
                            : LucideIcons.bellOff,
                        label: muted ? s.chatUnmute : s.chatDetailMute,
                        onTap: () async {
                          Navigator.pop(sheetCtx);
                          final v = await ref
                              .read(chatListViewModelProvider.notifier)
                              .setMuted(widget.conversationId, !muted);
                          if (v == null) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                v ? s.chatMutedToast : s.chatUnmutedToast,
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      if (!_isSystem)
                        _MoreMenuItem(
                          icon: pinned ? LucideIcons.pin : LucideIcons.pin,
                          label: pinned ? s.chatUnpin : s.chatPin,
                          onTap: () async {
                            Navigator.pop(sheetCtx);
                            final v = await ref
                                .read(chatListViewModelProvider.notifier)
                                .setPinned(widget.conversationId, !pinned);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  v == null
                                      ? s.chatPinLimit
                                      : (v
                                            ? s.chatPinnedToast
                                            : s.chatUnpinnedToast),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
              if (!_isSystem)
                _MoreMenuItem(
                  icon: LucideIcons.ban,
                  label: S.of(context).chatDetailBlockMenu(_participantName),
                  color: context.colors.danger,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _blockUser();
                  },
                ),
              if (!_isSystem)
                _MoreMenuItem(
                  icon: LucideIcons.flag,
                  label: S.of(context).chatDetailReport,
                  color: context.colors.danger,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    showReportSheet(
                      context,
                      targetType: 'conversation',
                      targetId: widget.conversationId,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatDetailViewModelProvider(widget.conversationId));
    // Rebuild quando a lista de conversas revelar que esta é a oficial da Brawe.
    ref.watch(
      chatListViewModelProvider.select(
        (st) => st.conversations.any(
          (c) => c.id == widget.conversationId && c.isSystem,
        ),
      ),
    );
    final isSystem = _isSystem;

    if (state.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    if (state.isTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    // Voltar do Android quando a conversa foi aberta com `go` (ex.: nova
    // conversa) e não há nada embaixo na pilha: sem isto o app FECHAVA.
    // Agora volta para a lista de conversas. No iOS: sem efeito.
    final exitToList = Platform.isAndroid && !context.canPop();
    return PopScope(
      canPop: !exitToList,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && exitToList) context.go('/chat');
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: _AppBar(
          name: _participantName,
          avatarUrl: _participantAvatarUrl,
          participantId: _participantId,
          isSystem: isSystem,
          isTyping: state.isTyping,
          // Volta para quem abriu a conversa (perfil, loja, carteira…), igual
          // ao voltar do sistema/gesto; só cai na lista se não houver pilha.
          onBack: () => context.canPop() ? context.pop() : context.go('/chat'),
          onMoreTap: () => _showMoreMenu(context),
        ),
        body: Container(
          decoration: BoxDecoration(color: context.colors.background),
          child: Column(
            children: [
              if (state.errorMessage != null)
                Container(
                  width: double.infinity,
                  color: context.colors.danger.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Text(
                    chatErrorText(S.of(context), state.errorMessage!),
                    style: TextStyle(
                      color: context.colors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
              Expanded(
                child: state.messages.isEmpty
                    ? const _EmptyState()
                    : _MessageList(
                        conversationId: widget.conversationId,
                        messages: state.messages,
                        scrollController: _scrollCtrl,
                        avatarUrl: _participantAvatarUrl,
                        isLoadingMore: state.isLoadingMore,
                        isTyping: state.isTyping,
                        onReply: _setReply,
                        onReact: _onReact,
                      ),
              ),
              if (isSystem)
                const SystemReadOnlyFooter()
              else
                _Composer(
                  controller: _messageCtrl,
                  conversationId: widget.conversationId,
                  hasText: _hasText,
                  isSending: state.isSending,
                  viewOnce: _viewOnce,
                  replyingTo: _replyingTo,
                  onClearReply: _clearReply,
                  onToggleViewOnce: () =>
                      setState(() => _viewOnce = !_viewOnce),
                  onChanged: _onTextChanged,
                  onSend: _send,
                  onPickImage: _pickAndSendImage,
                  onSendGif: _sendGif,
                  onScrollToBottom: _scrollToBottom,
                ),
            ],
          ),
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
    this.onMoreTap,
    this.isSystem = false,
  });
  final bool isSystem;
  final String name;
  final String? avatarUrl;
  final String? participantId;
  final bool isTyping;
  final VoidCallback onBack;
  final VoidCallback? onMoreTap;

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
    if (isSystem) {
      statusText = S.of(context).chatSystemOfficialLabel;
      statusColor = context.colors.accentPrimary;
    } else if (isTyping) {
      statusText = S.of(context).chatDetailStatusTyping;
      statusColor = context.colors.accentPrimary;
    } else if (isOnline) {
      statusText = S.of(context).chatDetailStatusOnline;
      statusColor = context.colors.success;
    } else if (lastSeen != null) {
      statusText = S
          .of(context)
          .chatDetailStatusSeen(_relative(context, lastSeen));
      statusColor = context.colors.textSecondary;
    } else {
      statusText = S.of(context).chatDetailStatusOffline;
      statusColor = context.colors.textSecondary;
    }

    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft, color: context.colors.textPrimary),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          if (isSystem)
            const BraweOfficialAvatar(radius: 18)
          else
            StoryRingAvatar(
              userId: participantId ?? '',
              avatarUrl: avatarUrl,
              fallbackText: name,
              radius: 18,
              isOnline: isOnline,
              showOnlineIndicator: true,
              onTapWithoutStories:
                  (participantId != null && participantId!.isNotEmpty)
                  ? () {
                      if (!context.mounted) return;
                      // Usa `go` em vez de `push`: a rota /chat/:id está
                      // fora da ShellRoute e /profile/:id está dentro
                      // dela. Um `push` empilharia uma segunda Shell com
                      // a mesma LocalKey → assert do Navigator.
                      context.go('/profile/$participantId');
                    }
                  : null,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isSystem ||
                        ref
                            .watch(chatListViewModelProvider)
                            .conversations
                            .any(
                              (c) =>
                                  c.participantId == participantId &&
                                  c.participantIsVerified,
                            ))
                      const VerifiedBadge(size: 14),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: isTyping
                            ? FontWeight.w600
                            : FontWeight.w500,
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
          icon: LucideIcons.ellipsisVertical,
          onTap: onMoreTap ?? () {},
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
        color: context.colors.surfaceHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(icon, color: context.colors.textPrimary, size: 19),
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
                  color: context.colors.accentSecondary.withValues(
                    alpha: 0.35 + v * 0.6,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.accentSecondary.withValues(
                        alpha: 0.4 * v,
                      ),
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
    this.isTyping = false,
  });
  final String conversationId;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String? avatarUrl;
  final bool isLoadingMore;
  final bool isTyping;
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
      itemCount: items.length + (isLoadingMore ? 1 : 0) + (isTyping ? 1 : 0),
      itemBuilder: (_, idx) {
        if (isLoadingMore && idx == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
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
          );
        }
        final adjustedIdx = isLoadingMore ? idx - 1 : idx;
        // Typing bubble is the last item
        if (isTyping && adjustedIdx == items.length) {
          return const _TypingBubble();
        }
        final i = adjustedIdx;
        final item = items[i];
        if (item is _DateSeparatorItem) {
          return _DateSeparator(date: item.date);
        }
        final mItem = item as _MessageItem;
        final m = mItem.message;
        // Determine "isMe": optimistic (local-) or sender matches current user id.
        final isMe =
            m.id.startsWith('local-') ||
            (myId != null && m.senderId == myId) ||
            m.senderId == 'current-user';

        // Group: hide avatar if next message is from same sender.
        final next = i + 1 < items.length ? items[i + 1] : null;
        final isLastInGroup =
            next is! _MessageItem || (next.message.senderId != m.senderId);

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

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.surfaceElevated,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: context.colors.accentPrimary.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accentPrimary.withValues(alpha: 0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    // Each dot peaks at a different time
                    final phase = (_c.value - i * 0.22) % 1.0;
                    final normalized = phase < 0 ? phase + 1.0 : phase;
                    final v = normalized < 0.5
                        ? normalized * 2
                        : (1.0 - normalized) * 2;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: AnimatedContainer(
                        duration: Duration.zero,
                        width: 7,
                        height: 7 + v * 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              context.colors.accentSecondary.withValues(
                                alpha: 0.6 + v * 0.4,
                              ),
                              context.colors.accentPrimary.withValues(
                                alpha: 0.5 + v * 0.4,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.accentSecondary.withValues(
                                alpha: 0.3 * v,
                              ),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});
  final DateTime date;

  String _label(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return S.of(context).chatDetailDateToday;
    if (date == yesterday) return S.of(context).chatDetailDateYesterday;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.accentPrimary.withValues(alpha: 0.18),
                context.colors.accentSecondary.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
            boxShadow: [
              BoxShadow(
                color: context.colors.accentPrimary.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _label(context),
            style: TextStyle(
              color: context.colors.textPrimary,
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

  /// Foto exibida "crua" (sem bolha colorida). Visualização única NÃO
  /// entra aqui: vira um cartão com texto e usa a bolha normal.
  bool get _isImage => message.messageType == 'image' && !message.isViewOnce;
  bool get _isGif =>
      message.messageType == 'text' && message.content.startsWith('gif:');

  /// GIF novo (GIPHY): `messageType == 'gif'` com {id,url,width,height} em `meta`.
  GifAttachment? get _gifAttachment => message.messageType == 'gif'
      ? GifAttachment.tryParse(message.meta)
      : null;

  /// Conteúdo rico + hora embaixo (as bolhas ricas não desenham a hora).
  Widget _withTime(BuildContext context, Widget child) {
    final t = message.timestamp;
    final hh =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 4),
        Text(
          hh,
          style: TextStyle(
            color: isMe
                ? context.colors.textOnAccent.withValues(alpha: 0.75)
                : context.colors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  bool get _isAudio => message.messageType == 'audio';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      chatDetailViewModelProvider(conversationId).notifier,
    );

    // Live invite: card especial clicável (ignora bolha padrão).
    if (message.messageType == 'live_invite' && !message.isBurned) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe)
              SizedBox(
                width: 32,
                child: showAvatar
                    ? CircleAvatar(
                        radius: 14,
                        backgroundColor: context.colors.surfaceElevated,
                        backgroundImage: avatarUrl != null
                            ? ResizeImage(
                                NetworkImage(avatarUrl!),
                                width: context.decodePx(28),
                              )
                            : null,
                        child: avatarUrl == null
                            ? Icon(
                                LucideIcons.user,
                                size: 14,
                                color: context.colors.textTertiary,
                              )
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

    // Aviso oficial da Brawe: cartão com ícone, tom e botão opcional.
    if (message.messageType == 'system_notice') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 32,
              child: showAvatar ? const BraweOfficialAvatar(radius: 14) : null,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SystemNoticeBubble(message: message),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4),
                    child: Text(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                        TimeOfDay.fromDateTime(message.timestamp),
                        alwaysUse24HourFormat: MediaQuery.of(
                          context,
                        ).alwaysUse24HourFormat,
                      ),
                      style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Convite de agência (Brawe Partners): cartão rico com "Abrir convite".
    if (message.messageType == 'agency_invite' && !message.isBurned) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe)
              SizedBox(
                width: 32,
                child: showAvatar
                    ? CircleAvatar(
                        radius: 14,
                        backgroundColor: context.colors.surfaceElevated,
                        backgroundImage: avatarUrl != null
                            ? ResizeImage(
                                NetworkImage(avatarUrl!),
                                width: context.decodePx(28),
                              )
                            : null,
                        child: avatarUrl == null
                            ? Icon(
                                LucideIcons.user,
                                size: 14,
                                color: context.colors.textTertiary,
                              )
                            : null,
                      )
                    : null,
              ),
            Flexible(
              child: AgencyInviteBubble(message: message, isMe: isMe),
            ),
          ],
        ),
      );
    }

    Widget content;
    if (message.isBurned) {
      content = _BurnedPlaceholder(isMe: isMe);
    } else if (_isGif) {
      final gifUrl = message.content.substring(4); // strip 'gif:'
      content = _GifBubbleContent(gifUrl: gifUrl, isMe: isMe);
    } else if (message.messageType == 'gif' && _gifAttachment != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GifBubble(gif: _gifAttachment!, borderRadius: 14),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 1),
            child: Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      );
    } else if (message.messageType == 'image' && message.isViewOnce) {
      // Visualização única: a foto NUNCA aparece na conversa (nem para quem
      // enviou). Quem recebe toca para abrir uma vez; depois vira "Aberta".
      content = _ViewOnceBubbleContent(
        message: message,
        isMe: isMe,
        onOpen: () async {
          await _openImageFullScreen(context, message);
          if (!message.isBurned) {
            await notifier.burnMessage(message.id);
          }
        },
      );
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
    } else if (_isAudio) {
      content = _AudioBubbleContent(message: message, isMe: isMe);
    } else if (message.messageType == 'story_reaction' ||
        message.messageType == 'story_reply') {
      content = _withTime(
        context,
        StoryInteractionBubble(message: message, isMe: isMe),
      );
    } else if (message.messageType == 'story_gift') {
      content = _withTime(
        context,
        GiftVaultBubble(
          message: message,
          isMe: isMe,
          onOpen: () => notifier.openGift(message.id),
        ),
      );
    } else if (message.messageType == 'location') {
      content = _withTime(
        context,
        LocationBubble(message: message, isMe: isMe),
      );
    } else if (message.messageType == 'file') {
      content = _withTime(context, FileBubble(message: message, isMe: isMe));
    } else {
      content = _TextBubbleContent(message: message, isMe: isMe);
    }
    if (message.isForwarded && !message.isBurned) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ForwardedLabel(isMe: isMe),
          content,
        ],
      );
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
            color:
                (!isMe ||
                    _isImage ||
                    _gifAttachment != null ||
                    message.isBurned)
                ? context.colors.surfaceHighest
                : context.colors.accentPrimary,
          ),
          padding: (_isImage || _gifAttachment != null) && !message.isBurned
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
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              SizedBox(
                width: 32,
                child: showAvatar
                    ? CircleAvatar(
                        radius: 14,
                        backgroundColor: context.colors.surfaceElevated,
                        backgroundImage: avatarUrl != null
                            ? ResizeImage(
                                NetworkImage(avatarUrl!),
                                width: context.decodePx(28),
                              )
                            : null,
                        child: avatarUrl == null
                            ? Icon(
                                LucideIcons.user,
                                color: context.colors.textPrimary,
                                size: 14,
                              )
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
      backgroundColor: context.colors.surfaceElevated,
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
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colors.accentPrimary.withValues(alpha: 0.18),
                        context.colors.accentSecondary.withValues(alpha: 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (final e in const [
                        '❤️',
                        '😂',
                        '😮',
                        '😢',
                        '🔥',
                        '👏',
                      ])
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            onReact(message, e);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pop(sheetCtx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.plus,
                            color: context.colors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            if (!message.isBurned)
              ListTile(
                leading: Icon(
                  LucideIcons.reply,
                  color: context.colors.accentSecondary,
                ),
                title: Text(
                  S.of(context).chatDetailReply,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  onReply(message);
                },
              ),
            // Editar: só minha mensagem de texto, até 15 minutos.
            if (isMe &&
                !message.isPending &&
                message.messageType == 'text' &&
                !message.content.startsWith('gif:') &&
                DateTime.now().difference(message.timestamp).inMinutes < 15)
              ListTile(
                leading: Icon(
                  LucideIcons.pencil,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  S.of(context).chatEdit,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final text = await showEditMessageSheet(
                    context,
                    message.content,
                  );
                  if (text != null) {
                    await notifier.editMessage(message.id, text);
                  }
                },
              ),
            if (canForward(message))
              ListTile(
                leading: Icon(
                  LucideIcons.forward,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  S.of(context).chatForward,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  showForwardSheet(
                    context,
                    message: message,
                    currentConversationId: conversationId,
                  );
                },
              ),
            if (!message.isBurned && message.messageType == 'text')
              ListTile(
                leading: Icon(
                  LucideIcons.copy,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  S.of(context).chatDetailCopy,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Clipboard.setData(ClipboardData(text: message.content));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).chatCopied),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            // Apagar direto do menu: "para mim" sai na hora (só some do
            // meu lado); "para todos" pede uma confirmação curta, porque
            // não dá para desfazer para a outra pessoa.
            ListTile(
              leading: Icon(LucideIcons.trash2, color: context.colors.danger),
              title: Text(
                S.of(context).chatDetailDeleteForMe,
                style: TextStyle(color: context.colors.danger),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                notifier.deleteMessage(message.id);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).chatMessageDeleted),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            if (isMe && !message.isPending)
              ListTile(
                leading: Icon(LucideIcons.trash2, color: context.colors.danger),
                title: Text(
                  S.of(context).chatDeleteForEveryone,
                  style: TextStyle(color: context.colors.danger),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDeleteForEveryone(context, notifier);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openImageFullScreen(BuildContext context, ChatMessage m) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageViewerPage(message: m),
      ),
    );
  }

  Future<void> _confirmDeleteForEveryone(
    BuildContext context,
    ChatDetailViewModel notifier,
  ) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.chatDeleteForEveryoneTitle),
        content: Text(s.chatDeleteForEveryoneBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.chatDeleteForEveryone,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      notifier.deleteMessage(message.id, forEveryone: true);
      HapticFeedback.lightImpact();
    }
  }
}

// Regex p/ detectar link de post compartilhado em mensagens de chat.
// Aceita os 2 formatos canônicos:
//   • https://brawe.app/post/<id>           (formato novo, a partir de v1.0.8)
//   • https://brawe.app/connect/p/<id>      (legacy, para mensagens antigas)
// O <id> pode ser UUID, slug ou qualquer string alfanumérica com - _ .
// Captura o ID no group(1) — usado para renderizar o preview rico.
final RegExp _kSharedPostRegex = RegExp(
  r'https?://(?:www\.)?brawe\.app/(?:post|connect/p)/([a-zA-Z0-9_\-\.]+)',
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

    // Só busca link preview genérico quando a mensagem não for um
    // "shared post" interno (esse já tem seu próprio card via postId).
    final previewUrl = postId == null ? BraweRichText.firstUrl(caption) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.replyTo != null) ...[
          _ReplyQuote(reply: message.replyTo!, isMe: isMe),
          const SizedBox(height: 6),
        ],
        // Mensagem que é só um link: o card de prévia já mostra o site,
        // então o texto cru do link não aparece (como no iMessage).
        if (caption.isNotEmpty &&
            !(previewUrl != null && BraweRichText.isOnlyUrl(caption)))
          BraweRichText(
            caption,
            style: TextStyle(
              // Balão próprio = accentPrimary → texto textOnAccent
              // Balão recebido → segue o tema
              color: isMe
                  ? context.colors.textOnAccent
                  : context.colors.textPrimary,
              fontSize: 14,
              height: 1.3,
            ),
            linkColor: isMe ? context.colors.textOnAccent : null,
          ),
        if (postId != null) ...[
          if (caption.isNotEmpty) const SizedBox(height: 6),
          _SharedPostPreview(postId: postId, isMe: isMe),
        ] else if (previewUrl != null) ...[
          if (caption.isNotEmpty && !BraweRichText.isOnlyUrl(caption))
            const SizedBox(height: 6),
          LinkPreviewCard(url: previewUrl, compact: true),
        ],
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.editedAt != null
                  ? '${S.of(context).chatEdited} · ${_formatTime(message.timestamp)}'
                  : _formatTime(message.timestamp),
              style: TextStyle(
                color: isMe
                    ? context.colors.textOnAccent.withValues(alpha: 0.75)
                    : context.colors.textSecondary,
                fontSize: 10,
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 4),
              Icon(
                message.isRead
                    ? LucideIcons.checkCheck
                    : (message.isPending
                          ? LucideIcons.clock
                          : LucideIcons.check),
                color: message.isRead
                    ? context.colors.textOnAccent
                    : context.colors.textOnAccent.withValues(alpha: 0.7),
                size: 13,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── GIF Bubble ───
class _GifBubbleContent extends StatelessWidget {
  const _GifBubbleContent({required this.gifUrl, required this.isMe});
  final String gifUrl;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Image.network(
            cacheWidth: context.decodePx(200),
            gifUrl,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 200,
              height: 100,
              color: context.colors.surfaceElevated,
              child: Center(
                child: Text(
                  'GIF',
                  style: TextStyle(color: context.colors.textTertiary),
                ),
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 200,
                height: 150,
                color: context.colors.surfaceElevated,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.accentPrimary,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'GIF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
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
                  ? Image.file(File(message.content), fit: BoxFit.cover)
                  : CachedNetworkImage(
                      memCacheWidth: context.decodeScreenPx,
                      imageUrl: message.content,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.accentPrimary,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Icon(
                        LucideIcons.imageOff,
                        color: context.colors.textTertiary,
                      ),
                    ),
            ),
            if (message.isViewOnce)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.flame,
                        size: 12,
                        color: context.colors.accentGold,
                      ),
                      SizedBox(width: 4),
                      Text(
                        S.of(context).chatDetailViewOnceBadge,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            if (message.isPending)
              Positioned(
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

/// Bolha de foto de visualização única (estilo WhatsApp): só um cartão com
/// ícone e estado — a imagem em si só aparece em tela cheia, uma vez, para
/// quem recebeu.
class _ViewOnceBubbleContent extends StatelessWidget {
  const _ViewOnceBubbleContent({
    required this.message,
    required this.isMe,
    required this.onOpen,
  });

  final ChatMessage message;
  final bool isMe;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final opened = message.isBurned || message.viewedAt != null;
    final canOpen = !isMe && !opened && !message.isPending;
    final fg = isMe ? context.colors.textOnAccent : context.colors.textPrimary;
    final sub = isMe
        ? context.colors.textOnAccent.withValues(alpha: 0.75)
        : context.colors.textSecondary;

    final String subtitle;
    if (opened) {
      subtitle = s.chatViewOnceOpened;
    } else if (isMe) {
      subtitle = s.chatViewOnceSent;
    } else {
      subtitle = s.chatViewOnceTapToOpen;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canOpen ? onOpen : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: opened ? sub : fg,
                  width: 1.6,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              alignment: Alignment.center,
              child: message.isPending
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fg,
                      ),
                    )
                  : Text(
                      '1',
                      style: TextStyle(
                        color: opened ? sub : fg,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.chatViewOncePhoto,
                    style: TextStyle(
                      color: opened ? sub : fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: sub, fontSize: 11.5)),
                ],
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
          Icon(
            LucideIcons.flame,
            size: 16,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            isMe
                ? S.of(context).chatDetailPhotoViewedOnce
                : S.of(context).chatDetailPhotoUnavailable,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
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
    final isLocal = message.isPending && !message.content.startsWith('http');
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        title: message.isViewOnce
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.flame,
                    color: context.colors.accentGold,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    S.of(context).chatDetailViewOnceTitle,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : null,
      ),
      body: Center(
        child: InteractiveViewer(
          child: isLocal
              ? Image.file(File(message.content))
              : CachedNetworkImage(
                  memCacheWidth: context.decodeScreenPx,
                  imageUrl: message.content,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => CircularProgressIndicator(
                    color: context.colors.accentPrimary,
                  ),
                  errorWidget: (_, _, _) => Icon(
                    LucideIcons.imageOff,
                    color: context.colors.textTertiary,
                  ),
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
                  context.colors.accentPrimary.withValues(alpha: 0.30),
                  context.colors.accentSecondary.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Icon(
              LucideIcons.hand,
              color: context.colors.textSecondary,
              size: 56,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            S.of(context).chatDetailEmptyTitle,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              S.of(context).chatDetailEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({
    required this.controller,
    required this.conversationId,
    required this.hasText,
    required this.isSending,
    required this.viewOnce,
    required this.replyingTo,
    required this.onClearReply,
    required this.onToggleViewOnce,
    required this.onChanged,
    required this.onSend,
    required this.onPickImage,
    required this.onScrollToBottom,
    this.onSendGif,
  });

  final TextEditingController controller;
  final String conversationId;
  final bool hasText;
  final bool isSending;
  final bool viewOnce;
  final ChatMessage? replyingTo;
  final VoidCallback onClearReply;
  final VoidCallback onToggleViewOnce;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final Future<void> Function(ImageSource source) onPickImage;
  final VoidCallback onScrollToBottom;
  final void Function(String gifUrl)? onSendGif;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer>
    with SingleTickerProviderStateMixin {
  // ── recording state ──
  final _recorder = AudioRecorder();
  final _focus = FocusNode();

  /// Painel de emoji aberto no lugar do teclado (estilo WhatsApp).
  bool _emojiOpen = false;
  bool _isRecording = false;
  bool _isCancelling = false;
  String? _recordingPath;
  int _recordingSeconds = 0;
  Timer? _recordTimer;

  // ── animation (pulse while recording) ──
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    _focus.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── helpers ──
  String _fmtSeconds(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _startRecording() async {
    if (_isRecording) {
      return; // evita double-start (tap + longPress simultâneos)
    }
    final perm = await _recorder.hasPermission();
    if (!perm) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).chatMicDenied)));
      }
      return;
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/brawe_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _isRecording = true;
      _isCancelling = false;
      _recordingPath = path;
      _recordingSeconds = 0;
    });
    _pulseCtrl.repeat(reverse: true);
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isRecording) setState(() => _recordingSeconds++);
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _stopAndSend() async {
    if (!_isRecording) return;
    _recordTimer?.cancel();
    _pulseCtrl.stop();
    await _recorder.stop();
    final path = _recordingPath;
    final secs = _recordingSeconds;
    setState(() {
      _isRecording = false;
      _isCancelling = false;
    });
    if (path == null || secs < 1) return; // muito curto → descartar
    await ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .sendAudio(filePath: path, duration: secs);
    widget.onScrollToBottom();
    HapticFeedback.lightImpact();
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    _recordTimer?.cancel();
    _pulseCtrl.stop();
    await _recorder.stop();
    // Apagar ficheiro
    if (_recordingPath != null) {
      try {
        File(_recordingPath!).deleteSync();
      } catch (_) {}
    }
    setState(() {
      _isRecording = false;
      _isCancelling = false;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
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
              child: widget.replyingTo == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 3,
                              height: 34,
                              decoration: BoxDecoration(
                                color: context.colors.accentPrimary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    S.of(context).chatDetailReplying,
                                    style: TextStyle(
                                      color: context.colors.accentPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _richPreviewLabel(
                                          S.of(context),
                                          widget.replyingTo!.messageType,
                                          widget.replyingTo!.content,
                                        ) ??
                                        widget.replyingTo!.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.colors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.x,
                                size: 16,
                                color: context.colors.textTertiary,
                              ),
                              onPressed: widget.onClearReply,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            // ===== Recording bar OR normal input =====
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isRecording
                  ? _RecordingBar(
                      key: const ValueKey('rec'),
                      seconds: _recordingSeconds,
                      isCancelling: _isCancelling,
                      fmtSeconds: _fmtSeconds,
                    )
                  : Padding(
                      key: const ValueKey('input'),
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _IconRoundButton(
                            icon: LucideIcons.paperclip,
                            onTap: () => _showAttachSheet(context),
                          ),
                          const SizedBox(width: 4),
                          _IconRoundButton(
                            icon: widget.viewOnce
                                ? LucideIcons.flame
                                : LucideIcons.flame,
                            onTap: widget.onToggleViewOnce,
                            tint: widget.viewOnce
                                ? context.colors.danger
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.colors.surfaceElevated,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: widget.controller,
                                      focusNode: _focus,
                                      onTap: () {
                                        if (_emojiOpen) {
                                          setState(() => _emojiOpen = false);
                                        }
                                      },
                                      onChanged: widget.onChanged,
                                      minLines: 1,
                                      maxLines: 5,
                                      style: TextStyle(
                                        color: context.colors.textPrimary,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: S
                                            .of(context)
                                            .chatDetailMessageHint,
                                        hintStyle: TextStyle(
                                          color: context.colors.textSecondary,
                                        ),
                                        // A pílula do composer já é o fundo: anula o
                                        // fill/bordas do inputDecorationTheme global.
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 11,
                                            ),
                                      ),
                                    ),
                                  ),
                                  // GIF (GIPHY): some enquanto há texto, para dar espaço ao campo.
                                  if (!widget.hasText)
                                    IconButton(
                                      tooltip: S.of(context).gifButtonSemantics,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 44,
                                      ),
                                      icon: Icon(
                                        LucideIcons.imagePlay,
                                        size: 22,
                                        color: context.colors.textSecondary,
                                      ),
                                      onPressed: _pickGif,
                                    ),
                                  // Emoji ⇄ teclado: o painel abre no
                                  // lugar do teclado e o texto continua
                                  // visível; o emoji entra no campo (não
                                  // envia sozinho).
                                  IconButton(
                                    tooltip: _emojiOpen
                                        ? S.of(context).chatEmojiKeyboard
                                        : null,
                                    icon: Icon(
                                      _emojiOpen
                                          ? LucideIcons.keyboard
                                          : LucideIcons.smile,
                                      color: _emojiOpen
                                          ? context.colors.accentPrimary
                                          : context.colors.textSecondary,
                                    ),
                                    onPressed: () {
                                      if (_emojiOpen) {
                                        setState(() => _emojiOpen = false);
                                        _focus.requestFocus();
                                      } else {
                                        _focus.unfocus();
                                        setState(() => _emojiOpen = true);
                                      }
                                    },
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
                            child: widget.hasText
                                ? _SendButton(
                                    key: const ValueKey('send'),
                                    onTap: widget.isSending
                                        ? null
                                        : widget.onSend,
                                    loading: widget.isSending,
                                  )
                                : _MicButton(
                                    key: const ValueKey('mic'),
                                    isRecording: _isRecording,
                                    isCancelling: _isCancelling,
                                    pulseAnim: _pulseAnim,
                                    onPointerDown: (_) => _startRecording(),
                                    onPointerUp: (_) {
                                      if (_isCancelling) {
                                        _cancelRecording();
                                      } else {
                                        _stopAndSend();
                                      }
                                    },
                                    onPointerMove: (e) {
                                      final dx =
                                          e.localPosition.dx -
                                          23; // centro do botão 46/2
                                      setState(() {
                                        _isCancelling = dx < -60;
                                      });
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
            // Painel de emoji no lugar do teclado.
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: _emojiOpen && !_isRecording
                  ? _EmojiPickerSheet(
                      inline: true,
                      onPick: (e) {
                        _insertEmoji(widget.controller, e);
                        widget.onChanged(widget.controller.text);
                      },
                      onGifPick: widget.onSendGif == null
                          ? null
                          : (url) {
                              setState(() => _emojiOpen = false);
                              widget.onSendGif!(url);
                            },
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre o seletor de GIFs e envia o escolhido como DM `gif`.
  Future<void> _pickGif() async {
    _focus.unfocus();
    final gif = await showGifPicker(context);
    if (gif == null || !mounted) return;
    await ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .sendGif(gif);
    widget.onScrollToBottom();
  }

  /// Localização atual: confirma, pede permissão e envia.
  Future<void> _sendLocation() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.chatLocationConfirmTitle),
        content: Text(s.chatLocationConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.chatSend),
          ),
        ],
      ),
    );
    if (ok != true) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      messenger.showSnackBar(SnackBar(content: Text(s.chatLocationDenied)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(s.chatLocationGetting),
        duration: const Duration(seconds: 2),
      ),
    );
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      await ref
          .read(chatDetailViewModelProvider(widget.conversationId).notifier)
          .sendLocation(pos.latitude, pos.longitude);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.chatLocationError)));
    }
  }

  /// Escolhe um documento e envia.
  Future<void> _pickFile() async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'csv',
        'zip',
        'rar',
      ],
    );
    final f = res?.files.singleOrNull;
    if (f == null || f.path == null) return;
    await ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .sendFile(f.path!, name: f.name);
  }

  void _showAttachSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Largura total como as demais gavetas (sem isso a gaveta encolhia até a
      // largura da fileira de botões e ficava estreita, centralizada).
      constraints: const BoxConstraints(maxWidth: 640),
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    _AttachOption(
                      icon: LucideIcons.image,
                      label: S.of(context).chatDetailAttachGallery,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        widget.onPickImage(ImageSource.gallery);
                      },
                    ),
                    _AttachOption(
                      icon: LucideIcons.camera,
                      label: S.of(context).chatDetailAttachCamera,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        widget.onPickImage(ImageSource.camera);
                      },
                    ),
                    _AttachOption(
                      icon: LucideIcons.mapPin,
                      label: S.of(context).chatDetailAttachLocation,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _sendLocation();
                      },
                    ),
                    _AttachOption(
                      icon: LucideIcons.fileText,
                      label: S.of(context).chatDetailAttachFile,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _pickFile();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({
    super.key,
    required this.seconds,
    required this.isCancelling,
    required this.fmtSeconds,
  });

  final int seconds;
  final bool isCancelling;
  final String Function(int) fmtSeconds;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.danger,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            fmtSeconds(seconds),
            style: TextStyle(
              color: context.colors.danger,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isCancelling
                    ? context.colors.danger
                    : context.colors.textSecondary,
                fontSize: 13,
              ),
              child: Text(
                isCancelling
                    ? '← Solte para cancelar'
                    : '← Deslize para cancelar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    super.key,
    required this.pulseAnim,
    required this.isRecording,
    required this.isCancelling,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.onPointerMove,
  });

  final Animation<double> pulseAnim;
  final bool isRecording;
  final bool isCancelling;
  final void Function(PointerDownEvent) onPointerDown;
  final void Function(PointerUpEvent) onPointerUp;
  final void Function(PointerMoveEvent) onPointerMove;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: onPointerDown,
      onPointerUp: onPointerUp,
      onPointerMove: onPointerMove,
      child: ScaleTransition(
        scale: pulseAnim,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRecording
                ? (isCancelling
                      ? context.colors.textTertiary
                      : context.colors.danger)
                : context.colors.accentPrimary,
          ),
          child: Icon(
            isRecording ? LucideIcons.square : LucideIcons.mic,
            color: context.colors.textOnAccent,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _IconRoundButton extends StatelessWidget {
  const _IconRoundButton({required this.icon, required this.onTap, this.tint});
  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: tint ?? context.colors.textPrimary, size: 22),
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
        decoration: BoxDecoration(
          color: context.colors.accentPrimary,
          shape: BoxShape.circle,
        ),
        child: loading
            ? Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.textOnAccent,
                ),
              )
            : Icon(
                LucideIcons.send,
                color: context.colors.textOnAccent,
                size: 20,
              ),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colors.accentPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: context.colors.accentPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MoreMenuItem
// ─────────────────────────────────────────────────────────────────────────────
class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.textPrimary;
    final isDanger = color == context.colors.danger;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDanger
                ? context.colors.danger.withValues(alpha: 0.07)
                : context.colors.surfaceHighest,
          ),
          child: Row(
            children: [
              Icon(icon, color: effectiveColor, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _relative(BuildContext context, DateTime dt) {
  final s = S.of(context);
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return s.chatDetailRelativeNow;
  if (diff.inHours < 1) return s.chatDetailRelativeMinutes(diff.inMinutes);
  if (diff.inDays < 1) return s.chatDetailRelativeHours(diff.inHours);
  if (diff.inDays < 7) return s.chatDetailRelativeDays(diff.inDays);
  return '${dt.day}/${dt.month}';
}

// ---------------------------------------------------------------------------
// Shared post preview card (Instagram-like rich link preview inside DM)
// ---------------------------------------------------------------------------

/// Provider de busca de post para preview no chat (cacheado por postId).
final sharedPostPreviewProvider = FutureProvider.autoDispose
    .family<Post, String>((ref, postId) async {
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
        ? context.colors.surface
        : context.colors.background.withValues(alpha: 0.55);
    final border = isMe
        ? context.colors.textOnAccent.withValues(alpha: 0.25)
        : context.colors.border;

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
          loading: () => _buildSkeleton(context),
          error: (_, _) => _buildError(context),
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
            aspectRatio:
                isVideoMedia(mediaType: post.mediaType, url: post.imageUrl)
                ? feedFrameAspect(
                    post.aspectRatio ?? MediaAspectCache.get(post.imageUrl),
                  )
                : 1,
            child: isVideoMedia(mediaType: post.mediaType, url: post.imageUrl)
                ? Container(
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                        // Capa do vídeo (antes era só um ícone de play).
                        if ((post.coverUrl ?? '').isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: post.coverUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 600,
                            errorWidget: (_, _, _) => const SizedBox.shrink(),
                          ),
                        Center(
                          child: Icon(
                            LucideIcons.circlePlay,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 48,
                            shadows: const [
                              Shadow(color: Colors.black45, blurRadius: 10),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.video,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  S.of(context).createVideoTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : CachedNetworkImage(
                    memCacheWidth: context.decodePx(280),
                    imageUrl: post.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: context.colors.surfaceElevated),
                    errorWidget: (_, _, _) => Container(
                      color: context.colors.surfaceElevated,
                      child: Icon(
                        LucideIcons.imageOff,
                        color: context.colors.textSecondary,
                      ),
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
                    backgroundColor: context.colors.surfaceElevated,
                    backgroundImage:
                        (post.author.avatarUrl != null &&
                            post.author.avatarUrl!.isNotEmpty)
                        ? ResizeImage(
                            NetworkImage(post.author.avatarUrl!),
                            width: context.decodePx(22),
                          )
                        : null,
                    child:
                        (post.author.avatarUrl == null ||
                            post.author.avatarUrl!.isEmpty)
                        ? Icon(
                            LucideIcons.user,
                            color: context.colors.textPrimary,
                            size: 12,
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      post.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (post.author.isVerified)
                    const VerifiedBadge(size: 13, gap: 3),
                ],
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                BraweRichText(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    LucideIcons.heart,
                    size: 12,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${post.likesCount}',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    LucideIcons.messageCircle,
                    size: 12,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${post.commentsCount}',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    S.of(context).chatDetailViewPost,
                    style: TextStyle(
                      color: context.colors.accentPrimary,
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

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(color: context.colors.surfaceElevated),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 10,
                color: context.colors.surfaceElevated,
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 10,
                color: context.colors.surfaceElevated,
              ),
              const SizedBox(height: 6),
              Container(
                width: 80,
                height: 10,
                color: context.colors.surfaceElevated,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(LucideIcons.link, size: 16, color: context.colors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              S.of(context).chatDetailPostUnavailable,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPost(BuildContext context) {
    // Abre o bottom sheet rico: preview + ações sem sair da conversa.
    // Tem botão "Ver publicação completa" caso o user queira navegar.
    SharedPostSheet.show(context, postId);
  }
}

class _WaveformPreview extends StatefulWidget {
  const _WaveformPreview({this.isRecording = true});
  final bool isRecording;
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
            final v = widget.isRecording
                ? (0.45 + 0.55 * (0.5 + 0.5 * math.sin(phase)))
                : 0.25 + 0.15 * math.sin(i.toDouble());
            return Container(
              width: 4,
              height: 48 * v,
              decoration: BoxDecoration(
                color: context.colors.accentPrimary,
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
// Voice Recorder Sheet — gravação real
// ============================================================

class _VoiceRecorderSheet extends StatefulWidget {
  const _VoiceRecorderSheet({required this.onSend});
  final Future<void> Function(String filePath, int duration) onSend;

  @override
  State<_VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<_VoiceRecorderSheet> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isSending = false;
  bool _hasRecording = false;
  String? _filePath;
  int _seconds = 0;
  int _recordedSeconds = 0;
  Timer? _timer;

  // Playback
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _playPosition = Duration.zero;
  Duration _playDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRecording && mounted) setState(() => _seconds++);
    });
  }

  Future<void> _startRecording() async {
    final perm = await _recorder.hasPermission();
    if (!perm) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).chatMicDenied)));
        Navigator.pop(context);
      }
      return;
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/brawe_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _isRecording = true;
      _filePath = path;
      _seconds = 0;
    });
    _startTimer();
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
      _recordedSeconds = _seconds;
    });
    // Preparar player
    if (_filePath != null) {
      await _player.setFilePath(_filePath!);
      final dur = await _player.durationFuture;
      if (dur != null && mounted) {
        setState(() => _playDuration = dur);
      }
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _playPosition = pos);
      });
      _player.playerStateStream.listen((s) {
        if (mounted) setState(() => _isPlaying = s.playing);
        if (s.processingState == ProcessingState.completed && mounted) {
          // Pausa antes do seek para evitar auto-replay do just_audio.
          _player.pause();
          _player.seek(Duration.zero);
          setState(() {
            _isPlaying = false;
            _playPosition = Duration.zero;
          });
        }
      });
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.seek(
        _playPosition >= _playDuration ? Duration.zero : _playPosition,
      );
      await _player.play();
    }
  }

  Future<void> _send() async {
    if (_filePath == null) return;
    setState(() => _isSending = true);
    await _player.stop();
    try {
      await widget.onSend(_filePath!, _recordedSeconds);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        28 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Ícone
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.accentPrimary,
            ),
            child: Icon(
              _hasRecording ? LucideIcons.mic : LucideIcons.mic,
              color: context.colors.textOnAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // Timer
          Text(
            _fmt(_isRecording ? _seconds : _recordedSeconds),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          // Waveform
          SizedBox(
            height: 48,
            child: _WaveformPreview(isRecording: _isRecording),
          ),
          const SizedBox(height: 24),
          // Botões
          if (_isRecording) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _stopRecording,
                icon: Icon(
                  LucideIcons.square,
                  color: context.colors.textOnAccent,
                ),
                label: Text(
                  S.of(context).chatxStop,
                  style: TextStyle(
                    color: context.colors.textOnAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (_hasRecording) ...[
            Row(
              children: [
                // Play/pause
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.accentPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _togglePlay,
                    icon: Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: context.colors.accentPrimary,
                    ),
                    label: Text(
                      _isPlaying
                          ? '${_fmt(_playPosition.inSeconds)} / ${_fmt(_playDuration.inSeconds)}'
                          : S.of(context).chatxListen,
                      style: TextStyle(
                        color: context.colors.accentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Enviar
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.accentPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colors.textOnAccent,
                            ),
                          )
                        : Icon(
                            LucideIcons.send,
                            color: context.colors.textOnAccent,
                          ),
                    label: Text(
                      S.of(context).chatSend,
                      style: TextStyle(
                        color: context.colors.textOnAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                _player.stop();
                Navigator.pop(context);
              },
              icon: Icon(
                LucideIcons.trash2,
                color: context.colors.textSecondary,
                size: 18,
              ),
              label: Text(
                S.of(context).composerDiscard,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Audio bubble — player inline na bolha
// ============================================================

class _AudioBubbleContent extends StatefulWidget {
  const _AudioBubbleContent({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  @override
  State<_AudioBubbleContent> createState() => _AudioBubbleContentState();
}

class _AudioBubbleContentState extends State<_AudioBubbleContent> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      if (d != null && mounted) setState(() => _duration = d);
    });
    _player.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s.playing);
      if (s.processingState == ProcessingState.completed) {
        // IMPORTANTE: pausar ANTES do seek, senão o just_audio
        // reinicia a reprodução automaticamente (auto-replay).
        _player.pause();
        _player.seek(Duration.zero);
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
    // Prefill duration from model
    if (widget.message.audioDuration != null) {
      _duration = Duration(seconds: widget.message.audioDuration!);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    if (!_loaded) {
      final url = widget.message.content;
      if (url.startsWith('http')) {
        setState(() => _isLoading = true);
        try {
          await _player.setUrl(url);
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        await _player.setFilePath(url);
      }
      _loaded = true;
    }
    await _player.seek(_position >= _duration ? Duration.zero : _position);
    await _player.play();
  }

  String _fmt(Duration d) {
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/pause button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.accentPrimary,
              ),
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.textOnAccent,
                      ),
                    )
                  : Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: context.colors.textOnAccent,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // Progress + timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: widget.isMe
                        ? context.colors.textOnAccent.withValues(alpha: 0.2)
                        : context.colors.border,
                    valueColor: AlwaysStoppedAnimation(
                      widget.isMe
                          ? context.colors.textOnAccent
                          : context.colors.accentPrimary,
                    ),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmt(_isPlaying ? _position : _position)} / ${_fmt(_duration)}',
                  style: TextStyle(
                    color: widget.isMe
                        ? context.colors.textOnAccent.withValues(alpha: 0.75)
                        : context.colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            LucideIcons.mic,
            size: 16,
            color: widget.isMe
                ? context.colors.textOnAccent.withValues(alpha: 0.6)
                : context.colors.textTertiary,
          ),
        ],
      ),
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
    final s = S.of(context);
    final preview = reply.isBurned
        ? s.chatDetailBurnedPreview
        : _richPreviewLabel(s, reply.messageType, reply.content) ??
              (reply.content.isEmpty ? '...' : reply.content);
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.18)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isMe
                ? context.colors.textOnAccent
                : context.colors.accentSecondary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s.chatDetailReplying,
            style: TextStyle(
              color: isMe
                  ? context.colors.textOnAccent
                  : context.colors.accentPrimary,
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
              color: isMe
                  ? context.colors.textOnAccent.withValues(alpha: 0.75)
                  : context.colors.textSecondary,
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
      children: entries
          .map((e) {
            final count = e.value.length;
            return GestureDetector(
              onTap: () => onTap(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentPrimary.withValues(alpha: 0.22),
                      context.colors.accentSecondary.withValues(alpha: 0.22),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 13)),
                    if (count > 1) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$count',
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

// ===========================================================================
// Emoji Picker (lightweight, no external deps)
// ===========================================================================

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
  const _EmojiPickerSheet({
    required this.onPick,
    this.onGifPick,
    this.inline = false,
  });
  final ValueChanged<String> onPick;
  final void Function(String gifUrl)? onGifPick;

  /// `true` = painel embutido no lugar do teclado (não é bottom sheet).
  final bool inline;

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet>
    with SingleTickerProviderStateMixin {
  // 0 = emoji tabs, last tab = GIF
  int _tab = 0;
  bool get _isGifTab => _tab == _emojiTabs.length;

  static const List<String> _emojiTabs = [
    'Smileys',
    'Gestos',
    'Coração',
    'Animais',
    'Comida',
    'Festa',
    'Objetos',
  ];

  static const Map<String, List<String>> _categories = {
    'Smileys': [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '🤣',
      '😂',
      '🙂',
      '🙃',
      '😉',
      '😊',
      '😇',
      '🥰',
      '😍',
      '🤩',
      '😘',
      '😗',
      '😚',
      '😙',
      '😋',
      '😛',
      '😜',
      '🤪',
      '😝',
      '🤑',
      '🤗',
      '🤭',
      '🤫',
      '🤔',
      '🤐',
      '😐',
      '😑',
      '😶',
      '😏',
      '😒',
      '🙄',
      '😬',
      '🤥',
      '😌',
      '😔',
      '😪',
      '🤤',
      '😴',
      '😷',
      '🤒',
      '🤕',
      '🤧',
      '🥵',
      '🥶',
      '🥴',
      '😵',
      '🤯',
      '🤠',
      '🥳',
      '😎',
      '🤓',
      '🧐',
      '😕',
      '😟',
      '🙁',
      '☹️',
      '😮',
      '😯',
      '😲',
      '😳',
      '🥺',
      '😦',
      '😧',
      '😨',
      '😰',
      '😥',
      '😢',
      '😭',
      '😱',
      '😖',
      '😣',
      '😞',
      '😓',
      '😩',
      '😫',
      '🥱',
      '😤',
      '😡',
      '😠',
      '🤬',
      '😈',
      '👿',
      '💀',
      '☠️',
      '💩',
      '🤡',
      '👹',
      '👺',
      '👻',
      '👽',
    ],
    'Gestos': [
      '👋',
      '🤚',
      '🖐',
      '✋',
      '🖖',
      '👌',
      '🤏',
      '✌️',
      '🤞',
      '🤟',
      '🤘',
      '🤙',
      '👈',
      '👉',
      '👆',
      '🖕',
      '👇',
      '☝️',
      '👍',
      '👎',
      '✊',
      '👊',
      '🤛',
      '🤜',
      '👏',
      '🙌',
      '👐',
      '🤲',
      '🤝',
      '🙏',
      '💅',
      '🤳',
      '💪',
      '🦾',
      '🦿',
      '🦵',
      '🦶',
      '👂',
      '🦻',
      '👃',
      '🧠',
      '🦷',
      '🦴',
      '👀',
      '👁',
      '👅',
      '👄',
      '💋',
    ],
    'Coração': [
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '🤎',
      '💔',
      '❣️',
      '💕',
      '💞',
      '💓',
      '💗',
      '💖',
      '💘',
      '💝',
      '💟',
      '♥️',
      '💌',
      '💍',
      '💐',
      '🌹',
    ],
    'Animais': [
      '🐶',
      '🐱',
      '🐭',
      '🐹',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🐨',
      '🐯',
      '🦁',
      '🐮',
      '🐷',
      '🐽',
      '🐸',
      '🐵',
      '🙈',
      '🙉',
      '🙊',
      '🐒',
      '🐔',
      '🐧',
      '🐦',
      '🐤',
      '🦆',
      '🦅',
      '🦉',
      '🦇',
      '🐺',
      '🐗',
      '🐴',
      '🦄',
      '🐝',
      '🪱',
      '🐛',
      '🦋',
    ],
    'Comida': [
      '🍎',
      '🍐',
      '🍊',
      '🍋',
      '🍌',
      '🍉',
      '🍇',
      '🍓',
      '🫐',
      '🍈',
      '🍒',
      '🍑',
      '🥭',
      '🍍',
      '🥥',
      '🥝',
      '🍅',
      '🍆',
      '🥑',
      '🥦',
      '🥬',
      '🥒',
      '🌶',
      '🫑',
      '🌽',
      '🥕',
      '🫒',
      '🧄',
      '🧅',
      '🥔',
      '🍠',
      '🥐',
      '🥨',
      '🍞',
      '🥖',
      '🧀',
      '🍕',
      '🍔',
      '🍟',
      '🌭',
      '🥪',
      '🌮',
      '🌯',
      '🥙',
      '🧆',
      '🍝',
      '🍜',
      '🍲',
    ],
    'Festa': [
      '🎉',
      '🎊',
      '🎈',
      '🎂',
      '🎁',
      '🎀',
      '🪅',
      '🎆',
      '🎇',
      '✨',
      '🎃',
      '🎄',
      '🎋',
      '🎍',
      '🎎',
      '🎏',
      '🎐',
      '🧧',
      '🪔',
      '🎌',
      '🏆',
      '🥇',
      '🥈',
      '🥉',
      '🏅',
      '🎖',
      '🏵',
      '🎗',
      '🎫',
      '🎟',
      '🎪',
      '🎭',
      '🎨',
      '🎬',
      '🎤',
      '🎧',
    ],
    'Objetos': [
      '💎',
      '🔥',
      '💥',
      '💫',
      '⭐',
      '🌟',
      '✨',
      '⚡',
      '☄️',
      '🌈',
      '☀️',
      '🌙',
      '⛅',
      '☁️',
      '🌧',
      '⛈',
      '❄️',
      '☃️',
      '💧',
      '🌊',
      '🎵',
      '🎶',
      '💯',
      '✅',
      '❌',
      '⛔',
      '🚫',
      '💢',
      '💬',
      '💭',
      '🗯',
      '♨️',
      '💤',
      '🆗',
      '🆒',
      '🆕',
    ],
  };

  // Popular GIF URLs (hosted — curated static list, no API key needed)
  static const List<_GifItem> _popularGifs = [
    _GifItem(
      'https://media.tenor.com/images/fb17e4c4fa86b19a2e09c4a71f15e8b6/tenor.gif',
      '👏',
    ),
    _GifItem(
      'https://media.tenor.com/images/36e9b6cdddb1e7e4f45b46c8f8c0c3b0/tenor.gif',
      '😂',
    ),
    _GifItem(
      'https://media.tenor.com/images/e81cdea1620b8c10d38e5a19ef0e54f7/tenor.gif',
      '🔥',
    ),
    _GifItem(
      'https://media.tenor.com/images/4e52c65af2def9cb7a77e4a9a10d0a99/tenor.gif',
      '🎉',
    ),
    _GifItem(
      'https://media.tenor.com/images/9c7a2f4fbbf8fcb1c2bf27b97e7b6049/tenor.gif',
      '😎',
    ),
    _GifItem(
      'https://media.tenor.com/images/c6e4d6a5b2df1a1cdf3f2c3b1c9a0d62/tenor.gif',
      '💪',
    ),
    _GifItem(
      'https://media.tenor.com/images/59e56eae34c4720561a2cff6d2c4d5d2/tenor.gif',
      '❤️',
    ),
    _GifItem(
      'https://media.tenor.com/images/af4d5d79e7f55a2f7c1e4fec3bce7b48/tenor.gif',
      '🤩',
    ),
    _GifItem(
      'https://media.tenor.com/images/a3e8c2b0f94f4c5c8a7b6d1e2f3c4d5a/tenor.gif',
      '😴',
    ),
    _GifItem(
      'https://media.tenor.com/images/8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e/tenor.gif',
      '👍',
    ),
    _GifItem(
      'https://media.tenor.com/images/1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d/tenor.gif',
      '🥳',
    ),
    _GifItem(
      'https://media.tenor.com/images/d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8/tenor.gif',
      '👀',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final emojiTabLabels = <String>[
      s.chatDetailEmojiSmileys,
      s.chatDetailEmojiGestures,
      s.chatDetailEmojiHearts,
      s.chatDetailEmojiAnimals,
      s.chatDetailEmojiFood,
      s.chatDetailEmojiParty,
      s.chatDetailEmojiObjects,
    ];
    final allTabs = [...emojiTabLabels, 'GIF'];
    final emojis = _isGifTab
        ? <String>[]
        : (_categories[_emojiTabs[_tab]] ?? []);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: widget.inline ? 280 : MediaQuery.of(context).size.height * 0.45,
        child: Column(
          children: [
            if (!widget.inline) ...[
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Tabs
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: allTabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final selected = i == _tab;
                  final isGif = i == _emojiTabs.length;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.colors.accentPrimary
                            : isGif
                            ? context.colors.accentPrimary.withValues(
                                alpha: 0.12,
                              )
                            : context.colors.surfaceHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: isGif && !selected
                            ? Border.all(
                                color: context.colors.accentPrimary.withValues(
                                  alpha: 0.35,
                                ),
                              )
                            : null,
                      ),
                      child: isGif
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.film,
                                  color: selected
                                      ? context.colors.textOnAccent
                                      : context.colors.accentPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'GIF',
                                  style: TextStyle(
                                    color: selected
                                        ? context.colors.textOnAccent
                                        : context.colors.accentPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              allTabs[i],
                              style: TextStyle(
                                color: selected
                                    ? context.colors.textOnAccent
                                    : context.colors.textSecondary,
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
            // Grid — emoji or GIF
            Expanded(
              child: _isGifTab
                  ? _GifGrid(
                      gifs: _popularGifs,
                      onPick: (url) {
                        if (widget.onGifPick != null) {
                          widget.onGifPick!(url);
                          if (!widget.inline) Navigator.pop(context);
                        }
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
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
                            HapticFeedback.selectionClick();
                          },
                          child: Center(
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 26),
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// GIF support
// ─────────────────────────────────────────────────────────────────────────────

class _GifItem {
  const _GifItem(this.url, this.label);
  final String url;
  final String label;
}

class _GifGrid extends StatelessWidget {
  const _GifGrid({required this.gifs, required this.onPick});
  final List<_GifItem> gifs;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.4,
      ),
      itemCount: gifs.length,
      itemBuilder: (_, i) {
        final gif = gifs[i];
        return GestureDetector(
          onTap: () => onPick(gif.url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  cacheWidth: context.decodeScreenFracPx(1 / 3),
                  gif.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: context.colors.surfaceElevated,
                    child: Center(
                      child: Text(
                        gif.label,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: context.colors.surfaceElevated,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colors.accentPrimary,
                        ),
                      ),
                    );
                  },
                ),
                // GIF label badge
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'GIF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
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
    } catch (_) {
      /* não é JSON válido */
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final data = _decode();
    final title =
        (data['title'] as String?) ?? S.of(context).chatDetailLiveFallbackTitle;
    final streamerName = (data['streamer_name'] as String?) ?? '';
    final streamerAvatar = data['streamer_avatar'] as String?;
    final thumb = data['thumbnail_url'] as String?;
    final note = (data['note'] as String?) ?? '';
    final slugOrId =
        (data['slug'] as String?) ?? (data['room_id'] as String?) ?? '';
    final status = (data['status'] as String?) ?? 'live';
    final isLive = status == 'live';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.colors.surface,
        border: Border.all(
          color: context.colors.accentPrimary.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.accentPrimary.withValues(alpha: 0.18),
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
                        cacheWidth: context.decodeScreenPx,
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            ColoredBox(color: context.colors.surfaceHighest),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.accentPrimary,
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.video,
                            color: context.colors.textSecondary,
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
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.danger,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.danger.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.circle,
                                color: Colors.white,
                                size: 8,
                              ),
                              SizedBox(width: 4),
                              Text(
                                S.of(context).liveBadgeLive,
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
                    Center(
                      child: Icon(
                        LucideIcons.circlePlay,
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
                          backgroundColor: context.colors.surfaceElevated,
                          backgroundImage:
                              (streamerAvatar != null &&
                                  streamerAvatar.isNotEmpty)
                              ? ResizeImage(
                                  NetworkImage(streamerAvatar),
                                  width: context.decodePx(28),
                                )
                              : null,
                          child:
                              (streamerAvatar == null || streamerAvatar.isEmpty)
                              ? Icon(
                                  LucideIcons.user,
                                  size: 14,
                                  color: context.colors.textTertiary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            streamerName.isNotEmpty
                                ? streamerName
                                : S.of(context).chatDetailStreamerFallback,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.textPrimary,
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
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.colors.textSecondary,
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
                        Icon(
                          LucideIcons.play,
                          color: context.colors.accentSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLive
                              ? S.of(context).chatDetailLiveTapToWatch
                              : S.of(context).chatDetailLiveSeeDetails,
                          style: TextStyle(
                            color: context.colors.accentPrimary,
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

/// Rótulo curto para citar mensagens que não são texto (imagem, áudio,
/// story, cofre, localização, arquivo). `null` = é texto, usar o conteúdo.
String? _richPreviewLabel(S s, String type, String content) {
  switch (type) {
    case 'image':
      return s.chatDetailReplyImagePreview;
    case 'audio':
      return '🎤';
    case 'agency_invite':
      return '🤝 ${s.agencyChatPreview}';
    case 'location':
      return '📍 ${s.chatLocationTitle}';
    case 'story_gift':
      return '🎁 ${s.chatVaultReceived}';
    case 'story_reaction':
    case 'story_reply':
      return '📸 Story';
    case 'file':
      try {
        final m = jsonDecode(content);
        if (m is Map && m['name'] != null) return '📎 ${m['name']}';
      } catch (_) {}
      return '📎 ${s.chatDetailAttachFile}';
    default:
      return null;
  }
}
