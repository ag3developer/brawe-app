import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/signup_view_model.dart';
import 'common/auth_action_button.dart';
import 'common/auth_background.dart';
import 'common/auth_input_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _sponsorController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _sponsorController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _sponsorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SignupCard(
                    state: state,
                    notifier: ref.read(signupViewModelProvider.notifier),
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    sponsorController: _sponsorController,
                    onSubmit: _onSubmit,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      'By signing up you agree to Brawe Terms.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.coolGray.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
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

  Future<void> _onSubmit() async {
    final success = await ref.read(signupViewModelProvider.notifier).submit();
    if (mounted) {
      if (success) {
        AppSnackBar.showSuccess(context, 'Account created successfully!');
        context.go('/feed');
      } else {
        final error = ref.read(signupViewModelProvider).errorMessage;
        if (error != null) {
          AppSnackBar.showError(context, error);
        }
      }
    }
  }
}

class _SignupCard extends StatelessWidget {
  const _SignupCard({
    required this.state,
    required this.notifier,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.sponsorController,
    required this.onSubmit,
  });

  final SignupState state;
  final SignupViewModel notifier;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController sponsorController;
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
          Text(
            'Create Account',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Join the Brawe community',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.coolGray,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthInputField(
            controller: nameController,
            label: 'Full Name',
            hintText: 'John Doe',
            onChanged: notifier.updateName,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.lg),
          AuthInputField(
            controller: sponsorController,
            label: 'Sponsor Code (Optional)',
            hintText: 'CODE123',
            onChanged: notifier.updateSponsorCode,
            prefixIcon: Icons.card_giftcard,
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
            label: state.status.isLoading ? 'Creating account...' : 'Sign up',
            onPressed: state.canSubmit ? onSubmit : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.coolGray,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.coolCyan,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
                child: const Text(
                  'Sign in',
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
