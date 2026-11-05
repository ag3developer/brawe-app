// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';import 'package:brawe_app/domain/models/battle_assets.dart';
import 'package:brawe_app/ui/live_feed/battle/battle_layout.dart';
import 'package:brawe_app/ui/live_feed/battle/battle_narrator.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

NarratorLine line(String key, int priority, {int ttlMs = 1000}) => NarratorLine(
  key: key,
  text: key,
  priority: priority,
  ttl: Duration(milliseconds: ttlMs),
);

void main() {
  test('prioridade maior interrompe; menor espera a vez', () {
    fakeAsync((async) {
      final c = BattleNarratorController(
        clock: () => async.getClock(DateTime(2026)).now(),
      );
      c.push(line('a', 50));
      expect(c.current?.key, 'a');
      c.push(line('b', 30));
      expect(c.current?.key, 'a');
      c.push(line('c', 90));
      expect(c.current?.key, 'c');
      async.elapse(const Duration(milliseconds: 1001));
      // 'c' acabou; 'b' esperou e ainda vale (<= ttl).
      expect(c.current?.key, 'b');
      async.elapse(const Duration(milliseconds: 1001));
      expect(c.current, isNull);
      c.dispose();
    });
  });

  test('mesma chave dentro do ttl é descartada', () {
    fakeAsync((async) {
      final c = BattleNarratorController(
        clock: () => async.getClock(DateTime(2026)).now(),
      );
      c.push(line('a', 50));
      async.elapse(const Duration(milliseconds: 1001));
      expect(c.current, isNull);
      c.push(line('a', 50));
      // 1,001 s depois do ttl de 1 s: já pode repetir.
      expect(c.current?.key, 'a');
      c.push(line('x', 10));
      c.push(line('x', 10));
      async.elapse(const Duration(milliseconds: 1001));
      expect(c.current?.key, 'x');
      c.dispose();
    });
  });

  test('variáveis do narrador são preenchidas e as ausentes somem', () {
    expect(
      fillNarratorVars('VIROU! {time} passou {poder}', {'time': 'Ana'}),
      'VIROU! Ana passou',
    );
  });

  test('manifesto: parse tolerante e URLs de mídia', () {
    final m = BattleManifest.tryParse({
      'version': 3,
      'theme_id': 'festival-nov',
      'moments': {
        'victory': {'lottie_url': 'https://x/v.json', 'sound_url': 'https://x/v.mp3'},
      },
      'bar_effects': [
        {'id': 'shine', 'trigger': 'lead_change', 'anchor': 'bar'},
      ],
      'narrator': {
        'start': {'pt': 'Oi', 'en': '', 'priority': 50, 'ttl_ms': 3000, 'style': 'gold'},
      },
    });
    expect(m, isNotNull);
    expect(m!.version, 3);
    expect(m.mediaUrls, {'https://x/v.json', 'https://x/v.mp3'});
    expect(m.narrator['start']!.textFor('pt'), 'Oi');
    expect(m.narrator['start']!.textFor('en'), isNull);
    expect(BattleManifest.tryParse('lixo'), isNull);
  });

  test('chat começa abaixo da faixa do jogo', () {
    final l = BattleLayout.compute(screen: const Size(390, 844), splitTop: 200);
    expect(l.rowsBottom, closeTo(l.chat.top + kBattleRowsH, 0.01));
    expect(l.narratorTop, greaterThan(l.chat.top));
    expect(l.rowsBottom, greaterThan(l.narratorTop));
  });
}
