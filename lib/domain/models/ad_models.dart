// Brawe Ads — modelos do app (entrega no feed, impulsionar e "Meus anúncios").
// Sem codegen: fromJson manual e tolerante (campos novos do servidor não quebram o app).

String _s(dynamic v, [String d = '']) => v == null ? d : v.toString();
double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<dynamic> _l(dynamic v) => v is List ? v : const [];

/// Espaços onde o anúncio pode aparecer no app.
class AdPlacement {
  static const forYou = 'foryou';
  static const following = 'following';
  static const stories = 'stories';
  static const lives = 'lives';
  static const explore = 'explore';
}

class AdAdvertiser {
  const AdAdvertiser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
  });
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;

  factory AdAdvertiser.fromJson(Map<String, dynamic> j) => AdAdvertiser(
    id: _s(j['id']),
    username: _s(j['username']),
    displayName: _s(j['display_name'], _s(j['username'])),
    avatarUrl: j['avatar_url'] as String?,
    isVerified: j['is_verified'] == true,
  );
}

/// Anúncio entregue para um espaço (GET /ads/serve). `token` volta em cada evento.
class FeedAd {
  const FeedAd({
    required this.adId,
    required this.token,
    required this.kind,
    required this.placement,
    required this.advertiser,
    required this.ctaType,
    required this.ctaLabel,
    this.ctaUrl,
    this.mediaType = 'image',
    this.mediaUrl,
    this.hlsUrl,
    this.posterUrl,
    this.headline,
    this.text,
    this.contentType,
    this.contentId,
    this.liveSlug,
    this.why = const [],
  });

  final String adId;
  final String token;

  /// boost · brand · creator
  final String kind;
  final String placement;
  final AdAdvertiser? advertiser;

  /// link · whatsapp · dm · profile · store
  final String ctaType;
  final String ctaLabel;
  final String? ctaUrl;

  /// image · video · live
  final String mediaType;
  final String? mediaUrl;
  final String? hlsUrl;
  final String? posterUrl;
  final String? headline;
  final String? text;

  /// impulsionado: post · media · story · live
  final String? contentType;
  final String? contentId;
  final String? liveSlug;
  final List<String> why;

  bool get isVideo => mediaType == 'video';
  bool get isLive => mediaType == 'live';
  bool get isBoost => kind == 'boost';

  /// Botão de contato (chat da Brawe ou WhatsApp) — também em impulsionamentos com objetivo "mensagens".
  bool get isContact => ctaType == 'dm' || ctaType == 'whatsapp';
  String? get playbackUrl =>
      (hlsUrl != null && hlsUrl!.isNotEmpty) ? hlsUrl : mediaUrl;

  factory FeedAd.fromJson(Map<String, dynamic> j) {
    final content = j['content'] is Map ? _m(j['content']) : null;
    final creative = _m(j['creative']);
    final cta = _m(j['cta']);
    final adv = j['advertiser'] is Map
        ? AdAdvertiser.fromJson(_m(j['advertiser']))
        : null;
    String mediaType;
    String? mediaUrl;
    String? poster;
    String? hls;
    if (content != null) {
      final mt = _s(content['media_type'], 'image');
      mediaType = content['type'] == 'live'
          ? 'live'
          : (mt == 'video' ? 'video' : 'image');
      mediaUrl = content['media_url'] as String?;
      hls = content['hls_url'] as String?;
      poster = content['thumbnail_url'] as String?;
    } else {
      mediaType = _s(creative['media_type'], 'image') == 'video'
          ? 'video'
          : 'image';
      mediaUrl = creative['media_url'] as String?;
      poster = creative['thumbnail_url'] as String?;
    }
    return FeedAd(
      adId: _s(j['ad_id']),
      token: _s(j['token']),
      kind: _s(j['kind'], 'brand'),
      placement: _s(j['placement']),
      advertiser: adv,
      ctaType: _s(cta['type'], 'profile'),
      ctaLabel: _s(cta['label']),
      ctaUrl: cta['url'] as String?,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      hlsUrl: hls,
      posterUrl: poster,
      headline: content == null ? creative['headline'] as String? : null,
      text: content != null
          ? (content['caption'] ?? content['title']) as String?
          : creative['text'] as String?,
      contentType: content?['type'] as String?,
      contentId: content?['id'] as String?,
      liveSlug: content?['slug'] as String?,
      why: _l(j['why']).map((e) => e.toString()).toList(),
    );
  }
}

class AdServeResult {
  const AdServeResult(this.items, this.every);
  final List<FeedAd> items;
  final int every;
}

/// Configuração pública (limites do impulsionar, espaços, interesses sugeridos).
class AdsPublicConfig {
  const AdsPublicConfig({
    required this.enabled,
    required this.boostMinDaily,
    required this.boostMaxDaily,
    required this.boostMinDays,
    required this.boostMaxDays,
    required this.boostCpm,
    required this.boostPlacements,
    required this.radiusMaxKm,
    required this.interestSuggestions,
    required this.categories,
  });

  final bool enabled;
  final double boostMinDaily;
  final double boostMaxDaily;
  final int boostMinDays;
  final int boostMaxDays;
  final double boostCpm;
  final List<String> boostPlacements;
  final int radiusMaxKm;
  final List<String> interestSuggestions;
  final List<MapEntry<String, String>> categories;

  factory AdsPublicConfig.fromJson(Map<String, dynamic> j) {
    final b = _m(j['boost']);
    return AdsPublicConfig(
      enabled: j['enabled'] != false,
      boostMinDaily: _d(b['min_daily_brl']),
      boostMaxDaily: _d(b['max_daily_brl']),
      boostMinDays: _i(b['min_days']),
      boostMaxDays: _i(b['max_days']),
      boostCpm: _d(b['cpm_brl']),
      boostPlacements: _l(
        _m(j['placements'])['boost'],
      ).map((e) => e.toString()).toList(),
      radiusMaxKm: _i(j['radius_max_km']) == 0 ? 300 : _i(j['radius_max_km']),
      interestSuggestions: _l(
        j['interest_suggestions'],
      ).map((e) => e.toString()).toList(),
      categories: _l(
        j['categories'],
      ).map((e) => MapEntry(_s(_m(e)['id']), _s(_m(e)['label']))).toList(),
    );
  }
}

class AdCity {
  const AdCity({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
  });
  final String id;
  final String label;
  final double lat;
  final double lng;

  factory AdCity.fromJson(Map<String, dynamic> j) => AdCity(
    id: _s(j['id']),
    label: _s(j['label']),
    lat: _d(j['lat']),
    lng: _d(j['lng']),
  );
}

class AdWhereAmI {
  const AdWhereAmI({this.lat, this.lng, this.city, this.exact = false});
  final double? lat;
  final double? lng;
  final AdCity? city;
  final bool exact;
}

class AdEstimate {
  const AdEstimate({required this.display, this.buysLabel});
  final String display;
  final String? buysLabel;
}

/// Campanha (lista e detalhe de "Meus anúncios").
class AdCampaign {
  const AdCampaign({
    required this.id,
    required this.kind,
    required this.name,
    required this.status,
    required this.dailyBudget,
    required this.totalBudget,
    required this.spent,
    required this.startAt,
    required this.endAt,
    required this.targeting,
    this.pausedBy,
    this.contentType,
    this.contentId,
    this.objective = 'views',
    this.ctaType = 'profile',
    this.mediaUrl,
  });

  final String id;
  final String kind;
  final String name;

  /// views · followers · profile_visits · link_clicks · contacts
  final String objective;

  /// profile · dm · whatsapp · link · store
  final String ctaType;

  /// imagem do anúncio da marca (para a lista)
  final String? mediaUrl;

  /// draft · pending_review · active · paused · completed · canceled · rejected
  final String status;
  final double dailyBudget;
  final double totalBudget;
  final double spent;
  final DateTime? startAt;
  final DateTime? endAt;
  final Map<String, dynamic> targeting;
  final String? pausedBy;
  final String? contentType;
  final String? contentId;

  bool get isOpen =>
      status == 'pending_review' || status == 'active' || status == 'paused';
  double get usedPct =>
      totalBudget > 0 ? (spent / totalBudget).clamp(0, 1).toDouble() : 0;

  factory AdCampaign.fromJson(Map<String, dynamic> j) {
    final c = j['content'] is Map ? _m(j['content']) : null;
    return AdCampaign(
      id: _s(j['id']),
      kind: _s(j['kind']),
      name: _s(j['name']),
      status: _s(j['status']),
      dailyBudget: _d(j['daily_budget_brl']),
      totalBudget: _d(j['total_budget_brl']),
      spent: _d(j['spent_brl']),
      startAt: DateTime.tryParse(_s(j['start_at'])),
      endAt: DateTime.tryParse(_s(j['end_at'])),
      targeting: _m(j['targeting']),
      pausedBy: j['paused_by'] as String?,
      contentType: c?['type'] as String?,
      contentId: c?['id'] as String?,
      objective: _s(j['objective']).isEmpty ? 'views' : _s(j['objective']),
      ctaType: _s(_m(j['cta'])['type']).isEmpty
          ? 'profile'
          : _s(_m(j['cta'])['type']),
      mediaUrl: _m(j['creative'])['media_url'] as String?,
    );
  }
}

class AdReportSummary {
  const AdReportSummary({
    required this.impressions,
    required this.reach,
    required this.clicks,
    required this.views,
    required this.newFollowers,
    required this.profileVisits,
    required this.spend,
    required this.cpm,
    required this.byDay,
  });

  final int impressions;
  final int reach;
  final int clicks;
  final int views;
  final int newFollowers;
  final int profileVisits;
  final double spend;
  final double cpm;
  final List<MapEntry<DateTime, int>> byDay;

  factory AdReportSummary.fromJson(Map<String, dynamic> j) {
    final m = _m(j['metrics']);
    final e = _m(m['engagement']);
    final v = _m(m['video']);
    return AdReportSummary(
      impressions: _i(m['impressions']),
      reach: _i(m['reach']),
      clicks: _i(m['clicks']),
      views: _i(v['view_25']),
      newFollowers: _i(e['new_followers']),
      profileVisits: _i(e['profile_visits']),
      spend: _d(m['spend_brl']),
      cpm: _d(m['cpm_brl']),
      byDay: _l(j['by_day'])
          .map(
            (d) => MapEntry(
              DateTime.tryParse(_s(_m(d)['day'])) ?? DateTime.now(),
              _i(_m(d)['impressions']),
            ),
          )
          .toList(),
    );
  }
}
