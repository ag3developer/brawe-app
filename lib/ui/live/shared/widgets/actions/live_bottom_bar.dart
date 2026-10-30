import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/themes/app_colors.dart';

/// Bottom bar da live no estilo TikTok Live (TELA DO ESPECTADOR):
///
/// **Linha ÚNICA** (clean): chat input flexível à esquerda + ações flat
/// à direita (Curtir · Rosa · Presente · [Loja]). Tudo numa faixa de ~52dp.
///
/// 🌹 O botão "Rosa" envia 1 rosa direto como presente (atalho rápido,
/// sem abrir o catálogo). O follow vive na `StreamerIdentityBar` no topo.
///
/// ⌨️ Enquanto o input tem foco as ações somem e o campo ocupa a linha
/// inteira (TikTok). Tocar fora da barra fecha o teclado.
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

  /// Limite de caracteres por mensagem do chat da live (padrão TikTok).
  static const maxMessageLength = 150;

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => focusNode.unfocus(),
      child: ListenableBuilder(
        listenable: focusNode,
        builder: (context, _) => _buildRow(typing: focusNode.hasFocus),
      ),
    );
  }

  Widget _buildRow({required bool typing}) {
    // ─── Linha ÚNICA (TikTok clean) ───
    // Input flexível à esquerda + ações flat à direita, tudo numa única
    // faixa horizontal de ~52dp. Antes eram 2 linhas (input + fileira de
    // círculos grandes) que "pesavam" a tela. Os ícones agora são flat,
    // sem círculo preenchido, com label minúsculo — respiro visual.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── Chat input (encolhe para dar espaço às ações) ───
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
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
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: maxMessageLength,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    // Mantém o teclado aberto no "enviar" do teclado — quem
                    // decide fechar é o `onSend` (fecha após enviar).
                    onSubmitted: (_) => onSend(),
                    onEditingComplete: () {},
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Comentar...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      // Contador só aparece perto do limite.
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                    ),
                  ),
                ),
                // Emoji / send (alterna) — ValueListenableBuilder escuta SÓ o
                // controller, então só o ícone reconstrói quando o texto muda
                // (não a barra inteira). Build leve + troca suave.
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, child) {
                    final hasText = value.text.trim().isNotEmpty;
                    final remaining = maxMessageLength - value.text.length;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (remaining <= 20)
                          Text(
                            '$remaining',
                            style: TextStyle(
                              color: remaining <= 5
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        GestureDetector(
                          // Sem texto: tocar no ícone abre o teclado.
                          onTap: hasText ? onSend : focusNode.requestFocus,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                hasText
                                    ? Icons.send_rounded
                                    : Icons.chat_bubble_outline_rounded,
                                key: ValueKey(hasText),
                                color: hasText
                                    ? AppColors.braweBlueLight
                                    : Colors.white.withValues(alpha: 0.85),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // ─── Ações flat (sem círculo preenchido) — clean TikTok ───
        // Ordem: Curtir · Rosa · Presente · [Loja]. Escondidas enquanto
        // digita: o input ganha a linha inteira.
        if (!typing) ...[
          const SizedBox(width: 6),
          _LiveActionButton(
            icon: isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: 'Curtir',
            iconColor: isLiked ? const Color(0xFFFF3D6E) : Colors.white,
            onTap: onLike,
          ),
          // 🌹 Rosa rápida — envia 1 rosa direto como presente (fast-tap).
          _LiveActionButton(
            icon: Icons.local_florist_rounded, // fallback (emoji override)
            emoji: '🌹',
            label: 'Rosa',
            onTap: onSendRose,
          ),
          // 🎁 Presentes — abre o catálogo. Ícone laranja de marca (sutil destaque).
          _LiveActionButton(
            icon: Icons.card_giftcard_rounded,
            label: 'Presente',
            iconColor: AppColors.braweOrange,
            onTap: onGifts,
          ),
          if (hasStorefront)
            _LiveActionButton(
              icon: Icons.shopping_bag_outlined,
              label: 'Loja',
              onTap: onShop,
            ),
        ],
      ],
    );
  }
}

/// Botão de ação FLAT compacto (estilo TikTok clean): ícone pequeno sem
/// círculo preenchido + label minúsculo embaixo. Otimizado para caber na
/// barra de linha única.
///
/// Privado: uso interno do `LiveBottomBar`.
class _LiveActionButton extends StatelessWidget {
  const _LiveActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
    this.emoji,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  /// Se fornecido, renderiza este emoji no lugar do `icon` (usado pra rosa).
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 26,
              child: Center(
                child: emoji != null
                    ? Text(
                        emoji!,
                        style: const TextStyle(fontSize: 22, height: 1.0),
                      )
                    : Icon(
                        icon,
                        color: iconColor,
                        size: 25,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
