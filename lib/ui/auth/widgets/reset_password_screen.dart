import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/services/auth_service.dart';
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
    final pwd = _passwordController.text;
    final confirm = _confirmController.text;
    if (pwd.length < 8) {
      AppSnackBar.showError(context, 'A senha deve ter pelo menos 8 caracteres.');
      return;
    }
    if (pwd != confirm) {
      AppSnackBar.showError(context, 'As senhas não coincidem.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).resetPassword(
            token: widget.token,
            newPassword: pwd,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Senha alterada com sucesso.');
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map
          ? (e.response?.data['detail']?.toString() ?? 'Token inválido ou expirado.')
          : 'Token inválido ou expirado.';
      AppSnackBar.showError(context, detail);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Erro de conexão.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Criar nova senha',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Escolha uma senha forte de pelo menos 8 caracteres.',
                    style: TextStyle(
                        color: context.colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  AuthInputField(
                    controller: _passwordController,
                    label: 'NOVA SENHA',
                    hintText: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  AuthInputField(
                    controller: _confirmController,
                    label: 'CONFIRMAR SENHA',
                    hintText: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 24),
                  AuthActionButton(
                    label: _loading ? 'Salvando...' : 'Salvar nova senha',
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
