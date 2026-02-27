import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_radius.dart';
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

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  _LoginCard(
                    state: state,
                    notifier: ref.read(loginViewModelProvider.notifier),
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmit: _onSubmit,
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      'By continuing you agree to Brawe Terms.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.coolGray.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    final success = await ref.read(loginViewModelProvider.notifier).submit();
    if (mounted) {
      if (success) {
        AppSnackBar.showSuccess(context, 'Login successful!');
        context.go('/feed');
      } else {
        final error = ref.read(loginViewModelProvider).errorMessage;
        if (error != null) {
          AppSnackBar.showError(context, error);
        }
      }
    }
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.state,
    required this.notifier,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  final LoginState state;
  final LoginViewModel notifier;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.slate.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.electricPurple,
                      AppColors.softViolet,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricPurple.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/brawe_logo.png',
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brawe',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Sign in to your account',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthInputField(
            controller: emailController,
            label: 'Email',
            hintText: 'you@brawe.app',
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.updateEmail,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthInputField(
            controller: passwordController,
            label: 'Password',
            hintText: '••••••••',
            obscureText: true,
            onChanged: notifier.updatePassword,
            prefixIcon: Icons.lock_outline,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.mutedRed,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AuthActionButton(
            label: state.status.isLoading ? 'Signing in...' : 'Sign in',
            onPressed: state.canSubmit ? onSubmit : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No account yet?',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.coolGray,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.coolCyan,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
                child: const Text(
                  'Create one',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
