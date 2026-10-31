import 'package:freezed_annotation/freezed_annotation.dart';

import 'gift_display_type.dart';

part 'live_gift.freezed.dart';
part 'live_gift.g.dart';

@freezed
sealed class LiveGift with _$LiveGift {
  const LiveGift._();

  const factory LiveGift({
    required String id,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    required String giftId,
    required String giftName,
    // Slug do gift (ex: "star", "rose") — usado para localizar o asset
    // Lottie local (`assets/lottie_test/<slug>.json`) antes de cair no
    // fallback remoto (`animationUrl`) ou no ícone estático PNG.
    String? giftSlug,
    String? giftIconUrl,
    String? animationUrl,
    String? animationType,
    @Default(false) bool isFullscreen,
    String? emoji,
    required int quantity,
    @Default(0) int value,
    required DateTime timestamp,
    // ─── Gifter level (chip estilo TikTok no toast) ───
    @Default(1) int gifterLevel,
    String? gifterBadge, // emoji do badge (⭐, ⚡, 🛡️, 🔥, 👑, 💎)
    String? gifterLabel, // "Fã", "Guardião", "Lenda", etc.
    String? gifterColor, // hex string ex. "#FFD700"
    String? gifterImageUrl, // PNG remoto do pin (CDN ou /static fallback)
    @Default(false) bool levelUpgraded,
    // 🎯 Lado da batalha que recebeu o gift (`'a'` esquerda, `'b'` direita).
    // `null` em lives solo. O toast do gift comum usa pra alinhar à lateral
    // certa do split-screen (lado A → bottom-left, lado B → bottom-right).
    // Gifts premium ignoram (mantêm burst central fullscreen).
    String? battleSide,
    // 🎬 Flag de animação: true enquanto a animação está rodando (3s),
    // false quando animação terminou mas notificação ainda está visível no chat (5s).
    // Garante fluxo TikTok: overlay → [3s] → chat notification.
    @Default(true) bool isAnimating,
    // ─── 🎯 Arquitetura profissional de exibição (4 modos) ───
    // Sempre vem RESOLVIDO do backend (nunca null em payloads novos —
    // ver `resolve_display_type()` no backend). Mantido nullable aqui
    // apenas para tolerar payloads antigos/incompletos (app antigo,
    // replay de evento histórico) — use [resolvedDisplayType] em vez de
    // ler este campo diretamente.
    String? displayType,
    // Prioridade visual na fila (0=chat, 10=center_small, 20=center_large,
    // 30=fullscreen). Usar [resolvedPriority] para ter o fallback certo.
    int? priority,
    @Default(true) bool showInChat,
    @Default(true) bool showSender,
    @Default(false) bool soundEnabled,
    // Som do efeito quando não é VAP (o .mp4 VAP já tem o áudio embutido).
    String? soundUrl,
    // Duração pretendida pelo backend (já validada/clampada lá, mas o
    // Flutter reclampa de novo via `resolvedDisplayType.clampDuration()`
    // como defesa em profundidade — nunca confiar só na rede).
    int? animationDurationMs,
  }) = _LiveGift;

  factory LiveGift.fromJson(Map<String, dynamic> json) =>
      _$LiveGiftFromJson(json);

  /// 🎯 Resolve o [GiftDisplayType] efetivo, com fallback retrocompatível.
  ///
  /// Prioridade:
  ///   1. `displayType` explícito, se presente e reconhecido.
  ///   2. Fallback legado baseado em `isFullscreen`:
  ///      - true  → fullscreen
  ///      - false → centerSmall (comportamento histórico do app antes
  ///        desta feature: presentes não-fullscreen sempre apareciam
  ///        como toast central, nunca "apenas chat").
  ///
  /// Isso garante que eventos antigos, presentes sem esse campo, ou apps
  /// mais antigos no ar durante o rollout NUNCA quebrem — sempre há um
  /// modo de exibição válido resolvido.
  GiftDisplayType get resolvedDisplayType {
    final parsed = GiftDisplayType.fromBackendValue(displayType);
    if (parsed != null) return parsed;
    return isFullscreen
        ? GiftDisplayType.fullscreen
        : GiftDisplayType.centerSmall;
  }

  /// Prioridade efetiva — usa o valor do backend se presente, senão cai
  /// no default do [resolvedDisplayType].
  int get resolvedPriority => priority ?? resolvedDisplayType.defaultPriority;

  /// Duração (ms) efetiva e SEMPRE dentro dos limites seguros do tipo
  /// resolvido — nunca confia ciegamente no valor da rede.
  int get resolvedDurationMs =>
      resolvedDisplayType.clampDuration(animationDurationMs);
}
