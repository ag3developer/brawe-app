import '../../domain/models/product.dart';

/// Mock data: produtos por vendedor.
/// Quando um perfil tem produtos aqui, exibe a tab "Loja" no perfil.
class MockUserProducts {
  static const Set<String> _sellerIds = {
    'u1', 'u2', 'u4', 'lucasmc', 'analima', 'carlam',
  };

  static bool isSeller(String userId) => _sellerIds.contains(userId);

  static List<Product> productsFor(String userId) {
    if (!isSeller(userId)) return const [];

    return [
      Product(
        id: '${userId}_p1',
        name: 'Camiseta Brawe Limited',
        imageUrl: 'https://picsum.photos/seed/${userId}p1/400',
        price: 89.90,
        originalPrice: 129.90,
        stock: 12,
        soldCount: 142,
        isFeatured: true,
      ),
      Product(
        id: '${userId}_p2',
        name: 'Boné Snapback Edição Streamer',
        imageUrl: 'https://picsum.photos/seed/${userId}p2/400',
        price: 59.00,
        stock: 4,
        soldCount: 87,
      ),
      Product(
        id: '${userId}_p3',
        name: 'Mousepad Gamer XL',
        imageUrl: 'https://picsum.photos/seed/${userId}p3/400',
        price: 49.90,
        originalPrice: 79.90,
        stock: 35,
        soldCount: 256,
      ),
      Product(
        id: '${userId}_p4',
        name: 'Caneca "Vai com tudo!"',
        imageUrl: 'https://picsum.photos/seed/${userId}p4/400',
        price: 35.00,
        stock: 0,
        soldCount: 412,
      ),
      Product(
        id: '${userId}_p5',
        name: 'Hoodie Premium',
        imageUrl: 'https://picsum.photos/seed/${userId}p5/400',
        price: 199.90,
        originalPrice: 249.90,
        stock: 8,
        soldCount: 64,
      ),
      Product(
        id: '${userId}_p6',
        name: 'Adesivos Pack Brawe',
        imageUrl: 'https://picsum.photos/seed/${userId}p6/400',
        price: 19.90,
        stock: 200,
        soldCount: 1043,
      ),
    ];
  }
}
