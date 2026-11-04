/// Nível do gifter (espectador) — espelha o payload do backend
/// `GET /live/gifts/me/level` do brawe-connect.
///
/// Fonte de verdade: `user_profiles.viewer_xp` + `gifter_level` no DB,
/// alimentado por:
///   +50 XP por gift enviado
///   +10 XP ao entrar numa live
///   +1  XP por minuto assistindo
///   +2  XP por mensagem no chat
///
/// Escala: 50 níveis (Visitante → Brawe Legend). Detalhes em
/// `brawe-connect/backend/app/services/gifter_level.py`.
class GifterLevel {
  final int level;
  final int xp;
  final GifterBadge badge;
  final NextLevelProgress? nextLevel;

  const GifterLevel({
    required this.level,
    required this.xp,
    required this.badge,
    this.nextLevel,
  });

  factory GifterLevel.fromJson(Map<String, dynamic> json) {
    return GifterLevel(
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      badge: GifterBadge.fromJson(
        (json['badge'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      nextLevel: json['next_level'] == null
          ? null
          : NextLevelProgress.fromJson(
              (json['next_level'] as Map).cast<String, dynamic>(),
            ),
    );
  }

  /// Estado neutro mostrado enquanto o request está em flight (não trava UI).
  factory GifterLevel.placeholder() => const GifterLevel(
        level: 1,
        xp: 0,
        badge: GifterBadge(label: 'Visitante', color: '#AAAAAA'),
        nextLevel: NextLevelProgress(
          nextLevel: 2,
          xpNeeded: 50,
          progressPct: 0,
          currentXp: 0,
          nextThreshold: 50,
        ),
      );
}

class GifterBadge {
  final String? emoji;
  final String label;
  final String color; // hex "#RRGGBB"
  final String? entryEffect; // "spark" | "shield" | "fire" | "galaxy" | "crown" | "epic" | null
  final String? imageUrl; // PNG do emblema da faixa (admin → Faixas)

  const GifterBadge({
    this.emoji,
    required this.label,
    required this.color,
    this.entryEffect,
    this.imageUrl,
  });

  factory GifterBadge.fromJson(Map<String, dynamic> json) {
    return GifterBadge(
      emoji: json['badge'] as String?,
      label: (json['label'] as String?) ?? 'Visitante',
      color: (json['color'] as String?) ?? '#AAAAAA',
      entryEffect: json['entry_effect'] as String?,
      imageUrl: (json['image_url'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['image_url'] as String).trim(),
    );
  }
}

class NextLevelProgress {
  final int nextLevel;
  final int xpNeeded;
  final double progressPct; // 0..100
  final int currentXp;
  final int nextThreshold;

  const NextLevelProgress({
    required this.nextLevel,
    required this.xpNeeded,
    required this.progressPct,
    required this.currentXp,
    required this.nextThreshold,
  });

  factory NextLevelProgress.fromJson(Map<String, dynamic> json) {
    return NextLevelProgress(
      nextLevel: (json['next_level'] as num?)?.toInt() ?? 2,
      xpNeeded: (json['xp_needed'] as num?)?.toInt() ?? 0,
      progressPct: (json['progress_pct'] as num?)?.toDouble() ?? 0,
      currentXp: (json['current_xp'] as num?)?.toInt() ?? 0,
      nextThreshold: (json['next_threshold'] as num?)?.toInt() ?? 0,
    );
  }

  /// 0..1 para uso direto em `FractionallySizedBox` / `LinearProgressIndicator`.
  double get progressFraction => (progressPct / 100).clamp(0.0, 1.0);
}
