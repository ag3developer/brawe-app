import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';

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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final asyncSettings = ref.watch(settingsViewModelProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: s.settingsLoadError,
          onRetry: () => ref.invalidate(settingsViewModelProvider),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _SectionHeader(
              icon: Icons.palette_outlined,
              title: s.settingsAppearance,
            ),
            _ThemeSelector(
              themeMode: themeMode,
              onSelect: (mode) async {
                final backendValue = switch (mode) {
                  ThemeMode.light => 'light',
                  ThemeMode.system => 'system',
                  ThemeMode.dark => 'dark',
                };
                await ref
                    .read(settingsViewModelProvider.notifier)
                    .setTheme(backendValue);
              },
            ),
            // Explica o "Automático": segue a aparência do celular.
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: themeMode == ThemeMode.system
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        s.settingsThemeAutoHint,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.language_outlined,
              title: s.settingsLanguage,
            ),
            ListTile(
              leading: const Icon(Icons.translate_rounded),
              title: Text(s.settingsAppLanguage),
              subtitle: Text(s.settingsLanguageSubtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => LanguagePickerSheet.show(context),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.notifications_outlined,
              title: s.settingsNotifications,
            ),
            _SwitchTile(
              title: s.settingsNotifLiveStart,
              subtitle: s.settingsNotifLiveStartHint,
              value: settings.notificationsLiveStart,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_live_start', v),
            ),
            _SwitchTile(
              title: s.settingsNotifGifts,
              subtitle: s.settingsNotifGiftsHint,
              value: settings.notificationsGifts,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_gifts', v),
            ),
            _SwitchTile(
              title: s.settingsNotifFollowers,
              value: settings.notificationsFollowers,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_followers', v),
            ),
            _SwitchTile(
              title: s.settingsNotifMessages,
              value: settings.notificationsMessages,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_messages', v),
            ),
            const SizedBox(height: 24),
            _SectionHeader(icon: Icons.lock_outline, title: s.settingsPrivacy),
            _SwitchTile(
              title: s.settingsPrivacyShowViewers,
              subtitle: s.settingsPrivacyShowViewersHint,
              value: settings.privacyShowViewers,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('privacy_show_viewers', v),
            ),
            _SwitchTile(
              title: s.settingsPrivacyShowEarnings,
              subtitle: s.settingsPrivacyShowEarningsHint,
              value: settings.privacyShowEarnings,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('privacy_show_earnings', v),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.volume_up_outlined,
              title: s.settingsSounds,
            ),
            _SwitchTile(
              title: s.settingsSoundsEnabled,
              subtitle: s.settingsSoundsHint,
              value: settings.soundsEnabled,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('sounds_enabled', v),
            ),
            const SizedBox(height: 24),
            _SectionHeader(icon: Icons.info_outline, title: s.settingsAbout),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(s.settingsTermsOfUse),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => LegalWebViewScreen.openLegal(context, privacy: false),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(s.settingsPrivacyPolicy),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => LegalWebViewScreen.openLegal(context, privacy: true),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: Text(s.settingsSendFeedback),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(s.settingsChildSafety),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => LegalWebViewScreen.openChildSafety(context),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(s.settingsSupport),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showSupportSheet(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.tag_outlined),
              title: Text(s.settingsVersion),
              trailing: Consumer(
                builder: (_, ref, _) {
                  final v = ref.watch(_appVersionProvider);
                  return Text(v.maybeWhen(data: (v) => v, orElse: () => '…'));
                },
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(icon: Icons.logout, title: s.settingsAccount),
            ListTile(
              leading: const Icon(LucideIcons.shieldCheck),
              title: Text(s.secSettingsEntry),
              subtitle: Text(s.secSettingsEntrySub),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => context.push('/settings/security'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset_outlined),
              title: Text(s.settingsChangePassword),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => context.push('/settings/change-password'),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: context.colors.danger),
              title: Text(
                s.settingsLogout,
                style: TextStyle(color: context.colors.danger),
              ),
              onTap: () => _confirmLogout(context, ref),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: context.colors.danger,
              ),
              title: Text(
                s.settingsDeleteAccount,
                style: TextStyle(color: context.colors.danger),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => context.push('/settings/delete-account'),
            ),
            const SizedBox(height: 32),
          ],
        ),
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
