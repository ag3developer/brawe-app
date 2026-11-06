import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../domain/models/poll_draft.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

/// Editor inline da enquete, mostrado sob o texto do compositor.
/// Todas as opções são obrigatórias (2 a 4, 1-60 caracteres, sem repetir).
class PostPollEditor extends StatefulWidget {
  const PostPollEditor({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
  });

  final PollDraft draft;

  /// Chamado a cada mudança (texto, adicionar/remover, duração).
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<PostPollEditor> createState() => _PostPollEditorState();
}

class _PostPollEditorState extends State<PostPollEditor> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _nodes = [];
  final Set<int> _touched = {};

  PollDraft get _d => widget.draft;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _d.options.length; i++) {
      _addControllerAt(_d.options[i]);
    }
  }

  void _addControllerAt(String text) {
    final node = FocusNode();
    node.addListener(() {
      final idx = _nodes.indexOf(node);
      if (!node.hasFocus && idx >= 0 && mounted) setState(() => _touched.add(idx));
    });
    _nodes.add(node);
    _controllers.add(TextEditingController(text: text));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  void _add() {
    if (!_d.canAdd) return;
    _d.options.add('');
    _addControllerAt('');
    _changed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nodes.last.requestFocus();
    });
  }

  void _remove(int i) {
    if (!_d.canRemove) return;
    _d.options.removeAt(i);
    _controllers.removeAt(i).dispose();
    _nodes.removeAt(i).dispose();
    // Os listeners de foco guardam o índice original: recria os marcadores.
    _touched.clear();
    _changed();
  }

  String? _errorText(S s, int i) {
    final e = _d.errorAt(i);
    if (e == null) return null;
    switch (e) {
      case PollOptionError.duplicate:
        return s.pollErrorDuplicate;
      case PollOptionError.empty:
        return _touched.contains(i) ? s.pollErrorEmpty : null;
      case PollOptionError.tooLong:
        return null; // o campo já limita em 60
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.chartBar, size: 16, color: c.accentPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.pollEditorTitle,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: s.pollRemove,
                visualDensity: VisualDensity.compact,
                onPressed: widget.onRemove,
                icon: Icon(LucideIcons.x, size: 18, color: c.textTertiary),
              ),
            ],
          ),
          for (var i = 0; i < _controllers.length; i++) _optionField(context, s, i),
          if (_d.canAdd)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _add,
                icon: Icon(LucideIcons.plus, size: 16, color: c.accentPrimary),
                label: Text(
                  s.pollAddOption,
                  style: TextStyle(color: c.accentPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            s.pollDurationLabel,
            style: TextStyle(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in PollDraft.durations)
                _DurationPill(
                  label: s.pollDurationDays(d),
                  selected: _d.durationDays == d,
                  onTap: () {
                    _d.durationDays = d;
                    _changed();
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            s.pollRulesHint,
            style: TextStyle(color: c.textTertiary, fontSize: 11.5, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _optionField(BuildContext context, S s, int i) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              key: ValueKey('poll-option-$i'),
              controller: _controllers[i],
              focusNode: _nodes[i],
              maxLength: PollDraft.maxOptionLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: c.textPrimary, fontSize: 14.5),
              cursorColor: c.accentPrimary,
              onChanged: (v) {
                _d.options[i] = v;
                _changed();
              },
              decoration: InputDecoration(
                hintText: s.pollOptionHint(i + 1),
                hintStyle: TextStyle(color: c.textTertiary, fontSize: 14.5),
                errorText: _errorText(s, i),
                errorStyle: TextStyle(color: c.danger, fontSize: 11.5),
                isDense: true,
                filled: true,
                fillColor: c.surfaceHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.accentPrimary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.danger),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.danger),
                ),
              ),
            ),
          ),
          if (_d.canRemove)
            IconButton(
              tooltip: s.pollRemoveOption,
              visualDensity: VisualDensity.compact,
              onPressed: () => _remove(i),
              icon: Icon(LucideIcons.circleMinus, size: 18, color: c.textTertiary),
            ),
        ],
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.accentPrimary : c.surfaceHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? c.textOnAccent : c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
