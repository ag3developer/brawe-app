/// Manifesto de mídia da Batalha v3 (`GET /live/battle/assets`, §19.2).
///
/// Tudo é opcional: arquivo ou texto ausente cai no desenho/ARB padrão do app.
library;

/// Chaves de momento do contrato.
const List<String> kBattleMomentKeys = [
  'countdown',
  'start',
  'lead_change',
  'momentum',
  'final_window',
  'final_tick',
  'flash_start',
  'flash_done',
  'victory',
  'defeat',
  'draw',
  'ended',
  'mvp',
  'my_points',
];

String? _url(dynamic v) {
  if (v is! String) return null;
  final s = v.trim();
  return s.isEmpty ? null : s;
}

int _int(dynamic v, int fallback) =>
    v is num ? v.toInt() : (int.tryParse('$v') ?? fallback);

/// Arquivos de um momento (contagem, início, virada, vitória...).
class BattleMoment {
  const BattleMoment({
    this.lottieUrl,
    this.imageUrl,
    this.soundUrl,
    this.durationMs,
    this.loop = false,
  });

  final String? lottieUrl;
  final String? imageUrl;
  final String? soundUrl;
  final int? durationMs;
  final bool loop;

  bool get hasVisual => lottieUrl != null || imageUrl != null;

  factory BattleMoment.fromJson(Map<String, dynamic> j) => BattleMoment(
    lottieUrl: _url(j['lottie_url']),
    imageUrl: _url(j['image_url']),
    soundUrl: _url(j['sound_url']),
    durationMs: j['duration_ms'] is num ? (j['duration_ms'] as num).toInt() : null,
    loop: j['loop'] == true,
  );
}

/// Efeito desenhado sobre a barra de pontos.
class BattleBarEffect {
  const BattleBarEffect({
    required this.id,
    required this.trigger,
    required this.anchor,
    this.lottieUrl,
    this.imageUrl,
    this.soundUrl,
    this.durationMs = 0,
    this.loop = false,
    this.z = 0,
  });

  final String id;

  /// lead_change, momentum, multiplier, final_window, event ou `power:slug`.
  final String trigger;

  /// bar | side | seam | slot
  final String anchor;
  final String? lottieUrl;
  final String? imageUrl;
  final String? soundUrl;

  /// 0 = enquanto o gatilho durar.
  final int durationMs;
  final bool loop;
  final int z;

  bool get hasVisual => lottieUrl != null || imageUrl != null;

  factory BattleBarEffect.fromJson(Map<String, dynamic> j) => BattleBarEffect(
    id: (j['id'] ?? '').toString(),
    trigger: (j['trigger'] ?? '').toString(),
    anchor: (j['anchor'] ?? 'bar').toString(),
    lottieUrl: _url(j['lottie_url']),
    imageUrl: _url(j['image_url']),
    soundUrl: _url(j['sound_url']),
    durationMs: _int(j['duration_ms'], 0),
    loop: j['loop'] == true,
    z: _int(j['z'], 0),
  );
}

/// Frase do narrador vinda do servidor (`pt`/`en`/`es` + prioridade/ttl/estilo).
class BattleNarratorEntry {
  const BattleNarratorEntry({
    this.texts = const {},
    this.priority,
    this.ttlMs,
    this.style,
  });

  final Map<String, String> texts;
  final int? priority;
  final int? ttlMs;
  final String? style;

  String? textFor(String lang) {
    final t = texts[lang];
    return t == null || t.trim().isEmpty ? null : t;
  }

  factory BattleNarratorEntry.fromJson(Map<String, dynamic> j) {
    final texts = <String, String>{};
    for (final l in const ['pt', 'en', 'es']) {
      final v = j[l];
      if (v is String && v.trim().isNotEmpty) texts[l] = v;
    }
    final style = j['style'];
    return BattleNarratorEntry(
      texts: texts,
      priority: j['priority'] is num ? (j['priority'] as num).toInt() : null,
      ttlMs: j['ttl_ms'] is num ? (j['ttl_ms'] as num).toInt() : null,
      style: style is String ? style : null,
    );
  }
}

class BattleManifest {
  const BattleManifest({
    required this.version,
    this.themeId,
    this.moments = const {},
    this.barEffects = const [],
    this.narrator = const {},
  });

  final int version;
  final String? themeId;
  final Map<String, BattleMoment> moments;
  final List<BattleBarEffect> barEffects;
  final Map<String, BattleNarratorEntry> narrator;

  BattleMoment? moment(String key) => moments[key];

  /// Todas as URLs de arquivos referenciadas (para baixar na contagem).
  Set<String> get mediaUrls => {
    for (final m in moments.values) ...[
      ?m.lottieUrl,
      ?m.imageUrl,
      ?m.soundUrl,
    ],
    for (final e in barEffects) ...[?e.lottieUrl, ?e.imageUrl, ?e.soundUrl],
  };

  /// Aceita o corpo cru ou embrulhado em `{data: ...}`. `null` se inválido.
  static BattleManifest? tryParse(dynamic raw) {
    try {
      if (raw is! Map) return null;
      var map = Map<String, dynamic>.from(raw);
      if (map['data'] is Map && map['version'] == null) {
        map = Map<String, dynamic>.from(map['data'] as Map);
      }
      final version = map['version'];
      if (version is! num) return null;
      final moments = <String, BattleMoment>{};
      final rawMoments = map['moments'];
      if (rawMoments is Map) {
        rawMoments.forEach((k, v) {
          if (v is Map) {
            moments['$k'] = BattleMoment.fromJson(Map<String, dynamic>.from(v));
          }
        });
      }
      final effects = <BattleBarEffect>[];
      final rawEffects = map['bar_effects'];
      if (rawEffects is List) {
        for (final e in rawEffects.whereType<Map>()) {
          final fx = BattleBarEffect.fromJson(Map<String, dynamic>.from(e));
          if (fx.trigger.isNotEmpty) effects.add(fx);
        }
      }
      final narrator = <String, BattleNarratorEntry>{};
      final rawNarr = map['narrator'];
      if (rawNarr is Map) {
        rawNarr.forEach((k, v) {
          if (v is Map) {
            narrator['$k'] = BattleNarratorEntry.fromJson(
              Map<String, dynamic>.from(v),
            );
          }
        });
      }
      return BattleManifest(
        version: version.toInt(),
        themeId: map['theme_id'] is String ? map['theme_id'] as String : null,
        moments: moments,
        barEffects: effects,
        narrator: narrator,
      );
    } catch (_) {
      return null;
    }
  }
}
