import 'package:flutter/material.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../core/themes/app_colors.dart';

/// Drawer (DraggableScrollableSheet) com a lista de produtos da live.
class ProductsDrawer extends StatelessWidget {
  const ProductsDrawer({
    super.key,
    required this.products,
    required this.author,
  });
  final List<Product> products;
  final FeedAuthor author;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.nearBlack,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag,
                        color: AppColors.electricPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loja ao vivo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${products.length} itens • ${author.name}',
                            style: const TextStyle(
                              color: AppColors.coolGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Lista
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ProductTile(product: products[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(14),
        border: product.isFeatured
            ? Border.all(color: AppColors.electricPurple, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: Colors.black26,
                child: const Icon(Icons.image_not_supported,
                    color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electricPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('EM DESTAQUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.coolCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mutedRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('-${product.discountPercent}%',
                            style: const TextStyle(
                              color: AppColors.mutedRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.isSoldOut
                      ? 'Esgotado'
                      : product.isLowStock
                          ? 'Apenas ${product.stock} restantes'
                          : '${product.soldCount} vendidos',
                  style: TextStyle(
                    color: product.isSoldOut
                        ? AppColors.mutedRed
                        : product.isLowStock
                            ? Colors.amber
                            : AppColors.coolGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: product.isSoldOut ? null : () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
              disabledBackgroundColor: AppColors.slate,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
            ),
            child: Text(product.isSoldOut ? 'Esgotado' : 'Comprar'),
          ),
        ],
      ),
    );
  }
}
