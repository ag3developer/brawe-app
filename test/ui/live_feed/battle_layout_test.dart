import 'dart:ui';

import 'package:brawe_app/ui/live_feed/battle/battle_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('faixa dividida segue as constantes do contrato (A esq / B dir)', () {
    final l = BattleLayout.compute(
      screen: const Size(390, 844),
      splitTop: 200,
    );
    final s = l.scale;
    expect(l.split.top, 200);
    expect(l.split.height, closeTo(kBattleSplitH * s, 0.01));
    expect(l.halfA.width, closeTo(358 * s, 0.01));
    expect(l.halfB.left, closeTo(l.halfA.left + 362 * s, 0.01));
    expect(l.halfA.right, lessThan(l.halfB.left));
    // O frame começa 208 px (escalados) acima da faixa dividida.
    expect(l.frame.top, closeTo(200 - kBattleSplitTop * s, 0.01));
    // Região do chat começa onde a faixa dividida termina.
    expect(l.chat.top, closeTo(l.split.bottom, 0.01));
  });

  test('tela baixa reduz a escala para sobrar espaço ao chat', () {
    final l = BattleLayout.compute(
      screen: const Size(360, 640),
      splitTop: 180,
    );
    expect(l.chat.height, greaterThanOrEqualTo(240));
  });
}
