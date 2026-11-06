import 'package:flutter/foundation.dart';

DateTime? _date(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

String? _str(Object? v) {
  if (v is! String) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

/// Um aparelho/navegador com a conta aberta (`GET /auth/sessions`).
@immutable
class AuthSession {
  const AuthSession({
    required this.id,
    required this.current,
    this.client,
    this.deviceName,
    this.platform,
    this.appVersion,
    this.city,
    this.region,
    this.country,
    this.ipMasked,
    this.createdAt,
    this.lastSeenAt,
  });

  final String id;
  final bool current;

  /// app | partners | dashboard | web …
  final String? client;
  final String? deviceName;

  /// ios | android | web …
  final String? platform;
  final String? appVersion;
  final String? city;
  final String? region;
  final String? country;
  final String? ipMasked;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;

  factory AuthSession.fromJson(Map<String, dynamic> j) => AuthSession(
    id: '${j['id']}',
    current: j['current'] == true,
    client: _str(j['client']),
    deviceName: _str(j['device_name']),
    platform: _str(j['platform']),
    appVersion: _str(j['app_version']),
    city: _str(j['city']),
    region: _str(j['region']),
    country: _str(j['country']),
    ipMasked: _str(j['ip_masked']),
    createdAt: _date(j['created_at']),
    lastSeenAt: _date(j['last_seen_at']),
  );

  /// "São Paulo, SP, BR" (só o que veio).
  String? get place {
    final parts = [city, region, country].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
}

@immutable
class SessionsData {
  const SessionsData({required this.sessions, this.geoAttribution});
  final List<AuthSession> sessions;
  final String? geoAttribution;

  factory SessionsData.fromJson(Map<String, dynamic> j) => SessionsData(
    sessions: [
      for (final e in (j['sessions'] as List? ?? const []))
        if (e is Map) AuthSession.fromJson(Map<String, dynamic>.from(e)),
    ],
    geoAttribution: _str(j['geo_attribution']),
  );
}

/// Eventos conhecidos do histórico de acessos.
enum SecurityEventType {
  login,
  loginFailed,
  loginBlocked,
  logout,
  sessionRevoked,
  sessionsRevokedAll,
  passwordChanged,
  passwordResetRequested,
  passwordReset,
  qrLogin,
  loginCode,
  stepUpRequired,
  stepUpPassed,
  newDeviceAlert,
  unknown;

  static SecurityEventType parse(String? v) => switch (v) {
    'login' => login,
    'login_failed' => loginFailed,
    'login_blocked' => loginBlocked,
    'logout' => logout,
    'session_revoked' => sessionRevoked,
    'sessions_revoked_all' => sessionsRevokedAll,
    'password_changed' => passwordChanged,
    'password_reset_requested' => passwordResetRequested,
    'password_reset' => passwordReset,
    'qr_login' => qrLogin,
    'login_code' => loginCode,
    'step_up_required' => stepUpRequired,
    'step_up_passed' => stepUpPassed,
    'new_device_alert' => newDeviceAlert,
    _ => unknown,
  };
}

@immutable
class SecurityEvent {
  const SecurityEvent({
    required this.id,
    required this.type,
    required this.success,
    this.at,
    this.client,
    this.deviceName,
    this.platform,
    this.city,
    this.region,
    this.country,
    this.ipMasked,
  });

  final String id;
  final SecurityEventType type;
  final bool success;
  final DateTime? at;
  final String? client;
  final String? deviceName;
  final String? platform;
  final String? city;
  final String? region;
  final String? country;
  final String? ipMasked;

  factory SecurityEvent.fromJson(Map<String, dynamic> j) => SecurityEvent(
    id: '${j['id']}',
    type: SecurityEventType.parse(j['event'] as String?),
    success: j['success'] != false,
    at: _date(j['at']),
    client: _str(j['client']),
    deviceName: _str(j['device_name']),
    platform: _str(j['platform']),
    city: _str(j['city']),
    region: _str(j['region']),
    country: _str(j['country']),
    ipMasked: _str(j['ip_masked']),
  );

  String? get place {
    final parts = [city, region, country].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Falha: marcada como erro pelo servidor ou evento de bloqueio/falha.
  bool get isFailure =>
      !success ||
      type == SecurityEventType.loginFailed ||
      type == SecurityEventType.loginBlocked;
}

@immutable
class SecurityEventsPage {
  const SecurityEventsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    this.geoAttribution,
  });

  final List<SecurityEvent> items;
  final int total;
  final int page;
  final int pageSize;
  final String? geoAttribution;

  factory SecurityEventsPage.fromJson(Map<String, dynamic> j) =>
      SecurityEventsPage(
        items: [
          for (final e in (j['items'] as List? ?? const []))
            if (e is Map) SecurityEvent.fromJson(Map<String, dynamic>.from(e)),
        ],
        total: (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        pageSize: (j['page_size'] as num?)?.toInt() ?? 20,
        geoAttribution: _str(j['geo_attribution']),
      );
}

/// Filtros do histórico (aplicados nas páginas já carregadas).
enum SecurityEventFilter {
  all,
  logins,
  failures,
  changes;

  bool matches(SecurityEvent e) => switch (this) {
    all => true,
    logins =>
      e.success &&
          const {
            SecurityEventType.login,
            SecurityEventType.qrLogin,
            SecurityEventType.loginCode,
            SecurityEventType.stepUpPassed,
          }.contains(e.type),
    failures => e.isFailure,
    changes => const {
      SecurityEventType.passwordChanged,
      SecurityEventType.passwordReset,
      SecurityEventType.passwordResetRequested,
      SecurityEventType.sessionRevoked,
      SecurityEventType.sessionsRevokedAll,
      SecurityEventType.logout,
    }.contains(e.type),
  };
}
