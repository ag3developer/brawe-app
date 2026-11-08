import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/grouped_list.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key, this.required = false});

  /// Depois de "Proteger conta": não dá para sair sem trocar a senha.
  final bool required;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty) {
      setState(() => _error = s.cpEnterCurrentPassword);
      return;
    }
    if (next.length < 8) {
      setState(() => _error = s.cpPasswordTooShort);
      return;
    }
    if (next != confirm) {
      setState(() => _error = s.cpPasswordsDontMatch);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final newToken = await ref
          .read(authServiceProvider)
          .changePassword(currentPassword: current, newPassword: next);
      // A troca de senha encerra as outras sessões e renova esta.
      if (newToken != null) {
        await ref.read(storageServiceProvider).saveToken(newToken);
      }
      if (!mounted) return;
      AppSnackBar.showSuccess(context, S.of(context).cpChangedSuccess);
      if (widget.required) {
        context.go('/settings/security');
      } else {
        context.pop();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final fallback = S.of(context).cpChangeError;
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
    Widget pwField(TextEditingController ctl, String label, {String? hint}) =>
        GroupedField(
          label: label,
          child: TextField(
            controller: ctl,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: groupedInput(context, hint: hint),
          ),
        );
    return PopScope(
      canPop: !widget.required,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          surfaceTintColor: Colors.transparent,
          title: Text(s.settingsChangePassword),
          automaticallyImplyLeading: false,
          leading: widget.required ? null : const BackButton(),
        ),
        body: GroupedBody(
          children: [
            if (widget.required) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.shieldAlert, size: 18, color: c.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.secPasswordRequired,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],
            GroupedSection(
              indent: 16,
              children: [pwField(_currentController, s.cpCurrentPassword)],
            ),
            GroupedSection(
              indent: 16,
              footer: _error == null ? s.cpMin8Chars : null,
              children: [
                pwField(_newController, s.cpNewPassword),
                pwField(_confirmController, s.cpConfirmNewPassword),
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
                backgroundColor: c.accentPrimary,
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
                  : Text(s.cpSaveNewPassword),
            ),
          ],
        ),
      ),
    );
  }
}
