import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/services/auth_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/app_snackbar.dart';
import 'common/auth_action_button.dart';
import 'common/auth_background.dart';
import 'common/auth_input_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final pwd = _passwordController.text;
    final confirm = _confirmController.text;
    if (pwd.length < 8) {
      AppSnackBar.showError(context, s.resetPasswordTooShort);
      return;
    }
    if (pwd != confirm) {
      AppSnackBar.showError(context, s.resetPasswordsDontMatch);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).resetPassword(
            token: widget.token,
            newPassword: pwd,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, S.of(context).cpChangedSuccess);
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      final fallback = S.of(context).resetInvalidToken;
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    s.resetTitle,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.resetSubtitle,
                    style: TextStyle(
                        color: context.colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  AuthInputField(
                    controller: _passwordController,
                    label: s.resetNewPasswordLabel,
                    hintText: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  AuthInputField(
                    controller: _confirmController,
                    label: s.resetConfirmPasswordLabel,
                    hintText: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 24),
                  AuthActionButton(
                    label: _loading ? s.resetSaving : s.cpSaveNewPassword,
                    onPressed: _loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
