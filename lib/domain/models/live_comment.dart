import 'user_award.dart';

class LiveComment {
  const LiveComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.avatarUrl,
    this.username,
    this.isPending = false,
    this.gifterLevel = 1,
    this.gifterBadge,
    this.gifterLabel,
    this.gifterColor,
    this.gifterImageUrl,
    this.isSystem = false,
    this.award,
    this.isModerator = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final String? avatarUrl;

  /// @username do autor (sem o "@"), resolvido pelo servidor. Usado para
  /// "Responder" com menção. Pode ser null em servidores antigos.
  final String? username;
  final bool isPending;
  // ─── Gifter level pin (TikTok-style) ───
  final int gifterLevel;
  final String? gifterBadge;     // emoji fallback (⭐, 🔥, 👑, 💎)
  final String? gifterLabel;     // "Fã", "Lenda", "Brawe Legend"
  final String? gifterColor;     // hex "#FFD700"
  final String? gifterImageUrl;  // PNG remoto do pin (CDN ou /static)

  /// Linha de sistema (ex.: "fulano subiu para o nível 10") — sem autor.
  final bool isSystem;

  /// Prêmio mais prestigioso ativo do autor (ausente em servidor antigo).
  final UserAward? award;

  /// Autor é moderador do criador desta live (selo de escudo).
  final bool isModerator;

  LiveComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? message,
    DateTime? timestamp,
    String? avatarUrl,
    String? username,
    bool? isPending,
    int? gifterLevel,
    String? gifterBadge,
    String? gifterLabel,
    String? gifterColor,
    String? gifterImageUrl,
  }) {
    return LiveComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      isPending: isPending ?? this.isPending,
      gifterLevel: gifterLevel ?? this.gifterLevel,
      gifterBadge: gifterBadge ?? this.gifterBadge,
      gifterLabel: gifterLabel ?? this.gifterLabel,
      gifterColor: gifterColor ?? this.gifterColor,
      gifterImageUrl: gifterImageUrl ?? this.gifterImageUrl,
      isSystem: isSystem,
      award: award,
      isModerator: isModerator,
    );
  }
}
