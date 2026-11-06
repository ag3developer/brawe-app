import 'package:flutter/material.dart';

/// Faixa de cor dentro do texto de um story: `[start, end)` em unidades UTF-16
/// (as mesmas do `TextSelection`). Só existem faixas com cor diferente da cor
/// base da camada — o resto do texto usa a cor base.
@immutable
class StoryColorSpan {
  const StoryColorSpan(this.start, this.end, this.colorValue);

  final int start;
  final int end;

  /// `Color.toARGB32()`.
  final int colorValue;

  int get length => end - start;
  Color get color => Color(colorValue);

  StoryColorSpan copyWith({int? start, int? end, int? colorValue}) =>
      StoryColorSpan(
        start ?? this.start,
        end ?? this.end,
        colorValue ?? this.colorValue,
      );

  Map<String, Object> toJson() => {'s': start, 'e': end, 'c': colorValue};

  static StoryColorSpan fromJson(Map<String, dynamic> j) => StoryColorSpan(
    (j['s'] as num).toInt(),
    (j['e'] as num).toInt(),
    (j['c'] as num).toInt(),
  );

  @override
  bool operator ==(Object other) =>
      other is StoryColorSpan &&
      other.start == start &&
      other.end == end &&
      other.colorValue == colorValue;

  @override
  int get hashCode => Object.hash(start, end, colorValue);

  @override
  String toString() => 'Span($start,$end,0x${colorValue.toRadixString(16)})';
}

/// Ordena, recorta em `[0, textLength]`, descarta vazias, resolve sobreposição
/// (a última vence) e funde vizinhas de mesma cor.
List<StoryColorSpan> normalizeSpans(
  Iterable<StoryColorSpan> spans,
  int textLength,
) {
  // Pinta caractere a caractere em ordem de chegada → a última vence.
  final sorted = spans
      .map(
        (s) => StoryColorSpan(
          s.start.clamp(0, textLength),
          s.end.clamp(0, textLength),
          s.colorValue,
        ),
      )
      .where((s) => s.end > s.start)
      .toList();
  if (sorted.isEmpty) return const [];
  final paint = List<int?>.filled(textLength, null);
  for (final s in sorted) {
    for (var i = s.start; i < s.end; i++) {
      paint[i] = s.colorValue;
    }
  }
  final out = <StoryColorSpan>[];
  var i = 0;
  while (i < textLength) {
    final c = paint[i];
    if (c == null) {
      i++;
      continue;
    }
    var j = i + 1;
    while (j < textLength && paint[j] == c) {
      j++;
    }
    out.add(StoryColorSpan(i, j, c));
    i = j;
  }
  return out;
}

/// Reajusta as faixas depois que o texto mudou de [oldText] para [newText].
///
/// A edição é deduzida por prefixo/sufixo comum (ou pelo [caret], quando
/// informado, para desambiguar "aa" → "aaa"). Regras:
/// * faixa antes da edição: intacta; depois: deslocada;
/// * inserção estritamente DENTRO de uma faixa herda a cor dela;
/// * inserção na borda não herda (digita-se com a cor base);
/// * remoção/substituição recorta as faixas atingidas e descarta as vazias.
List<StoryColorSpan> adjustSpans(
  List<StoryColorSpan> spans,
  String oldText,
  String newText, {
  int? caret,
}) {
  if (oldText == newText) return normalizeSpans(spans, newText.length);
  if (spans.isEmpty) return const [];

  final oldLen = oldText.length;
  final newLen = newText.length;
  final delta = newLen - oldLen;

  int start;
  int removedEnd; // fim (exclusivo) do trecho removido, em coordenadas antigas
  var resolved = false;
  start = 0;
  removedEnd = 0;

  if (caret != null && caret >= 0 && caret <= newLen) {
    if (delta > 0) {
      final s = caret - delta;
      if (s >= 0 &&
          oldText.substring(0, s) == newText.substring(0, s) &&
          oldText.substring(s) == newText.substring(caret)) {
        start = s;
        removedEnd = s;
        resolved = true;
      }
    } else if (delta < 0) {
      final removed = -delta;
      if (caret + removed <= oldLen &&
          oldText.substring(0, caret) == newText.substring(0, caret) &&
          oldText.substring(caret + removed) == newText.substring(caret)) {
        start = caret;
        removedEnd = caret + removed;
        resolved = true;
      }
    }
  }
  if (!resolved) {
    var p = 0;
    final minLen = oldLen < newLen ? oldLen : newLen;
    while (p < minLen && oldText.codeUnitAt(p) == newText.codeUnitAt(p)) {
      p++;
    }
    var q = 0;
    while (q < minLen - p &&
        oldText.codeUnitAt(oldLen - 1 - q) ==
            newText.codeUnitAt(newLen - 1 - q)) {
      q++;
    }
    start = p;
    removedEnd = oldLen - q;
  }

  final insLen = (newLen - (oldLen - (removedEnd - start))) < 0
      ? 0
      : newLen - (oldLen - (removedEnd - start));

  final out = <StoryColorSpan>[];
  for (final s in spans) {
    if (s.end <= start) {
      out.add(s);
    } else if (s.start >= removedEnd) {
      out.add(s.copyWith(start: s.start + delta, end: s.end + delta));
    } else if (s.start < start && s.end > removedEnd) {
      // Edição totalmente dentro da faixa: herda a cor.
      out.add(s.copyWith(end: s.end + delta));
    } else if (s.start < start) {
      // Faixa começa antes e termina dentro do trecho removido.
      out.add(s.copyWith(end: start));
    } else if (s.end > removedEnd) {
      // Faixa começa dentro do trecho removido e termina depois.
      out.add(s.copyWith(start: start + insLen, end: s.end + delta));
    }
    // Senão: engolida pela remoção.
  }
  return normalizeSpans(out, newLen);
}

/// Aplica [colorValue] em `[start, end)`. Se for igual a [baseValue] apenas
/// limpa as faixas naquele trecho (volta à cor base).
List<StoryColorSpan> applyColorToRange(
  List<StoryColorSpan> spans,
  int textLength,
  int start,
  int end,
  int colorValue, {
  int? baseValue,
}) {
  final a = start < end ? start : end;
  final b = start < end ? end : start;
  final lo = a.clamp(0, textLength);
  final hi = b.clamp(0, textLength);
  if (hi <= lo) return normalizeSpans(spans, textLength);
  final next = <StoryColorSpan>[...spans];
  if (colorValue == baseValue) {
    // Recorta o trecho: pinta "sem cor" refazendo as bordas.
    final carved = <StoryColorSpan>[];
    for (final s in spans) {
      if (s.end <= lo || s.start >= hi) {
        carved.add(s);
        continue;
      }
      if (s.start < lo) carved.add(s.copyWith(end: lo));
      if (s.end > hi) carved.add(s.copyWith(start: hi));
    }
    return normalizeSpans(carved, textLength);
  }
  next.add(StoryColorSpan(lo, hi, colorValue));
  return normalizeSpans(next, textLength);
}

/// Recorta as faixas para a janela `[from, to)` e as reposiciona em 0
/// (usado quando o texto é "trimado" antes de virar camada).
List<StoryColorSpan> sliceSpans(List<StoryColorSpan> spans, int from, int to) {
  final out = <StoryColorSpan>[];
  for (final s in spans) {
    final a = s.start < from ? from : s.start;
    final b = s.end > to ? to : s.end;
    if (b > a) out.add(StoryColorSpan(a - from, b - from, s.colorValue));
  }
  return normalizeSpans(out, to - from);
}

/// Cor da faixa que cobre todo `[start, end)`; `null` se for mista ou base.
int? uniformSpanColor(List<StoryColorSpan> spans, int start, int end) {
  for (final s in spans) {
    if (s.start <= start && s.end >= end) return s.colorValue;
  }
  return null;
}

/// Constrói o `TextSpan` rico. [styleFor] devolve o estilo completo de uma
/// faixa colorida (assim a camada e o campo usam exatamente a mesma regra).
/// [composing] (opcional) recebe sublinhado, como o `TextField` padrão.
TextSpan buildStoryTextSpan({
  required String text,
  required List<StoryColorSpan> spans,
  required TextStyle? baseStyle,
  required TextStyle Function(Color color) styleFor,
  TextRange? composing,
}) {
  final cuts = <int>{0, text.length};
  for (final s in spans) {
    cuts
      ..add(s.start.clamp(0, text.length))
      ..add(s.end.clamp(0, text.length));
  }
  final hasComposing =
      composing != null && composing.isValid && !composing.isCollapsed;
  if (hasComposing) {
    cuts
      ..add(composing.start.clamp(0, text.length))
      ..add(composing.end.clamp(0, text.length));
  }
  final points = cuts.toList()..sort();
  final children = <TextSpan>[];
  for (var i = 0; i < points.length - 1; i++) {
    final a = points[i];
    final b = points[i + 1];
    if (b <= a) continue;
    TextStyle? st;
    for (final s in spans) {
      if (s.start <= a && s.end >= b) {
        st = styleFor(s.color);
        break;
      }
    }
    if (hasComposing && a >= composing.start && b <= composing.end) {
      st = (st ?? const TextStyle()).merge(
        const TextStyle(decoration: TextDecoration.underline),
      );
    }
    children.add(TextSpan(text: text.substring(a, b), style: st));
  }
  return TextSpan(style: baseStyle, children: children);
}

/// `TextEditingController` com cores por trecho. As faixas acompanham a
/// digitação/remoção via [adjustSpans].
class StoryRichTextController extends TextEditingController {
  StoryRichTextController({
    super.text,
    required this.styleFor,
    List<StoryColorSpan> spans = const [],
  }) : _spans = List.of(spans);

  /// Estilo completo de uma faixa colorida (definido pelo editor; muda com
  /// fonte/fundo, por isso é um campo e não final no construtor do estilo).
  TextStyle Function(Color color) styleFor;

  List<StoryColorSpan> _spans;
  List<StoryColorSpan> get spans => List.unmodifiable(_spans);

  /// Troca texto + faixas de uma vez (abrir/reeditar camada).
  void load(String newText, List<StoryColorSpan> newSpans) {
    super.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    _spans = normalizeSpans(newSpans, newText.length);
    notifyListeners();
  }

  void clearSpans() {
    if (_spans.isEmpty) return;
    _spans = [];
    notifyListeners();
  }

  /// Pinta a seleção atual; devolve `false` se não há seleção (cursor só).
  bool applyColorToSelection(int colorValue, {int? baseValue}) {
    final sel = value.selection;
    if (!sel.isValid || sel.isCollapsed) return false;
    _spans = applyColorToRange(
      _spans,
      text.length,
      sel.start,
      sel.end,
      colorValue,
      baseValue: baseValue,
    );
    notifyListeners();
    return true;
  }

  /// Toque numa cor: com seleção pinta só o trecho (devolve `true`); com
  /// cursor limpa as faixas (a cor passa a valer para o texto todo — e para
  /// o que for digitado) e devolve `false` para o chamador trocar a cor base.
  bool pickColor(int colorValue, {required int baseValue}) {
    if (applyColorToSelection(colorValue, baseValue: baseValue)) return true;
    clearSpans();
    return false;
  }

  @override
  set value(TextEditingValue newValue) {
    if (newValue.text != text) {
      final sel = newValue.selection;
      _spans = adjustSpans(
        _spans,
        text,
        newValue.text,
        caret: sel.isValid && sel.isCollapsed ? sel.baseOffset : null,
      );
    }
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return buildStoryTextSpan(
      text: text,
      spans: _spans,
      baseStyle: style,
      styleFor: styleFor,
      composing: withComposing && value.isComposingRangeValid
          ? value.composing
          : null,
    );
  }
}
