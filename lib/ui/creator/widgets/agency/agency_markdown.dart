import 'package:flutter/material.dart';

import '../../../core/themes/brawe_colors.dart';

/// Renderizador mínimo de markdown (títulos, listas, negrito, parágrafos)
/// para os termos — sem dependência extra.
class AgencyMarkdown extends StatelessWidget {
  const AgencyMarkdown(this.source, {super.key});
  final String source;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final blocks = <Widget>[];
    for (final raw in source.replaceAll('\r', '').split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        blocks.add(const SizedBox(height: 6));
        continue;
      }
      final h = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
      if (h != null) {
        final level = h.group(1)!.length;
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: _rich(context, h.group(2)!,
              TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: level <= 1 ? 17 : (level == 2 ? 15.5 : 14), height: 1.3)),
        ));
        continue;
      }
      final b = RegExp(r'^\s*(?:[-*•]|\d+[.)])\s+(.*)$').firstMatch(line);
      final body = TextStyle(color: c.textSecondary, fontSize: 13.5, height: 1.45);
      if (b != null) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(left: 4, top: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: body),
            Expanded(child: _rich(context, b.group(1)!, body)),
          ]),
        ));
        continue;
      }
      blocks.add(_rich(context, line.trim(), body));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }

  Widget _rich(BuildContext context, String text, TextStyle style) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    var last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w800)));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
