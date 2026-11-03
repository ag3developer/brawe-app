import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/account_suspension.dart';
import '../../../core/network/live_dio_provider.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import 'legal_webview_screen.dart';

/// Tela mostrada quando a moderação suspende a conta (backend responde
/// 403 `account_suspended` em qualquer rota). O roteador prende o usuário
/// aqui até a suspensão acabar ou ele sair da conta.
class AccountSuspendedScreen extends ConsumerStatefulWidget {
  const AccountSuspendedScreen({super.key});

  @override
  ConsumerState<AccountSuspendedScreen> createState() =>
      _AccountSuspendedScreenState();
}

class _AccountSuspendedScreenState
    extends ConsumerState<AccountSuspendedScreen> {
  bool _checking = false;

  Future<void> _checkAgain() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checking = true);
    try {
      // Qualquer rota autenticada serve: se passar, a suspensão acabou.
      await ref.read(liveDioProvider).get('/messages/blocks');
      AccountSuspension.instance.clear();
    } on DioException catch (e) {
      final stillSuspended = e.response?.statusCode == 403 &&
          AccountSuspensionInfo.fromResponseData(e.response?.data) != null;
      if (stillSuspended) {
        messenger.showSnackBar(SnackBar(content: Text(s.suspendedStillActive)));
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _logout() async {
    AccountSuspension.instance.clear();
    await ref.read(authStateProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ValueListenableBuilder<AccountSuspensionInfo?>(
      valueListenable: AccountSuspension.instance,
      builder: (context, info, _) {
        final locale = Localizations.localeOf(context).toLanguageTag();
        final until = info?.until;
        return PopScope(
          canPop: false,
          child: Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  Icon(Icons.gpp_bad_outlined,
                      size: 72, color: context.colors.danger),
                  const SizedBox(height: 20),
                  Text(
                    s.suspendedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.suspendedBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  if (info != null && info.reason.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.suspendedReasonLabel,
                            style: TextStyle(
                              color: context.colors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            info.reason,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    until != null
                        ? s.suspendedUntil(
                            DateFormat.yMMMMd(locale).add_Hm().format(until))
                        : s.suspendedPermanent,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.suspendedAppeal,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  if (until != null)
                    FilledButton(
                      onPressed: _checking ? null : _checkAgain,
                      child: _checking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(s.suspendedRetry),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.mail_outline),
                    label: Text(s.suspendedContact),
                    onPressed: () => launchUrl(
                      Uri(
                        scheme: 'mailto',
                        path: AppConstants.supportEmail,
                        queryParameters: {'subject': s.suspendedTitle},
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        LegalWebViewScreen.openChildSafety(context),
                    child: Text(s.settingsChildSafety),
                  ),
                  TextButton(
                    onPressed: _logout,
                    child: Text(
                      s.settingsLogout,
                      style: TextStyle(color: context.colors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
