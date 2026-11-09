// Privacidade › Pedidos para seguir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/privacy_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/verified_badge.dart';
import '../../core/widgets/brawe_avatar.dart';
import 'privacy_common.dart';

class FollowRequestsScreen extends ConsumerStatefulWidget {
  const FollowRequestsScreen({super.key});

  @override
  ConsumerState<FollowRequestsScreen> createState() =>
      _FollowRequestsScreenState();
}

class _FollowRequestsScreenState extends ConsumerState<FollowRequestsScreen> {
  List<PrivacyAccount>? _items;
  Object? _error;

  PrivacyRepository get _repo => ref.read(privacyRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _repo.followRequests();
      if (!mounted) return;
      setState(() {
        _items = r;
        _error = null;
      });
      ref.read(privacyProvider.notifier).setFollowRequests(r.length);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _resolve(PrivacyAccount a, {required bool accept}) async {
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
    final notifier = ref.read(privacyProvider.notifier);
    final before = _items ?? const [];
    final idx = before.indexWhere((e) => e.userId == a.userId);
    setState(() => _items = before.where((e) => e.userId != a.userId).toList());
    try {
      if (accept) {
        await _repo.acceptRequest(a.userId);
      } else {
        await _repo.declineRequest(a.userId);
      }
      notifier.bump(requestsDelta: -1);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final cur = [...?_items];
        cur.insert(idx < 0 || idx > cur.length ? cur.length : idx, a);
        _items = cur;
      });
      showPrivacyError(messenger, privacyErrorText(context, e), danger);
    }
  }

  Future<void> _acceptAll() async {
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
    final before = _items ?? const [];
    setState(() => _items = const []);
    try {
      await _repo.acceptAll();
      ref.read(privacyProvider.notifier).setFollowRequests(0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = before);
      showPrivacyError(messenger, privacyErrorText(context, e), danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
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
      body = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.userPlus, size: 44, color: colors.textTertiary),
              const SizedBox(height: 14),
              Text(
                s.privacyEmptyRequestsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.privacyEmptyRequestsBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final a = items[i];
          return InkWell(
            onTap: () => context.push('/profile/${a.userId}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  BraweAvatar(
                    avatarUrl: a.avatarUrl,
                    displayName: a.name,
                    size: 46,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                a.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (a.isVerified) const VerifiedBadge(size: 14),
                          ],
                        ),
                        if (a.username.isNotEmpty)
                          Text(
                            '@${a.username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _resolve(a, accept: true),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(s.privacyConfirm),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () => _resolve(a, accept: false),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colors.textPrimary,
                    ),
                    child: Text(s.privacyDelete),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.privacyFollowRequests),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          if ((items?.length ?? 0) > 1)
            TextButton(onPressed: _acceptAll, child: Text(s.privacyConfirmAll)),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: body,
        ),
      ),
    );
  }
}
