/// Rascunho da enquete no compositor. Regras (todas obrigatórias):
/// 2 a 4 opções, cada uma de 1 a 60 caracteres, sem repetição.
enum PollOptionError { empty, tooLong, duplicate }

class PollDraft {
  PollDraft({List<String>? options, this.durationDays = 1})
    : options = List<String>.of(options ?? const ['', '']);

  static const minOptions = 2;
  static const maxOptions = 4;
  static const maxOptionLength = 60;
  static const durations = [1, 3, 7];

  final List<String> options;
  int durationDays;

  bool get canAdd => options.length < maxOptions;
  bool get canRemove => options.length > minOptions;

  static String _norm(String s) => s.trim().toLowerCase();

  /// Erro da opção [i], ou null se estiver válida.
  PollOptionError? errorAt(int i) {
    final t = options[i].trim();
    if (t.isEmpty) return PollOptionError.empty;
    if (t.length > maxOptionLength) return PollOptionError.tooLong;
    final n = _norm(t);
    for (var j = 0; j < options.length; j++) {
      if (j != i && _norm(options[j]) == n) return PollOptionError.duplicate;
    }
    return null;
  }

  bool get isValid =>
      options.length >= minOptions &&
      options.length <= maxOptions &&
      durations.contains(durationDays) &&
      List.generate(options.length, errorAt).every((e) => e == null);

  /// Payload do campo `poll` em `POST /posts`.
  Map<String, dynamic> toRequestJson() => {
    'options': [for (final o in options) o.trim()],
    'duration_days': durationDays,
  };
}
