import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/signup_view_model.dart';
import 'common/auth_action_button.dart';
import 'common/auth_background.dart';
import '../../../core/constants/app_constants.dart';
import 'common/auth_input_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _sponsorController;
  late final AnimationController _entry;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _sponsorController = TextEditingController();

    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
    _entry.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _sponsorController.dispose();
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(onBack: () => context.go('/welcome')),
                  const SizedBox(height: AppSpacing.lg),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: const _Hero(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: _SignupCard(
                        state: state,
                        notifier: ref.read(signupViewModelProvider.notifier),
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        sponsorController: _sponsorController,
                        onSubmit: _onSubmit,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _TermsCheckbox(
                    accepted: state.termsAccepted,
                    onChanged: (v) => ref
                        .read(signupViewModelProvider.notifier)
                        .updateTermsAccepted(v),
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
        AppSnackBar.showSuccess(context, 'Conta criada com sucesso.');
      } else {
        final error = ref.read(signupViewModelProvider).errorMessage;
        if (error != null) AppSnackBar.showError(context, error);
      }
    }
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: colors.surface.withValues(alpha: 0.6),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Icon(LucideIcons.arrowLeft,
                  color: colors.textPrimary, size: 20),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(LucideIcons.helpCircle,
              color: colors.textTertiary, size: 16),
          label: Text(
            'Ajuda',
            style: TextStyle(color: colors.textTertiary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ── Hero (mesma linguagem do login) ─────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.accentPrimary.withValues(alpha: 0.6),
                    colors.accentPrimary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.accentPrimary,
                    AppColors.softViolet,
                    colors.accentSecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colors.accentPrimary.withValues(alpha: 0.55),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/brawe_logo.png',
                  fit: BoxFit.contain,
                  color: colors.textOnAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Crie sua conta.',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Leva menos de um minuto para começar.',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Card de cadastro ────────────────────────────────────────────────────────
class _SignupCard extends StatefulWidget {
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
  State<_SignupCard> createState() => _SignupCardState();
}

class _SignupCardState extends State<_SignupCard> {
  bool _showSponsor = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surface.withValues(alpha: 0.8),
                colors.surfaceElevated.withValues(alpha: 0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.overlay.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthInputField(
                controller: widget.nameController,
                label: 'Nome completo',
                hintText: 'Como devemos te chamar?',
                onChanged: widget.notifier.updateName,
                prefixIcon: LucideIcons.user,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthInputField(
                controller: widget.emailController,
                label: 'E-mail',
                hintText: 'voce@brawe.app',
                keyboardType: TextInputType.emailAddress,
                onChanged: widget.notifier.updateEmail,
                prefixIcon: LucideIcons.atSign,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthInputField(
                controller: widget.passwordController,
                label: 'Senha',
                hintText: 'mínimo 8 caracteres',
                obscureText: true,
                onChanged: widget.notifier.updatePassword,
                prefixIcon: LucideIcons.lock,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PasswordStrength(password: state.password),
              const SizedBox(height: AppSpacing.sm),
              if (_showSponsor) ...[
                AuthInputField(
                  controller: widget.sponsorController,
                  label: 'Código do patrocinador',
                  hintText: 'BRAWE-XXXX',
                  onChanged: widget.notifier.updateSponsorCode,
                  prefixIcon: LucideIcons.tag,
                ),
                const SizedBox(height: AppSpacing.sm),
              ] else
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showSponsor = true),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.accentSecondary,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text(
                      'Tenho um código de indicação',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: colors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle,
                          color: colors.danger, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AuthActionButton(
                label: state.status.isLoading
                    ? 'Criando conta…'
                    : 'Criar conta',
                onPressed: state.canSubmit ? widget.onSubmit : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem conta?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.accentSecondary,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Indicador de força de senha ─────────────────────────────────────────────
class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.password});
  final String password;

  int get _score {
    int s = 0;
    if (password.length >= 8) s++;
    if (password.length >= 12) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password)) s++;
    return s.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox(height: 8);
    final score = _score;
    final tokens = context.colors;
    final colors = [
      tokens.danger,
      Colors.orange,
      Colors.amber,
      tokens.accentSecondary,
      tokens.success,
    ];
    final labels = ['Fraca', 'Fraca', 'Média', 'Boa', 'Forte'];
    final color = colors[score];

    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: i < score
                    ? color
                    : tokens.surfaceHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 4),
        ],
        const SizedBox(width: 8),
        Text(
          labels[score],
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Terms checkbox ──────────────────────────────────────────────────────────
class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.accepted, required this.onChanged});
  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () => onChanged(!accepted),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: accepted,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: colors.accentPrimary,
                checkColor: colors.textOnAccent,
                side: BorderSide(
                  color: colors.textTertiary,
                  width: 1.4,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TermsRichText(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tappable legal text ─────────────────────────────────────────────────────
class _TermsRichText extends StatefulWidget {
  @override
  State<_TermsRichText> createState() => _TermsRichTextState();
}

class _TermsRichTextState extends State<_TermsRichText> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () => _open(AppConstants.termsUrl);
    _privacyTap = TapGestureRecognizer()..onTap = () => _open(AppConstants.privacyUrl);
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir $url')),
        );
      }
    }
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = TextStyle(
      color: colors.textSecondary,
      fontSize: 12,
      height: 1.4,
    );
    final link = base.copyWith(
      color: colors.accentPrimary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'Li e aceito os '),
          TextSpan(text: 'Termos de Uso', style: link, recognizer: _termsTap),
          const TextSpan(text: ' e a '),
          TextSpan(text: 'Política de Privacidade', style: link, recognizer: _privacyTap),
          const TextSpan(text: ' do Brawe.'),
        ],
      ),
    );
  }
}
