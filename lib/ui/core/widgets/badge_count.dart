/// Formatação do rótulo de um badge de contagem (ex.: sininho de notificações,
/// ícone de mensagens). Lógica pura, isolada do widget para ser testável sem
/// `WidgetTester` — segue o padrão de métodos estáticos puros já usado em
/// `NotificationNavigationService`.
class BadgeCount {
  const BadgeCount._();

  /// Limite acima do qual o rótulo vira "N+".
  static const int max = 9;

  /// Deve exibir o badge? Apenas quando há itens não lidos.
  static bool isVisible(int count) => count > 0;

  /// Rótulo a exibir: o número, ou "9+" quando passa de [max].
  /// Para `count <= 0` retorna string vazia (o badge fica escondido).
  static String label(int count) {
    if (count <= 0) return '';
    return count > max ? '$max+' : '$count';
  }
}
