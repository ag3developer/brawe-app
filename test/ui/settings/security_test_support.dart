import 'package:brawe_app/data/services/security_service.dart';
import 'package:brawe_app/domain/models/account_security.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now();

AuthSession fakeSession(
  String id, {
  bool current = false,
  String name = 'iPhone 15 Pro',
  String platform = 'ios',
  String client = 'app',
  String? city = 'São Paulo',
  Duration ago = const Duration(minutes: 3),
}) => AuthSession(
  id: id,
  current: current,
  client: client,
  deviceName: name,
  platform: platform,
  appVersion: '1.0.46',
  city: city,
  region: city == null ? null : 'SP',
  country: city == null ? null : 'BR',
  ipMasked: '187.12.*.*',
  lastSeenAt: _now.subtract(ago),
);

final fakeSessions = [
  fakeSession('s1', current: true, ago: Duration.zero),
  fakeSession('s2', name: 'Samsung SM-S918B', platform: 'android', ago: const Duration(hours: 5), city: 'Rio de Janeiro'),
  fakeSession('s3', name: 'Chrome no Mac', platform: 'web', client: 'web', ago: const Duration(days: 2), city: null),
  fakeSession('s4', name: 'Brawe Partners', platform: 'web', client: 'partners', ago: const Duration(days: 9)),
];

SecurityEvent fakeEvent(
  String id,
  String type, {
  bool success = true,
  Duration ago = const Duration(hours: 1),
  String? device = 'iPhone 15 Pro',
  String? city = 'São Paulo',
}) => SecurityEvent(
  id: id,
  type: SecurityEventType.parse(type),
  success: success,
  at: _now.subtract(ago),
  client: 'app',
  deviceName: device,
  platform: 'ios',
  city: city,
  region: city == null ? null : 'SP',
  country: city == null ? null : 'BR',
);

final fakeEvents = [
  fakeEvent('e1', 'login', ago: const Duration(minutes: 3)),
  fakeEvent('e2', 'login_failed', success: false, ago: const Duration(hours: 2), device: 'Samsung SM-S918B', city: 'Manaus'),
  fakeEvent('e3', 'step_up_required', ago: const Duration(hours: 2, minutes: 5), device: 'Samsung SM-S918B', city: 'Manaus'),
  fakeEvent('e4', 'login_blocked', success: false, ago: const Duration(hours: 3), device: null, city: null),
  fakeEvent('e5', 'password_changed', ago: const Duration(days: 1)),
  fakeEvent('e6', 'new_device_alert', ago: const Duration(days: 2)),
  fakeEvent('e7', 'sessions_revoked_all', ago: const Duration(days: 3)),
  fakeEvent('e8', 'qr_login', ago: const Duration(days: 12)),
];

class FakeSecurityService implements SecurityService {
  FakeSecurityService({
    List<AuthSession>? list,
    List<SecurityEvent>? eventList,
    this.sessionsError,
    this.eventsError,
    this.pageSize = 20,
  }) : list = list ?? [...fakeSessions],
       eventList = eventList ?? [...fakeEvents];

  List<AuthSession> list;
  List<SecurityEvent> eventList;
  Object? sessionsError;
  Object? eventsError;
  final int pageSize;
  final revoked = <String>[];
  int revokeOthersCalls = 0;
  int secureCalls = 0;
  final pagesRequested = <int>[];

  @override
  Future<SessionsData> sessions() async {
    if (sessionsError != null) throw sessionsError!;
    return SessionsData(
      sessions: List.of(list),
      geoAttribution: 'IP Geolocation by DB-IP',
    );
  }

  @override
  Future<RevokeResult> revokeSession(String id) async {
    revoked.add(id);
    final wasCurrent = list.any((x) => x.id == id && x.current);
    list.removeWhere((x) => x.id == id);
    return RevokeResult(revoked: true, current: wasCurrent);
  }

  @override
  Future<int> revokeOthers() async {
    revokeOthersCalls++;
    final n = list.where((x) => !x.current).length;
    list.removeWhere((x) => !x.current);
    return n;
  }

  @override
  Future<SecurityEventsPage> events({int page = 1, int pageSize = 20}) async {
    if (eventsError != null) throw eventsError!;
    pagesRequested.add(page);
    final from = (page - 1) * this.pageSize;
    final items = eventList.skip(from).take(this.pageSize).toList();
    return SecurityEventsPage(
      items: items,
      total: eventList.length,
      page: page,
      pageSize: this.pageSize,
      geoAttribution: 'IP Geolocation by DB-IP',
    );
  }

  @override
  Future<SecureAccountResult> secureAccount() async {
    secureCalls++;
    return const SecureAccountResult(accessToken: 'secured-token');
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

List<Override> securityOverrides(FakeSecurityService svc) => [
  securityServiceProvider.overrideWithValue(svc),
];

Widget securityApp({
  required Widget home,
  required List<Override> overrides,
  bool dark = false,
  double textScale = 1,
  GlobalKey? boundaryKey,
  Locale locale = const Locale('pt'),
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    locale: locale,
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    builder: (context, child) {
      final mq = MediaQuery.of(context);
      return MediaQuery(
        data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
        child: RepaintBoundary(key: boundaryKey, child: child),
      );
    },
    home: home,
  ),
);

void setScreen(WidgetTester tester, double w, double h) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(w, h);
  addTearDown(tester.view.reset);
}
