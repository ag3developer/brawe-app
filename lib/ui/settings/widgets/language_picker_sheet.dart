import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/locale_provider.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Bottom sheet de seleção de idioma do app.
///
/// Uso:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => const LanguagePickerSheet(),
/// );
/// ```
class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  /// Helper para abrir o sheet de forma consistente.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final current = ref.watch(localeControllerProvider);

    final entries = <_LangEntry>[
      _LangEntry(
        locale: const Locale('pt', 'BR'),
        flag: '🇧🇷',
        label: s.languagePt,
      ),
      _LangEntry(locale: const Locale('es'), flag: '🇪🇸', label: s.languageEs),
      _LangEntry(locale: const Locale('en'), flag: '🇺🇸', label: s.languageEn),
    ];

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                s.languagePickerTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          ...entries.map((e) {
            final selected = _sameLocale(current, e.locale);
            return ListTile(
              leading: Text(e.flag, style: const TextStyle(fontSize: 24)),
              title: Text(e.label),
              trailing: selected
                  ? Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(e.locale);
                if (context.mounted) Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static bool _sameLocale(Locale a, Locale b) {
    return a.languageCode == b.languageCode &&
        (a.countryCode ?? '') == (b.countryCode ?? '');
  }
}

class _LangEntry {
  final Locale locale;
  final String flag;
  final String label;
  const _LangEntry({
    required this.locale,
    required this.flag,
    required this.label,
  });
}
