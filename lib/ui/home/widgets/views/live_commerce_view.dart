import 'package:flutter/material.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../../domain/models/live_room.dart';
import '../../../../domain/models/product.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import 'shared/_live_peek.dart';
import 'products_drawer.dart';

/// 🛍️ View para LiveCommerceItem — thumbnail + produto em destaque + botão de carrinho.
class LiveCommerceView extends StatelessWidget {
  const LiveCommerceView({super.key, required this.item, this.isActive = true});
  final LiveCommerceItem item;
  final bool isActive;

  Product get _featured => item.products.firstWhere(
    (p) => p.id == item.featuredProductId,
    orElse: () => item.products.first,
  );

  void _openCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ProductsDrawer(products: item.products, author: item.author),
    );
  }

  void _enter(BuildContext context) {
    final room = LiveRoom(
      id: item.id,
      slug: item.slug ?? item.id,
      title: item.caption,
      liveType: 'commerce',
      isPrivate: false,
      status: 'live',
      viewerCount: item.viewerCount,
      totalLikes: item.likesCount,
      thumbnailUrl: item.thumbnailUrl,
      streamUrl: item.streamUrl,
      streamerId: item.author.id,
      streamerName: item.author.name,
      streamerAvatarUrl: item.author.avatarUrl,
      streamerUsername: item.author.username,
      streamerVerified: item.author.isVerified,
    );
    openLiveRoom(context, item.id, room);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Tap em qualquer lugar do fundo entra na live (com som).
        // Controles interativos (CTA, action rail, produto) ficam por cima.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _enter(context),
          child: LivePeekBackground(
            roomId: item.id,
            thumbnailUrl: item.thumbnailUrl,
            streamUrl: item.streamUrl,
            isActive: isActive,
          ),
        ),
        // ── CTA "Assistir ao Vivo" — centro da tela ──
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Align(
              alignment: const Alignment(0, 0.55),
              child: WatchLiveButton(onTap: () => _enter(context)),
            ),
          ),
        ),
        // Comentários reais
        Positioned(
          left: 16,
          right: 16,
          bottom: 202,
          child: IgnorePointer(
            child: RealCommentsTicker(roomId: item.id, isActive: isActive),
          ),
        ),
        // Bloco inferior esquerdo: identidade + badges + caption
        Positioned(
          left: 16,
          right: 16,
          bottom: 122,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _enter(context),
                child: StreamerIdentity(
                  userId: item.author.id,
                  name: item.author.name,
                  username: item.author.username,
                  avatarUrl: item.author.avatarUrl,
                  isVerified: item.author.isVerified,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiveDotPulse(label: S.of(context).liveBadgeShop),
                  const SizedBox(width: 6),
                  ViewerCountChip(count: item.viewerCount),
                ],
              ),
              if (item.caption.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Featured product card + cart button
        Positioned(
          left: 16,
          right: 16,
          bottom: 22,
          child: _FeaturedProductCard(
            product: _featured,
            totalProducts: item.products.length,
            onTap: () => _openCart(context),
          ),
        ),
      ],
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({
    required this.product,
    required this.totalProducts,
    required this.onTap,
  });
  final Product product;
  final int totalProducts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.nearBlack.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.electricPurple.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricPurple.withValues(alpha: 0.25),
              blurRadius: 18,
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumb
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.slate,
                  child: const Icon(Icons.shopping_bag, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mutedRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          S.of(context).liveOfferNow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (product.isLowStock) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Restam ${product.stock}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.coolCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          'R\$ ${product.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.coolGray,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Cart button
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.electricPurple, AppColors.coolCyan],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.mutedRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$totalProducts',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
