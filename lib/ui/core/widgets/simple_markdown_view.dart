import 'package:flutter/material.dart';

import '../../core/themes/brawe_colors.dart';

/// Mini renderer de Markdown — suporta o subset que usamos nos termos:
///   • `# `, `## `, `### ` headings
///   • `---` separator
///   • parágrafos
///   • listas `- `
///   • `**bold**` inline
///   • `_italic_` ou `*italic*` inline
///   • `[label](url)` (renderiza só o label sublinhado)
///
/// Não puxa nenhuma dependência externa.
class SimpleMarkdownView extends StatelessWidget {
  const SimpleMarkdownView({
    super.key,
    required this.markdown,
    this.padding = const EdgeInsets.all(20),
  });

  final String markdown;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];

    final listBuffer = <String>[];
    final paraBuffer = <String>[];

    void flushPara() {
      if (paraBuffer.isEmpty) return;
      widgets.add(_paragraph(context, paraBuffer.join(' ')));
      paraBuffer.clear();
    }

    void flushList() {
      if (listBuffer.isEmpty) return;
      widgets.add(_list(context, List.of(listBuffer)));
      listBuffer.clear();
    }

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.trim().isEmpty) {
        flushPara();
        flushList();
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      if (line.startsWith('---')) {
        flushPara();
        flushList();
        widgets.add(_divider(context));
        continue;
      }

      if (line.startsWith('### ')) {
        flushPara();
        flushList();
        widgets.add(_heading(context, line.substring(4), 3));
        continue;
      }
      if (line.startsWith('## ')) {
        flushPara();
        flushList();
        widgets.add(_heading(context, line.substring(3), 2));
        continue;
      }
      if (line.startsWith('# ')) {
        flushPara();
        flushList();
        widgets.add(_heading(context, line.substring(2), 1));
        continue;
      }

      if (line.startsWith('- ')) {
        flushPara();
        listBuffer.add(line.substring(2));
        continue;
      }

      flushList();
      paraBuffer.add(line);
    }

    flushPara();
    flushList();

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _divider(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Container(height: 1, color: context.colors.border),
      );

  Widget _heading(BuildContext context, String text, int level) {
    final sizes = {1: 24.0, 2: 19.0, 3: 16.0};
    final weights = {
      1: FontWeight.w800,
      2: FontWeight.w800,
      3: FontWeight.w700,
    };
    return Padding(
      padding: EdgeInsets.only(top: level == 1 ? 4 : 18, bottom: 8),
      child: _RichLine(
        text: text,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: sizes[level],
          fontWeight: weights[level],
          height: 1.25,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _paragraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _RichLine(
        text: text,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 10, left: 4),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.colors.accentPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _RichLine(
                      text: item,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RichLine extends StatelessWidget {
  const _RichLine({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final spans = _parseInline(text, style);
    return SelectableText.rich(TextSpan(children: spans, style: style));
  }

  /// Parse `**bold**`, `_italic_`/`*italic*` e `[label](url)` num único passe.
  List<InlineSpan> _parseInline(String input, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'(\*\*([^*]+)\*\*)|(\_([^_]+)\_)|(\*([^*]+)\*)|(\[([^\]]+)\]\(([^)]+)\))',
    );

    var idx = 0;
    for (final m in pattern.allMatches(input)) {
      if (m.start > idx) {
        spans.add(TextSpan(text: input.substring(idx, m.start)));
      }
      if (m.group(2) != null) {
        spans.add(TextSpan(
          text: m.group(2),
          style: baseStyle.copyWith(fontWeight: FontWeight.w800),
        ));
      } else if (m.group(4) != null) {
        spans.add(TextSpan(
          text: m.group(4),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (m.group(6) != null) {
        spans.add(TextSpan(
          text: m.group(6),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (m.group(8) != null) {
        spans.add(TextSpan(
          text: m.group(8),
          style: baseStyle.copyWith(
            decoration: TextDecoration.underline,
          ),
        ));
      }
      idx = m.end;
    }
    if (idx < input.length) spans.add(TextSpan(text: input.substring(idx)));
    return spans;
  }
}
