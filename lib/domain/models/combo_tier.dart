import 'gift_presentation.dart';

/// Predefinições do motor de partículas (contrato da Fase 3).
enum ParticlePreset {
  petals,
  hearts,
  confetti,
  sparks,
  stars,
  coins,
  bubbles,
  embers;

  /// Interpreta o nome do servidor; `null` se desconhecido.
  static ParticlePreset? parse(Object? v) {
    if (v is! String) return null;
    final key = v.trim().toLowerCase();
    for (final p in values) {
      if (p.name == key) return p;
    }
    return null;
  }
}

enum ComboEffectType {
  particles,
  lottie,
  vap;

  static ComboEffectType? parse(Object? v) => switch (v) {
    'particles' => particles,
    'lottie' => lottie,
    'vap' => vap,
    _ => null,
  };
}

/// Efeito de um degrau de combo (`gift_combo_tier.tier`). Nunca lança.
class ComboTierFx {
  const ComboTierFx({
    required this.type,
    this.preset,
    this.effectUrl,
    this.presentation,
    this.soundUrl,
    this.haptic = GiftHaptic.light,
    this.announce = false,
  });

  final ComboEffectType type;
  final ParticlePreset? preset;
  final String? effectUrl;
  final Map<String, dynamic>? presentation;
  final String? soundUrl;
  final GiftHaptic haptic;
  final bool announce;

  /// Padrão das partículas: tela cheia sob o chat, sem fundo.
  static const GiftPresentation particlesDefault = GiftPresentation(
    enter: GiftPhase(GiftTransition.fade, 200),
    exit: GiftPhase(GiftTransition.fade, 400),
    position: GiftPosition.full,
    scale: 0.8,
    layer: GiftLayer.underChat,
    backdrop: GiftBackdrop.none,
    backdropOpacity: 0.35,
    haptic: GiftHaptic.light,
    holdMs: 2500,
  );

  /// Encenação efetiva do degrau (receita do servidor sobre o padrão do tipo).
  GiftPresentation get resolvedPresentation {
    final base = type == ComboEffectType.particles
        ? particlesDefault.copyWith(haptic: haptic)
        : GiftPresentation.centerLargeDefault.copyWith(haptic: haptic);
    return GiftPresentation.parse(presentation, fallback: base);
  }

  /// `null` quando o payload não serve (tipo inválido, partículas sem
  /// preset conhecido, lottie/vap sem arquivo).
  static ComboTierFx? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final type = ComboEffectType.parse(raw['effect_type']);
    if (type == null) return null;
    final preset = ParticlePreset.parse(raw['particles']);
    final url = _str(raw['effect_url']);
    if (type == ComboEffectType.particles && preset == null) return null;
    if (type != ComboEffectType.particles && url == null) return null;
    return ComboTierFx(
      type: type,
      preset: preset,
      effectUrl: url,
      presentation: raw['presentation'] is Map
          ? Map<String, dynamic>.from(raw['presentation'] as Map)
          : null,
      soundUrl: _str(raw['sound_url']),
      haptic: GiftHaptic.parse(raw['haptic']) ?? GiftHaptic.light,
      announce: raw['announce'] == true,
    );
  }

  static String? _str(Object? v) {
    final s = v?.toString().trim();
    return s == null || s.isEmpty || s == 'null' ? null : s;
  }
}

/// Evento `gift_combo_tier`: todos na sala veem o mesmo degrau.
class ComboTierEvent {
  const ComboTierEvent({
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.giftSlug,
    required this.count,
    required this.at,
    required this.tier,
    this.nextAt,
    this.giftName,
    this.senderAvatar,
  });

  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String giftSlug;
  final String? giftName;
  final int count;
  final int at;
  final int? nextAt;
  final ComboTierFx tier;

  /// Chave do combo (remetente + presente), igual à do contador do servidor.
  String get comboKey => '$senderId::$giftSlug';

  static ComboTierEvent? tryParse(Map<String, dynamic> d) {
    final tier = ComboTierFx.tryParse(d['tier']);
    final at = int.tryParse('${d['at']}');
    if (tier == null || at == null) return null;
    return ComboTierEvent(
      roomId: d['room_id']?.toString() ?? '',
      senderId: d['sender_id']?.toString() ?? '',
      senderName: d['sender_name']?.toString() ?? '',
      senderAvatar: d['sender_avatar']?.toString(),
      giftSlug: d['gift_slug']?.toString() ?? '',
      giftName: d['gift_name']?.toString(),
      count: int.tryParse('${d['count']}') ?? at,
      at: at,
      nextAt: int.tryParse('${d['next_at']}'),
      tier: tier,
    );
  }
}

/// Lógica pura do combo (espelho do cliente, só para exibição).
class ComboMath {
  ComboMath._();

  /// Degrau cruzado ao ir de [oldCount] para [newCount]: o MAIOR `at` com
  /// `old < at <= new`, ou `null`. [ats] precisa estar em ordem crescente.
  static int? crossedTier(List<int> ats, int oldCount, int newCount) {
    int? hit;
    for (final at in ats) {
      if (oldCount < at && at <= newCount) hit = at;
    }
    return hit;
  }

  /// Próximo degrau acima de [count], ou `null`.
  static int? nextTier(List<int> ats, int count) {
    for (final at in ats) {
      if (at > count) return at;
    }
    return null;
  }

  /// Fração 0..1 do caminho até [nextAt], partindo do degrau [prevAt]
  /// (0 se ainda não passou por nenhum).
  static double progress(int count, int nextAt, {int prevAt = 0}) {
    final span = nextAt - prevAt;
    if (span <= 0) return 1;
    return ((count - prevAt) / span).clamp(0.0, 1.0).toDouble();
  }

  /// Texto da barra: "×37 · faltam 13". Sem próximo degrau (ou já
  /// atingido) mostra só o contador.
  static String progressText(int count, int? nextAt) {
    if (nextAt == null || nextAt <= count) return '×$count';
    final left = nextAt - count;
    return '×$count · ${left == 1 ? 'falta 1' : 'faltam $left'}';
  }

  /// Contagem a exibir: a do servidor quando presente, senão a local.
  static int displayCount({int? serverCount, required int localCount}) =>
      serverCount != null && serverCount > 0 ? serverCount : localCount;
}
