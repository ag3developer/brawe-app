
import 'package:flutter/widgets.dart';

// ─── Constantes compartilhadas (BATTLE_V2_CONTRACT §1) ─────────────────────
// Frame de vídeo da composição enviado ao Mux: 720×1280 (9:16, 30 fps).
const double kBattleFrameW = 720;
const double kBattleFrameH = 1280;

/// Faixa superior (HUD): y 0..208.
const double kBattleSplitTop = 208;

/// Faixa dividida: y 208..784 (A à esquerda, B à direita).
const double kBattleSplitH = 576;

/// Divisor central, em pixels do frame (x 358..362).
const double kBattleDividerW = 4;

/// Largura de cada metade no frame (358).
const double kBattleHalfW = (kBattleFrameW - kBattleDividerW) / 2;

/// Posições (em coordenadas da tela) das faixas da batalha. Usado pelo
/// espectador e pelo criador, nos modos `composite` e `dual_hls`.
///
/// A faixa dividida do frame (y 208..784) é ancorada em [splitTop]; o topo
/// do frame (fundo `#0B0F1A`, 208 px) fica por baixo da barra superior/linha
/// de eventos do app, que são opacas — por isso o frame pode começar "acima"
/// do `splitTop` sem cortar nada visível. A barra de vantagem (com os pontos
/// dentro, [stripH] px) é desenhada pelo app sobre o topo da faixa dividida.
@immutable
class BattleLayout {
  const BattleLayout._({
    required this.screen,
    required this.scale,
    required this.frame,
    required this.strip,
    required this.split,
    required this.halfA,
    required this.halfB,
    required this.divider,
    required this.chat,
  });

  /// [splitTop]: Y (na tela) onde começa a faixa dividida.
  /// [minChat]: altura mínima reservada abaixo da faixa dividida (chat,
  /// avisos e barra de ações); se faltar, a escala diminui.
  factory BattleLayout.compute({
    required Size screen,
    required double splitTop,
    double stripH = 24,
    double minChat = 250,
  }) {
    final byWidth = screen.width / kBattleFrameW;
    final byHeight = (screen.height - splitTop - minChat) / kBattleSplitH;
    final scale = byHeight < byWidth
        ? byHeight.clamp(0.2, byWidth).toDouble()
        : byWidth;
    final fw = kBattleFrameW * scale;
    final fh = kBattleFrameH * scale;
    final left = (screen.width - fw) / 2;
    final frame = Rect.fromLTWH(left, splitTop - kBattleSplitTop * scale, fw, fh);
    // A barra de vantagem fica COLADA no topo da faixa dividida (sobre ela).
    final strip = Rect.fromLTWH(left, splitTop, fw, stripH);
    final splitH = kBattleSplitH * scale;
    final split = Rect.fromLTWH(left, splitTop, fw, splitH);
    final halfW = kBattleHalfW * scale;
    final halfA = Rect.fromLTWH(left, splitTop, halfW, splitH);
    final halfB = Rect.fromLTWH(
      left + (kBattleHalfW + kBattleDividerW) * scale,
      splitTop,
      halfW,
      splitH,
    );
    final divider = Rect.fromLTWH(
      left + kBattleHalfW * scale,
      splitTop,
      kBattleDividerW * scale,
      splitH,
    );
    final chat = Rect.fromLTRB(0, split.bottom, screen.width, screen.height);
    return BattleLayout._(
      screen: screen,
      scale: scale,
      frame: frame,
      strip: strip,
      split: split,
      halfA: halfA,
      halfB: halfB,
      divider: divider,
      chat: chat,
    );
  }

  final Size screen;
  final double scale;

  /// Retângulo do frame 720×1280 na tela (pode passar do topo da tela).
  final Rect frame;

  /// Faixa do HUD (placar/cronômetro/barra de vantagem).
  final Rect strip;

  /// Faixa dividida (vídeo dos dois lados).
  final Rect split;
  final Rect halfA;
  final Rect halfB;
  final Rect divider;

  /// Região inferior (chat, avisos e ações), até o fim da tela.
  final Rect chat;

  Rect half(String side) => side == 'b' ? halfB : halfA;

  @override
  bool operator ==(Object other) =>
      other is BattleLayout && other.screen == screen && other.frame == frame;

  @override
  int get hashCode => Object.hash(screen, frame);
}

/// Áreas das metades que os efeitos de presente da batalha devem usar
/// (publicado pelo HUD enquanto há batalha; `null` fora dela).
class BattleGiftRegions {
  const BattleGiftRegions({
    required this.halfA,
    required this.halfB,
    required this.chat,
  });
  final Rect halfA;
  final Rect halfB;

  /// Região de baixo (efeitos de entrada VIP, combos de degrau).
  final Rect chat;

  Rect? half(String? side) => side == 'a'
      ? halfA
      : side == 'b'
      ? halfB
      : null;

  static final ValueNotifier<BattleGiftRegions?> current =
      ValueNotifier<BattleGiftRegions?>(null);

  /// Publica as áreas (sem notificar à toa se nada mudou).
  static void publish(BattleLayout layout) {
    final next = BattleGiftRegions(
      halfA: layout.halfA,
      halfB: layout.halfB,
      chat: layout.chat,
    );
    final cur = current.value;
    if (cur != null &&
        cur.halfA == next.halfA &&
        cur.halfB == next.halfB &&
        cur.chat == next.chat) {
      return;
    }
    current.value = next;
  }

  static void clear() {
    if (current.value != null) current.value = null;
  }
}

/// Confina [child] (efeitos que dependem de `MediaQuery.size`) a [rect]:
/// o efeito se comporta como se a tela fosse só aquela região.
Widget battleRegionWrap(BuildContext context, Rect rect, Widget child) {
  final mq = MediaQuery.of(context);
  return Positioned.fromRect(
    rect: rect,
    child: ClipRect(
      child: MediaQuery(
        data: mq.copyWith(
          size: rect.size,
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
        ),
        child: child,
      ),
    ),
  );
}
