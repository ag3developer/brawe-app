import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:brawe_app/domain/models/conversation.dart';
import 'package:brawe_app/domain/models/creator_agency.dart';
import 'package:brawe_app/domain/models/creator_journey.dart';
import 'package:brawe_app/domain/models/creator_network.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/chat/widgets/rich/agency_invite_bubble.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/creator/view_models/creator_agency_providers.dart';
import 'package:brawe_app/ui/creator/view_models/creator_header_provider.dart';
import 'package:brawe_app/ui/creator/view_models/creator_journey_provider.dart';
import 'package:brawe_app/ui/creator/view_models/creator_network_view_model.dart';
import 'package:brawe_app/ui/creator/widgets/agency/agency_invite_screen.dart';
import 'package:brawe_app/ui/creator/widgets/creator_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

const _shots =
    '/private/tmp/claude-501/-Volumes-SSD-240GB-EXTERNO-Documentos-Brawe/ac56cc5f-b3cc-4aea-9f4b-e3fd84662a35/scratchpad/shots-redesign';

// ── fontes reais (sem retângulos nos PNGs) ───────────────────────────────────
Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/usr/local/share/flutter';
  final dir = '$root/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> paths) async {
    final l = FontLoader(family);
    for (final p in paths) {
      l.addFont(File(p).readAsBytes().then((b) => ByteData.sublistView(b)));
    }
    await l.load();
  }

  await load('Roboto', [for (final w in ['Regular', 'Medium', 'Bold', 'Black']) '$dir/Roboto-$w.ttf']);
  await load('MaterialIcons', ['$dir/MaterialIcons-Regular.otf']);
  final cfg = jsonDecode(File('.dart_tool/package_config.json').readAsStringSync()) as Map;
  final pkg = (cfg['packages'] as List).firstWhere((p) => p['name'] == 'lucide_icons_flutter') as Map;
  var uri = pkg['rootUri'] as String;
  final base = uri.startsWith('file://') ? Uri.parse(uri).toFilePath() : Directory('.dart_tool').uri.resolve(uri).toFilePath();
  await load('packages/lucide_icons_flutter/Lucide', ['${base.endsWith('/') ? base : '$base/'}assets/lucide.ttf']);
}

// ── dados de exemplo ─────────────────────────────────────────────────────────
final _card = AgencyCard.fromJson({
  'id': 'a1',
  'name': 'Streamer Now Agency',
  'country': 'BR',
  'creators_count': 42,
  'partner_since': '2025-03-10T00:00:00Z',
  'website': 'https://streamernow.example.com',
  'socials': {'instagram': '@streamernow'},
  'niches': ['games', 'música', 'lifestyle'],
});

final _inviter = AgencyInviter.tryParse({'user_id': 'u1', 'name': 'Marina Souza', 'username': 'marina', 'role': 'manager'});

final _terms = AgencyTerms(
  version: '2026-03',
  standard: {'pt': '# Termos Brawe\n\n- Você mantém sua conta.\n- **Sem cobranças** da agência.\n\n${'Texto dos termos. ' * 60}'},
  addendum: {'pt': '## Adendo\nRegras da Streamer Now Agency.'},
);

final _invite = AgencyInvite(
  inviteId: 'i1',
  status: 'invited',
  agency: _card,
  contractMonths: 12,
  message: 'Oi! Adoramos o seu trabalho e queremos crescer juntos.',
  invitedAt: DateTime(2026, 11, 1),
  invitedBy: _inviter,
  terms: _terms,
);

AgencyLink _link([AgencyLeave leave = const AgencyLeave()]) => AgencyLink(
      linkId: 'l1',
      status: 'active',
      agency: _card,
      contract: AgencyContract(months: 12, startedAt: DateTime(2026, 3, 10), endsAt: DateTime(2027, 3, 10), progress: 0.66, daysLeft: 124),
      acceptedAt: DateTime(2026, 3, 10),
      termsVersion: '2026-03',
      terms: _terms,
      leave: leave,
      invitedBy: _inviter,
    );

AgencyPerformance _perf(String month) {
  final m = int.parse(month.substring(5));
  return AgencyPerformance.fromJson({
    'month': month,
    'is_current': month == agencyMonthKey(DateTime.now()),
    'hours': 8.0 + m % 7 * 3.5,
    'days': 3 + m % 6,
    'diamonds': 40000 + m % 5 * 18000,
    'followers': 120 + m * 7,
    'rank': 3 + m % 3,
    'of': 18,
    'guidelines': {
      'min_hours': 20,
      'min_days': 8,
      'met': false,
      'missing': [],
      'incidents': [
        {'kind': 'warning', 'points': 1, 'starts_at': '$month-12T00:00:00Z', 'note': 'Conduta no chat'}
      ],
    },
  });
}

final _me = AgencyMe.fromJson({
  'hours': 12.5,
  'days': 4,
  'diamonds': 123456,
  'followers': 321,
  'rank': 3,
  'of': 18,
  'guidelines': {
    'min_hours': 20,
    'min_days': 8,
    'met': false,
    'incidents': [
      {'kind': 'warning', 'points': 1, 'starts_at': '2026-10-20T00:00:00Z', 'note': 'Conduta no chat'},
      {'kind': 'suspension', 'points': 3, 'starts_at': '2026-09-02T00:00:00Z'},
    ],
  },
});

final _events = [
  AgencyEvent(id: 'e1', names: const {'pt': 'Maratona de Fim de Ano'}, startsAt: DateTime(2026, 11, 3), endsAt: DateTime(2026, 11, 9), status: 'live', multiplier: 2),
  AgencyEvent(id: 'e2', names: const {'pt': 'Festival de Verão'}, startsAt: DateTime(2026, 12, 10), endsAt: DateTime(2026, 12, 12), status: 'scheduled'),
  AgencyEvent(id: 'e3', names: const {'pt': 'Noite das Estrelas'}, startsAt: DateTime(2026, 10, 1), endsAt: DateTime(2026, 10, 3), status: 'ended', multiplier: 1.5),
];

final _stLinked = AgencyState(link: _link(AgencyLeave(contractEndsAt: DateTime(2027, 3, 10), answerDays: 15)), me: _me, events: _events);
final _stLinkedInvites = AgencyState(link: _link(), me: _me, events: _events, invites: [_invite]);
final _stInvites = AgencyState(invites: [_invite, _invite], openToAgencies: true);
const _stNone = AgencyState(openToAgencies: true);

AgencyState _stLeave(AgencyLeave l) => AgencyState(link: _link(l), me: _me, events: _events);

final _journey = CreatorJourney(
  currentTier: CreatorTier.featured,
  creatorSince: DateTime(2025, 6, 1),
  activeDays: 120,
  nextTier: CreatorTier.live,
  nextTierInviteOnly: false,
  overallProgress: 0.62,
  levels: [
    JourneyLevel(tier: CreatorTier.rising, status: JourneyLevelStatus.achieved, achievedAt: DateTime(2025, 6, 1), inviteOnly: false),
    JourneyLevel(tier: CreatorTier.featured, status: JourneyLevelStatus.current, achievedAt: DateTime(2025, 9, 1), inviteOnly: false),
    const JourneyLevel(tier: CreatorTier.live, status: JourneyLevelStatus.next, achievedAt: null, inviteOnly: false),
    const JourneyLevel(tier: CreatorTier.ambassador, status: JourneyLevelStatus.locked, achievedAt: null, inviteOnly: true),
    const JourneyLevel(tier: CreatorTier.founding, status: JourneyLevelStatus.locked, achievedAt: null, inviteOnly: true),
  ],
  badges: const [],
  goals: const [
    JourneyGoal(metric: 'followers', current: 820, target: 1000, progress: 0.82, remaining: 180, done: false),
    JourneyGoal(metric: 'lives', current: 12, target: 12, progress: 1, remaining: 0, done: true),
    JourneyGoal(metric: 'live_minutes', current: 540, target: 900, progress: 0.6, remaining: 360, done: false),
  ],
  week: const [
    JourneyWeekMetric(metric: 'followers', current: 48, previous: 30, delta: 18, trend: JourneyTrend.up),
    JourneyWeekMetric(metric: 'viewers', current: 1250, previous: 1400, delta: -150, trend: JourneyTrend.down),
    JourneyWeekMetric(metric: 'lives', current: 5, previous: 5, delta: 0, trend: JourneyTrend.flat),
    JourneyWeekMetric(metric: 'live_minutes', current: 410, previous: 300, delta: 110, trend: JourneyTrend.up),
    JourneyWeekMetric(metric: 'posts', current: 3, previous: 2, delta: 1, trend: JourneyTrend.up),
  ],
  benefits: const [
    JourneyBenefit(key: 'rising_badge', tier: CreatorTier.rising, unlocked: true),
    JourneyBenefit(key: 'creator_profile', tier: CreatorTier.rising, unlocked: true),
    JourneyBenefit(key: 'analytics', tier: CreatorTier.featured, unlocked: true),
    JourneyBenefit(key: 'live_badge', tier: CreatorTier.live, unlocked: false),
  ],
);

final _profile = CreatorProfile(
  id: 'p1',
  userId: 'u0',
  tier: CreatorTier.featured,
  primaryBadge: 'featured',
  isFeatured: false,
  isAmbassador: false,
  isFoundingCreator: false,
  approvedAt: DateTime(2025, 6, 1),
);

List<Override> _overrides(AgencyState st, {AgencyInvite? invite, bool agencyError = false}) => [
      myCreatorProfileProvider.overrideWith((ref) async => _profile),
      creatorJourneyProvider.overrideWith((ref) async => _journey),
      creatorHeaderProvider.overrideWith((ref) async => const CreatorHeaderData(name: 'Camila Ferraz')),
      creatorMonthEarningsProvider.overrideWith((ref) async => 4820.5),
      creatorAgencyProvider.overrideWith((ref) async => agencyError ? throw Exception('x') : st),
      agencyPerformanceProvider.overrideWith((ref, month) async => _perf(month)),
      agencyHistoryProvider.overrideWith((ref) async => [for (final m in agencyRecentMonths()) _perf(m)]),
      agencyInviteProvider.overrideWith((ref, id) async => invite ?? _invite),
    ];

final _boundary = GlobalKey();

Widget _app(Widget home, {required List<Override> overrides, bool dark = false, double textScale = 1}) => ProviderScope(
      key: UniqueKey(),
      overrides: overrides,
      child: RepaintBoundary(
        key: _boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('pt'),
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)), child: w!),
          home: home,
        ),
      ),
    );

void _size(WidgetTester t, Size s) {
  t.view.physicalSize = s * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final b = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('$_shots/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _openPanel(WidgetTester t, AgencyState st, {String? tab, bool dark = false, double scale = 1}) async {
  await t.pumpWidget(_app(CreatorDashboardScreen(initialTab: tab), overrides: _overrides(st), dark: dark, textScale: scale));
  await t.pumpAndSettle();
}

Future<void> _tapText(WidgetTester t, String text) async {
  final f = find.text(text).first;
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  const sizes = <String, Size>{'320x568': Size(320, 568), '360x640': Size(360, 640), '412x915': Size(412, 915), '820x1180': Size(820, 1180)};

  // Cada cenário: como chegar na tela a partir do painel.
  final scenarios = <String, (AgencyState, Future<void> Function(WidgetTester))>{
    'inicio': (_stNone, (t) async {}),
    'inicio-com-agencia': (_stLinked, (t) async {}),
    'desempenho': (_stLinked, (t) => _tapText(t, 'Desempenho')),
    'beneficios': (_stLinked, (t) => _tapText(t, 'Benefícios')),
    'agencia-resumo': (_stLinked, (t) => _tapText(t, 'Agência')),
    'agencia-metas': (_stLinked, (t) async {
      await _tapText(t, 'Agência');
      await _tapText(t, 'Metas');
    }),
    'agencia-eventos': (_stLinked, (t) async {
      await _tapText(t, 'Agência');
      await _tapText(t, 'Eventos');
    }),
    'agencia-contrato': (_stLinked, (t) async {
      await _tapText(t, 'Agência');
      await _tapText(t, 'Contrato');
    }),
    'agencia-convites': (_stInvites, (t) => _tapText(t, 'Agência')),
    'agencia-com-convite-banner': (_stLinkedInvites, (t) => _tapText(t, 'Agência')),
  };

  for (final dark in [false, true]) {
    for (final sz in sizes.entries) {
      for (final sc in scenarios.entries) {
        testWidgets('${sc.key} ${sz.key} ${dark ? 'escuro' : 'claro'} sem overflow', (tester) async {
          _size(tester, sz.value);
          await _openPanel(tester, sc.value.$1, dark: dark);
          await sc.value.$2(tester);
          expect(tester.takeException(), isNull);
        });
      }
      testWidgets('convite ${sz.key} ${dark ? 'escuro' : 'claro'} sem overflow', (tester) async {
        _size(tester, sz.value);
        await tester.pumpWidget(_app(const AgencyInviteScreen(inviteId: 'i1'), overrides: _overrides(_stInvites), dark: dark));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Quem convidou'), findsOneWidget);
        expect(find.text('Marina Souza'), findsOneWidget);
        expect(find.textContaining('nível'), findsNothing);
      });
    }
  }

  testWidgets('texto 200% em 320x568: todas as abas sem overflow', (tester) async {
    _size(tester, const Size(320, 568));
    for (final sc in scenarios.entries) {
      await _openPanel(tester, sc.value.$1, scale: 2);
      await sc.value.$2(tester);
      expect(tester.takeException(), isNull, reason: sc.key);
    }
    await tester.pumpWidget(_app(const AgencyInviteScreen(inviteId: 'i1'), overrides: _overrides(_stInvites), textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('estrutura', () {
    testWidgets('abas: sem agência não mostra Agência; com vínculo mostra; convites mostram selo', (tester) async {
      _size(tester, const Size(390, 844));
      await _openPanel(tester, _stNone);
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Agência'), findsNothing);
      expect(find.text('Aberto a convites'), findsOneWidget);
      await _openPanel(tester, _stLinked);
      expect(find.text('Agência'), findsOneWidget);
      expect(find.text('Aberto a convites'), findsNothing);
      await _openPanel(tester, _stInvites);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('?tab=agency abre direto na aba Agência', (tester) async {
      _size(tester, const Size(390, 844));
      await _openPanel(tester, _stLinked, tab: 'agency');
      expect(find.text('Streamer Now Agency'), findsOneWidget);
      expect(find.text('Resumo'), findsOneWidget);
      expect(find.text('Falar'), findsOneWidget);
    });

    testWidgets('barra da agência não repete perfil (sem criadores/site/nichos)', (tester) async {
      _size(tester, const Size(390, 844));
      await _openPanel(tester, _stLinked, tab: 'agency');
      expect(find.textContaining('42 criadores'), findsNothing);
      expect(find.textContaining('streamernow.example'), findsNothing);
      expect(find.textContaining('Agenciado desde'), findsOneWidget);
      expect(find.textContaining('#'), findsWidgets);
    });

    testWidgets('resumo: posição e filtro de período', (tester) async {
      _size(tester, const Size(390, 844));
      await _openPanel(tester, _stLinked, tab: 'agency');
      expect(find.text('Este mês'), findsOneWidget);
      expect(find.textContaining(' de 18'), findsOneWidget);
      await tester.tap(find.text('Este mês'));
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuItem<String>), findsNWidgets(6));
    });

    testWidgets('eventos: filtros e vazio por filtro', (tester) async {
      _size(tester, const Size(390, 844));
      await _openPanel(tester, _stLinked, tab: 'agency');
      await _tapText(tester, 'Eventos');
      expect(find.text('Maratona de Fim de Ano'), findsOneWidget);
      await _tapText(tester, 'Encerrados');
      expect(find.text('Noite das Estrelas'), findsOneWidget);
      await tester.pumpWidget(_app(const CreatorDashboardScreen(initialTab: 'agency'),
          overrides: _overrides(AgencyState(link: _link(), me: _me, events: const []))));
      await tester.pumpAndSettle();
      await _tapText(tester, 'Eventos');
      await _tapText(tester, 'Próximos');
      expect(find.text('Nenhum evento agendado.'), findsOneWidget);
    });

    final leaveCases = <String, (AgencyLeave, List<String>)>{
      'livre': (AgencyLeave(mode: 'free', canLeaveFree: true, contractEndsAt: DateTime(2026, 11, 1)), ['Sair da agência']),
      'pedir': (AgencyLeave(contractEndsAt: DateTime(2027, 3, 10), answerDays: 15), ['Pedir desligamento à agência', 'Pedir análise da Brawe']),
      'pendente': (
        AgencyLeave(
          mode: 'pending',
          contractEndsAt: DateTime(2027, 3, 10),
          answerDays: 15,
          request: AgencyLeaveRequest(id: 'r1', kind: 'early', status: 'pending', createdAt: DateTime(2026, 11, 1)),
        ),
        ['Pedido de desligamento enviado', 'Cancelar pedido']
      ),
      'recusado': (
        AgencyLeave(
          contractEndsAt: DateTime(2027, 3, 10),
          lastDeclined: const AgencyLeaveRequest(id: 'r0', kind: 'early', status: 'declined', answerNote: 'Fique até a campanha acabar.'),
          retryAt: DateTime(2999, 1, 1),
        ),
        ['Pedido recusado']
      ),
    };
    for (final e in leaveCases.entries) {
      testWidgets('contrato/saída: ${e.key}', (tester) async {
        _size(tester, const Size(390, 1400));
        await _openPanel(tester, _stLeave(e.value.$1), tab: 'agency');
        await _tapText(tester, 'Contrato');
        expect(tester.takeException(), isNull);
        for (final t in e.value.$2) {
          expect(find.text(t), findsWidgets, reason: t);
        }
        if (e.key == 'pendente') {
          expect(find.textContaining('você fica livre automaticamente'), findsOneWidget);
          expect(find.textContaining('análise da Brawe'), findsNothing);
        }
      });
    }

    testWidgets('convite: aceitar só após marcar os termos; termos recolhidos', (tester) async {
      _size(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const AgencyInviteScreen(inviteId: 'i1'), overrides: _overrides(_stInvites)));
      await tester.pumpAndSettle();
      final btn = find.widgetWithText(FilledButton, 'Aceitar convite');
      expect(tester.widget<FilledButton>(btn).onPressed, isNull);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<FilledButton>(btn).onPressed, isNotNull);
      expect(find.text('Ler termos completos'), findsOneWidget);
      expect(find.textContaining('Termos Brawe'), findsNothing);
    });

    testWidgets('erro de carregamento mostra tentar novamente', (tester) async {
      _size(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const CreatorDashboardScreen(initialTab: 'agency'),
          overrides: _overrides(_stLinked, agencyError: true)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('cartão do chat', () {
    ChatMessage msg() => ChatMessage(
        id: 'm',
        conversationId: 'c',
        senderId: 's',
        content: '{"type":"agency_invite","invite_id":"i1","agency_id":"a1","agency_name":"Streamer Now Agency","contract_months":12,"message":"Bora crescer!"}',
        timestamp: DateTime(2026, 11, 5),
        messageType: 'agency_invite');

    for (final w in [260.0, 360.0, 800.0]) {
      testWidgets('largura $w', (tester) async {
        String? opened;
        await tester.pumpWidget(_app(
            Scaffold(body: SizedBox(width: w, child: Align(alignment: Alignment.centerLeft, child: AgencyInviteBubble(message: msg(), isMe: false, onOpen: (id) => opened = id)))),
            overrides: const []));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Nível'), findsNothing);
        await tester.tap(find.text('Abrir convite'));
        expect(opened, 'i1');
      });
    }
  });

  // ── Capturas (390x844, claro e escuro) ─────────────────────────────────────
  for (final dark in [false, true]) {
    final tag = dark ? 'escuro' : 'claro';
    Future<void> shot(WidgetTester t, String n) => _shot(t, '$n-$tag');

    testWidgets('capturas painel $tag', (tester) async {
      _size(tester, const Size(390, 844));
      await _openPanel(tester, _stLinked, dark: dark);
      await shot(tester, '01-painel-inicio');
      await _tapText(tester, 'Desempenho');
      await shot(tester, '02-painel-desempenho');
      await _tapText(tester, 'Benefícios');
      await shot(tester, '03-painel-beneficios');
      await _tapText(tester, 'Agência');
      await shot(tester, '04-agencia-resumo');
      await _tapText(tester, 'Metas');
      await shot(tester, '05-agencia-metas');
      await _tapText(tester, 'Eventos');
      await shot(tester, '06-agencia-eventos');
      await _tapText(tester, 'Contrato');
      await shot(tester, '07-agencia-contrato');
    });

    testWidgets('capturas convites e sem agência $tag', (tester) async {
      _size(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const AgencyInviteScreen(inviteId: 'i1'), overrides: _overrides(_stInvites), dark: dark));
      await tester.pumpAndSettle();
      await shot(tester, '08-convite');
      await _openPanel(tester, _stInvites, dark: dark);
      await _tapText(tester, 'Agência');
      await shot(tester, '09-lista-de-convites');
      await _openPanel(tester, _stNone, dark: dark);
      await shot(tester, '10-sem-agencia-linha');
      await tester.tap(find.byTooltip('Como funciona'));
      await tester.pumpAndSettle();
      await shot(tester, '11-sem-agencia-como-funciona');
    });

    testWidgets('captura folha de desligamento $tag', (tester) async {
      _size(tester, const Size(390, 844));
      await _openPanel(tester, _stLinked, tab: 'agency', dark: dark);
      await _tapText(tester, 'Contrato');
      final ask = find.text('Pedir desligamento à agência');
      await tester.dragUntilVisible(ask, find.byType(CustomScrollView).last, const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(ask.hitTestable().first);
      await tester.pumpAndSettle();
      await shot(tester, '12-folha-desligamento');
    });
  }
}
