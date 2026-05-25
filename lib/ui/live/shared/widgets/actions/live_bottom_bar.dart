import 'package:flutter/material.dart';

/// Bottom bar da live no estilo TikTok Live (TELA DO ESPECTADOR):
///
/// - Linha 1: chat input full-width TRANSPARENTE (mesmo "peso visual" do
///   ChatTicker — sem caixa glass, só texto sobre o vídeo com sombra para
///   legibilidade).
/// - Linha 2: ações flutuantes (Presentes · Curtir · Rosa · [Loja] ·
///   Compartilhar) — "Loja" só aparece quando `hasStorefront=true`.
///
/// 🌹 O botão "Rosa" envia 1 rosa direto como presente (atalho rápido,
/// sem abrir o catálogo). Substituiu o antigo "Seguir" — o follow agora
/// vive só na `StreamerIdentityBar` no topo.
///
/// ⚠️ `likesCount` é mantido no contrato por compat — hoje não é usado
/// na UI, mas pode voltar quando o contador inline for reativado.
class LiveBottomBar extends StatelessWidget {
  const LiveBottomBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.isLiked,
    required this.likesCount,
    required this.onSend,
    required this.onSendRose,
    required this.onGifts,
    required this.onLike,
    this.onShare,
    required this.onSeguir,
    required this.onShop,
    required this.hasStorefront,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final bool isLiked;
  final int likesCount;
  final VoidCallback onSend;
  final VoidCallback onSendRose;
  final VoidCallback onGifts;
  final VoidCallback onLike;
  /// Mantido opcional para callers legados; hoje o botão "Compartilhar" foi
  /// removido do bottom bar (confundia com "enviar mensagem"). Acessível
  /// pelo sheet do streamer.
  final VoidCallback? onShare;
  final VoidCallback onSeguir;
  final VoidCallback onShop;
  final bool hasStorefront;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Chat input full-width — TRANSPARENTE (TikTok-style) ──
        // Sem BackdropFilter / sem container glass. O input flutua sobre
        // o vídeo igual aos comentários do `ChatTicker` — só borda fina
        // translúcida pra delimitar a zona de toque, e sombras no texto
        // para legibilidade. Visual minimalista, sem "barra cortando" o
        // frame.
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Diga algo...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 13),
                  ),
                ),
              ),
              // Emoji / send (alterna)
              GestureDetector(
                onTap: () {
                  if (controller.text.trim().isEmpty) {
                    // TODO: abrir emoji picker
                  } else {
                    onSend();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                  child: Icon(
                    controller.text.trim().isEmpty
                        ? Icons.emoji_emotions_outlined
                        : Icons.send_rounded,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 22,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // ─── Floating actions: Presentes · Curtir · Seguir · [Loja] · Mais
        // O botão "Loja" só aparece quando o criador tem vitrine ativa.
        // TODO(backend): expor `hasStorefront` na LiveRoom e usar aqui.
        // Por enquanto, mantemos escondido (mais limpo que mostrar vazio).
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LiveActionButton(
              icon: Icons.card_giftcard_rounded,
              label: 'Presentes',
              filled: true,
              onTap: onGifts,
            ),
            _LiveActionButton(
              icon: isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: 'Curtir',
              iconColor: isLiked ? const Color(0xFFFF3D6E) : Colors.white,
              onTap: onLike,
            ),
            // 🌹 Rosa rápida — envia 1 rosa direto como presente.
            // Substituiu o antigo "Seguir" (que vivia duplicado aqui +
            // na StreamerIdentityBar do topo). Atalho fast-tap, sem
            // abrir o catálogo. Visual: emoji rosa sobre o círculo
            // outlined padrão.
            _LiveActionButton(
              icon: Icons.local_florist_rounded, // fallback (não usado — emoji override)
              emoji: '🌹',
              label: 'Rosa',
              onTap: onSendRose,
            ),
            if (hasStorefront)
              _LiveActionButton(
                icon: Icons.shopping_bag_outlined,
                label: 'Loja',
                onTap: onShop,
              ),
            // 🗑 "Compartilhar" foi removido do bottom bar: o ícone de
            // avião era confundido com "enviar mensagem" (mesmo glifo do
            // input de chat acima). Compartilhamento externo continua
            // acessível pelo sheet do streamer (StreamerIdentityBar).
          ],
        ),
      ],
    );
  }
}

/// Botão circular outlined com label embaixo (estilo do mockup).
/// `filled=true` aplica o gradient rosa→roxo (usado em "Presentes").
///
/// Privado: uso interno do `LiveBottomBar`.
class _LiveActionButton extends StatelessWidget {
  const _LiveActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.iconColor = Colors.white,
    this.emoji,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color iconColor;
  /// Se fornecido, renderiza este emoji no lugar do `icon` (usado pra rosa).
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    const double size = 38;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: filled
                  ? const LinearGradient(
                      colors: [Color(0xFFFF4F8B), Color(0xFFB44CF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: filled ? null : Colors.transparent,
              border: filled
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFFB44CF0).withValues(alpha: 0.40),
                        blurRadius: 14,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: emoji != null
                ? Center(
                    child: Text(
                      emoji!,
                      style: const TextStyle(fontSize: 20, height: 1.0),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
