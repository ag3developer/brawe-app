import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/push_notification_service.dart';

import '../../core/themes/app_colors.dart';
import '../../core/widgets/brawe_logo.dart';
import '../view_models/settings_view_model.dart';
import '../view_models/theme_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(settingsViewModelProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const BraweLogo(iconSize: 32),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: 'Não conseguimos carregar suas configurações.',
          onRetry: () => ref.invalidate(settingsViewModelProvider),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _SectionHeader(
              icon: Icons.palette_outlined,
              title: 'Aparência',
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
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.notifications_outlined,
              title: 'Notificações',
            ),
            _SwitchTile(
              title: 'Lives começando',
              subtitle: 'Receba aviso quando seus creators favoritos forem ao vivo',
              value: settings.notificationsLiveStart,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_live_start', v),
            ),
            _SwitchTile(
              title: 'Presentes recebidos',
              subtitle: 'Avisar quando alguém te enviar um gift',
              value: settings.notificationsGifts,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_gifts', v),
            ),
            _SwitchTile(
              title: 'Novos seguidores',
              value: settings.notificationsFollowers,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_followers', v),
            ),
            _SwitchTile(
              title: 'Mensagens diretas',
              value: settings.notificationsMessages,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('notifications_messages', v),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.lock_outline,
              title: 'Privacidade',
            ),
            _SwitchTile(
              title: 'Mostrar nº de espectadores',
              subtitle: 'Outros podem ver quantas pessoas assistem suas lives',
              value: settings.privacyShowViewers,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('privacy_show_viewers', v),
            ),
            _SwitchTile(
              title: 'Mostrar ganhos publicamente',
              subtitle: 'Exibir total de coins/ganhos no seu perfil',
              value: settings.privacyShowEarnings,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('privacy_show_earnings', v),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.volume_up_outlined,
              title: 'Sons',
            ),
            _SwitchTile(
              title: 'Efeitos sonoros',
              subtitle: 'Sons ao receber gifts, mensagens etc.',
              value: settings.soundsEnabled,
              onChanged: (v) => ref
                  .read(settingsViewModelProvider.notifier)
                  .setBool('sounds_enabled', v),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.info_outline,
              title: 'Sobre & Legal',
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Termos de Uso'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openExternal(context, AppConstants.termsUrl),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Política de Privacidade'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openExternal(context, AppConstants.privacyUrl),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Suporte'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openExternal(context, AppConstants.supportUrl),
            ),
            const ListTile(
              leading: Icon(Icons.tag_outlined),
              title: Text('Versão'),
              trailing: Text('1.0.0'),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.logout,
              title: 'Conta',
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternal(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir $url')),
        );
      }
    }
  }

    Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
      activeThumbColor: AppColors.electricPurple,
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
    final options = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.wb_sunny_outlined, 'Claro'),
      (ThemeMode.dark, Icons.dark_mode_outlined, 'Escuro'),
      (ThemeMode.system, Icons.brightness_auto_outlined, 'Auto'),
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
              color: selected
                  ? scheme.primary
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : scheme.onSurface,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : scheme.onSurface,
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
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
