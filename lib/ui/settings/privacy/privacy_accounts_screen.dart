// Privacidade › Contas bloqueadas / silenciadas / restritas.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/privacy_repository.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/verified_badge.dart';
import '../../core/widgets/brawe_avatar.dart';
import 'privacy_common.dart';

class PrivacyAccountsScreen extends ConsumerStatefulWidget {
  const PrivacyAccountsScreen({super.key, required this.list});
  final PrivacyList list;

  @override
  ConsumerState<PrivacyAccountsScreen> createState() =>
      _PrivacyAccountsScreenState();
}

class _PrivacyAccountsScreenState extends ConsumerState<PrivacyAccountsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<PrivacyAccount>? _items;
  Object? _error;
  String _q = '';

  PrivacyRepository get _repo => ref.read(privacyRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final q = _q;
    try {
      final r = await _repo.list(widget.list, q: q);
      if (!mounted || q != _q) return;
      setState(() {
        _items = r;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _q = v.trim();
      _load();
    });
  }

  Future<void> _readd(PrivacyAccount a) async {
    switch (widget.list) {
      case PrivacyList.blocked:
        await ref.read(socialActionsServiceProvider).blockUser(a.userId);
      case PrivacyList.muted:
        await ref.read(socialActionsServiceProvider).muteUser(a.userId);
      case PrivacyList.restricted:
        await _repo.restrict(a.userId);
    }
  }

  Future<void> _action(PrivacyAccount a) async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
    final notifier = ref.read(privacyProvider.notifier);
    final list = widget.list;
    final items = _items ?? const [];
    final idx = items.indexWhere((e) => e.userId == a.userId);
    setState(() => _items = items.where((e) => e.userId != a.userId).toList());
    try {
      await _repo.remove(list, a.userId);
      notifier.bump(list: list, delta: -1);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final cur = [...?_items];
        cur.insert(idx < 0 || idx > cur.length ? cur.length : idx, a);
        _items = cur;
      });
      showPrivacyError(messenger, privacyErrorText(context, e), danger);
      return;
    }
    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (list) {
          PrivacyList.blocked => s.privacyUnblockedSnack(a.name),
          PrivacyList.muted => s.privacyUnmutedSnack(a.name),
          PrivacyList.restricted => s.privacyUnrestrictedSnack(a.name),
        }),
        action: SnackBarAction(
          label: s.privacyUndo,
          onPressed: () async {
            try {
              await _readd(a);
              notifier.bump(list: list, delta: 1);
              if (mounted) await _load();
            } catch (e) {
              showPrivacyError(
                messenger,
                e is PrivacyFailure && e.message.isNotEmpty
                    ? e.message
                    : s.privacyErrorGeneric,
                danger,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final list = widget.list;
    final title = switch (list) {
      PrivacyList.blocked => s.privacyBlocked,
      PrivacyList.muted => s.privacyMuted,
      PrivacyList.restricted => s.privacyRestricted,
    };
    final actionLabel = switch (list) {
      PrivacyList.blocked => s.privacyUnblock,
      PrivacyList.muted => s.privacyUnmute,
      PrivacyList.restricted => s.privacyUnrestrict,
    };
    final items = _items;

    Widget body;
    if (items == null && _error == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (items == null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              privacyErrorText(context, _error!),
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                setState(() => _error = null);
                _load();
              },
              child: Text(s.privacyRetry),
            ),
          ],
        ),
      );
    } else if (items.isEmpty) {
      body = _Empty(list: list, searching: _q.isNotEmpty);
    } else {
      final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
      body = ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final a = items[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: BraweAvatar(
              avatarUrl: a.avatarUrl,
              displayName: a.name,
              size: 46,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (a.isVerified) const VerifiedBadge(size: 14),
              ],
            ),
            subtitle: Text(
              [
                if (a.username.isNotEmpty) '@${a.username}',
                if (a.since != null) s.privacySince(fmt.format(a.since!)),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            trailing: OutlinedButton(
              onPressed: () => _action(a),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: colors.textPrimary,
              ),
              child: Text(actionLabel),
            ),
            onTap: () => context.push('/profile/${a.userId}'),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _search,
                  onChanged: _onSearch,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: s.privacySearchHint,
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 20,
                      color: colors.textTertiary,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.list, required this.searching});
  final PrivacyList list;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final icon = switch (list) {
      PrivacyList.blocked => LucideIcons.ban,
      PrivacyList.muted => LucideIcons.volumeX,
      PrivacyList.restricted => LucideIcons.userMinus,
    };
    final title = searching
        ? s.privacyNoResults
        : switch (list) {
            PrivacyList.blocked => s.privacyEmptyBlockedTitle,
            PrivacyList.muted => s.privacyEmptyMutedTitle,
            PrivacyList.restricted => s.privacyEmptyRestrictedTitle,
          };
    final body = searching
        ? null
        : switch (list) {
            PrivacyList.blocked => s.privacyEmptyBlockedBody,
            PrivacyList.muted => s.privacyEmptyMutedBody,
            PrivacyList.restricted => s.privacyEmptyRestrictedBody,
          };
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: colors.textTertiary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
