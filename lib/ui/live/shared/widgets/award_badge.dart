import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/remote_config/remote_flags.dart';
import '../../../../domain/models/user_award.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Cor `#RRGGBB` -> [Color]; [fallback] se inválida.
Color awardColor(String? hex, [Color fallback = const Color(0xFFFFB800)]) {
  if (hex == null) return fallback;
  final c = hex.replaceAll('#', '').trim();
  if (c.length != 6) return fallback;
  final v = int.tryParse('FF$c', radix: 16);
  return v == null ? fallback : Color(v);
}

/// Selo do prêmio ativo, ao lado do [LevelChip] (chat, combo, entrada).
/// Sem imagem cai num ícone Lucide na cor do prêmio. Quadrado pequeno: o
/// texto do prêmio fica só no perfil.
class AwardBadge extends StatelessWidget {
  const AwardBadge({super.key, required this.award, this.height = 16});

  final UserAward award;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Interruptor remoto (`feature_awards`): esconde o selo em todo lugar.
    if (!RemoteFlags.current.featureAwards) return const SizedBox.shrink();
    final color = awardColor(award.badgeColor);
    final url = award.badgeImageUrl;
    final fallback = Icon(LucideIcons.award, size: height * 0.66, color: Colors.white);
    return Container(
      width: height,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.6),
      ),
      child: url == null
          ? fallback
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                width: height - 2,
                height: height - 2,
                fit: BoxFit.cover,
                memCacheWidth: context.decodePx(height),
                fadeInDuration: Duration.zero,
                errorWidget: (_, _, _) => fallback,
                placeholder: (_, _) => fallback,
              ),
            ),
    );
  }
}

/// Moldura de avatar: UMA imagem em cache sobre o avatar (centro
/// transparente). Sem [frameUrl] devolve o [child] intacto.
class AvatarFrame extends StatelessWidget {
  const AvatarFrame({
    super.key,
    required this.child,
    required this.size,
    this.frameUrl,
    this.overflow = 0.2,
  });

  final Widget child;
  final double size;
  final String? frameUrl;

  /// Quanto a moldura ultrapassa o avatar (fração do tamanho).
  final double overflow;

  @override
  Widget build(BuildContext context) {
    final url = frameUrl;
    if (url == null || url.isEmpty || !RemoteFlags.current.featureAwards) {
      return child;
    }
    final framed = size * (1 + overflow * 2);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          child,
          Positioned(
            left: -size * overflow,
            top: -size * overflow,
            width: framed,
            height: framed,
            child: IgnorePointer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                memCacheWidth: context.decodePx(framed),
                fadeInDuration: Duration.zero,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
                placeholder: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
