import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/feature_flags.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/media_headers.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/push_notification_service.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/settings_view_model.dart';
import '../view_models/theme_view_model.dart';
import 'language_picker_sheet.dart';
import 'feedback_screen.dart';
import 'legal_webview_screen.dart';

/// Lê a versão do app em runtime via package_info_plus.
/// Formato: "1.0.6+6" (versionName + versionCode/build).
final _appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
});

/// Configurações — organizada como os Ajustes do iOS/Instagram:
/// cartões agrupados, legenda discreta por grupo, valor atual à direita,
/// detalhes (notificações, privacidade) em subpáginas e a versão no rodapé.
///
/// Ordem: você → conta → preferências → ajuda → sobre → sair.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final asyncSettings = ref.watch(settingsViewModelProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final colors = context.colors;
    final user = ref.watch(authStateProvider).value;

    final themeLabel = switch (themeMode) {
      ThemeMode.light => s.settingsThemeLight,
      ThemeMode.dark => s.settingsThemeDark,
      ThemeMode.system => s.settingsThemeAuto,
    };
    final langLabel = switch (Localizations.localeOf(context).languageCode) {
      'en' => 'English',
      'es' => 'Español',
      _ => 'Português',
    };

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.settingsTitle),
        centerTitle: true,
        leading: const BackButton(),
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: s.settingsLoadError,
          onRetry: () => ref.invalidate(settingsViewModelProvider),
        ),
        data: (settings) => _SettingsBody(
          children: [
            // ── você ─────────────────────────────────────────────
            if (user != null)
              _Group(
                children: [
                  _ProfileRow(
                    name: user.name,
                    subtitle: user.email,
                    avatarUrl: user.avatarUrl,
                    onTap: () => context.push('/edit-profile'),
                  ),
                ],
              ),

            // ── conta ────────────────────────────────────────────
            _Group(
              caption: s.settingsAccount,
              children: [
                _Row(
                  icon: LucideIcons.shieldCheck,
                  title: s.secSettingsEntry,
                  onTap: () => context.push('/settings/security'),
                ),
                _Row(
                  icon: LucideIcons.keyRound,
                  title: s.settingsChangePassword,
                  onTap: () => context.push('/settings/change-password'),
                ),
                if (kEnableMonetization)
                  _Row(
                    icon: LucideIcons.rocket,
                    title: s.myAdsTitle,
                    onTap: () => context.push('/ads/campaigns'),
                  ),
              ],
            ),

            // ── preferências ─────────────────────────────────────
            _Group(
              caption: s.settingsGroupPreferences,
              children: [
                _Row(
                  icon: LucideIcons.bell,
                  title: s.settingsNotifications,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _NotificationsPage(),
                    ),
                  ),
                ),
                _Row(
                  icon: LucideIcons.lock,
                  title: s.settingsPrivacy,
                  onTap: () => context.push('/settings/privacy'),
                ),
                _Row(
                  icon: LucideIcons.sunMoon,
                  title: s.settingsAppearance,
                  value: themeLabel,
                  onTap: () => _showThemeSheet(context, ref),
                ),
                _Row(
                  icon: LucideIcons.languages,
                  title: s.settingsLanguage,
                  value: langLabel,
                  onTap: () => LanguagePickerSheet.show(context),
                ),
                _Row(
                  icon: LucideIcons.volume2,
                  title: s.settingsSoundsEnabled,
                  trailing: Switch.adaptive(
                    value: settings.soundsEnabled,
                    activeTrackColor: colors.accentPrimary,
                    onChanged: (v) => ref
                        .read(settingsViewModelProvider.notifier)
                        .setBool('sounds_enabled', v),
                  ),
                ),
              ],
            ),

            // ── ajuda ────────────────────────────────────────────
            _Group(
              caption: s.settingsGroupHelp,
              children: [
                _Row(
                  icon: LucideIcons.lifeBuoy,
                  title: s.settingsSupport,
                  onTap: () => _showSupportSheet(context, ref),
                ),
                _Row(
                  icon: LucideIcons.messageSquareText,
                  title: s.settingsSendFeedback,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                  ),
                ),
              ],
            ),

            // ── sobre ────────────────────────────────────────────
            _Group(
              caption: s.settingsGroupAbout,
              children: [
                _Row(
                  icon: LucideIcons.fileText,
                  title: s.settingsTermsOfUse,
                  onTap: () =>
                      LegalWebViewScreen.openLegal(context, privacy: false),
                ),
                _Row(
                  icon: LucideIcons.shield,
                  title: s.settingsPrivacyPolicy,
                  onTap: () =>
                      LegalWebViewScreen.openLegal(context, privacy: true),
                ),
                _Row(
                  icon: LucideIcons.baby,
                  title: s.settingsChildSafety,
                  onTap: () => LegalWebViewScreen.openChildSafety(context),
                ),
              ],
            ),

            // ── sair ─────────────────────────────────────────────
            _Group(
              children: [
                _Row(
                  title: s.settingsLogout,
                  danger: true,
                  centered: true,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
            Center(
              child: TextButton(
                onPressed: () => context.push('/settings/delete-account'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textTertiary,
                ),
                child: Text(
                  s.settingsDeleteAccount,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            Consumer(
              builder: (_, ref, _) {
                final v = ref.watch(_appVersionProvider);
                return Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 24),
                  child: Text(
                    'Brawe ${v.maybeWhen(data: (v) => v, orElse: () => '')}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textTertiary, fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final mode = ref.watch(themeControllerProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                    child: Text(
                      s.settingsAppearance,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _ThemeSelector(
                    themeMode: mode,
                    onSelect: (m) => ref
                        .read(settingsViewModelProvider.notifier)
                        .setTheme(switch (m) {
                          ThemeMode.light => 'light',
                          ThemeMode.system => 'system',
                          ThemeMode.dark => 'dark',
                        }),
                  ),
                  if (mode == ThemeMode.system)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                      child: Text(
                        s.settingsThemeAutoHint,
                        style: TextStyle(
                          color: ctx.colors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openLegal(
    BuildContext context, {
    required String url,
    required String title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalWebViewScreen(url: url, title: title),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSupportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final s = S.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.support_agent_outlined,
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s.settingsHelpTitle,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(s.settingsSendSupportEmail),
                subtitle: const Text(AppConstants.supportEmail),
                onTap: () async {
                  Navigator.pop(ctx);
                  final version = await ref.read(_appVersionProvider.future);
                  final uri = Uri(
                    scheme: 'mailto',
                    path: AppConstants.supportEmail,
                    queryParameters: {
                      'subject': s.settingsSupportEmailSubject(version),
                    },
                  );
                  if (!await launchUrl(uri)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).settingsNoMailApp),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(s.settingsHelpCenterFaq),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  _openLegal(
                    context,
                    url: AppConstants.supportUrl,
                    title: s.settingsSupport,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.settingsLogout),
        content: Text(s.settingsLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.settingsLogout),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(pushNotificationServiceProvider).unregister();
    } catch (_) {}
    await ref.read(authStateProvider.notifier).logout();
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      onChanged: onChanged,
      activeThumbColor: context.colors.accentPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onSelect;
  const _ThemeSelector({required this.themeMode, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final options = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.wb_sunny_outlined, s.settingsThemeLight),
      (ThemeMode.dark, Icons.dark_mode_outlined, s.settingsThemeDark),
      (ThemeMode.system, Icons.brightness_auto_outlined, s.settingsThemeAuto),
    ];
    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        children: options
            .map(
              (opt) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ThemeOption(
                    icon: opt.$2,
                    label: opt.$3,
                    selected: themeMode == opt.$1,
                    onTap: () => onSelect(opt.$1),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? scheme.primary : Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? context.colors.textOnAccent
                    : scheme.onSurface,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? context.colors.textOnAccent
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: Text(S.of(context).actionRetry),
          ),
        ],
      ),
    );
  }
}

// ── peças do layout agrupado ─────────────────────────────────────────────

/// Lista centralizada (até 640 px em tablet) com espaço entre os grupos.
class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: children,
      ),
    ),
  );
}

/// Grupo em cartão com legenda pequena acima (sem ícone, sem título duplicado).
class _Group extends StatelessWidget {
  const _Group({required this.children, this.caption});
  final String? caption;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 52,
            color: colors.divider,
          ),
        );
      }
      rows.add(children[i]);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (caption != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 7),
              child: Text(
                caption!.toUpperCase(),
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Material(
              color: colors.surface,
              child: Column(children: rows),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha: ícone discreto · título · valor atual (cinza) · seta (ou um interruptor).
class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    this.icon,
    this.value,
    this.trailing,
    this.onTap,
    this.danger = false,
    this.centered = false,
  });
  final IconData? icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = danger ? colors.danger : colors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: danger ? colors.danger : colors.textSecondary,
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  title,
                  textAlign: centered ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    color: fg,
                    fontSize: 15.5,
                    fontWeight: centered ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  value!,
                  style: TextStyle(color: colors.textSecondary, fontSize: 14.5),
                ),
              ],
              if (trailing != null)
                trailing!
              else if (onTap != null && !centered) ...[
                const SizedBox(width: 6),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: colors.textTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho "você": foto, nome e e-mail → editar perfil.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    required this.onTap,
  });
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colors.surfaceHighest,
              backgroundImage: (avatarUrl ?? '').isNotEmpty
                  ? CachedNetworkImageProvider(
                      avatarUrl!,
                      headers: mediaHeadersFor(avatarUrl),
                    )
                  : null,
              child: (avatarUrl ?? '').isEmpty
                  ? Icon(LucideIcons.user, color: colors.textSecondary)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Subpágina de notificações (interruptores com explicação curta).
class _NotificationsPage extends ConsumerWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final settings = ref.watch(settingsViewModelProvider).value;
    final vm = ref.read(settingsViewModelProvider.notifier);
    return _SubPage(
      title: s.settingsNotifications,
      children: settings == null
          ? const []
          : [
              _Group(
                children: [
                  _SwitchTile(
                    title: s.settingsNotifLiveStart,
                    subtitle: s.settingsNotifLiveStartHint,
                    value: settings.notificationsLiveStart,
                    onChanged: (v) => vm.setBool('notifications_live_start', v),
                  ),
                  _SwitchTile(
                    title: s.settingsNotifGifts,
                    subtitle: s.settingsNotifGiftsHint,
                    value: settings.notificationsGifts,
                    onChanged: (v) => vm.setBool('notifications_gifts', v),
                  ),
                  _SwitchTile(
                    title: s.settingsNotifFollowers,
                    value: settings.notificationsFollowers,
                    onChanged: (v) => vm.setBool('notifications_followers', v),
                  ),
                  _SwitchTile(
                    title: s.settingsNotifMessages,
                    value: settings.notificationsMessages,
                    onChanged: (v) => vm.setBool('notifications_messages', v),
                  ),
                ],
              ),
            ],
    );
  }
}

/// Subpágina de privacidade.
class _SubPage extends StatelessWidget {
  const _SubPage({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _SettingsBody(children: [const SizedBox(height: 8), ...children]),
    );
  }
}
