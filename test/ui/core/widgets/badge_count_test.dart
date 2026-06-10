import 'package:brawe_app/ui/core/widgets/badge_count.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes da formatação PURA do badge de contagem (sininho de notificações e
/// ícone de mensagens no top bar do feed).
void main() {
  group('BadgeCount.isVisible', () {
    test('esconde quando 0', () {
      expect(BadgeCount.isVisible(0), isFalse);
    });

    test('esconde quando negativo (defensivo)', () {
      expect(BadgeCount.isVisible(-1), isFalse);
    });

    test('mostra quando > 0', () {
      expect(BadgeCount.isVisible(1), isTrue);
      expect(BadgeCount.isVisible(42), isTrue);
    });
  });

  group('BadgeCount.label', () {
    test('0 ou negativo retorna string vazia', () {
      expect(BadgeCount.label(0), '');
      expect(BadgeCount.label(-5), '');
    });

    test('mostra o número exato até o limite (9)', () {
      expect(BadgeCount.label(1), '1');
      expect(BadgeCount.label(9), '9');
    });

    test('acima do limite vira "9+"', () {
      expect(BadgeCount.label(10), '9+');
      expect(BadgeCount.label(150), '9+');
    });
  });
}
