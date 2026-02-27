import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/login_view_model.dart';

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
          const _LoginBackground(),
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
      } else {
        final error = ref.read(loginViewModelProvider).errorMessage;
        if (error != null) {
          AppSnackBar.showError(context, error);
        }
      }
    }
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.nearBlack,
        gradient: RadialGradient(
          center: Alignment(0.7, -0.6),
          radius: 1.5,
          colors: [
            Color(0xFF1E2A5E),
            AppColors.nearBlack,
          ],
          stops: [0.0, 0.7],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _LoginBackgroundPainter(),
            child: const SizedBox.expand(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const gridSpacing = 32.0;
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final accentPaint = Paint()
      ..color = AppColors.electricPurple.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width + size.height; i += 128) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginInputField extends StatelessWidget {
  const _LoginInputField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.coolGray,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: textTheme.bodyLarge?.copyWith(color: Colors.white),
          cursorColor: AppColors.electricPurple,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: AppColors.coolGray.withValues(alpha: 0.5),
            ),
            prefixIcon:
                prefixIcon != null
                    ? Icon(
                      prefixIcon,
                      color: AppColors.coolGray.withValues(alpha: 0.7),
                      size: 20,
                    )
                    : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.electricPurple,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              !isDisabled
                  ? const LinearGradient(
                    colors: [AppColors.electricPurple, AppColors.softViolet],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                  : null,
          color: isDisabled ? Colors.white.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow:
              !isDisabled
                  ? [
                    BoxShadow(
                      color: AppColors.electricPurple.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
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
          _LoginInputField(
            controller: emailController,
            label: 'Email',
            hintText: 'you@brawe.app',
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.updateEmail,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          _LoginInputField(
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
          _PrimaryActionButton(
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
                onPressed: () {},
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
