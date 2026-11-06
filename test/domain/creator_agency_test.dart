import 'package:brawe_app/data/repositories/creator_agency_repository.dart';
import 'package:brawe_app/domain/models/creator_agency.dart';
import 'package:brawe_app/data/services/creator_agency_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a full state', () {
    final s = AgencyState.fromJson({
      'invites': [
        {
          'invite_id': 'i1',
          'status': 'invited',
          'agency': {
            'id': 'a1',
            'name': 'Studio X',
            'logo_url': 'https://x/logo.png',
            'country': 'BR',
            'level': 2,
            'level_name': 'Prata',
            'creators_count': 18,
            'partner_since': '2026-01-10T00:00:00Z',
            'website': 'https://x.com',
            'socials': {'instagram': '@x', 'tiktok': ''},
            'niches': ['games'],
          },
          'contract_months': 12,
          'message': 'Vem!',
          'invited_at': '2026-11-01T10:00:00Z',
          'terms': {
            'version': 'v2',
            'standard': {'pt': '# Termos', 'en': null, 'es': null},
            'addendum': {'pt': null, 'en': null, 'es': null},
          },
          'invited_by': {'user_id': 'u1', 'name': 'Ana', 'username': 'ana', 'avatar_url': null, 'role': 'manager', 'is_owner': false},
        },
      ],
      'link': {
        'link_id': 'l1',
        'status': 'active',
        'agency': {'id': 'a1', 'name': 'Studio X'},
        'contract': {'months': 12, 'started_at': '2026-01-01T00:00:00Z', 'ends_at': '2027-01-01T00:00:00Z', 'progress': 0.8, 'days_left': 55},
        'accepted_at': '2026-01-01T00:00:00Z',
        'terms_version': 'v1',
        'terms': {'version': 'v1', 'standard': {'pt': 'a'}, 'addendum': {}},
        'can_leave': false,
        'can_leave_at': '2027-01-01T00:00:00Z',
        'invited_by': {'user_id': 'u0', 'name': 'Dono', 'role': 'owner', 'is_owner': true},
      },
      'events': [
        {'id': 'e1', 'name_pt': 'Festival', 'name_en': 'Fest', 'starts_at': '2026-11-10T00:00:00Z', 'ends_at': '2026-11-12T00:00:00Z', 'status': 'scheduled', 'multiplier': 2}
      ],
      'me': {
        'hours': 12.5,
        'days': 4,
        'diamonds': 1000,
        'followers': 30,
        'rank': 3,
        'of': 18,
        'guidelines': {
          'min_hours': 20,
          'min_days': 8,
          'met': false,
          'missing': [
            {'code': 'hours', 'have': 12.5, 'need': 20, 'missing': 7.5},
            {'code': 'days', 'have': 4, 'need': 8, 'missing': 4},
          ],
          'incidents': [
            {'kind': 'warning', 'points': 1, 'starts_at': '2026-10-20T00:00:00Z', 'ends_at': null, 'note': 'x'}
          ],
        },
      },
      'open_to_agencies': true,
      'terms_current_version': 'v2',
    });
    expect(s.pendingInvites, hasLength(1));
    final i = s.invites.first;
    expect(i.agency.name, 'Studio X');
    expect(i.agency.socials, {'instagram': '@x'});
    expect(i.agency.creatorsCount, 18);
    expect(i.invitedBy!.role, 'manager');
    expect(i.terms.standardFor('en'), '# Termos'); // cai para pt
    expect(s.link!.contract.progress, 0.8);
    expect(s.link!.contract.daysLeft, 55);
    expect(s.link!.invitedBy!.isOwner, isTrue);
    expect(s.pendingCount, 0); // já em agência
    expect(s.events.single.nameFor('en'), 'Fest');
    expect(s.events.single.nameFor('es'), 'Festival');
    expect(s.me!.rank, 3);
    expect(s.me!.guidelines.missing.first.missing, 7.5);
    expect(s.me!.guidelines.incidents.single.kind, 'warning');
    expect(s.openToAgencies, isTrue);
  });

  test('tolerates missing optional fields', () {
    final s = AgencyState.fromJson({});
    expect(s.invites, isEmpty);
    expect(s.link, isNull);
    expect(s.me, isNull);
    expect(s.openToAgencies, isFalse);

    final i = AgencyInvite.fromJson({'invite_id': 'x', 'agency': {'id': 'a'}});
    expect(i.agency.name, '');
    expect(i.invitedBy, isNull);
    expect(i.terms.isEmpty, isTrue);
    expect(i.contractMonths, isNull);
    expect(i.isPending, isTrue);
  });

  test('old link payload without contract key still works', () {
    final l = AgencyLink.fromJson({
      'link_id': 'l',
      'agency': {'id': 'a', 'name': 'A'},
      'contract_months': 6,
      'started_at': '2026-01-01T00:00:00Z',
      'ends_at': '2026-07-01T00:00:00Z',
    });
    expect(l.contract.months, 6);
    expect(l.contract.endsAt, isNotNull);
    expect(l.canLeave, isFalse);
  });

  test('maps backend error codes', () {
    DioException err(int status, Object? data) => DioException(
        requestOptions: RequestOptions(path: '/x'), response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: status, data: data));
    final a = mapAgencyError(err(409, {'detail': {'code': 'cannot_leave_yet', 'can_leave_at': '2027-01-01T00:00:00Z'}}));
    expect(a.code, 'cannot_leave_yet');
    expect(a.canLeaveAt, isNotNull);
    final b = mapAgencyError(err(409, {'detail': {'code': 'terms_version_mismatch', 'current_version': 'v9'}}));
    expect(b.currentVersion, 'v9');
    expect(mapAgencyError(err(404, {'detail': 'x'})).code, 'not_found');
    expect(mapAgencyError(err(500, null)).code, 'server');
    expect(mapAgencyError(DioException(requestOptions: RequestOptions(path: '/'))).code, 'network');
  });

  group('saída (leave)', () {
    Map<String, dynamic> link(Map<String, dynamic> extra) => {
          'link_id': 'l1',
          'status': 'active',
          'agency': {'id': 'a1', 'name': 'Ag'},
          'ends_at': '2027-01-01T00:00:00Z',
          'can_leave': false,
          'can_leave_at': '2027-01-01T00:00:00Z',
          ...extra,
        };

    test('payload antigo sem `leave` cai no fim do contrato', () {
      final l = AgencyLink.fromJson(link({}));
      expect(l.leave.mode, 'request');
      expect(l.leave.isFree, isFalse);
      expect(l.leave.contractEndsAt, isNotNull);
      expect(l.leave.request, isNull);
      final free = AgencyLink.fromJson(link({'can_leave': true}));
      expect(free.leave.isFree, isTrue);
      expect(free.leave.mode, 'free');
    });

    test('pedido pendente, recusado e escalado', () {
      final l = AgencyLink.fromJson(link({
        'leave': {
          'mode': 'pending',
          'can_leave_free': false,
          'contract_ends_at': '2027-01-01T00:00:00Z',
          'request': {'id': 'r1', 'kind': 'early', 'status': 'pending', 'created_at': '2026-11-01T10:00:00Z', 'answer_due_at': '2026-11-16T10:00:00Z', 'reason': 'x'},
          'retry_at': null,
          'answer_days': 15,
        },
      }));
      expect(l.leave.isPending, isTrue);
      expect(l.leave.request!.isOpen, isTrue);
      expect(l.leave.request!.answerDueAt, isNotNull);
      expect(l.leave.answerDays, 15);

      final d = AgencyLink.fromJson(link({
        'leave': {
          'mode': 'request',
          'can_leave_free': false,
          'request': null,
          'last_declined': {'id': 'r0', 'kind': 'early', 'status': 'declined', 'answer_note': 'Fica mais um pouco'},
          'retry_at': '2999-01-01T00:00:00Z',
        },
      }));
      expect(d.leave.isPending, isFalse);
      expect(d.leave.lastDeclined!.answerNote, 'Fica mais um pouco');
      expect(d.leave.retryBlocked(), isTrue);
      expect(d.leave.reviewBlocked(), isFalse);

      final e = AgencyLink.fromJson(link({
        'leave': {'mode': 'pending', 'request': {'id': 'r2', 'kind': 'brawe_review', 'status': 'escalated'}},
      }));
      expect(e.leave.request!.isWithBrawe, isTrue);
      expect(e.leave.request!.isBraweReview, isTrue);
    });

    test('free vence mesmo com pedido antigo', () {
      final l = AgencyLink.fromJson(link({
        'leave': {'mode': 'free', 'can_leave_free': true, 'request': null},
      }));
      expect(l.leave.isFree, isTrue);
      expect(l.leave.isPending, isFalse);
    });

    test('erros novos mapeiam o código e retry_at', () {
      final a = mapAgencyError(DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: 409, data: {
          'detail': {'code': 'leave_request_cooldown', 'retry_at': '2026-12-01T00:00:00Z'},
        }),
      ));
      expect(a.code, 'leave_request_cooldown');
      expect(a.retryAt, isNotNull);
      final b = mapAgencyError(DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: 409, data: {
          'detail': {'code': 'leave_requires_agreement'},
        }),
      ));
      expect(b.code, 'leave_requires_agreement');
    });
  });

  group('perfil público', () {
    test('nunca expõe nível; campos escondidos chegam nulos/vazios', () {
      final c = AgencyCard.fromJson({
        'id': 'a1',
        'name': 'Ag',
        'level': 4,
        'level_name': 'Elite',
        'creators_count': null,
        'partner_since': null,
        'website': null,
        'socials': {},
        'niches': [],
        'countries': [],
        'country': null,
      });
      expect(c.name, 'Ag');
      expect(c.creatorsCount, isNull);
      expect(c.partnerSince, isNull);
      expect(c.website, isNull);
      expect(c.socials, isEmpty);
      expect(c.niches, isEmpty);
      expect(c.country, isNull);
    });
  });

  group('desempenho por mês', () {
    final json = {
      'month': '2026-10',
      'is_current': false,
      'hours': 12.5,
      'days': 4,
      'diamonds': 1200,
      'followers': 30,
      'rank': 3,
      'of': 18,
      'guidelines': {
        'min_hours': 20,
        'min_days': 8,
        'met': false,
        'missing': [
          {'code': 'hours', 'have': 12.5, 'need': 20, 'missing': 7.5},
          {'code': 'incidents', 'count': 1},
        ],
        'incidents': [
          {'kind': 'warning', 'points': 1, 'starts_at': '2026-10-20T00:00:00Z', 'note': 'x'}
        ],
      },
    };

    test('parse + meta combinada', () {
      final p = AgencyPerformance.fromJson(json);
      expect(p.month, '2026-10');
      expect(p.isCurrent, isFalse);
      expect(p.rank, 3);
      expect(p.of, 18);
      expect(p.guidelines.missing.first.missing, 7.5);
      expect(p.guidelines.missing.last.count, 1);
      expect(p.guidelines.incidents.single.kind, 'warning');
      expect(p.monthStart, DateTime(2026, 10));
      // (12.5/20 + 4/8) / 2
      expect(p.goalProgress, closeTo(0.5625, 1e-9));
    });

    test('sem meta definida = 100%; campos ausentes não quebram', () {
      final p = AgencyPerformance.fromJson({'month': '2026-11'});
      expect(p.goalProgress, 1);
      expect(p.rank, isNull);
      expect(p.hours, 0);
    });

    test('histórico: lista mais recente primeiro', () {
      final l = AgencyPerformance.listFromJson({
        'months': [json, {...json, 'month': '2026-09'}]
      });
      expect(l.map((e) => e.month), ['2026-10', '2026-09']);
      expect(AgencyPerformance.listFromJson(null), isEmpty);
    });
  });

  group('cliente de desempenho', () {
    test('GET /performance?month e /performance/history?months', () async {
      final seen = <Uri>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://x.test'))..httpClientAdapter = _Fake(seen);
      final svc = CreatorAgencyService(dio);
      final p = await svc.getPerformance(month: '2026-10');
      expect(p.month, '2026-10');
      expect(seen.last.path, '/creator/agency/performance');
      expect(seen.last.queryParameters['month'], '2026-10');
      await svc.getPerformance();
      expect(seen.last.queryParameters.containsKey('month'), isFalse);
      final h = await svc.getPerformanceHistory(months: 6);
      expect(seen.last.path, '/creator/agency/performance/history');
      expect(seen.last.queryParameters['months'], '6');
      expect(h.length, 2);
    });
  });
}

class _Fake implements HttpClientAdapter {
  _Fake(this.seen);
  final List<Uri> seen;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    seen.add(options.uri);
    final one = '{"month":"2026-10","is_current":false,"hours":1,"days":1,"diamonds":1,"followers":1,"rank":1,"of":2,"guidelines":{}}';
    final body = options.uri.path.endsWith('history') ? '{"months":[$one,$one]}' : one;
    return ResponseBody.fromString(body, 200, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
  }
}
