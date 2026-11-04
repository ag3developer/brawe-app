import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/signup_view_model.dart';
import 'common/auth_action_button.dart';
import 'common/auth_background.dart';
import 'common/auth_input_field.dart';
import '../../core/widgets/brawe_logo.dart';
import '../../settings/widgets/legal_webview_screen.dart';
import 'package:dio/dio.dart';
import '../../../data/services/auth_service.dart';
import 'email_code_screen.dart';

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
    // Celular baixo (SE, mini): menos respiro para o formulário inteiro
    // caber e o botão Criar conta ficar à vista.
    final compact = MediaQuery.sizeOf(context).height < 760;

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
                  SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: const _Hero(),
                    ),
                  ),
                  SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl),
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
                        sendingCode: _sendingCode,
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

  bool _sendingCode = false;

  /// Criar conta: 1) confere o formulário, 2) envia o código para o e-mail,
  /// 3) abre a tela do código, 4) só com o código certo cria a conta (com o
  /// e-mail já confirmado). Assim não nasce conta com e-mail falso.
  Future<void> _onSubmit() async {
    final s = S.of(context);
    final vm = ref.read(signupViewModelProvider.notifier);
    if (_sendingCode) return;
    if (!vm.validate()) {
      final error = ref.read(signupViewModelProvider).errorMessage;
      if (error != null) {
        AppSnackBar.showError(context, signupErrorText(s, error));
      }
      return;
    }
    final email = ref.read(signupViewModelProvider).email.trim().toLowerCase();
    setState(() => _sendingCode = true);
    String? token;
    var serverHasCode = true;
    try {
      await ref.read(authServiceProvider).sendRegisterCode(
            email,
            language: Localizations.localeOf(context).languageCode,
          );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final d = e.response?.data;
      final detail = d is Map ? d['detail']?.toString() : null;
      if (status == 404 || status == 405) {
        // Servidor antigo, sem o código: segue o cadastro de antes.
        serverHasCode = false;
      } else if (status == 429 && detail == 'resend_too_soon') {
        // Já enviamos há pouco: segue para a tela do código.
      } else {
        if (mounted) {
          setState(() => _sendingCode = false);
          AppSnackBar.showError(
            context,
            switch (detail) {
              'email_already_registered' => s.signupErrEmailTaken,
              'invalid_email' => s.signupErrEmail,
              'too_many_requests' => s.codeTooManyRequests,
              _ when status == 409 => s.signupErrEmailTaken,
              // Bloqueios do servidor (domínio descartável etc.) já vêm
              // com mensagem legível.
              _ when status == 400 && detail != null => detail,
              _ => s.codeError,
            },
          );
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _sendingCode = false);
        AppSnackBar.showError(context, s.codeError);
      }
      return;
    }
    if (!mounted) return;
    setState(() => _sendingCode = false);

    if (serverHasCode) {
      token = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => EmailCodeScreen(email: email)),
      );
      if (token == null || !mounted) return; // voltou para trocar o e-mail
    }

    final success = await vm.submit(emailVerificationToken: token);
    if (mounted) {
      if (success) {
        AppSnackBar.showSuccess(context, s.signupSuccess);
      } else {
        final error = ref.read(signupViewModelProvider).errorMessage;
        if (error != null) {
          AppSnackBar.showError(context, signupErrorText(s, error));
        }
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
              child: Icon(
                LucideIcons.arrowLeft,
                color: colors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(
            LucideIcons.helpCircle,
            color: colors.textTertiary,
            size: 16,
          ),
          label: Text(
            S.of(context).signupHelp,
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
    final s = S.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BraweLogo(size: 36),
        SizedBox(height: MediaQuery.sizeOf(context).height < 760 ? AppSpacing.sm : AppSpacing.lg),
        Text(
          s.signupTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: MediaQuery.sizeOf(context).height < 760 ? 30 : 36,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          s.signupSubtitle,
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
    this.sendingCode = false,
  });

  /// Enviando o código de confirmação para o e-mail.
  final bool sendingCode;

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
    final s = S.of(context);

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
                label: s.signupNameLabel,
                hintText: s.signupNameHint,
                onChanged: widget.notifier.updateName,
                prefixIcon: LucideIcons.user,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthInputField(
                controller: widget.emailController,
                label: s.signupEmailLabel,
                hintText: '',
                keyboardType: TextInputType.emailAddress,
                onChanged: widget.notifier.updateEmail,
                prefixIcon: LucideIcons.atSign,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthInputField(
                controller: widget.passwordController,
                label: s.signupPasswordLabel,
                hintText: s.signupPasswordHint,
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
                  label: s.signupSponsorLabel,
                  hintText: s.signupSponsorHint,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: Text(
                      s.signupHaveReferral,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
                      Icon(
                        LucideIcons.alertCircle,
                        color: colors.danger,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          signupErrorText(S.of(context), state.errorMessage!),
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
                label: widget.sendingCode
                    ? s.signupSendingCode
                    : (state.status.isLoading
                        ? s.signupCreatingAccount
                        : s.signupCreateAccountButton),
                onPressed: state.canSubmit && !widget.sendingCode
                    ? widget.onSubmit
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.authAlreadyHaveAccount,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.accentSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      s.authEntrar,
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
    final s = S.of(context);
    final score = _score;
    final tokens = context.colors;
    final colors = [
      tokens.danger,
      Colors.orange,
      Colors.amber,
      tokens.accentSecondary,
      tokens.success,
    ];
    final labels = [
      s.pwStrengthWeak,
      s.pwStrengthWeak,
      s.pwStrengthMedium,
      s.pwStrengthGood,
      s.pwStrengthStrong,
    ];
    final color = colors[score];

    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: i < score ? color : tokens.surfaceHighest,
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
                side: BorderSide(color: colors.textTertiary, width: 1.4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _TermsRichText()),
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
    _termsTap = TapGestureRecognizer()
      ..onTap = () => LegalWebViewScreen.openLegal(context, privacy: false);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => LegalWebViewScreen.openLegal(context, privacy: true);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
          TextSpan(text: s.signupTermsPrefix),
          TextSpan(
            text: s.settingsTermsOfUse,
            style: link,
            recognizer: _termsTap,
          ),
          TextSpan(text: s.signupTermsAnd),
          TextSpan(
            text: s.settingsPrivacyPolicy,
            style: link,
            recognizer: _privacyTap,
          ),
          TextSpan(text: s.signupTermsSuffix),
        ],
      ),
    );
  }
}


/// Traduz os erros do formulário de cadastro (o view model grava códigos).
String signupErrorText(S s, String raw) => switch (raw) {
      'signup.err.name' => s.signupErrName,
      'signup.err.email' => s.signupErrEmail,
      'signup.err.password' => s.signupErrPassword,
      'signup.err.terms' => s.signupErrTerms,
      _ => raw,
    };
