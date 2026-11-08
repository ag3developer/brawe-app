import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/push_notification_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/grouped_list.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _ack = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = s.delAccEnterPassword);
      return;
    }
    if (!_ack) {
      setState(() => _error = s.delAccAckRequired);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ds = S.of(ctx);
        return AlertDialog(
          title: Text(ds.delAccTitle),
          content: Text(ds.delAccConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ds.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: ctx.colors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ds.delAccConfirmButton),
            ),
          ],
        );
      },
    );
    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).deleteAccount(password);
      try {
        await ref.read(pushNotificationServiceProvider).unregister();
      } catch (_) {}
      await ref.read(authStateProvider.notifier).logout();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, S.of(context).delAccSuccess);
      context.go('/welcome');
    } on DioException catch (e) {
      if (!mounted) return;
      final fallback = S.of(context).delAccError;
      final detail = e.response?.data is Map
          ? (e.response?.data['detail']?.toString() ?? fallback)
          : fallback;
      setState(() => _error = detail);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = S.of(context).errorNetwork);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        title: Text(s.delAccTitle),
        leading: const BackButton(),
      ),
      body: GroupedBody(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.triangleAlert, size: 18, color: c.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.delAccWarningBanner,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          GroupedSection(
            caption: s.delAccWhatHappens,
            indent: 16,
            children: [
              GroupedRow(title: s.delAccBullet1),
              GroupedRow(title: s.delAccBullet2),
              GroupedRow(title: s.delAccBullet3),
              GroupedRow(title: s.delAccBullet4),
            ],
          ),
          GroupedSection(
            indent: 16,
            footer: _error == null ? s.delAccPasswordHelper : null,
            children: [
              GroupedField(
                label: s.cpCurrentPassword,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: groupedInput(context),
                ),
              ),
              GroupedRow(
                title: s.delAccAckCheckbox,
                onTap: () => setState(() {
                  _ack = !_ack;
                  _error = null;
                }),
                trailing: Checkbox(
                  value: _ack,
                  activeColor: c.danger,
                  onChanged: (v) => setState(() {
                    _ack = v ?? false;
                    _error = null;
                  }),
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.circleAlert, size: 15, color: c.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: c.danger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: c.danger,
              foregroundColor: c.textOnAccent,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _loading ? null : _submit,
            child: _loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.textOnAccent,
                    ),
                  )
                : Text(s.delAccDeleteMyAccount),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(s.actionCancel),
          ),
        ],
      ),
    );
  }
}
