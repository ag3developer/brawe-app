// Brawe Partners — modelos do criador ("Minha agência").
// Parsing tolerante: todo campo opcional pode faltar sem quebrar a tela.

DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;
int? _int(Object? v) => v is num ? v.toInt() : (v is String ? int.tryParse(v) : null);
double? _dbl(Object? v) => v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);
String? _str(Object? v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

List<String> _strs(Object? v) =>
    v is List ? v.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList() : const [];
Map<String, dynamic> _map(Object? v) => v is Map ? Map<String, dynamic>.from(v) : const {};

/// Perfil público da agência (nunca razão social/documento nem o nível: o criador não vê o nível da agência).
/// Tudo que a agência escondeu chega nulo/vazio e a UI não mostra.
class AgencyCard {
  const AgencyCard({
    required this.id,
    required this.name,
    this.logoUrl,
    this.website,
    this.country,
    this.creatorsCount,
    this.partnerSince,
    this.socials = const {},
    this.countries = const [],
    this.niches = const [],
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? website;
  final String? country;
  final int? creatorsCount;
  final DateTime? partnerSince;
  final Map<String, String> socials;
  final List<String> countries;
  final List<String> niches;

  factory AgencyCard.fromJson(Map<String, dynamic> j) => AgencyCard(
        id: j['id']?.toString() ?? '',
        name: _str(j['name']) ?? '',
        logoUrl: _str(j['logo_url']),
        website: _str(j['website']),
        country: _str(j['country']),
        creatorsCount: _int(j['creators_count']),
        partnerSince: _dt(j['partner_since']),
        socials: {
          for (final e in _map(j['socials']).entries)
            if (_str(e.value) != null) e.key: _str(e.value)!,
        },
        countries: _strs(j['countries']),
        niches: _strs(j['niches']),
      );
}

/// Quem enviou o convite (dono, gerente/recrutador ou equipe).
class AgencyInviter {
  const AgencyInviter({
    required this.userId,
    this.name,
    this.username,
    this.avatarUrl,
    this.role,
    this.isOwner = false,
  });

  final String userId;
  final String? name;
  final String? username;
  final String? avatarUrl;

  /// owner | manager | analyst | null
  final String? role;
  final bool isOwner;

  String get displayName => name ?? (username != null ? '@$username' : '');

  static AgencyInviter? tryParse(Object? v) {
    if (v is! Map) return null;
    final j = Map<String, dynamic>.from(v);
    return AgencyInviter(
      userId: j['user_id']?.toString() ?? '',
      name: _str(j['name']),
      username: _str(j['username']),
      avatarUrl: _str(j['avatar_url']),
      role: _str(j['role']),
      isOwner: j['is_owner'] == true || j['role'] == 'owner',
    );
  }
}

/// Termos: padrão Brawe + adendo da agência, por idioma.
class AgencyTerms {
  const AgencyTerms({this.version, this.standard = const {}, this.addendum = const {}});

  final String? version;
  final Map<String, String> standard;
  final Map<String, String> addendum;

  factory AgencyTerms.fromJson(Object? v) {
    final j = _map(v);
    Map<String, String> by(Object? o) => {
          for (final e in _map(o).entries)
            if (_str(e.value) != null) e.key: e.value.toString(),
        };
    return AgencyTerms(
      version: _str(j['version']),
      standard: by(j['standard']),
      addendum: by(j['addendum']),
    );
  }

  static String? _pick(Map<String, String> m, String lang) =>
      m[lang] ?? m['pt'] ?? m['en'] ?? (m.isEmpty ? null : m.values.first);

  String? standardFor(String lang) => _pick(standard, lang);
  String? addendumFor(String lang) => _pick(addendum, lang);
  bool get isEmpty => standard.isEmpty && addendum.isEmpty;
}

class AgencyInvite {
  const AgencyInvite({
    required this.inviteId,
    required this.status,
    required this.agency,
    this.contractMonths,
    this.message,
    this.invitedAt,
    this.terms = const AgencyTerms(),
    this.invitedBy,
  });

  final String inviteId;
  final String status;
  final AgencyCard agency;
  final int? contractMonths;
  final String? message;
  final DateTime? invitedAt;
  final AgencyTerms terms;
  final AgencyInviter? invitedBy;

  bool get isPending => status == 'invited';

  factory AgencyInvite.fromJson(Map<String, dynamic> j) => AgencyInvite(
        inviteId: j['invite_id']?.toString() ?? '',
        status: j['status']?.toString() ?? 'invited',
        agency: AgencyCard.fromJson(_map(j['agency'])),
        contractMonths: _int(j['contract_months']),
        message: _str(j['message']),
        invitedAt: _dt(j['invited_at']),
        terms: AgencyTerms.fromJson(j['terms']),
        invitedBy: AgencyInviter.tryParse(j['invited_by']),
      );
}

class AgencyContract {
  const AgencyContract({this.months, this.startedAt, this.endsAt, this.progress, this.daysLeft});

  final int? months;
  final DateTime? startedAt;
  final DateTime? endsAt;
  final double? progress; // 0..1
  final int? daysLeft;

  factory AgencyContract.fromJson(Object? v) {
    final j = _map(v);
    return AgencyContract(
      months: _int(j['months']),
      startedAt: _dt(j['started_at']),
      endsAt: _dt(j['ends_at']),
      progress: _dbl(j['progress'])?.clamp(0.0, 1.0),
      daysLeft: _int(j['days_left']),
    );
  }
}

/// Pedido de saída antes do fim do contrato (BRAWE_PARTNERS §4.1).
class AgencyLeaveRequest {
  const AgencyLeaveRequest({
    required this.id,
    required this.kind,
    required this.status,
    this.reason,
    this.answerNote,
    this.createdAt,
    this.answeredAt,
    this.answerDueAt,
  });

  final String id;

  /// early (à agência) | brawe_review (análise da Brawe)
  final String kind;

  /// pending | escalated | approved | declined | cancelled
  final String status;
  final String? reason;
  final String? answerNote;
  final DateTime? createdAt;
  final DateTime? answeredAt;
  final DateTime? answerDueAt;

  bool get isOpen => status == 'pending' || status == 'escalated';
  bool get isBraweReview => kind == 'brawe_review';

  /// Com a Brawe: análise direta ou agência que não respondeu no prazo.
  bool get isWithBrawe => status == 'escalated';

  static AgencyLeaveRequest? tryParse(Object? v) {
    if (v is! Map) return null;
    final j = Map<String, dynamic>.from(v);
    final id = j['id']?.toString();
    if (id == null || id.isEmpty) return null;
    return AgencyLeaveRequest(
      id: id,
      kind: _str(j['kind']) ?? 'early',
      status: _str(j['status']) ?? 'pending',
      reason: _str(j['reason']),
      answerNote: _str(j['answer_note']),
      createdAt: _dt(j['created_at']),
      answeredAt: _dt(j['answered_at']),
      answerDueAt: _dt(j['answer_due_at']),
    );
  }
}

/// Como o criador pode sair agora: free (fim do contrato) | request (pedir à agência) | pending (pedido em aberto).
class AgencyLeave {
  const AgencyLeave({
    this.mode = 'request',
    this.canLeaveFree = false,
    this.contractEndsAt,
    this.request,
    this.lastDeclined,
    this.retryAt,
    this.reviewRetryAt,
    this.answerDays,
    this.retryDays,
  });

  final String mode;
  final bool canLeaveFree;
  final DateTime? contractEndsAt;
  final AgencyLeaveRequest? request;
  final AgencyLeaveRequest? lastDeclined;

  /// Quando poderá pedir de novo à agência (null = já pode).
  final DateTime? retryAt;
  final DateTime? reviewRetryAt;
  final int? answerDays;
  final int? retryDays;

  bool get isFree => mode == 'free' || canLeaveFree;
  bool get isPending => !isFree && request != null && request!.isOpen;

  bool retryBlocked([DateTime? now]) => retryAt != null && retryAt!.isAfter(now ?? DateTime.now());
  bool reviewBlocked([DateTime? now]) => reviewRetryAt != null && reviewRetryAt!.isAfter(now ?? DateTime.now());

  /// `leave` ausente = backend antigo: só `can_leave`/`can_leave_at` (fim do contrato).
  factory AgencyLeave.fromJson(Object? v, {bool fallbackFree = false, DateTime? fallbackEndsAt}) {
    if (v is! Map) {
      return AgencyLeave(
        mode: fallbackFree ? 'free' : 'request',
        canLeaveFree: fallbackFree,
        contractEndsAt: fallbackEndsAt,
      );
    }
    final j = Map<String, dynamic>.from(v);
    final free = j['can_leave_free'] == true || j['mode'] == 'free';
    final req = AgencyLeaveRequest.tryParse(j['request']);
    final mode = free ? 'free' : (req != null && req.isOpen ? 'pending' : 'request');
    return AgencyLeave(
      mode: mode,
      canLeaveFree: free,
      contractEndsAt: _dt(j['contract_ends_at']) ?? fallbackEndsAt,
      request: req,
      lastDeclined: AgencyLeaveRequest.tryParse(j['last_declined']),
      retryAt: _dt(j['retry_at']),
      reviewRetryAt: _dt(j['review_retry_at']),
      answerDays: _int(j['answer_days']),
      retryDays: _int(j['retry_days']),
    );
  }
}

class AgencyLink {
  const AgencyLink({
    required this.linkId,
    required this.status,
    required this.agency,
    this.contract = const AgencyContract(),
    this.acceptedAt,
    this.termsVersion,
    this.terms = const AgencyTerms(),
    this.canLeave = false,
    this.canLeaveAt,
    this.leave = const AgencyLeave(),
    this.invitedBy,
  });

  final String linkId;
  final String status; // active | trial
  final AgencyCard agency;
  final AgencyContract contract;
  final DateTime? acceptedAt;
  final String? termsVersion;
  final AgencyTerms terms;
  final bool canLeave;
  final DateTime? canLeaveAt;
  final AgencyLeave leave;
  final AgencyInviter? invitedBy;

  bool get isTrial => status == 'trial';

  factory AgencyLink.fromJson(Map<String, dynamic> j) {
    final base = AgencyContract.fromJson(j['contract']);
    // Compatível com a API antiga (sem `contract`).
    final contract = j['contract'] is Map
        ? base
        : AgencyContract(
            months: _int(j['contract_months']),
            startedAt: _dt(j['started_at']),
            endsAt: _dt(j['ends_at']),
          );
    return AgencyLink(
      linkId: j['link_id']?.toString() ?? '',
      status: j['status']?.toString() ?? 'active',
      agency: AgencyCard.fromJson(_map(j['agency'])),
      contract: contract,
      acceptedAt: _dt(j['accepted_at']),
      termsVersion: _str(j['terms_version']),
      terms: AgencyTerms.fromJson(j['terms']),
      canLeave: j['can_leave'] == true,
      canLeaveAt: _dt(j['can_leave_at']),
      leave: AgencyLeave.fromJson(j['leave'], fallbackFree: j['can_leave'] == true, fallbackEndsAt: contract.endsAt ?? _dt(j['can_leave_at'])),
      invitedBy: AgencyInviter.tryParse(j['invited_by']),
    );
  }
}

class AgencyEvent {
  const AgencyEvent({
    required this.id,
    this.names = const {},
    this.startsAt,
    this.endsAt,
    this.status,
    this.multiplier,
    this.bannerUrl,
  });

  final String id;
  final Map<String, String> names;
  final DateTime? startsAt;
  final DateTime? endsAt;

  /// scheduled | live | ended
  final String? status;
  final double? multiplier;
  final String? bannerUrl;

  String nameFor(String lang) => names[lang] ?? names['pt'] ?? names['en'] ?? names['es'] ?? '';

  factory AgencyEvent.fromJson(Map<String, dynamic> j) {
    return AgencyEvent(
      id: j['id']?.toString() ?? '',
      names: {
        for (final l in const ['pt', 'en', 'es'])
          if (_str(j['name_$l']) != null) l: _str(j['name_$l'])!,
      },
      startsAt: _dt(j['starts_at']),
      endsAt: _dt(j['ends_at']),
      status: _str(j['status']),
      multiplier: _dbl(j['multiplier']),
      bannerUrl: _str(j['banner_image_url']),
    );
  }
}

class GuidelineMissing {
  const GuidelineMissing({required this.code, this.have, this.need, this.missing, this.count});
  final String code; // hours | days | incidents
  final double? have;
  final double? need;
  final double? missing;
  final int? count;

  factory GuidelineMissing.fromJson(Map<String, dynamic> j) => GuidelineMissing(
        code: j['code']?.toString() ?? '',
        have: _dbl(j['have']),
        need: _dbl(j['need']),
        missing: _dbl(j['missing']),
        count: _int(j['count']),
      );
}

class AgencyIncident {
  const AgencyIncident({required this.kind, this.points = 0, this.startsAt, this.endsAt, this.note});
  final String kind;
  final int points;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? note;

  factory AgencyIncident.fromJson(Map<String, dynamic> j) => AgencyIncident(
        kind: j['kind']?.toString() ?? '',
        points: _int(j['points']) ?? 0,
        startsAt: _dt(j['starts_at']),
        endsAt: _dt(j['ends_at']),
        note: _str(j['note']),
      );
}

class AgencyGuidelines {
  const AgencyGuidelines({
    this.minHours = 0,
    this.minDays = 0,
    this.met = true,
    this.missing = const [],
    this.incidents = const [],
  });

  final double minHours;
  final int minDays;
  final bool met;
  final List<GuidelineMissing> missing;
  final List<AgencyIncident> incidents;

  factory AgencyGuidelines.fromJson(Object? v) {
    final j = _map(v);
    List<T> list<T>(Object? o, T Function(Map<String, dynamic>) f) =>
        o is List ? [for (final e in o) if (e is Map) f(Map<String, dynamic>.from(e))] : <T>[];
    return AgencyGuidelines(
      minHours: _dbl(j['min_hours']) ?? 0,
      minDays: _int(j['min_days']) ?? 0,
      met: j['met'] != false,
      missing: list(j['missing'], GuidelineMissing.fromJson),
      incidents: list(j['incidents'], AgencyIncident.fromJson),
    );
  }
}

/// Desempenho do mês corrente + posição entre os agenciados.
class AgencyMe {
  const AgencyMe({
    this.hours = 0,
    this.days = 0,
    this.diamonds = 0,
    this.followers = 0,
    this.rank,
    this.of,
    this.guidelines = const AgencyGuidelines(),
  });

  final double hours;
  final int days;
  final int diamonds;
  final int followers;
  final int? rank;
  final int? of;
  final AgencyGuidelines guidelines;

  factory AgencyMe.fromJson(Map<String, dynamic> j) => AgencyMe(
        hours: _dbl(j['hours']) ?? 0,
        days: _int(j['days']) ?? 0,
        diamonds: _int(j['diamonds']) ?? 0,
        followers: _int(j['followers']) ?? 0,
        rank: _int(j['rank']),
        of: _int(j['of']),
        guidelines: AgencyGuidelines.fromJson(j['guidelines']),
      );
}

/// Desempenho de um mês (GET /creator/agency/performance e /performance/history).
class AgencyPerformance {
  const AgencyPerformance({
    required this.month,
    this.isCurrent = false,
    this.hours = 0,
    this.days = 0,
    this.diamonds = 0,
    this.followers = 0,
    this.rank,
    this.of,
    this.guidelines = const AgencyGuidelines(),
  });

  /// YYYY-MM
  final String month;
  final bool isCurrent;
  final double hours;
  final int days;
  final int diamonds;
  final int followers;
  final int? rank;
  final int? of;
  final AgencyGuidelines guidelines;

  /// Primeiro dia do mês (local).
  DateTime get monthStart {
    final p = month.split('-');
    final y = p.isNotEmpty ? int.tryParse(p[0]) : null;
    final m = p.length > 1 ? int.tryParse(p[1]) : null;
    return DateTime(y ?? 1970, m ?? 1);
  }

  /// Meta do mês combinada (média do progresso de horas e dias), 0..1.
  /// Sem meta configurada (mínimos zerados) devolve 1.
  double get goalProgress {
    final parts = <double>[
      if (guidelines.minHours > 0) (hours / guidelines.minHours).clamp(0.0, 1.0),
      if (guidelines.minDays > 0) (days / guidelines.minDays).clamp(0.0, 1.0),
    ];
    if (parts.isEmpty) return 1;
    return parts.reduce((a, b) => a + b) / parts.length;
  }

  factory AgencyPerformance.fromJson(Map<String, dynamic> j) => AgencyPerformance(
        month: _str(j['month']) ?? '',
        isCurrent: j['is_current'] == true,
        hours: _dbl(j['hours']) ?? 0,
        days: _int(j['days']) ?? 0,
        diamonds: _int(j['diamonds']) ?? 0,
        followers: _int(j['followers']) ?? 0,
        rank: _int(j['rank']),
        of: _int(j['of']),
        guidelines: AgencyGuidelines.fromJson(j['guidelines']),
      );

  /// `{months: [...]}` (mais recente primeiro).
  static List<AgencyPerformance> listFromJson(Object? v) {
    final raw = v is Map ? v['months'] : null;
    if (raw is! List) return const [];
    return [for (final e in raw) if (e is Map) AgencyPerformance.fromJson(Map<String, dynamic>.from(e))];
  }
}

class AgencyState {
  const AgencyState({
    this.invites = const [],
    this.link,
    this.events = const [],
    this.me,
    this.openToAgencies = false,
    this.termsCurrentVersion,
  });

  final List<AgencyInvite> invites;
  final AgencyLink? link;
  final List<AgencyEvent> events;
  final AgencyMe? me;
  final bool openToAgencies;
  final String? termsCurrentVersion;

  List<AgencyInvite> get pendingInvites => invites.where((i) => i.isPending).toList();
  int get pendingCount => link == null ? pendingInvites.length : 0;

  factory AgencyState.fromJson(Map<String, dynamic> j) => AgencyState(
        invites: j['invites'] is List
            ? [for (final e in j['invites'] as List) if (e is Map) AgencyInvite.fromJson(Map<String, dynamic>.from(e))]
            : const [],
        link: j['link'] is Map ? AgencyLink.fromJson(Map<String, dynamic>.from(j['link'] as Map)) : null,
        events: j['events'] is List
            ? [for (final e in j['events'] as List) if (e is Map) AgencyEvent.fromJson(Map<String, dynamic>.from(e))]
            : const [],
        me: j['me'] is Map ? AgencyMe.fromJson(Map<String, dynamic>.from(j['me'] as Map)) : null,
        openToAgencies: j['open_to_agencies'] == true,
        termsCurrentVersion: _str(j['terms_current_version']),
      );
}

/// Erro de regra do Partners (409/422/404) com `code` estável.
class AgencyException implements Exception {
  const AgencyException(this.code, {this.canLeaveAt, this.retryAt, this.currentVersion, this.statusCode});
  final String code;
  final DateTime? canLeaveAt;

  /// `leave_request_cooldown`: quando poderá pedir de novo.
  final DateTime? retryAt;
  final String? currentVersion;
  final int? statusCode;

  @override
  String toString() => 'AgencyException($code)';
}
