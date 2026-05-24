import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Bottom bar da live no estilo TikTok Live:
///
/// - Linha 1: chat input full-width (glass) com ícone emoji/send no canto.
/// - Linha 2: ações flutuantes (Presentes · Curtir · Seguir · [Loja] ·
///   Compartilhar) — "Loja" só aparece quando `hasStorefront=true`.
///
/// ⚠️ `onSendRose` e `likesCount` são mantidos no contrato por compat —
/// hoje não são usados na UI, mas podem voltar quando a feature de
/// "rosa rápida" e contador inline forem reativadas.
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
    required this.onShare,
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
  final VoidCallback onShare;
  final VoidCallback onSeguir;
  final VoidCallback onShop;
  final bool hasStorefront;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Chat input full-width com 😊 dentro ────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 0.6,
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
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Diga algo...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.50),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
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
                        color: Colors.white.withValues(alpha: 0.55),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            _LiveActionButton(
              icon: Icons.person_add_alt_1_outlined,
              label: 'Seguir',
              onTap: onSeguir,
            ),
            if (hasStorefront)
              _LiveActionButton(
                icon: Icons.shopping_bag_outlined,
                label: 'Loja',
                onTap: onShop,
              ),
            _LiveActionButton(
              icon: Icons.send_rounded,
              label: 'Compartilhar',
              onTap: onShare,
            ),
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
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color iconColor;

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
            child: Icon(icon, color: iconColor, size: 19),
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
