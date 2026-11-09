// Privacidade › Palavras ocultas: filtro de ofensas + lista própria (até 200).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/privacy_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/grouped_list.dart';
import 'privacy_common.dart';

const _maxWords = 200;

class HiddenWordsScreen extends ConsumerStatefulWidget {
  const HiddenWordsScreen({super.key});

  @override
  ConsumerState<HiddenWordsScreen> createState() => _HiddenWordsScreenState();
}

class _HiddenWordsScreenState extends ConsumerState<HiddenWordsScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _patch(
    Map<String, dynamic> body,
    PrivacySettings Function(PrivacySettings) apply,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(privacyProvider.notifier).patch(body, apply);
    } catch (e) {
      if (!mounted) return;
      showPrivacyError(
        messenger,
        privacyErrorText(context, e),
        context.colors.danger,
      );
    }
  }

  void _add(List<String> words) {
    final w = _ctrl.text.trim().toLowerCase();
    if (w.isEmpty) return;
    if (words.contains(w)) {
      _ctrl.clear();
      return;
    }
    if (words.length >= _maxWords) {
      showPrivacyError(
        ScaffoldMessenger.of(context),
        S.of(context).privacyHiddenWordsMax(_maxWords),
        context.colors.danger,
      );
      return;
    }
    final next = [...words, w];
    _ctrl.clear();
    _patch({'hidden_words': next}, (x) => x.copyWith(hiddenWords: next));
  }

  void _remove(List<String> words, String w) {
    final next = words.where((e) => e != w).toList();
    _patch({'hidden_words': next}, (x) => x.copyWith(hiddenWords: next));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final st = ref.watch(privacyProvider).value?.settings;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.privacyHiddenWords),
        centerTitle: true,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: st == null
          ? const Center(child: CircularProgressIndicator())
          : GroupedBody(
              children: [
                GroupedSection(
                  footer: s.privacyFilterOffensiveHint,
                  children: [
                    GroupedRow(
                      icon: LucideIcons.shieldAlert,
                      title: s.privacyFilterOffensive,
                      trailing: PrivacySwitch(
                        value: st.filterOffensive,
                        onChanged: (v) => _patch({
                          'filter_offensive': v,
                        }, (x) => x.copyWith(filterOffensive: v)),
                      ),
                    ),
                  ],
                ),
                GroupedSection(
                  caption: s.privacyCustomWords,
                  footer: s.privacyCustomWordsHint(_maxWords),
                  children: [
                    GroupedField(
                      label: s.privacyAddWord,
                      trailing: IconButton(
                        icon: Icon(
                          LucideIcons.plus,
                          color: colors.accentPrimary,
                        ),
                        onPressed: () => _add(st.hiddenWords),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        maxLength: 40,
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _add(st.hiddenWords),
                        decoration: groupedInput(
                          context,
                          hint: s.privacyAddWordHint,
                          counter: '',
                        ),
                      ),
                    ),
                    if (st.hiddenWords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final w in st.hiddenWords)
                                InputChip(
                                  label: Text(w),
                                  onDeleted: () => _remove(st.hiddenWords, w),
                                  deleteIcon: const Icon(
                                    LucideIcons.x,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
