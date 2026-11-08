import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/security_service.dart';
import '../../../domain/models/account_security.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/grouped_list.dart';
import '../view_models/security_view_model.dart';

const kDefaultGeoAttribution = 'IP Geolocation by DB-IP';

// ── Mapeamentos (visíveis para testes) ─────────────────────────────────────

IconData securityPlatformIcon({String? platform, String? client}) {
  final p = (platform ?? '').toLowerCase();
  final c = (client ?? '').toLowerCase();
  if (p == 'ios' || p == 'android') return LucideIcons.smartphone;
  if (const {'macos', 'windows', 'linux', 'desktop'}.contains(p) ||
      c == 'partners' ||
      c == 'dashboard') {
    return LucideIcons.monitor;
  }
  return LucideIcons.globe;
}

String securityClientLabel(S s, String? client) =>
    switch ((client ?? '').toLowerCase()) {
      'app' => s.secClientApp,
      'partners' => s.secClientPartners,
      _ => s.secClientWeb,
    };

IconData securityEventIcon(SecurityEventType t) => switch (t) {
  SecurityEventType.login => LucideIcons.logIn,
  SecurityEventType.loginFailed => LucideIcons.shieldAlert,
  SecurityEventType.loginBlocked => LucideIcons.ban,
  SecurityEventType.logout => LucideIcons.logOut,
  SecurityEventType.sessionRevoked => LucideIcons.monitorX,
  SecurityEventType.sessionsRevokedAll => LucideIcons.monitorX,
  SecurityEventType.passwordChanged => LucideIcons.keyRound,
  SecurityEventType.passwordResetRequested => LucideIcons.keyRound,
  SecurityEventType.passwordReset => LucideIcons.keyRound,
  SecurityEventType.qrLogin => LucideIcons.qrCode,
  SecurityEventType.loginCode => LucideIcons.mailCheck,
  SecurityEventType.stepUpRequired => LucideIcons.shieldAlert,
  SecurityEventType.stepUpPassed => LucideIcons.shieldCheck,
  SecurityEventType.newDeviceAlert => LucideIcons.triangleAlert,
  SecurityEventType.unknown => LucideIcons.shield,
};

String securityEventLabel(S s, SecurityEventType t) => switch (t) {
  SecurityEventType.login => s.secEvLogin,
  SecurityEventType.loginFailed => s.secEvLoginFailed,
  SecurityEventType.loginBlocked => s.secEvLoginBlocked,
  SecurityEventType.logout => s.secEvLogout,
  SecurityEventType.sessionRevoked => s.secEvSessionRevoked,
  SecurityEventType.sessionsRevokedAll => s.secEvSessionsRevokedAll,
  SecurityEventType.passwordChanged => s.secEvPasswordChanged,
  SecurityEventType.passwordResetRequested => s.secEvPasswordResetRequested,
  SecurityEventType.passwordReset => s.secEvPasswordReset,
  SecurityEventType.qrLogin => s.secEvQrLogin,
  SecurityEventType.loginCode => s.secEvLoginCode,
  SecurityEventType.stepUpRequired => s.secEvStepUpRequired,
  SecurityEventType.stepUpPassed => s.secEvStepUpPassed,
  SecurityEventType.newDeviceAlert => s.secEvNewDeviceAlert,
  SecurityEventType.unknown => s.secEvUnknown,
};

/// "há 5 min", "há 3 h", "há 2 d" e, passado 1 semana, a data.
String securityRelativeTime(
  S s,
  DateTime? t, {
  DateTime? now,
  String locale = 'pt',
}) {
  if (t == null) return '';
  final diff = (now ?? DateTime.now()).difference(t);
  if (diff.inMinutes < 60) return s.secTimeMinutes(diff.inMinutes.clamp(1, 59));
  if (diff.inHours < 24) return s.secTimeHours(diff.inHours);
  if (diff.inDays < 7) return s.secTimeDays(diff.inDays);
  return DateFormat.yMd(locale).format(t);
}

String securityErrorText(S s, Object error) {
  final kind = error is SecurityException ? error.kind : null;
  return kind == SecurityErrorKind.unavailable
      ? s.secUnavailable
      : s.secLoadError;
}

// ── Tela ───────────────────────────────────────────────────────────────────

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key, this.openProtect = false});

  /// `?secure=1` (CTA do aviso "Novo login"): abre a aba Proteção e a folha
  /// de confirmação direto.
  final bool openProtect;

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 3,
    vsync: this,
    initialIndex: widget.openProtect ? 2 : 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.openProtect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showProtectAccountSheet(context, ref);
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(s.secTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/settings'),
        ),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: s.secTabDevices),
            Tab(text: s.secTabHistory),
            Tab(text: s.secTabProtect),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [_DevicesTab(), _HistoryTab(), _ProtectTab()],
      ),
    );
  }
}

// ── Mensagens de estado ────────────────────────────────────────────────────

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.text, this.onRetry});
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: c.textTertiary),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(S.of(context).secRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GeoFooter extends StatelessWidget {
  const _GeoFooter(this.text);
  final String? text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    child: Text(
      text ?? kDefaultGeoAttribution,
      textAlign: TextAlign.center,
      style: TextStyle(color: context.colors.textTertiary, fontSize: 11.5),
    ),
  );
}

// ── Aparelhos conectados ───────────────────────────────────────────────────

class _DevicesTab extends ConsumerWidget {
  const _DevicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(sessionsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _StateMessage(
        icon: LucideIcons.cloudOff,
        text: securityErrorText(s, e),
        onRetry: () => ref.invalidate(sessionsProvider),
      ),
      data: (data) {
        if (data.sessions.isEmpty) {
          return _StateMessage(
            icon: LucideIcons.smartphone,
            text: s.secDevicesEmpty,
          );
        }
        final others = data.sessions.where((x) => !x.current).toList();
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(sessionsProvider);
            await ref.read(sessionsProvider.future).catchError((_) => data);
          },
          child: GroupedBody(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            children: [
              GroupedSection(
                caption: s.secDevicesTitle,
                footer: s.secDevicesSubtitle,
                indent: 70,
                children: [
                  for (final x in data.sessions)
                    SessionCard(
                      session: x,
                      onEnd: x.current ? null : () => _endOne(context, ref, x),
                    ),
                ],
              ),
              if (others.isEmpty)
                Text(
                  s.secNoOtherDevices,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                )
              else
                GroupedSection(
                  children: [
                    GroupedRow(
                      icon: LucideIcons.logOut,
                      title: s.secSignOutOthers,
                      danger: true,
                      onTap: () => _endOthers(context, ref),
                    ),
                  ],
                ),
              _GeoFooter(data.geoAttribution),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.secCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: ctx.colors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _endOne(
    BuildContext context,
    WidgetRef ref,
    AuthSession x,
  ) async {
    final s = S.of(context);
    final ok = await _confirm(
      context,
      title: s.secEndSessionTitle,
      body: s.secEndSessionBody(x.deviceName ?? s.secUnknownDevice),
      action: s.secEndSession,
    );
    if (!ok || !context.mounted) return;
    try {
      final res = await ref.read(securityServiceProvider).revokeSession(x.id);
      if (res.current) {
        // Revogou a sessão deste aparelho: equivale a sair.
        await ref.read(authStateProvider.notifier).logout();
        return;
      }
      ref.invalidate(sessionsProvider);
      if (context.mounted) AppSnackBar.showSuccess(context, s.secEndedOk);
    } catch (_) {
      if (context.mounted) AppSnackBar.showError(context, s.secActionError);
    }
  }

  Future<void> _endOthers(BuildContext context, WidgetRef ref) async {
    final s = S.of(context);
    final ok = await _confirm(
      context,
      title: s.secSignOutOthersTitle,
      body: s.secSignOutOthersBody,
      action: s.secSignOutOthers,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(securityServiceProvider).revokeOthers();
      ref.invalidate(sessionsProvider);
      if (context.mounted)
        AppSnackBar.showSuccess(context, s.secSignedOutOthersOk);
    } catch (_) {
      if (context.mounted) AppSnackBar.showError(context, s.secActionError);
    }
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, this.onEnd});
  final AuthSession session;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final x = session;
    final locale = Localizations.localeOf(context).languageCode;
    final last = x.current
        ? s.secActiveNow
        : s.secLastActive(
            securityRelativeTime(s, x.lastSeenAt, locale: locale),
          );
    final clientLine = [
      securityClientLabel(s, x.client),
      if (x.appVersion != null) s.secAppVersion(x.appVersion!),
    ].join(' · ');
    return Padding(
      key: Key('session-${x.id}'),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: c.surfaceHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  securityPlatformIcon(platform: x.platform, client: x.client),
                  color: c.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      x.deviceName ?? s.secUnknownDevice,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (x.current) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.secThisDevice,
                          style: TextStyle(
                            color: c.success,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      clientLine,
                      style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      x.place ?? s.secUnknownPlace,
                      style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      last,
                      style: TextStyle(color: c.textTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onEnd != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: c.danger),
                onPressed: onEnd,
                child: Text(s.secEndSession),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Histórico de acessos ───────────────────────────────────────────────────

class _HistoryTab extends ConsumerStatefulWidget {
  const _HistoryTab();

  @override
  ConsumerState<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<_HistoryTab> {
  SecurityEventFilter _filter = SecurityEventFilter.all;

  String _label(S s, SecurityEventFilter f) => switch (f) {
    SecurityEventFilter.all => s.secFilterAll,
    SecurityEventFilter.logins => s.secFilterLogins,
    SecurityEventFilter.failures => s.secFilterFailures,
    SecurityEventFilter.changes => s.secFilterChanges,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final async = ref.watch(securityEventsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _StateMessage(
        icon: LucideIcons.cloudOff,
        text: securityErrorText(s, e),
        onRetry: () => ref.invalidate(securityEventsProvider),
      ),
      data: (st) {
        final items = st.items.where(_filter.matches).toList();
        return GroupedBody(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 7),
              child: Text(
                s.secHistoryTitle.toUpperCase(),
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final f in SecurityEventFilter.values)
                  ChoiceChip(
                    key: Key('filter-${f.name}'),
                    label: Text(_label(s, f)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  s.secHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              )
            else
              GroupedSection(
                indent: 64,
                children: [for (final e in items) SecurityEventTile(event: e)],
              ),
            if (st.hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: st.loadingMore
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () => ref
                            .read(securityEventsProvider.notifier)
                            .loadMore(),
                        child: Text(
                          st.loadMoreFailed ? s.secRetry : s.secLoadMore,
                        ),
                      ),
              ),
            _GeoFooter(st.geoAttribution),
          ],
        );
      },
    );
  }
}

class SecurityEventTile extends StatelessWidget {
  const SecurityEventTile({super.key, required this.event});
  final SecurityEvent event;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final e = event;
    final tone = e.isFailure ? c.danger : c.success;
    final locale = Localizations.localeOf(context).languageCode;
    final where = [
      if (e.deviceName != null) e.deviceName!,
      e.place ?? s.secUnknownPlace,
    ].join(' · ');
    return Padding(
      key: Key('event-${e.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(securityEventIcon(e.type), size: 18, color: tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  securityEventLabel(s, e.type),
                  style: TextStyle(
                    color: e.isFailure ? c.danger : c.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  where,
                  style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  securityRelativeTime(s, e.at, locale: locale),
                  style: TextStyle(color: c.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Proteger conta ─────────────────────────────────────────────────────────

class _ProtectTab extends ConsumerWidget {
  const _ProtectTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    return GroupedBody(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: c.warning.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.shieldAlert, color: c.warning, size: 28),
              const SizedBox(height: 10),
              Text(
                s.secProtectTitle,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.secProtectBody,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                key: const Key('protect-open'),
                style: FilledButton.styleFrom(
                  backgroundColor: c.danger,
                  foregroundColor: c.textOnAccent,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => showProtectAccountSheet(context, ref),
                child: Text(s.secProtectButton, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        GroupedSection(
          children: [
            GroupedRow(
              icon: LucideIcons.keyRound,
              title: s.settingsChangePassword,
              subtitle: s.secChangePasswordSub,
              onTap: () => context.push('/settings/change-password'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Folha de confirmação de "Proteger minha conta": sai dos outros aparelhos,
/// troca o token guardado e abre a troca de senha obrigatória.
Future<void> showProtectAccountSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ProtectAccountSheet(
      onDone: () => context.go('/settings/change-password?required=1'),
    ),
  );
}

class ProtectAccountSheet extends ConsumerStatefulWidget {
  const ProtectAccountSheet({super.key, required this.onDone});

  /// Chamado depois de proteger (token já trocado) — abre a nova senha.
  final VoidCallback onDone;

  @override
  ConsumerState<ProtectAccountSheet> createState() =>
      _ProtectAccountSheetState();
}

class _ProtectAccountSheetState extends ConsumerState<ProtectAccountSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _protect() async {
    final s = S.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(securityServiceProvider).secureAccount();
      ref.invalidate(sessionsProvider);
      ref.invalidate(securityEventsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDone();
    } catch (e) {
      if (!mounted) return;
      final unavailable =
          e is SecurityException && e.kind == SecurityErrorKind.unavailable;
      setState(() {
        _busy = false;
        _error = unavailable ? s.secUnavailable : s.secProtectError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    Widget step(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.accentPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.shieldCheck, color: c.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.secProtectSheetTitle,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              s.secProtectSheetIntro,
              style: TextStyle(color: c.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 10),
            step(LucideIcons.monitorX, s.secProtectStep1),
            step(LucideIcons.keyRound, s.secProtectStep2),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!, style: TextStyle(color: c.danger, fontSize: 13)),
            ],
            const SizedBox(height: 14),
            FilledButton(
              key: const Key('protect-confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: c.danger,
                foregroundColor: c.textOnAccent,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _busy ? null : _protect,
              child: _busy
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.textOnAccent,
                      ),
                    )
                  : Text(s.secProtectConfirm, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(s.secCancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
