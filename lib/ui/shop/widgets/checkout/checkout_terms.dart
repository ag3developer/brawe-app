import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../../gen/l10n/app_localizations.dart';

/// Small, clickable terms/privacy notice shown near the bottom of
/// checkout. Reuses the same `AppConstants.termsUrl`/`privacyUrl` pattern
/// already used in `signup_screen.dart` — no new legal copy invented.
class CheckoutTerms extends StatefulWidget {
  const CheckoutTerms({super.key});

  @override
  State<CheckoutTerms> createState() => _CheckoutTermsState();
}

class _CheckoutTermsState extends State<CheckoutTerms> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => _open(AppConstants.termsUrl);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => _open(AppConstants.privacyUrl);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).signupCantOpenUrl(url))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final baseStyle = TextStyle(
      color: context.colors.textSecondary,
      fontSize: 12,
      height: 1.4,
    );
    final linkStyle = TextStyle(
      color: context.colors.accentPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: s.shopCheckoutTermsPrefix),
          TextSpan(
            text: s.shopCheckoutTermsLink,
            style: linkStyle,
            recognizer: _termsTap,
          ),
          TextSpan(text: s.shopCheckoutTermsAnd),
          TextSpan(
            text: s.shopCheckoutPrivacyLink,
            style: linkStyle,
            recognizer: _privacyTap,
          ),
          TextSpan(text: s.shopCheckoutTermsSuffix),
        ],
      ),
    );
  }
}
