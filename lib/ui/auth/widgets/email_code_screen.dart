import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/services/auth_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

/// Confirmação do e-mail ANTES de criar a conta: a pessoa digita o código
/// de 6 dígitos enviado por e-mail. Devolve (pop) o `verification_token`
/// que o cadastro usa — ou null se ela voltar para trocar o e-mail.
///
/// O código já foi enviado pela tela de cadastro antes de abrir esta.
class EmailCodeScreen extends ConsumerStatefulWidget {
  const EmailCodeScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<EmailCodeScreen> createState() => _EmailCodeScreenState();
}

class _EmailCodeScreenState extends ConsumerState<EmailCodeScreen> {
  static const _len = 6;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _resendIn = 60;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown(60);
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
      final token = await ref
          .read(authServiceProvider)
          .verifyRegisterCode(widget.email, _ctrl.text);
      HapticFeedback.lightImpact();
      if (mounted) Navigator.of(context).pop(token);
    } on DioException catch (e) {
      final d = e.response?.data;
      final detail = d is Map ? d['detail']?.toString() : null;
      final left = d is Map ? (d['attempts_left'] as num?)?.toInt() : null;
      HapticFeedback.heavyImpact();
      setState(() {
        _error = switch (detail) {
          'code_expired' => s.codeExpired,
          'too_many_attempts' => s.codeTooMany,
          'code_invalid' when left != null => s.codeInvalid(left),
          _ => s.codeInvalidSimple,
        };
        _ctrl.clear();
      });
      _focus.requestFocus();
    } catch (_) {
      setState(() => _error = s.codeError);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resendIn > 0 || _resending) return;
    final s = S.of(context);
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).sendRegisterCode(
            widget.email,
            language: Localizations.localeOf(context).languageCode,
          );
      _ctrl.clear();
      _startCountdown(60);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.codeResent)));
      }
    } on DioException catch (e) {
      final d = e.response?.data;
      final retry = d is Map ? (d['retry_after'] as num?)?.toInt() : null;
      if (retry != null) {
        _startCountdown(retry);
      } else {
        setState(() => _error = s.codeError);
      }
    } catch (_) {
      setState(() => _error = s.codeError);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final code = _ctrl.text;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(LucideIcons.mailCheck,
                    color: colors.accentPrimary, size: 26),
              ),
              const SizedBox(height: 18),
              Text(
                s.codeTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.codeSubtitle(widget.email),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // 6 caixas desenhadas sobre UM campo invisível: o iOS sugere o
              // código do e-mail (oneTimeCode) e colar funciona.
              GestureDetector(
                onTap: () => _focus.requestFocus(),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: TextField(
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  width: 1.6,
                                  color: _error != null
                                      ? const Color(0xFFEF4444)
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
              SizedBox(
                height: 20,
                child: _verifying
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(s.codeVerifying,
                              style: TextStyle(color: colors.textSecondary)),
                        ],
                      )
                    : (_error != null
                        ? Text(
                            _error!,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox.shrink()),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: (_resendIn > 0 || _resending) ? null : _resend,
                    icon: const Icon(LucideIcons.rotateCcw, size: 16),
                    label: Text(
                      _resendIn > 0 ? s.codeResendIn(_resendIn) : s.codeResend,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(s.codeChangeEmail),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                s.codeSpamHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textTertiary, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
