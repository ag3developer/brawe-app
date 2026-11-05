import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/battle_assets.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Estilo visual da frase do narrador.
enum NarratorStyle { normal, boost, gold }

NarratorStyle narratorStyleOf(String? s) => switch (s) {
  'boost' => NarratorStyle.boost,
  'gold' => NarratorStyle.gold,
  _ => NarratorStyle.normal,
};

/// Uma frase pronta para a faixa do jogo (§19.3).
@immutable
class NarratorLine {
  const NarratorLine({
    required this.key,
    required this.text,
    this.priority = 50,
    this.ttl = const Duration(seconds: 4),
    this.style = NarratorStyle.normal,
  });

  final String key;
  final String text;
  final int priority;
  final Duration ttl;
  final NarratorStyle style;
}

/// Prioridade/ttl/estilo padrão por chave (espelha o seed do servidor);
/// usados quando o manifesto não traz a chave.
const Map<String, ({int priority, int ttlMs, NarratorStyle style})>
kNarratorDefaults = {
  'start': (priority: 50, ttlMs: 4000, style: NarratorStyle.normal),
  'lead_change_own': (priority: 70, ttlMs: 4000, style: NarratorStyle.boost),
  'lead_change_other': (priority: 70, ttlMs: 4000, style: NarratorStyle.normal),
  'momentum': (priority: 40, ttlMs: 4000, style: NarratorStyle.boost),
  'flash_start': (priority: 80, ttlMs: 4000, style: NarratorStyle.boost),
  'flash_done': (priority: 80, ttlMs: 4000, style: NarratorStyle.boost),
  'final_10s': (priority: 90, ttlMs: 4000, style: NarratorStyle.boost),
  'victory': (priority: 100, ttlMs: 5000, style: NarratorStyle.gold),
  'defeat': (priority: 100, ttlMs: 5000, style: NarratorStyle.normal),
  'draw': (priority: 100, ttlMs: 5000, style: NarratorStyle.gold),
  'ended': (priority: 100, ttlMs: 5000, style: NarratorStyle.normal),
  'mvp': (priority: 95, ttlMs: 5000, style: NarratorStyle.gold),
  'goal_reached': (priority: 30, ttlMs: 4000, style: NarratorStyle.normal),
  'level_up': (priority: 20, ttlMs: 4000, style: NarratorStyle.normal),
  'muted_by_you': (priority: 30, ttlMs: 4000, style: NarratorStyle.normal),
  'muted_you': (priority: 30, ttlMs: 4000, style: NarratorStyle.normal),
};

/// Substitui `{nome} {time} {tempo} {mult} {pontos} {falta} {poder}`.
/// Variável sem valor some (sem deixar chaves na tela).
String fillNarratorVars(String template, Map<String, String> vars) {
  final out = template.replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) {
    return vars[m.group(1)] ?? '';
  });
  return out.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

/// Texto padrão (ARB) de cada chave do narrador.
String narratorFallbackText(S l10n, String key, Map<String, String> v) {
  String g(String k) => v[k] ?? '';
  switch (key) {
    case 'start':
      return l10n.battleNarrStart;
    case 'lead_change_own':
      return l10n.battleNarrLeadOwn(g('time'));
    case 'lead_change_other':
      return l10n.battleNarrLeadOther(g('time'));
    case 'momentum':
      return l10n.battleNarrMomentum(g('time'));
    case 'flash_start':
      return l10n.battleNarrFlashStart(g('pontos'), g('nome'), g('tempo'));
    case 'flash_done':
      return l10n.battleNarrFlashDone(g('mult'), g('tempo'));
    case 'final_10s':
      return l10n.battleNarrFinal10(g('mult'));
    case 'victory':
      return l10n.battleNarrVictory(g('time'));
    case 'defeat':
      return l10n.battleNarrDefeat(g('time'));
    case 'draw':
      return l10n.battleNarrDraw;
    case 'ended':
      return l10n.battleNarrEnded;
    case 'mvp':
      return l10n.battleMvpPill(g('nome'), g('pontos'));
    case 'goal_reached':
      return l10n.goalReachedChat(g('nome'));
    case 'level_up':
      return l10n.liveLevelUpPublic(g('nome'), int.tryParse(g('nivel')) ?? 0);
    case 'muted_by_you':
      return l10n.battleMutedLine(g('nome'));
    case 'muted_you':
      return l10n.battleMutedByLine(g('nome'));
  }
  return '';
}

/// Monta a frase: texto do manifesto (idioma do app) com as variáveis, ou o
/// texto padrão (ARB). `null` se não houver texto nenhum.
NarratorLine? resolveNarratorLine({
  required BattleManifest? manifest,
  required S l10n,
  required String lang,
  required String key,
  Map<String, String> vars = const {},
}) {
  final entry = manifest?.narrator[key];
  final def = kNarratorDefaults[key];
  final custom = entry?.textFor(lang);
  final text = custom != null
      ? fillNarratorVars(custom, vars)
      : narratorFallbackText(l10n, key, vars);
  if (text.isEmpty) return null;
  final ttlMs = (entry?.ttlMs ?? def?.ttlMs ?? 4000).clamp(800, 15000);
  return NarratorLine(
    key: key,
    text: text,
    priority: entry?.priority ?? def?.priority ?? 50,
    ttl: Duration(milliseconds: ttlMs),
    style: entry?.style != null
        ? narratorStyleOf(entry!.style)
        : (def?.style ?? NarratorStyle.normal),
  );
}

/// Fila do narrador: UMA frase por vez; prioridade maior interrompe a atual;
/// a mesma chave repetida dentro do ttl é descartada.
class BattleNarratorController extends ChangeNotifier {
  BattleNarratorController({DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final DateTime Function() _now;

  NarratorLine? _current;
  final List<({NarratorLine line, DateTime at})> _queue = [];
  final Map<String, DateTime> _lastSeen = {};
  Timer? _timer;
  bool _disposed = false;

  /// Há uma batalha na tela (decide se avisos do jogo vão para o narrador
  /// ou para o painel de avisos da live).
  bool active = false;

  NarratorLine? get current => _current;

  void push(NarratorLine line) {
    final now = _now();
    final seen = _lastSeen[line.key];
    if (seen != null && now.difference(seen) < line.ttl) return;
    _lastSeen[line.key] = now;

    final cur = _current;
    if (cur == null) {
      _show(line);
    } else if (line.priority > cur.priority) {
      // Interrompe: a frase que estava na tela já perdeu a vez (informação
      // velha não volta depois).
      _show(line);
    } else {
      _queue.add((line: line, at: now));
    }
  }

  void _show(NarratorLine line) {
    _current = line;
    _timer?.cancel();
    _timer = Timer(line.ttl, _next);
    _notify();
  }

  void _next() {
    final now = _now();
    // Frases que esperaram mais que o próprio ttl já não valem.
    _queue.removeWhere((e) => now.difference(e.at) > e.line.ttl);
    if (_queue.isEmpty) {
      _current = null;
      _timer = null;
      _notify();
      return;
    }
    var best = 0;
    for (var i = 1; i < _queue.length; i++) {
      if (_queue[i].line.priority > _queue[best].line.priority) best = i;
    }
    final e = _queue.removeAt(best);
    _show(e.line);
  }

  /// Limpa tudo (nova batalha / fim).
  void clear() {
    _timer?.cancel();
    _timer = null;
    _queue.clear();
    _lastSeen.clear();
    if (_current != null) {
      _current = null;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

final battleNarratorProvider = Provider<BattleNarratorController>((ref) {
  final c = BattleNarratorController();
  ref.onDispose(c.dispose);
  return c;
});
