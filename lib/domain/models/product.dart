class Product {
  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.stock = 0,
    this.soldCount = 0,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final int stock;
  final int soldCount;
  final bool isFeatured;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent =>
      hasDiscount ? (((originalPrice! - price) / originalPrice!) * 100).round() : 0;
  bool get isLowStock => stock > 0 && stock <= 5;
  bool get isSoldOut => stock == 0;
}
