import 'package:flutter/material.dart';

import '../../../../../domain/models/live_gift.dart';
import '../../../../../gen/l10n/app_localizations.dart';

/// Linha do chat representando um presente enviado — estilo TikTok.
///
/// Pill com gradiente dourado, avatar do remetente, `fulano enviou
/// gift_name` e contador `xN` quando aplicável. Aparece na mesma timeline
/// do chat, não numa coluna separada.
class GiftChatLine extends StatelessWidget {
  const GiftChatLine({super.key, required this.gift});
  final LiveGift gift;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final hasAvatar =
        gift.senderAvatarUrl != null && gift.senderAvatarUrl!.isNotEmpty;
    final initial = gift.senderName.isNotEmpty
        ? gift.senderName.characters.first.toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xE6FFB23A), Color(0xE6FF4D8B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: const Color(0xFFFFD166),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66FFD166),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar do remetente
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            // Nome + "enviou" + nome do presente
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: gift.senderName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(text: s.livePlayerGiftSentVerb),
                    TextSpan(
                      text: gift.giftName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Ícone do gift
            SizedBox(
              width: 24,
              height: 24,
              child: gift.giftIconUrl != null && gift.giftIconUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        gift.giftIconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
            if (gift.quantity > 1) ...[
              const SizedBox(width: 4),
              Text(
                'x${gift.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
