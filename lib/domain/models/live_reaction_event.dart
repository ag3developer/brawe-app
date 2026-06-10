/// ❤️ Evento de reação (coração flutuante) recebido via socket.
///
/// Representa um *batch* de toques (count) enviados por um único viewer
/// num intervalo curto. O overlay no app desenha N corações subindo.
class LiveReactionEvent {
  const LiveReactionEvent({
    required this.userId,
    required this.count,
    required this.timestamp,
    this.color,
    this.battleSide,
  });

  final String userId;
  final int count;
  final String? color;

  /// 🎯 Lado da batalha que recebeu o reaction (`'a'` esquerda, `'b'` direita)
  /// ou `null` quando a sala é live solo (sem batalha).
  ///
  /// Usado pelo `FloatingHeartsOverlay` no app pra ancorar os corações no
  /// hemisfério correto do split-screen (TikTok-style), em vez de cair
  /// sempre na faixa direita. Também força a cor pra combinar com o lado
  /// (lado A = roxo, lado B = rosa — mesmas cores do score panel).
  final String? battleSide;

  final DateTime timestamp;
}
