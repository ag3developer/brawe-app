// Configurações › Privacidade (hub).

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/repositories/privacy_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/grouped_list.dart';
import '../view_models/settings_view_model.dart';
import 'privacy_common.dart';
import 'privacy_pickers.dart';

class PrivacyHubScreen extends ConsumerStatefulWidget {
  const PrivacyHubScreen({super.key});

  @override
  ConsumerState<PrivacyHubScreen> createState() => _PrivacyHubScreenState();
}

class _PrivacyHubScreenState extends ConsumerState<PrivacyHubScreen> {
  bool _exporting = false;

  PrivacyNotifier get _vm => ref.read(privacyProvider.notifier);

  /// PATCH otimista; se falhar, volta atrás e avisa nesta tela.
  Future<bool> _patch(
    Map<String, dynamic> body,
    PrivacySettings Function(PrivacySettings) apply,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _vm.patch(body, apply);
      return true;
    } catch (e) {
      if (!mounted) return false;
      showPrivacyError(
        messenger,
        privacyErrorText(context, e),
        context.colors.danger,
      );
      return false;
    }
  }

  Future<void> _togglePrivate(bool want) async {
    final s = S.of(context);
    final lines = want
        ? [s.privacyPrivateOn1, s.privacyPrivateOn2, s.privacyPrivateOn3]
        : [s.privacyPrivateOff1, s.privacyPrivateOff2];
    final ok = await showPrivacySheet<bool>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrivacySheetHeader(
            title: want ? s.privacyPrivateOnTitle : s.privacyPrivateOffTitle,
          ),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      LucideIcons.check,
                      size: 18,
                      color: ctx.colors.accentPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: ctx.colors.textPrimary,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(s.actionCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      want
                          ? s.privacyPrivateOnConfirm
                          : s.privacyPrivateOffConfirm,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final done = await _patch({
      'is_private': want,
    }, (st) => st.copyWith(isPrivate: want));
    // Ao desligar, o servidor aceita os pedidos pendentes.
    if (done && !want) _vm.setFollowRequests(0);
  }

  Future<void> _pickWho({
    required String title,
    required String description,
    required String key,
    required String current,
    required List<String> options,
    required PrivacySettings Function(PrivacySettings, String) apply,
  }) async {
    final v = await pickWho(
      context,
      title: title,
      description: description,
      current: current,
      options: options,
    );
    if (v == null || v == current || !mounted) return;
    await _patch({key: v}, (st) => apply(st, v));
  }

  Future<void> _pickLimit(PrivacySettings st) async {
    final h = await pickLimit(context, st);
    if (h == null || !mounted) return;
    await _patch(
      {'limit_hours': h},
      (x) => h == 0
          ? x.copyWith(clearLimit: true)
          : x.copyWith(limitUntil: DateTime.now().add(Duration(hours: h))),
    );
  }

  Future<void> _export() async {
    if (_exporting) return;
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    setState(() => _exporting = true);
    try {
      final data = await ref.read(privacyRepositoryProvider).export();
      final text = data is String
          ? data
          : const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/brawe-meus-dados.json');
      await file.writeAsString(text);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: s.privacyExportShareSubject,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      if (mounted) {
        showPrivacyError(
          messenger,
          privacyErrorText(context, e),
          context.colors.danger,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(privacyProvider);
    final app = ref.watch(settingsViewModelProvider).value;
    final appVm = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.settingsPrivacy),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  privacyErrorText(context, e),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(privacyProvider),
                  child: Text(s.privacyRetry),
                ),
              ],
            ),
          ),
        ),
        data: (o) {
          final st = o.settings;
          final limitText = limitRemainingText(s, st);
          return GroupedBody(
            children: [
              GroupedSection(
                caption: s.privacySectionAccount,
                footer: o.canBePrivate
                    ? s.privacyPrivateFooter
                    : s.privacyPrivateUnavailableFooter,
                children: [
                  GroupedRow(
                    icon: LucideIcons.lock,
                    title: s.privacyPrivateAccount,
                    subtitle: o.canBePrivate
                        ? null
                        : s.privacyPrivateUnavailable,
                    trailing: PrivacySwitch(
                      value: st.isPrivate,
                      onChanged: o.canBePrivate ? _togglePrivate : null,
                    ),
                  ),
                ],
              ),
              GroupedSection(
                caption: s.privacySectionInteractions,
                children: [
                  GroupedRow(
                    icon: LucideIcons.messageCircle,
                    title: s.privacyComments,
                    value: whoLabel(s, st.comments),
                    onTap: () => _pickWho(
                      title: s.privacyComments,
                      description: s.privacyCommentsDesc,
                      key: 'comments',
                      current: st.comments,
                      options: const [
                        Who.everyone,
                        Who.followers,
                        Who.following,
                        Who.none,
                      ],
                      apply: (x, v) => x.copyWith(comments: v),
                    ),
                  ),
                  GroupedRow(
                    icon: LucideIcons.send,
                    title: s.privacyMessages,
                    value: whoLabel(s, st.messages),
                    onTap: () => _pickWho(
                      title: s.privacyMessages,
                      description: s.privacyMessagesDesc,
                      key: 'messages',
                      current: st.messages,
                      options: const [Who.everyone, Who.following, Who.none],
                      apply: (x, v) => x.copyWith(messages: v),
                    ),
                  ),
                  GroupedRow(
                    icon: LucideIcons.atSign,
                    title: s.privacyMentions,
                    value: whoLabel(s, st.mentions),
                    onTap: () => _pickWho(
                      title: s.privacyMentions,
                      description: s.privacyMentionsDesc,
                      key: 'mentions',
                      current: st.mentions,
                      options: const [Who.everyone, Who.following, Who.none],
                      apply: (x, v) => x.copyWith(mentions: v),
                    ),
                  ),
                  GroupedRow(
                    icon: LucideIcons.reply,
                    title: s.privacyStoryReplies,
                    value: whoLabel(s, st.storyReplies),
                    onTap: () => _pickWho(
                      title: s.privacyStoryReplies,
                      description: s.privacyStoryRepliesDesc,
                      key: 'story_replies',
                      current: st.storyReplies,
                      options: const [Who.everyone, Who.following, Who.none],
                      apply: (x, v) => x.copyWith(storyReplies: v),
                    ),
                  ),
                  GroupedRow(
                    icon: LucideIcons.swords,
                    title: s.privacyBattleInvites,
                    value: whoLabel(s, st.battleInvites),
                    onTap: () => _pickWho(
                      title: s.privacyBattleInvites,
                      description: s.privacyBattleInvitesDesc,
                      key: 'battle_invites',
                      current: st.battleInvites,
                      options: const [Who.everyone, Who.following, Who.none],
                      apply: (x, v) => x.copyWith(battleInvites: v),
                    ),
                  ),
                  GroupedRow(
                    icon: LucideIcons.eyeOff,
                    title: s.privacyHiddenWords,
                    value: st.hiddenWords.isEmpty && !st.filterOffensive
                        ? s.privacyLimitOff
                        : s.privacyHiddenWordsValue(st.hiddenWords.length),
                    onTap: () => context.push('/settings/privacy/hidden-words'),
                  ),
                  GroupedRow(
                    icon: LucideIcons.timer,
                    title: s.privacyLimit,
                    value: limitText ?? s.privacyLimitOff,
                    valueColor: limitText != null ? colors.accentPrimary : null,
                    onTap: () => _pickLimit(st),
                  ),
                ],
              ),
              GroupedSection(
                caption: s.privacySectionShow,
                children: [
                  _sw(
                    LucideIcons.heartOff,
                    s.privacyHideLikes,
                    s.privacyHideLikesHint,
                    st.hideLikeCounts,
                    (v) => _patch({
                      'hide_like_counts': v,
                    }, (x) => x.copyWith(hideLikeCounts: v)),
                  ),
                  _sw(
                    LucideIcons.heart,
                    s.privacyHideOthersLikes,
                    s.privacyHideOthersLikesHint,
                    st.hideOthersLikeCounts,
                    (v) => _patch({
                      'hide_others_like_counts': v,
                    }, (x) => x.copyWith(hideOthersLikeCounts: v)),
                  ),
                  _sw(
                    LucideIcons.activity,
                    s.privacyActivityStatus,
                    s.privacyActivityStatusHint,
                    st.showActivity,
                    (v) => _patch({
                      'show_activity': v,
                    }, (x) => x.copyWith(showActivity: v)),
                  ),
                  _sw(
                    LucideIcons.users,
                    s.privacyHideFollowLists,
                    s.privacyHideFollowListsHint,
                    st.hideFollowLists,
                    (v) => _patch({
                      'hide_follow_lists': v,
                    }, (x) => x.copyWith(hideFollowLists: v)),
                  ),
                  _sw(
                    LucideIcons.compass,
                    s.privacyShowInExplore,
                    s.privacyShowInExploreHint,
                    st.showInExplore,
                    (v) => _patch({
                      'show_in_explore': v,
                    }, (x) => x.copyWith(showInExplore: v)),
                  ),
                  _sw(
                    LucideIcons.checkCheck,
                    s.privacyReadReceipts,
                    s.privacyReadReceiptsHint,
                    st.readReceipts,
                    (v) => _patch({
                      'read_receipts': v,
                    }, (x) => x.copyWith(readReceipts: v)),
                  ),
                  if (app != null) ...[
                    _sw(
                      LucideIcons.eye,
                      s.settingsPrivacyShowViewers,
                      s.settingsPrivacyShowViewersHint,
                      app.privacyShowViewers,
                      (v) => appVm.setBool('privacy_show_viewers', v),
                    ),
                    _sw(
                      LucideIcons.coins,
                      s.settingsPrivacyShowEarnings,
                      s.settingsPrivacyShowEarningsHint,
                      app.privacyShowEarnings,
                      (v) => appVm.setBool('privacy_show_earnings', v),
                    ),
                  ],
                ],
              ),
              GroupedSection(
                caption: s.privacySectionAccounts,
                children: [
                  if (st.isPrivate || o.followRequests > 0)
                    GroupedRow(
                      icon: LucideIcons.userPlus,
                      title: s.privacyFollowRequests,
                      value: '${o.followRequests}',
                      valueColor: o.followRequests > 0
                          ? colors.accentPrimary
                          : null,
                      onTap: () async {
                        await context.push('/settings/privacy/follow-requests');
                        if (mounted) ref.invalidate(privacyProvider);
                      },
                    ),
                  GroupedRow(
                    icon: LucideIcons.userMinus,
                    title: s.privacyRestricted,
                    value: '${o.counts.restricted}',
                    onTap: () => context.push('/settings/privacy/restricted'),
                  ),
                  GroupedRow(
                    icon: LucideIcons.volumeX,
                    title: s.privacyMuted,
                    value: '${o.counts.muted}',
                    onTap: () => context.push('/settings/privacy/muted'),
                  ),
                  GroupedRow(
                    icon: LucideIcons.ban,
                    title: s.privacyBlocked,
                    value: '${o.counts.blocked}',
                    onTap: () => context.push('/settings/privacy/blocked'),
                  ),
                ],
              ),
              GroupedSection(
                caption: s.privacySectionData,
                footer: s.privacyExportFooter,
                children: [
                  GroupedRow(
                    icon: LucideIcons.download,
                    title: s.privacyExport,
                    trailing: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            LucideIcons.chevronRight,
                            size: 18,
                            color: colors.textTertiary,
                          ),
                    onTap: _export,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sw(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => GroupedRow(
    icon: icon,
    title: title,
    subtitle: subtitle,
    trailing: PrivacySwitch(value: value, onChanged: onChanged),
  );
}
