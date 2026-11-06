import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/widgets/brawe_logo.dart';
import '../../../domain/models/user.dart';
import '../view_models/login_view_model.dart';
import 'common/session_ended_notice.dart';
import 'step_up_screen.dart';
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
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
    _entryController.forward();
    showSessionEndedNoticeIfPending(this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  /// Abre a tela do código e conclui o login com o resultado.
  Future<void> _openStepUp(StepUpChallenge challenge) async {
    final user = await Navigator.of(context).push<User>(
      MaterialPageRoute(builder: (_) => StepUpScreen(challenge: challenge)),
    );
    if (!mounted) return;
    ref.read(stepUpChallengeProvider.notifier).set(null);
    if (user != null) {
      ref.read(loginViewModelProvider.notifier).finishLogin(user);
      AppSnackBar.showSuccess(context, S.of(context).authWelcomeBackSuccess);
    }
  }

  Future<void> _onSubmit() async {
    final success = await ref.read(loginViewModelProvider.notifier).submit();
    if (mounted) {
      final challenge = ref.read(stepUpChallengeProvider);
      if (!success && challenge != null) {
        await _openStepUp(challenge);
        return;
      }
      if (success) {
        AppSnackBar.showSuccess(context, S.of(context).authWelcomeBackSuccess);
      } else {
        final error = ref.read(loginViewModelProvider).errorMessage;
        if (error != null) AppSnackBar.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final state = ref.watch(loginViewModelProvider);
    final notifier = ref.read(loginViewModelProvider.notifier);
    final colors = context.colors;
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
                        child: Icon(
                          Icons.arrow_back,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                      ),

                      // Celular baixo (SE, mini): espaços menores para o
                      // botão Entrar caber acima do teclado.
                      SizedBox(height: compact ? 20 : 52),

                      // ── Logo + Título ────────────────────────────────────
                      // Widget de marca reutilizável, consistente com o
                      // resto do app.
                      const BraweLogo(size: 36),
                      const SizedBox(height: 24),
                      Text(
                        s.authWelcomeBackTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: compact ? 28 : 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.authLoginSubtitle,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: compact ? 24 : 48),

                      // ── Campos ───────────────────────────────────────────
                      AuthInputField(
                        controller: _emailController,
                        label: s.authEmailLabel,
                        hintText: '',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: notifier.updateEmail,
                      ),
                      const SizedBox(height: 16),
                      AuthInputField(
                        controller: _passwordController,
                        label: s.authPasswordLabel,
                        hintText: s.authPasswordHint,
                        obscureText: true,
                        onChanged: notifier.updatePassword,
                      ),

                      // ── Esqueci senha ─────────────────────────────────────
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push('/forgot-password'),
                          child: Text(
                            s.authForgotPasswordShort,
                            style: TextStyle(
                              color: colors.textSecondary,
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
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.danger.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colors.danger,
                                size: 15,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: colors.danger,
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
                        label: state.status.isLoading
                            ? s.authLoggingIn
                            : s.authEntrar,
                        onPressed: state.canSubmit ? _onSubmit : null,
                      ),

                      const SizedBox(height: 32),

                      // ── Criar conta ────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.authNoAccount,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => context.push('/signup'),
                            child: Text(
                              s.authCreateNow,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Termos ─────────────────────────────────────────────
                      Center(
                        child: Text(
                          s.authAcceptTermsAndPrivacy,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textTertiary,
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
// Social sign-in (Google/Apple) is not yet implemented; the dead UI was
// removed to comply with App Review (Guideline 2.1).
