import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/login_view_model.dart';
import 'common/auth_action_button.dart';
import 'common/auth_background.dart';
import 'common/auth_input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final success = await ref.read(loginViewModelProvider.notifier).submit();
    if (mounted) {
      if (success) {
        AppSnackBar.showSuccess(context, 'Bem-vindo de volta.');
      } else {
        final error = ref.read(loginViewModelProvider).errorMessage;
        if (error != null) AppSnackBar.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final notifier = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ── Voltar ──────────────────────────────────────────
                      GestureDetector(
                        onTap: () => context.go('/welcome'),
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF5A5A6A), size: 22),
                      ),

                      const SizedBox(height: 52),

                      // ── Logo + Título ────────────────────────────────────
                      Image.asset(
                        'assets/images/brawe_logo.png',
                        width: 36,
                        height: 36,
                        color: AppColors.electricPurple,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Bem-vindo\nde volta.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Entre na sua conta para continuar.',
                        style: TextStyle(
                          color: Color(0xFF5A5A6A),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ── Campos ───────────────────────────────────────────
                      AuthInputField(
                        controller: _emailController,
                        label: 'E-MAIL',
                        hintText: 'voce@brawe.app',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: notifier.updateEmail,
                      ),
                      const SizedBox(height: 16),
                      AuthInputField(
                        controller: _passwordController,
                        label: 'SENHA',
                        hintText: '••••••••',
                        obscureText: true,
                        onChanged: notifier.updatePassword,
                      ),

                      // ── Esqueci senha ─────────────────────────────────────
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                              color: Color(0xFF6B6B8A),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // ── Erro ──────────────────────────────────────────────
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.mutedRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.mutedRed.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.mutedRed, size: 15),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.mutedRed,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ── Botão Entrar ──────────────────────────────────────
                      AuthActionButton(
                        label: state.status.isLoading ? 'Entrando…' : 'Entrar',
                        onPressed: state.canSubmit ? _onSubmit : null,
                      ),

                      const SizedBox(height: 32),

                      // ── Divisor ──────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                                height: 1,
                                color: const Color(0xFF1A1A2A)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                color: Color(0xFF3A3A4A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                height: 1,
                                color: const Color(0xFF1A1A2A)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Social ────────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _SocialBtn(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialBtn(
                              label: 'Apple',
                              icon: Icons.apple,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Criar conta ────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não tem conta?',
                            style: TextStyle(
                              color: Color(0xFF5A5A6A),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => context.push('/signup'),
                            child: const Text(
                              'Criar agora',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Termos ─────────────────────────────────────────────
                      const Center(
                        child: Text(
                          'Ao continuar você aceita os Termos de Uso\ne a Política de Privacidade.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2E2E3E),
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Social Button ─────────────────────────────────────────────────────────────
class _SocialBtn extends StatelessWidget {
  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E1E2E)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6B6B8A), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8A8A9A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}