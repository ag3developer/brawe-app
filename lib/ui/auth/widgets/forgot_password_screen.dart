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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackBar.showError(context, 'Informe um email válido.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).forgotPassword(email);
      if (!mounted) return;
      setState(() => _sent = true);
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map
          ? (e.response?.data['detail']?.toString() ?? 'Não foi possível enviar.')
          : 'Não foi possível enviar.';
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
    final colors = context.colors;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recuperar senha',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Informe seu email e enviaremos instruções para criar uma nova senha.',
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  if (_sent)
                    _SentCard(email: _emailController.text.trim())
                  else ...[
                    AuthInputField(
                      controller: _emailController,
                      label: 'EMAIL',
                      hintText: 'voce@exemplo.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 24),
                    AuthActionButton(
                      label: _loading ? 'Enviando...' : 'Enviar instruções',
                      onPressed: _loading ? null : _submit,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Voltar para login',
                      style: TextStyle(color: colors.accentPrimary),
                    ),
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

class _SentCard extends StatelessWidget {
  final String email;
  const _SentCard({required this.email});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.mark_email_read_outlined,
              color: colors.accentPrimary, size: 40),
          const SizedBox(height: 12),
          Text(
            'Verifique seu email',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Se $email estiver cadastrado, você receberá um link para criar uma nova senha em alguns minutos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
