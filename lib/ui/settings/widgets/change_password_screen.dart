import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/themes/brawe_colors.dart';

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
      AppSnackBar.showError(context, s.cpEnterCurrentPassword);
      return;
    }
    if (next.length < 8) {
      AppSnackBar.showError(context, s.cpPasswordTooShort);
      return;
    }
    if (next != confirm) {
      AppSnackBar.showError(context, s.cpPasswordsDontMatch);
      return;
    }
    setState(() => _loading = true);
    try {
      final newToken = await ref.read(authServiceProvider).changePassword(
            currentPassword: current,
            newPassword: next,
          );
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
      AppSnackBar.showError(context, detail);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, S.of(context).errorNetwork);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: !widget.required,
      child: Scaffold(
      appBar: AppBar(
        title: Text(s.settingsChangePassword),
        automaticallyImplyLeading: false,
        leading: widget.required ? null : const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.required) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  s.secPasswordRequired,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _currentController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: s.cpCurrentPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: s.cpNewPassword,
                helperText: s.cpMin8Chars,
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: s.cpConfirmNewPassword,
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.accentPrimary,
                foregroundColor: context.colors.textOnAccent,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.textOnAccent,
                      ),
                    )
                  : Text(s.cpSaveNewPassword),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
