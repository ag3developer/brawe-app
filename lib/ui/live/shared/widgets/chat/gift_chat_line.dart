import 'package:flutter/material.dart';

import '../../../../../domain/models/live_gift.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/app_colors.dart';

/// Linha do chat representando um presente enviado — estilo TikTok MINIMALISTA.
///
/// ✅ NOVO: Avatar pequeno (20px) + nome + "enviou" + presente com ícone,
/// sem fundo colorido. Apenas sombra para legibilidade (igual ChatLine).
/// Aparece na mesma timeline do chat, não numa coluna separada.
class GiftChatLine extends StatelessWidget {
  const GiftChatLine({super.key, required this.gift});
  final LiveGift gift;

  /// 🎁 Emoji de fallback por nome do presente — usado quando não há
  /// `giftIconUrl` (ou falha o load), pra não cair no ícone genérico
  /// de "caixinha" (Icons.card_giftcard) que não representa o presente.
  /// Espelha `_giftEmoji` de `gift_animation_overlay.dart`.
  static String _giftEmoji(String giftName) {
    final n = giftName.toLowerCase();
    if (n.contains('rose') || n.contains('rosa')) return '🌹';
    if (n.contains('heart') || n.contains('coração')) return '❤️';
    if (n.contains('star') || n.contains('estrela')) return '⭐';
    if (n.contains('fire') || n.contains('fogo')) return '🔥';
    if (n.contains('crown') || n.contains('coroa')) return '👑';
    if (n.contains('diamond') || n.contains('diamante')) return '💎';
    if (n.contains('kiss') || n.contains('beijo')) return '💋';
    if (n.contains('money') || n.contains('dinheiro')) return '💰';
    if (n.contains('unicorn') || n.contains('unicórnio')) return '🦄';
    if (n.contains('rocket') || n.contains('foguete')) return '🚀';
    if (n.contains('bomb') || n.contains('bomba')) return '💣';
    if (n.contains('butterfly') || n.contains('borboleta')) return '🦋';
    return '🎁';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final hasAvatar =
        gift.senderAvatarUrl != null && gift.senderAvatarUrl!.isNotEmpty;
    final initial = gift.senderName.isNotEmpty
        ? gift.senderName.characters.first.toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // ✨ +3px (era 5px)
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pequeno (20px) — igual ChatLine
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2), // ✨ +1px (era 1px)

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.braweBlue,
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(gift.senderAvatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: hasAvatar
                ? null
                : Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          // Nome + "enviou" + presente + ícone (sombra apenas)
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35, // ✨ +0.10 line-height (era 1.25)
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        children: [
                          TextSpan(
                            text: '${gift.senderName} ',
                            style: const TextStyle(
                              color: AppColors.braweBlueSoft,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                          TextSpan(
                            text: s.livePlayerGiftSentVerb,
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: ' ${gift.giftName}',
                            style: const TextStyle(
                              color: Color(
                                0xFFFFD700,
                              ), // ✨ Ouro destaca (premium!)
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Ícone do gift (pequeno) — emoji correspondente ao
                  // presente como fallback (nunca a caixinha genérica).
                  SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        gift.giftIconUrl != null && gift.giftIconUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.network(
                              gift.giftIconUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  _giftEmoji(gift.giftName),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              _giftEmoji(gift.giftName),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                  ),
                  // Quantidade se > 1
                  if (gift.quantity > 1) ...[
                    const SizedBox(width: 3),
                    Text(
                      'x${gift.quantity}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
