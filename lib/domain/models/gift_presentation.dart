import 'dart:convert';

/// Encenação ("presentation") de um presente — contrato v1.
///
/// Receita enviada pelo servidor por presente (`gift_received.presentation`).
/// Valores desconhecidos ou ausentes caem SEMPRE no padrão; números são
/// limitados às faixas do contrato. Nunca lança exceção.

enum GiftTransition {
  none,
  fade,
  zoom,
  rise,
  drop,
  slideLeft,
  slideRight,
  dawn,
  curtain;

  static GiftTransition? parse(Object? v) => switch (v) {
    'none' => none,
    'fade' => fade,
    'zoom' => zoom,
    'rise' => rise,
    'drop' => drop,
    'slide_left' => slideLeft,
    'slide_right' => slideRight,
    'dawn' => dawn,
    'curtain' => curtain,
    _ => null,
  };
}

enum GiftPosition {
  center,
  top,
  bottom,
  full;

  static GiftPosition? parse(Object? v) => switch (v) {
    'center' => center,
    'top' => top,
    'bottom' => bottom,
    'full' => full,
    _ => null,
  };
}

enum GiftLayer {
  overChat,
  underChat;

  static GiftLayer? parse(Object? v) => switch (v) {
    'over_chat' => overChat,
    'under_chat' => underChat,
    _ => null,
  };
}

enum GiftBackdrop {
  none,
  darken,
  lighten,
  dawn;

  static GiftBackdrop? parse(Object? v) => switch (v) {
    'none' => none,
    'darken' => darken,
    'lighten' => lighten,
    'dawn' => dawn,
    _ => null,
  };
}

enum GiftHaptic {
  none,
  light,
  medium,
  heavy;

  static GiftHaptic? parse(Object? v) => switch (v) {
    'none' => none,
    'light' => light,
    'medium' => medium,
    'heavy' => heavy,
    _ => null,
  };
}

class GiftPhase {
  const GiftPhase(this.type, this.ms);

  final GiftTransition type;
  final int ms;

  /// Duração efetiva: sem transição não há o que animar.
  int get effectiveMs => type == GiftTransition.none ? 0 : ms;

  @override
  bool operator ==(Object other) =>
      other is GiftPhase && other.type == type && other.ms == ms;

  @override
  int get hashCode => Object.hash(type, ms);

  @override
  String toString() => '${type.name}/${ms}ms';
}

class GiftPresentation {
  const GiftPresentation({
    required this.enter,
    required this.exit,
    required this.position,
    required this.scale,
    required this.layer,
    required this.backdrop,
    required this.backdropOpacity,
    required this.haptic,
    this.holdMs,
  });

  final GiftPhase enter;
  final GiftPhase exit;
  final GiftPosition position;

  /// Fração da largura da tela (0.4–1.0). Ignorada em [GiftPosition.full].
  final double scale;
  final GiftLayer layer;
  final GiftBackdrop backdrop;

  /// 0–0.8.
  final double backdropOpacity;
  final GiftHaptic haptic;

  /// `null` = vídeo VAP até o fim / `animation_duration_ms` nos demais.
  /// Senão 1000–15000.
  final int? holdMs;

  static const int minMs = 0;
  static const int maxMs = 2000;
  static const double minScale = 0.4;
  static const double maxScale = 1.0;
  static const double maxBackdropOpacity = 0.8;
  static const int minHoldMs = 1000;
  static const int maxHoldMs = 15000;

  /// Padrão do `center_large` (visual de hoje).
  static const GiftPresentation centerLargeDefault = GiftPresentation(
    enter: GiftPhase(GiftTransition.zoom, 450),
    exit: GiftPhase(GiftTransition.fade, 350),
    position: GiftPosition.center,
    scale: 0.7,
    layer: GiftLayer.overChat,
    backdrop: GiftBackdrop.none,
    backdropOpacity: 0.35,
    haptic: GiftHaptic.medium,
  );

  /// Padrão do `fullscreen` e de todos os vídeos VAP.
  static const GiftPresentation fullscreenDefault = GiftPresentation(
    enter: GiftPhase(GiftTransition.fade, 300),
    exit: GiftPhase(GiftTransition.fade, 400),
    position: GiftPosition.full,
    scale: 0.8,
    layer: GiftLayer.overChat,
    backdrop: GiftBackdrop.darken,
    backdropOpacity: 0.25,
    haptic: GiftHaptic.heavy,
  );

  /// Padrão dos efeitos de entrada de viewer (Fase 1 — níveis).
  static const GiftPresentation entranceDefault = GiftPresentation(
    enter: GiftPhase(GiftTransition.slideLeft, 400),
    exit: GiftPhase(GiftTransition.fade, 300),
    position: GiftPosition.center,
    scale: 0.6,
    layer: GiftLayer.underChat,
    backdrop: GiftBackdrop.none,
    backdropOpacity: 0.35,
    haptic: GiftHaptic.light,
  );

  /// Padrão conforme o visual. [haptic] é o padrão por nível do presente.
  static GiftPresentation defaultsFor({
    required bool fullscreenLook,
    GiftHaptic? haptic,
  }) {
    final base = fullscreenLook ? fullscreenDefault : centerLargeDefault;
    return haptic == null ? base : base.copyWith(haptic: haptic);
  }

  /// Interpreta a receita do servidor. [raw] pode ser `Map`, texto JSON ou
  /// `null`. Qualquer campo inválido/ausente usa o de [fallback].
  static GiftPresentation parse(Object? raw, {required GiftPresentation fallback}) {
    Object? data = raw;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        return fallback;
      }
    }
    if (data is! Map) return fallback;

    try {
      return GiftPresentation(
        enter: _phase(data['enter'], fallback.enter),
        exit: _phase(data['exit'], fallback.exit),
        position: GiftPosition.parse(data['position']) ?? fallback.position,
        scale: _num(data['scale'])?.clamp(minScale, maxScale).toDouble() ??
            fallback.scale,
        layer: GiftLayer.parse(data['layer']) ?? fallback.layer,
        backdrop: GiftBackdrop.parse(data['backdrop']) ?? fallback.backdrop,
        backdropOpacity: _num(data['backdrop_opacity'])
                ?.clamp(0.0, maxBackdropOpacity)
                .toDouble() ??
            fallback.backdropOpacity,
        haptic: GiftHaptic.parse(data['haptic']) ?? fallback.haptic,
        holdMs: _num(data['hold_ms'])?.round().clamp(minHoldMs, maxHoldMs),
      );
    } catch (_) {
      return fallback;
    }
  }

  static GiftPhase _phase(Object? v, GiftPhase fallback) {
    if (v is! Map) return fallback;
    return GiftPhase(
      GiftTransition.parse(v['type']) ?? fallback.type,
      _num(v['ms'])?.round().clamp(minMs, maxMs) ?? fallback.ms,
    );
  }

  static num? _num(Object? v) {
    if (v is num) return v.isFinite ? v : null;
    if (v is String) {
      final n = num.tryParse(v);
      return n != null && n.isFinite ? n : null;
    }
    return null;
  }

  GiftPresentation copyWith({GiftHaptic? haptic}) => GiftPresentation(
    enter: enter,
    exit: exit,
    position: position,
    scale: scale,
    layer: layer,
    backdrop: backdrop,
    backdropOpacity: backdropOpacity,
    haptic: haptic ?? this.haptic,
    holdMs: holdMs,
  );

  @override
  bool operator ==(Object other) =>
      other is GiftPresentation &&
      other.enter == enter &&
      other.exit == exit &&
      other.position == position &&
      other.scale == scale &&
      other.layer == layer &&
      other.backdrop == backdrop &&
      other.backdropOpacity == backdropOpacity &&
      other.haptic == haptic &&
      other.holdMs == holdMs;

  @override
  int get hashCode => Object.hash(enter, exit, position, scale, layer,
      backdrop, backdropOpacity, haptic, holdMs);
}
