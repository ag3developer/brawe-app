import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/login_view_model.dart';

/// Segundo passo de um login arriscado: "Enviamos um código para j***@gmail.com".
/// Devolve (pop) o [User] já logado, ou null se a pessoa voltar ao login.
class StepUpScreen extends ConsumerStatefulWidget {
  const StepUpScreen({super.key, required this.challenge});
  final StepUpChallenge challenge;

  @override
  ConsumerState<StepUpScreen> createState() => _StepUpScreenState();
}

class _StepUpScreenState extends ConsumerState<StepUpScreen> {
  static const _len = 6;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  late StepUpChallenge _challenge = widget.challenge;
  int _resendIn = 0;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown(widget.challenge.resendIn);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _resendIn = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendIn <= 1) {
        t.cancel();
        setState(() => _resendIn = 0);
      } else {
        setState(() => _resendIn--);
      }
    });
  }

  String _wait(int? seconds) {
    final v = seconds ?? 60;
    return v >= 90 ? '${(v / 60).ceil()} min' : '$v s';
  }

  void _onChanged(String v) {
    if (_error != null) setState(() => _error = null);
    setState(() {});
    if (v.length == _len) _verify();
  }

  Future<void> _verify() async {
    if (_verifying || _ctrl.text.length != _len) return;
    final s = S.of(context);
    setState(() => _verifying = true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .stepUp(_challenge.challengeId, _ctrl.text);
      HapticFeedback.lightImpact();
      if (mounted) Navigator.of(context).pop<User>(user);
    } on DioException catch (e) {
      final d = e.response?.data;
      final detail = d is Map ? d['detail'] : null;
      final code = detail is Map ? detail['code'] : (d is Map ? d['code'] ?? detail : detail);
      // Corpo real do core: {detail:"invalid_code", remaining_attempts:n}.
      final left = d is Map ? (d['remaining_attempts'] as num?)?.toInt() : null;
      HapticFeedback.heavyImpact();
      setState(() {
        final retry = retryAfterSeconds(e.response);
        if (e.response?.statusCode == 429 && retry != null) {
          _error = s.stepUpTooMany(_wait(retry));
        } else {
          _error = switch ('$code') {
            'code_expired' => s.codeExpired,
            'too_many_attempts' => s.codeTooMany,
            'invalid_code' when left != null => s.codeInvalid(left),
            _ => s.codeInvalidSimple,
          };
        }
        _ctrl.clear();
      });
      _focus.requestFocus();
    } catch (_) {
      setState(() => _error = s.codeError);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  /// Reenvia o código do MESMO desafio (`POST /auth/login/step-up/resend`);
  /// não repete o login com senha.
  Future<void> _resend() async {
    if (_resendIn > 0 || _resending) return;
    final s = S.of(context);
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final wait = await ref
          .read(authRepositoryProvider)
          .resendStepUp(_challenge.challengeId);
      _ctrl.clear();
      _startCountdown(wait);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.codeResent)));
      }
    } on DioException catch (e) {
      final retry = retryAfterSeconds(e.response);
      if (e.response?.statusCode == 429 && retry != null && retry > 0) {
        _startCountdown(retry); // ainda em cooldown: usa o prazo do servidor
      } else if (e.response?.statusCode == 400) {
        if (mounted) setState(() => _error = s.codeExpired);
      } else if (mounted) {
        setState(() => _error = e.response?.statusCode == 429 ? s.codeTooMany : s.codeError);
      }
    } catch (_) {
      if (mounted) setState(() => _error = s.codeError);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final code = _ctrl.text;
    final email = _challenge.emailMasked;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.accentPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        LucideIcons.shieldCheck,
                        color: colors.accentPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    s.stepUpTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.stepUpSubtitle(email),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.stepUpHint,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 26),
                  GestureDetector(
                    onTap: () => _focus.requestFocus(),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0,
                          child: TextField(
                            key: const Key('stepup-field'),
                            controller: _ctrl,
                            focusNode: _focus,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            maxLength: _len,
                            enabled: !_verifying,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: _onChanged,
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < _len; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 1.6,
                                      color: _error != null
                                          ? colors.danger
                                          : (i == code.length && _focus.hasFocus
                                              ? colors.accentPrimary
                                              : colors.border),
                                    ),
                                  ),
                                  child: Text(
                                    i < code.length ? code[i] : '',
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_verifying)
                    Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.codeVerifying,
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    )
                  else if (_error != null)
                    Text(
                      _error!,
                      key: const Key('stepup-error'),
                      style: TextStyle(
                        color: colors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        key: const Key('stepup-resend'),
                        onPressed:
                            (_resendIn > 0 || _resending) ? null : _resend,
                        icon: const Icon(LucideIcons.rotateCcw, size: 16),
                        label: Text(
                          _resendIn > 0
                              ? s.codeResendIn(_resendIn)
                              : s.codeResend,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(s.stepUpBack),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    s.codeSpamHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
