import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/text/brawe_rich_text.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../domain/models/conversation.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../view_models/chat_list_view_model.dart';

/// Folhas extras do chat: editar, encaminhar e buscar na conversa.

// ─────────────────────────────────────────────────────────────────────────────
// Editar

/// Abre a edição de uma mensagem de texto. Devolve o texto novo (ou null).
Future<String?> showEditMessageSheet(BuildContext context, String initial) {
  return showModalBottomSheet<String>(
    useRootNavigator: true,
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceElevated,
    builder: (ctx) => _EditSheet(initial: initial),
  );
}

class _EditSheet extends StatefulWidget {
  const _EditSheet({required this.initial});
  final String initial;
  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _c = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final changed =
        _c.text.trim().isNotEmpty && _c.text.trim() != widget.initial.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.chatEditTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _c,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 6,
                      maxLength: 4000,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: changed
                        ? () => Navigator.pop(context, _c.text.trim())
                        : null,
                    style: FilledButton.styleFrom(shape: const StadiumBorder()),
                    child: Text(s.chatEditSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Encaminhar

/// Tipos que podem ser encaminhados.
bool canForward(ChatMessage m) =>
    !m.isBurned &&
    !m.isViewOnce &&
    !m.isPending &&
    const {'text', 'image', 'location', 'file'}.contains(m.messageType);

Future<void> showForwardSheet(
  BuildContext context, {
  required ChatMessage message,
  required String currentConversationId,
}) {
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceElevated,
    builder: (ctx) => _ForwardSheet(
      message: message,
      currentConversationId: currentConversationId,
      hostContext: context,
    ),
  );
}

class _ForwardSheet extends ConsumerStatefulWidget {
  const _ForwardSheet({
    required this.message,
    required this.currentConversationId,
    required this.hostContext,
  });
  final ChatMessage message;
  final String currentConversationId;
  final BuildContext hostContext;

  @override
  ConsumerState<_ForwardSheet> createState() => _ForwardSheetState();
}

class _ForwardSheetState extends ConsumerState<_ForwardSheet> {
  final Set<String> _sending = {};
  final Set<String> _sent = {};

  Future<void> _send(Conversation c) async {
    if (_sending.contains(c.id) || _sent.contains(c.id)) return;
    setState(() => _sending.add(c.id));
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendRaw(
            conversationId: c.id,
            content: widget.message.content,
            messageType: widget.message.messageType,
            isForwarded: true,
          );
      if (!mounted) return;
      setState(() {
        _sending.remove(c.id);
        _sent.add(c.id);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending.remove(c.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final convs = ref
        .watch(chatListViewModelProvider)
        .conversations
        .where((c) => c.id != widget.currentConversationId && !c.isArchived)
        .toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.chatForwardTitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_sent.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        MaterialLocalizations.of(context).okButtonLabel,
                      ),
                    ),
                ],
              ),
            ),
            if (convs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  s.chatForwardEmpty,
                  style: TextStyle(color: colors.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: convs.length,
                  itemBuilder: (_, i) {
                    final c = convs[i];
                    final sent = _sent.contains(c.id);
                    final sending = _sending.contains(c.id);
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: colors.surfaceHighest,
                        backgroundImage:
                            (c.participantAvatarUrl != null &&
                                c.participantAvatarUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(
                                c.participantAvatarUrl!,
                              )
                            : null,
                        child:
                            (c.participantAvatarUrl == null ||
                                c.participantAvatarUrl!.isEmpty)
                            ? Text(
                                c.participantName.isEmpty
                                    ? '?'
                                    : c.participantName[0].toUpperCase(),
                              )
                            : null,
                      ),
                      title: Text(
                        c.participantName,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : sent
                          ? Icon(LucideIcons.check, color: colors.accentPrimary)
                          : FilledButton(
                              onPressed: () => _send(c),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 32),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(s.chatSend),
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
// Buscar na conversa

Future<void> showChatSearchSheet(
  BuildContext context, {
  required String conversationId,
}) {
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceElevated,
    builder: (_) => _SearchSheet(conversationId: conversationId),
  );
}

class _SearchSheet extends ConsumerStatefulWidget {
  const _SearchSheet({required this.conversationId});
  final String conversationId;
  @override
  ConsumerState<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends ConsumerState<_SearchSheet> {
  Timer? _debounce;
  String _q = '';
  bool _loading = false;
  List<ChatMessage> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(v.trim()));
  }

  Future<void> _run(String q) async {
    setState(() => _q = q);
    if (q.length < 2) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await ref
          .read(chatRepositoryProvider)
          .searchMessages(widget.conversationId, q);
      if (!mounted || q != _q) return;
      setState(() {
        _results = r;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _textOf(ChatMessage m) {
    if (m.messageType == 'story_reply') {
      return m.payload?['text']?.toString() ?? '';
    }
    return m.content;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final loc = MaterialLocalizations.of(context);

    Widget body;
    if (_q.length < 2) {
      body = _hint(s.chatSearchMinChars, colors);
    } else if (_loading) {
      body = const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_results.isEmpty) {
      body = _hint(s.chatSearchEmpty, colors);
    } else {
      body = ListView.separated(
        shrinkWrap: true,
        itemCount: _results.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: colors.divider, indent: 16),
        itemBuilder: (_, i) {
          final m = _results[i];
          final text = _textOf(m);
          return ListTile(
            title: _highlight(text, _q, colors),
            subtitle: Text(
              '${loc.formatShortDate(m.timestamp)} · '
              '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(m.timestamp))}',
              style: TextStyle(color: colors.textTertiary, fontSize: 12),
            ),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: _onChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: s.chatMsgSearchHint,
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                  ),
                ),
              ),
              Flexible(child: body),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hint(String text, BraweColors colors) => Padding(
    padding: const EdgeInsets.all(32),
    child: Text(text, style: TextStyle(color: colors.textSecondary)),
  );

  /// Destaca o termo buscado no texto.
  Widget _highlight(String text, String q, BraweColors colors) {
    final plain = BraweRichText.humanize(text, sharedPostLabel: '📎');
    final lower = plain.toLowerCase();
    final i = lower.indexOf(q.toLowerCase());
    final base = TextStyle(color: colors.textPrimary, fontSize: 14);
    if (i < 0) {
      return Text(
        plain,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: plain.substring(0, i)),
          TextSpan(
            text: plain.substring(i, i + q.length),
            style: TextStyle(
              backgroundColor: colors.accentPrimary.withValues(alpha: 0.25),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: plain.substring(i + q.length)),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
