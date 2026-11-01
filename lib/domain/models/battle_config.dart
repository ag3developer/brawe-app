import 'package:flutter/foundation.dart';

/// Regras públicas da batalha (`GET /live/battle/config`) que o app usa:
/// durações permitidas e a padrão.
@immutable
class BattleConfig {
  const BattleConfig({required this.durationsS, required this.defaultDurationS});

  /// Comportamento anterior ao servidor expor a configuração.
  static const fallback = BattleConfig(
    durationsS: [180, 300, 600],
    defaultDurationS: 300,
  );

  final List<int> durationsS;
  final int defaultDurationS;

  /// Aceita `{success, data:{...}}` ou as chaves no topo. Qualquer coisa
  /// inválida (lista vazia, valores não positivos) devolve `null`.
  static BattleConfig? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final m = raw['data'] is Map ? raw['data'] as Map : raw;
    final list = m['durations_s'];
    if (list is! List) return null;
    final durations = <int>{
      for (final e in list)
        if ((e is num ? e.toInt() : int.tryParse('$e')) case final n?)
          if (n > 0) n,
    }.toList()..sort();
    if (durations.isEmpty) return null;
    final d = m['default_duration_s'];
    final def = d is num ? d.toInt() : int.tryParse('${d ?? ''}');
    return BattleConfig(
      durationsS: durations,
      // Padrão fora da lista: cai na duração mais próxima da lista (a menor).
      defaultDurationS: def != null && durations.contains(def)
          ? def
          : durations.first,
    );
  }
}
