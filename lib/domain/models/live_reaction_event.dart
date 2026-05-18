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
  });

  final String userId;
  final int count;
  final String? color;
  final DateTime timestamp;
}
