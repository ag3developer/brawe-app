import 'dart:async';

import 'package:brawe_app/data/model/post_dto.dart';
import 'package:brawe_app/data/repositories/post_repository.dart';
import 'package:brawe_app/data/services/city_location_service.dart';
import 'package:brawe_app/domain/models/poll_draft.dart';
import 'package:brawe_app/domain/models/post_poll.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/feed/widgets/post_location_widgets.dart';
import 'package:brawe_app/ui/feed/widgets/post_poll_card.dart';
import 'package:brawe_app/ui/feed/widgets/post_poll_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';

final _now = DateTime.utc(2026, 11, 6, 12);

PostPoll _poll({
  bool voted = false,
  bool ended = false,
  bool counts = false,
  Duration left = const Duration(days: 2, hours: 3),
}) {
  final show = voted || ended || counts;
  return PostPoll(
    endsAt: _now.add(ended ? const Duration(hours: -1) : left),
    ended: ended,
    myVote: voted ? 'b' : null,
    totalVotes: show ? 1234 : null,
    options: [
      PollOption(id: 'a', text: 'Praia com a turma toda no fim de semana', votes: show ? 617 : null, percent: show ? 50 : null),
      PollOption(id: 'b', text: 'Montanha', votes: show ? 370 : null, percent: show ? 30 : null),
      PollOption(id: 'c', text: 'Cidade', votes: show ? 247 : null, percent: show ? 20 : null),
    ],
  );
}

Widget _host(Widget child, {bool dark = false, double scale = 1}) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('pt'),
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: w!,
        ),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void _size(WidgetTester t, double w) {
  t.view.physicalSize = Size(w, 800) * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
}

void main() {
  group('PollDraft', () {
    test('começa com 2 opções vazias e é inválido', () {
      final d = PollDraft();
      expect(d.options.length, 2);
      expect(d.isValid, isFalse);
      expect(d.errorAt(0), PollOptionError.empty);
      expect(d.durationDays, 1);
    });

    test('válido com 2 opções preenchidas', () {
      final d = PollDraft(options: ['Sim', 'Não']);
      expect(d.isValid, isTrue);
      expect(d.toRequestJson(), {'options': ['Sim', 'Não'], 'duration_days': 1});
    });

    test('espaços não contam como preenchido', () {
      expect(PollDraft(options: ['Sim', '   ']).isValid, isFalse);
    });

    test('duplicadas (sem diferenciar caixa) são inválidas', () {
      final d = PollDraft(options: ['Sim', ' sim ']);
      expect(d.errorAt(0), PollOptionError.duplicate);
      expect(d.errorAt(1), PollOptionError.duplicate);
      expect(d.isValid, isFalse);
    });

    test('limite de 60 caracteres', () {
      expect(PollDraft(options: ['x' * 60, 'y']).isValid, isTrue);
      expect(PollDraft(options: ['x' * 61, 'y']).isValid, isFalse);
    });

    test('mínimo 2 e máximo 4 opções', () {
      final d = PollDraft(options: ['a', 'b']);
      expect(d.canRemove, isFalse);
      expect(d.canAdd, isTrue);
      d.options..add('c')..add('d');
      expect(d.canAdd, isFalse);
      expect(d.canRemove, isTrue);
      expect(d.isValid, isTrue);
      expect(PollDraft(options: ['a']).isValid, isFalse);
      expect(PollDraft(options: ['a', 'b', 'c', 'd', 'e']).isValid, isFalse);
    });

    test('duração só 1, 3 ou 7 dias', () {
      expect(PollDraft(options: ['a', 'b'], durationDays: 3).isValid, isTrue);
      expect(PollDraft(options: ['a', 'b'], durationDays: 2).isValid, isFalse);
    });
  });

  group('modelos', () {
    final base = {
      'id': 'p1',
      'content': 'oi',
      'likes_count': 0,
      'comments_count': 0,
      'reposts_count': 0,
      'views_count': 0,
      'created_at': '2026-11-06T10:00:00Z',
      'updated_at': '2026-11-06T10:00:00Z',
      'author': {'id': 'u', 'name': 'N', 'username': 'n'},
    };

    test('post sem enquete nem localização', () {
      final post = PostResponseDto.fromJson(base).toDomain();
      expect(post.poll, isNull);
      expect(post.location, isNull);
    });

    test('post com "poll": null e "location": null', () {
      final post = PostResponseDto.fromJson({...base, 'poll': null, 'location': null}).toDomain();
      expect(post.poll, isNull);
      expect(post.location, isNull);
    });

    test('post com enquete (contagens ocultas) e localização', () {
      final post = PostResponseDto.fromJson({
        ...base,
        'poll': {
          'options': [
            {'id': 'a', 'text': 'A', 'votes': null, 'percent': null},
            {'id': 'b', 'text': 'B'},
          ],
          'total_votes': null,
          'ends_at': '2026-11-07T10:00:00Z',
          'ended': false,
          'my_vote': null,
          'counts_visible': false,
        },
        'location': {'city': 'Recife', 'region': 'PE', 'country': 'BR', 'label': 'Recife, PE'},
      }).toDomain();
      expect(post.poll!.options.length, 2);
      expect(post.poll!.hasCounts, isFalse);
      expect(post.poll!.hasVoted, isFalse);
      expect(post.location!.label, 'Recife, PE');
    });

    test('enquete votada com percentuais', () {
      final p = PostPoll.fromJson({
        'options': [
          {'id': 'a', 'text': 'A', 'votes': 3, 'percent': 75},
          {'id': 'b', 'text': 'B', 'votes': 1, 'percent': 25},
        ],
        'total_votes': 4,
        'ends_at': '2026-11-07T10:00:00Z',
        'ended': false,
        'my_vote': 'b',
      });
      expect(p.hasCounts, isTrue);
      expect(p.myVote, 'b');
      expect(p.isEnded(DateTime.utc(2026, 11, 8)), isTrue);
      expect(p.isEnded(DateTime.utc(2026, 11, 6)), isFalse);
    });

    test('rótulo de localização', () {
      expect(PostLocation.buildLabel('Recife', 'PE', 'BR'), 'Recife, PE');
      expect(PostLocation.buildLabel('Lisboa', null, 'PT'), 'Lisboa, PT');
      final loc = PostLocation.fromJson({'city': 'Recife', 'region': 'PE', 'country': 'BR'});
      expect(loc.label, 'Recife, PE');
      expect(loc.toRequestJson(), {'city': 'Recife', 'region': 'PE', 'country': 'BR'});
      expect(loc.toRequestJson().keys, isNot(contains('latitude')));
    });
  });

  group('geocodificação -> cidade', () {
    test('Android (estado por extenso) vira UF e ignora rua', () {
      final loc = placemarksToCity([
        Placemark(
          street: 'Rua Secreta 123',
          locality: 'Recife',
          administrativeArea: 'Pernambuco',
          isoCountryCode: 'BR',
        ),
      ])!;
      expect(loc.label, 'Recife, PE');
      expect(loc.country, 'BR');
      expect(loc.label, isNot(contains('Secreta')));
    });

    test('iOS (sigla) mantém UF; exterior mantém a região', () {
      expect(
        placemarksToCity([Placemark(locality: 'Recife', administrativeArea: 'PE', isoCountryCode: 'BR')])!.label,
        'Recife, PE',
      );
      expect(
        placemarksToCity([Placemark(locality: 'Austin', administrativeArea: 'TX', isoCountryCode: 'US')])!.label,
        'Austin, TX',
      );
    });

    test('sem cidade ou país => null', () {
      expect(placemarksToCity([Placemark(administrativeArea: 'PE', isoCountryCode: 'BR')]), isNull);
      expect(placemarksToCity([Placemark(locality: 'Recife')]), isNull);
      expect(placemarksToCity([]), isNull);
    });
  });

  group('editor de enquete', () {
    testWidgets('adicionar até 4, remover até 2, duplicada mostra erro', (t) async {
      _size(t, 390);
      final d = PollDraft();
      var changes = 0;
      await t.pumpWidget(_host(PostPollEditor(draft: d, onChanged: () => changes++, onRemove: () {})));
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Adicionar opção'), findsOneWidget);

      await t.tap(find.text('Adicionar opção'));
      await t.pump();
      await t.tap(find.text('Adicionar opção'));
      await t.pump();
      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.text('Adicionar opção'), findsNothing);

      await t.tap(find.byTooltip('Remover opção').first);
      await t.pump();
      await t.tap(find.byTooltip('Remover opção').first);
      await t.pump();
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byTooltip('Remover opção'), findsNothing);

      await t.enterText(find.byType(TextField).at(0), 'Sim');
      await t.enterText(find.byType(TextField).at(1), 'sim');
      await t.pump();
      expect(find.text('Opção repetida'), findsNWidgets(2));
      expect(d.isValid, isFalse);
      expect(changes, greaterThan(3));

      await t.enterText(find.byType(TextField).at(1), 'Não');
      await t.pump();
      expect(find.text('Opção repetida'), findsNothing);
      expect(d.isValid, isTrue);
    });

    testWidgets('duração 1/3/7 dias, padrão 1', (t) async {
      _size(t, 320);
      final d = PollDraft(options: ['a', 'b']);
      await t.pumpWidget(_host(PostPollEditor(draft: d, onChanged: () {}, onRemove: () {}), scale: 2));
      expect(find.text('1 dia'), findsOneWidget);
      await t.tap(find.text('7 dias'));
      await t.pump();
      expect(d.durationDays, 7);
      expect(t.takeException(), isNull);
    });
  });

  group('card da enquete', () {
    for (final dark in [false, true]) {
      for (final w in [320.0, 390.0]) {
        final tag = '${dark ? 'dark' : 'light'} ${w.toInt()}';
        final states = <String, PostPoll>{
          'não votou': _poll(),
          'votou': _poll(voted: true),
          'encerrada': _poll(ended: true),
          'autor (contagens antes de votar)': _poll(counts: true),
        };
        states.forEach((name, poll) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('$name · $tag · x$scale sem overflow', (t) async {
              _size(t, w);
              await t.pumpWidget(_host(
                PostPollCard(postId: 'p', poll: poll, clock: () => _now),
                dark: dark,
                scale: scale,
              ));
              await t.pumpAndSettle();
              expect(t.takeException(), isNull);
              expect(find.text('Montanha'), findsOneWidget);
            });
          }
        });
      }
    }

    testWidgets('não votou: sem percentuais e com dica', (t) async {
      _size(t, 390);
      await t.pumpWidget(_host(PostPollCard(postId: 'p', poll: _poll(), clock: () => _now)));
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('Vote para ver os resultados'), findsOneWidget);
      expect(find.textContaining('termina em 2 d'), findsOneWidget);
    });

    testWidgets('votou: percentuais, total formatado e minha escolha', (t) async {
      _size(t, 390);
      await t.pumpWidget(_host(PostPollCard(postId: 'p', poll: _poll(voted: true), clock: () => _now)));
      await t.pumpAndSettle();
      expect(find.text('30%'), findsOneWidget);
      expect(find.textContaining('1.234 votos'), findsOneWidget);
      expect(find.textContaining('termina em 2 d'), findsOneWidget);
    });

    testWidgets('encerrada: mostra "Encerrada" e não aceita voto', (t) async {
      _size(t, 390);
      var called = false;
      await t.pumpWidget(_host(PostPollCard(
        postId: 'p',
        poll: _poll(ended: true),
        clock: () => _now,
        voter: (_, _) async {
          called = true;
          return _poll(voted: true);
        },
      )));
      await t.pumpAndSettle();
      expect(find.textContaining('Encerrada'), findsOneWidget);
      await t.tap(find.text('Cidade'));
      await t.pump();
      expect(called, isFalse);
    });

    testWidgets('voto otimista: marca na hora e aplica o resultado do servidor', (t) async {
      _size(t, 390);
      final c = Completer<PostPoll>();
      PostPoll? notified;
      await t.pumpWidget(_host(PostPollCard(
        postId: 'p',
        poll: _poll(),
        clock: () => _now,
        voter: (_, id) {
          expect(id, 'b');
          return c.future;
        },
        onChanged: (p) => notified = p,
      )));
      await t.tap(find.text('Montanha'));
      await t.pump();
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.textContaining('%'), findsNothing); // aguardando servidor
      c.complete(_poll(voted: true));
      await t.pumpAndSettle();
      expect(find.text('30%'), findsOneWidget);
      expect(notified!.myVote, 'b');
    });

    testWidgets('erro de rede: reverte e avisa', (t) async {
      _size(t, 390);
      await t.pumpWidget(_host(PostPollCard(
        postId: 'p',
        poll: _poll(),
        clock: () => _now,
        voter: (_, _) async => throw Exception('rede'),
      )));
      await t.tap(find.text('Montanha'));
      await t.pumpAndSettle();
      expect(find.textContaining('Não foi possível registrar seu voto'), findsOneWidget);
      expect(find.textContaining('Vote para ver os resultados'), findsOneWidget);
    });

    testWidgets('409 já votou: reverte com mensagem', (t) async {
      _size(t, 390);
      await t.pumpWidget(_host(PostPollCard(
        postId: 'p',
        poll: _poll(),
        clock: () => _now,
        voter: (_, _) async => throw const PollVoteException('already_voted'),
      )));
      await t.tap(find.text('Cidade'));
      await t.pumpAndSettle();
      expect(find.text('Você já votou nesta enquete.'), findsOneWidget);
    });
  });

  group('localização na UI', () {
    for (final dark in [false, true]) {
      for (final w in [320.0, 390.0]) {
        testWidgets('chip e linha · ${dark ? 'dark' : 'light'} $w x2 sem overflow', (t) async {
          _size(t, w);
          var removed = false;
          await t.pumpWidget(_host(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostLocationChip(label: 'Recife, PE', onRemove: () => removed = true),
                const PostLocationRow(label: 'Santa Cruz do Capibaribe, Pernambuco, Brasil'),
              ],
            ),
            dark: dark,
            scale: 2,
          ));
          expect(find.text('Recife, PE'), findsOneWidget);
          expect(t.takeException(), isNull);
          await t.tap(find.byTooltip('Remover localização'));
          expect(removed, isTrue);
        });
      }
    }
  });
}
