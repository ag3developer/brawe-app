/// Texto em pt/en/es (`{pt,en,es}`) com fallback entre idiomas.
class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  bool get isEmpty => values.isEmpty;

  /// Texto no idioma [lang]; cai para pt, en e depois qualquer um.
  String resolve(String lang) {
    if (values.isEmpty) return '';
    return values[lang] ?? values['pt'] ?? values['en'] ?? values.values.first;
  }

  /// Aceita `{pt,en,es}` ou uma string simples (vira `pt`). `null` se vazio.
  static LocalizedText? tryParse(dynamic raw) {
    if (raw is String) {
      final t = raw.trim();
      return t.isEmpty ? null : LocalizedText({'pt': t});
    }
    if (raw is! Map) return null;
    final out = <String, String>{};
    raw.forEach((k, v) {
      final s = v?.toString().trim();
      if (s != null && s.isNotEmpty && s != 'null') out[k.toString()] = s;
    });
    return out.isEmpty ? null : LocalizedText(out);
  }
}

/// Evento com prazo da sala (`room.event` / `event_update.event`): multiplica
/// só os pontos do ranking. Servidor antigo não manda o campo.
class LiveEvent {
  const LiveEvent({
    required this.id,
    required this.slug,
    required this.name,
    required this.multiplier,
    required this.endsAt,
    this.bannerImageUrl,
    this.collectionSlug,
    this.description,
  });

  /// Coleção de presentes do evento (aba da sacola).
  final String? collectionSlug;

  /// "Como funciona" (`description_pt/en/es`); ausente no backend atual.
  final LocalizedText? description;
  final String id;
  final String slug;
  final LocalizedText name;
  final double multiplier;
  final DateTime endsAt;
  final String? bannerImageUrl;

  String localizedName(String lang) {
    final n = name.resolve(lang);
    return n.isEmpty ? slug : n;
  }

  /// Tempo que falta até o fim (nunca negativo).
  Duration remaining(DateTime now) {
    final d = endsAt.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  bool isEnded(DateTime now) => !endsAt.isAfter(now);

  /// `2×`, `1.5×`.
  String get multiplierLabel => formatMultiplier(multiplier);

  /// Parse tolerante: `null` se não for um evento utilizável.
  static LiveEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = raw['id']?.toString().trim() ?? '';
    final endsAt = DateTime.tryParse(raw['ends_at']?.toString() ?? '')?.toLocal();
    if (id.isEmpty || endsAt == null) return null;
    final mult = raw['multiplier'] is num
        ? (raw['multiplier'] as num).toDouble()
        : double.tryParse('${raw['multiplier']}');
    final banner = raw['banner_image_url']?.toString().trim();
    final slug = raw['slug']?.toString().trim() ?? '';
    final name = LocalizedText.tryParse(raw['name']) ?? LocalizedText({'pt': slug});
    return LiveEvent(
      id: id,
      slug: slug,
      name: name,
      multiplier: (mult == null || mult < 1) ? 1.0 : mult,
      endsAt: endsAt,
      bannerImageUrl: (banner == null || banner.isEmpty) ? null : banner,
      collectionSlug: _nz(raw['collection_slug']),
      description: LocalizedText.tryParse(raw['description']) ??
          LocalizedText.tryParse({
            'pt': raw['description_pt'],
            'en': raw['description_en'],
            'es': raw['description_es'],
          }),
    );
  }
}

String? _nz(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty || s == 'null') ? null : s;
}

/// Multiplicador de evento > 1 vindo do servidor; senão `null`.
double? activeMultiplier(dynamic raw) {
  final m = raw is num ? raw.toDouble() : double.tryParse('${raw ?? ''}');
  return (m != null && m > 1.0) ? m : null;
}

/// `2.0` -> `2×`, `1.5` -> `1.5×`.
String formatMultiplier(double m) {
  final isInt = m == m.roundToDouble();
  return '${isInt ? m.toInt() : m.toStringAsFixed(1)}×';
}

/// Contagem regressiva compacta: `05:12:30`; com 1 dia ou mais `2d 05h`.
String formatEventCountdown(Duration d) {
  if (d.isNegative) d = Duration.zero;
  String two(int n) => n.toString().padLeft(2, '0');
  if (d.inDays >= 1) return '${d.inDays}d ${two(d.inHours % 24)}h';
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

/// Prêmio de uma faixa do ranking (`prizes` nas respostas de ranking).
class PrizeRule {
  const PrizeRule({required this.rankFrom, required this.rankTo, required this.label});

  final int rankFrom;
  final int rankTo;
  final LocalizedText label;

  bool covers(int rank) => rank >= rankFrom && rank <= rankTo;

  static PrizeRule? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final label = LocalizedText.tryParse(raw['label']);
    if (label == null) return null;
    final from = (raw['rank_from'] as num?)?.toInt() ?? int.tryParse('${raw['rank_from']}');
    final to = (raw['rank_to'] as num?)?.toInt() ?? int.tryParse('${raw['rank_to']}') ?? from;
    if (from == null || to == null || from < 1 || to < from) return null;
    return PrizeRule(rankFrom: from, rankTo: to, label: label);
  }

  static List<PrizeRule> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map(PrizeRule.tryParse).whereType<PrizeRule>().toList();
  }

  /// Prêmio do 1º lugar, se houver regra que o cubra.
  static PrizeRule? firstPlace(List<PrizeRule> rules) {
    for (final r in rules) {
      if (r.covers(1)) return r;
    }
    return null;
  }
}
