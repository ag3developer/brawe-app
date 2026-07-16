// =============================================================================
// 🎯 GIFT DISPLAY TYPE — Arquitetura profissional de exibição de presentes
// =============================================================================
// Substitui a decisão binária antiga (`isFullscreen` true/false) por 4
// níveis de impacto visual, alinhados com a experiência de plataformas de
// live consolidadas (TikTok Live, Bigo Live) — apenas como referência
// CONCEITUAL de hierarquia visual, SEM copiar identidade visual, layout
// literal, código, assets ou comportamento exclusivo dessas plataformas.
//
// Ver GIFT_DISPLAY_ARCHITECTURE_ANALYSIS.md e SVGA_NOT_SUPPORTED.md.
// =============================================================================

/// Classificação de exibição visual de um presente.
enum GiftDisplayType {
  /// Presente simples — aparece direto no chat (rosa, coração, aplauso).
  /// Não ocupa overlay de vídeo, não bloqueia nada.
  chat,

  /// Pequena animação central/lateral (estrela, borboleta, diamante).
  /// Não bloqueia chat nem controles.
  centerSmall,

  /// Animação central de maior impacto (foguete, carro, urso, galáxia).
  /// Prioridade maior que centerSmall — nunca dois centerLarge ao mesmo
  /// tempo.
  centerLarge,

  /// Presente épico — ocupa quase toda a tela (dragão, universo, tsunami).
  /// Nunca dois fullscreen simultâneos.
  fullscreen;

  /// Parse robusto a partir da string vinda do backend
  /// (`"chat"`, `"center_small"`, `"center_large"`, `"fullscreen"`).
  /// Retorna `null` se o valor for desconhecido/ausente — o CALLER decide
  /// o fallback (ver `LiveGift.resolvedDisplayType` para a lógica
  /// retrocompatível baseada em `isFullscreen`).
  static GiftDisplayType? fromBackendValue(String? value) {
    switch (value) {
      case 'chat':
        return GiftDisplayType.chat;
      case 'center_small':
        return GiftDisplayType.centerSmall;
      case 'center_large':
        return GiftDisplayType.centerLarge;
      case 'fullscreen':
        return GiftDisplayType.fullscreen;
      default:
        return null;
    }
  }

  /// Serializa de volta pro formato do backend (útil em logs/analytics).
  String get backendValue {
    switch (this) {
      case GiftDisplayType.chat:
        return 'chat';
      case GiftDisplayType.centerSmall:
        return 'center_small';
      case GiftDisplayType.centerLarge:
        return 'center_large';
      case GiftDisplayType.fullscreen:
        return 'fullscreen';
    }
  }

  /// Prioridade visual sugerida por tipo (usada na fila caso o backend
  /// não envie `priority` explicitamente). Mantém em sincronia com
  /// `DISPLAY_TYPE_DEFAULT_PRIORITY` no backend (app/models/gift.py).
  int get defaultPriority {
    switch (this) {
      case GiftDisplayType.chat:
        return 0;
      case GiftDisplayType.centerSmall:
        return 10;
      case GiftDisplayType.centerLarge:
        return 20;
      case GiftDisplayType.fullscreen:
        return 30;
    }
  }

  /// Limites seguros de duração (ms) por tipo — mesmo contrato do backend
  /// (`DISPLAY_TYPE_DURATION_LIMITS_MS`). Usado para clampar valores
  /// vindos da rede antes de aplicar no `AnimationController`, garantindo
  /// que o Flutter NUNCA confie ciegamente num valor de rede (defesa em
  /// profundidade — o backend já clampa, mas o cliente não deve depender
  /// disso sozinho).
  (int min, int max) get durationLimitsMs {
    switch (this) {
      case GiftDisplayType.chat:
        return (500, 2000);
      case GiftDisplayType.centerSmall:
        return (2000, 4000);
      case GiftDisplayType.centerLarge:
        return (4000, 7000);
      case GiftDisplayType.fullscreen:
        return (6000, 12000);
    }
  }

  /// Clampa `durationMs` dentro dos limites seguros deste tipo. Nunca
  /// permite negativo/zero — cai no piso mínimo se inválido.
  int clampDuration(int? durationMs) {
    final (min, max) = durationLimitsMs;
    if (durationMs == null || durationMs <= 0) return min;
    if (durationMs < min) return min;
    if (durationMs > max) return max;
    return durationMs;
  }

  /// Este tipo entra na fila visual principal (overlay)? `chat` NÃO
  /// entra — presentes simples vão direto pro chat, sem competir por
  /// espaço/tempo de tela com animações.
  bool get entersVisualQueue => this != GiftDisplayType.chat;

  /// Ocupa a tela inteira (bloqueia parcialmente a visão do vídeo)?
  bool get isFullscreen => this == GiftDisplayType.fullscreen;
}
