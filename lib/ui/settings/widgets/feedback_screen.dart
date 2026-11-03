import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/services/social_actions_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/report_sheet.dart';

/// Feedback DENTRO do app (exigência do Google Play — Child Safety Standards:
/// o usuário precisa conseguir falar com a equipe sem sair do aplicativo).
///
/// Envia para POST /messages/reports com target_type = 'app'.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key, this.initialType = 'bug'});

  /// bug | suggestion | child_safety
  final String initialType;

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  late String _type = widget.initialType;
  final _text = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final body = _text.text.trim();
    if (body.length < 10) {
      messenger.showSnackBar(SnackBar(content: Text(s.feedbackTooShort)));
      return;
    }
    setState(() => _sending = true);
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version}+${info.buildNumber}';
    } catch (_) {}
    try {
      await ref.read(socialActionsServiceProvider).report(
        targetType: 'app',
        targetId: 'app',
        reason: _type,
        details: version.isEmpty ? body : '[v$version] $body',
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.feedbackSent)));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(s.feedbackError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final types = <(String, String, IconData)>[
      ('bug', s.feedbackTypeBug, Icons.bug_report_outlined),
      ('suggestion', s.feedbackTypeSuggestion, Icons.lightbulb_outline),
      (kReportReasonChildSafety, s.feedbackTypeChildSafety, Icons.shield_outlined),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(s.settingsSendFeedback)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              s.feedbackIntro,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (value, label, icon) in types)
                  ChoiceChip(
                    avatar: Icon(icon, size: 18),
                    label: Text(label),
                    selected: _type == value,
                    onSelected: (_) => setState(() => _type = value),
                  ),
              ],
            ),
            if (_type == kReportReasonChildSafety) ...[
              const SizedBox(height: 12),
              Text(
                s.reportChildSafetyNote,
                style: TextStyle(color: context.colors.danger, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _text,
              minLines: 5,
              maxLines: 10,
              maxLength: 1900,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: s.feedbackHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.feedbackSend),
            ),
          ],
        ),
      ),
    );
  }
}
