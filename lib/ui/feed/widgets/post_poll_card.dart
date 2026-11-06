import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post_poll.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

typedef PollVoter = Future<PostPoll> Function(String postId, String optionId);

/// Enquete no card do feed.
///
/// Estados: não votou (linhas tocáveis, sem resultados) · votou / encerrada
/// (barras de percentual animadas; minha escolha na cor da marca). O autor
/// recebe os resultados do servidor desde o início (sem mudar nada aqui). O voto é otimista: a escolha aparece
/// na hora e volta atrás se o servidor recusar.
class PostPollCard extends ConsumerStatefulWidget {
  const PostPollCard({
    super.key,
    required this.postId,
    required this.poll,
    this.onChanged,
    this.voter,
    this.clock = DateTime.now,
  });

  final String postId;
  final PostPoll poll;

  /// Avisa o pai com a enquete atualizada (para manter o post em sincronia).
  final ValueChanged<PostPoll>? onChanged;

  /// Injetável em teste; por padrão usa o [PostRepository].
  final PollVoter? voter;
  final DateTime Function() clock;

  @override
  ConsumerState<PostPollCard> createState() => _PostPollCardState();
}

class _PostPollCardState extends ConsumerState<PostPollCard> {
  late PostPoll _poll = widget.poll;
  String? _pending;

  @override
  void didUpdateWidget(covariant PostPollCard old) {
    super.didUpdateWidget(old);
    if (old.poll != widget.poll && _pending == null) _poll = widget.poll;
  }

  bool get _ended => _poll.isEnded(widget.clock());
  bool get _canVote => !_ended && !_poll.hasVoted && _pending == null;

  Future<void> _vote(PollOption o) async {
    if (!_canVote) return;
    final previous = _poll;
    setState(() => _pending = o.id);
    final voter = widget.voter ??
        (id, opt) => ref.read(postRepositoryProvider).votePoll(id, opt);
    final s = S.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final updated = await voter(widget.postId, o.id);
      if (!mounted) return;
      setState(() {
        _poll = updated;
        _pending = null;
      });
      widget.onChanged?.call(updated);
    } on PollVoteException catch (e) {
      if (!mounted) return;
      setState(() {
        _pending = null;
        _poll = e.code == 'poll_ended' ? previous.copyWith(ended: true) : previous;
      });
      messenger?.showSnackBar(SnackBar(
        content: Text(e.code == 'poll_ended' ? s.pollEndedMessage : s.pollAlreadyVoted),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pending = null;
        _poll = previous;
      });
      messenger?.showSnackBar(SnackBar(content: Text(s.pollVoteError)));
    }
  }

  String _endsLabel(S s) {
    final diff = _poll.endsAt.difference(widget.clock());
    if (diff.inDays >= 1) return s.pollEndsInDays(diff.inDays);
    if (diff.inHours >= 1) return s.pollEndsInHours(diff.inHours);
    return s.pollEndsInMinutes(diff.inMinutes < 1 ? 1 : diff.inMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    final showCounts = _poll.hasCounts && _pending == null;
    final String footer;
    if (showCounts) {
      final votes = s.pollVotesCount(_poll.totalVotes ?? 0);
      footer = '$votes · ${_ended ? s.pollEnded : _endsLabel(s)}';
    } else {
      footer = _ended
          ? s.pollEnded
          : '${s.pollVoteToSee} · ${_endsLabel(s)}';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final o in _poll.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PollRow(
                option: o,
                showBar: showCounts,
                mine: (_pending ?? _poll.myVote) == o.id,
                enabled: _canVote,
                onTap: () => _vote(o),
              ),
            ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(LucideIcons.chartBar, size: 13, color: c.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footer,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textTertiary, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PollRow extends StatelessWidget {
  const _PollRow({
    required this.option,
    required this.showBar,
    required this.mine,
    required this.enabled,
    required this.onTap,
  });

  final PollOption option;
  final bool showBar;
  final bool mine;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    final percent = showBar ? (option.percent ?? 0) : null;
    final radius = BorderRadius.circular(12);
    final label = percent == null ? option.text : '${option.text}, $percent%';
    return Semantics(
      button: enabled,
      selected: mine,
      label: mine ? '$label, ${s.pollMyVoteSemantics}' : label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: mine ? c.accentPrimary : c.border,
                width: mine ? 1.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  if (percent != null)
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: percent / 100),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (_, f, _) => Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: FractionallySizedBox(
                            widthFactor: f.clamp(0.0, 1.0),
                            heightFactor: 1,
                            child: ColoredBox(
                              color: mine
                                  ? c.accentPrimary.withValues(alpha: 0.28)
                                  : c.surfaceHighest,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        if (mine) ...[
                          Icon(LucideIcons.circleCheck, size: 16, color: c.accentPrimary),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            option.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14.5,
                              fontWeight: mine ? FontWeight.w700 : FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (percent != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            '$percent%',
                            style: TextStyle(
                              color: mine ? c.accentPrimary : c.textSecondary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
