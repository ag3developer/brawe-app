import 'package:flutter/material.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../../domain/models/product.dart';
import '../../../core/themes/app_colors.dart';
import '../action_rail.dart';
import 'shared/_live_overlay.dart';
import 'shared/_caption_block.dart';
import 'products_drawer.dart';

/// 🛍️ View para LiveCommerceItem — thumbnail + produto em destaque + botão de carrinho.
class LiveCommerceView extends StatelessWidget {
  const LiveCommerceView({super.key, required this.item});
  final LiveCommerceItem item;

  Product get _featured => item.products.firstWhere(
        (p) => p.id == item.featuredProductId,
        orElse: () => item.products.first,
      );

  void _openCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductsDrawer(
        products: item.products,
        author: item.author,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // BG: thumbnail da live
        _Thumbnail(url: item.thumbnailUrl),
        // Gradient overlay para contraste
        const _BottomGradient(),
        // LIVE badge + viewers
        Positioned(
          top: 60,
          left: 16,
          child: LiveBadge(viewerCount: item.viewerCount, label: 'AO VIVO • SHOP'),
        ),
        // Action rail
        Positioned(
          right: 8,
          bottom: 220,
          child: ActionRail(
            item: item,
            onLike: () {},
            onComment: () {},
            onShare: () {},
            onFollow: () {},
            onGift: () {},
            onProfile: () {},
          ),
        ),
        // Caption
        Positioned(
          left: 16,
          right: 90,
          bottom: 200,
          child: CaptionBlock(author: item.author, caption: item.caption),
        ),
        // Featured product card + cart button
        Positioned(
          left: 16,
          right: 16,
          bottom: 100,
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppColors.slate),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.35),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
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
                errorBuilder: (_, __, ___) => Container(
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mutedRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('OFERTA AGORA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      if (product.isLowStock) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Restam ${product.stock}',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
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
                  child: const Icon(Icons.shopping_bag,
                      color: Colors.white, size: 22),
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
                        minWidth: 20, minHeight: 20),
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
