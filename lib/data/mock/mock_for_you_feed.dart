import '../../domain/models/feed_item.dart';
import '../../domain/models/product.dart';
import '../../domain/models/battle_state.dart';

/// Mock data para o For You feed enquanto a API não está integrada.
class MockForYouFeed {
  static const _picsum = 'https://picsum.photos/seed';

  static List<FeedItem> generate() {
    return [
      // 1. Live Commerce
      LiveCommerceItem(
        id: 'lc1',
        author: const FeedAuthor(
          id: 'u1',
          name: 'Marina Costa',
          username: 'marina.style',
          avatarUrl: '$_picsum/marina/200',
          isVerified: true,
        ),
        likesCount: 12400,
        commentsCount: 832,
        sharesCount: 156,
        userLiked: false,
        userFollowingAuthor: false,
        caption: '🛍️ Liquidação relâmpago! Tudo com até 70% OFF até meia-noite!',
        thumbnailUrl: '$_picsum/shop1/800/1400',
        viewerCount: 3421,
        featuredProductId: 'p2',
        products: [
          const Product(
            id: 'p1',
            name: 'Vestido Floral Verão',
            imageUrl: '$_picsum/dress1/200',
            price: 89.90,
            originalPrice: 159.90,
            stock: 14,
            soldCount: 87,
          ),
          const Product(
            id: 'p2',
            name: 'Bolsa Couro Premium',
            imageUrl: '$_picsum/bag1/200',
            price: 199.90,
            originalPrice: 399.00,
            stock: 3,
            soldCount: 142,
            isFeatured: true,
          ),
          const Product(
            id: 'p3',
            name: 'Tênis Casual Branco',
            imageUrl: '$_picsum/shoes1/200',
            price: 249.00,
            stock: 22,
            soldCount: 56,
          ),
          const Product(
            id: 'p4',
            name: 'Óculos de Sol Aviador',
            imageUrl: '$_picsum/sun1/200',
            price: 79.00,
            originalPrice: 129.00,
            stock: 0,
            soldCount: 200,
          ),
        ],
      ),

      // 2. Live Battle
      LiveBattleItem(
        id: 'lb1',
        author: const FeedAuthor(
          id: 'u2',
          name: 'Lucas MC',
          username: 'lucasmc',
          avatarUrl: '$_picsum/lucas/200',
        ),
        opponent: const FeedAuthor(
          id: 'u3',
          name: 'Rapper Z',
          username: 'rapperz',
          avatarUrl: '$_picsum/rapperz/200',
          isVerified: true,
        ),
        likesCount: 28900,
        commentsCount: 4120,
        sharesCount: 612,
        userLiked: true,
        userFollowingAuthor: true,
        caption: '🎤 Batalha de rimas! Quem leva essa? Vote no seu favorito 🔥',
        thumbnailUrlA: '$_picsum/battle1a/800/700',
        thumbnailUrlB: '$_picsum/battle1b/800/700',
        viewerCount: 8745,
        battleState: const BattleState(
          scoreA: 1284,
          scoreB: 942,
          timeRemaining: Duration(minutes: 2, seconds: 18),
        ),
      ),

      // 3. Live Chat
      LiveChatItem(
        id: 'lch1',
        author: const FeedAuthor(
          id: 'u4',
          name: 'Dr. André Souza',
          username: 'drandre',
          avatarUrl: '$_picsum/andre/200',
          isVerified: true,
        ),
        likesCount: 5612,
        commentsCount: 287,
        sharesCount: 92,
        userLiked: false,
        userFollowingAuthor: false,
        caption: 'Tirando dúvidas sobre saúde mental. Mande sua pergunta no chat!',
        thumbnailUrl: '$_picsum/chat1/800/1400',
        viewerCount: 1234,
        topic: 'Saúde Mental',
      ),

      // 4. Video Post
      VideoFeedItem(
        id: 'v1',
        author: const FeedAuthor(
          id: 'u5',
          name: 'Bia Travel',
          username: 'biatravel',
          avatarUrl: '$_picsum/bia/200',
        ),
        likesCount: 19800,
        commentsCount: 1023,
        sharesCount: 432,
        userLiked: false,
        userFollowingAuthor: false,
        caption: '✈️ Top 5 lugares para visitar em Portugal — você já foi em algum?',
        videoUrl: '',
        thumbnailUrl: '$_picsum/portugal/800/1400',
        duration: const Duration(minutes: 1, seconds: 23),
      ),

      // 5. Photo Post
      PhotoPostFeedItem(
        id: 'p1',
        author: const FeedAuthor(
          id: 'u6',
          name: 'Ana Photo',
          username: 'ana.photo',
          avatarUrl: '$_picsum/ana/200',
        ),
        likesCount: 3421,
        commentsCount: 89,
        sharesCount: 23,
        userLiked: false,
        userFollowingAuthor: true,
        caption: 'Pôr-do-sol perfeito hoje 🌅',
        imageUrl: '$_picsum/sunset/800/1400',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),

      // 6. Text-only post
      PhotoPostFeedItem(
        id: 'p2',
        author: const FeedAuthor(
          id: 'u7',
          name: 'Filósofo Carlos',
          username: 'filocarlos',
          avatarUrl: '$_picsum/carlos/200',
        ),
        likesCount: 920,
        commentsCount: 156,
        sharesCount: 78,
        userLiked: false,
        userFollowingAuthor: false,
        caption:
            '"A vida é o que fazemos dela. Cada escolha é uma semente plantada no jardim do amanhã."',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }
}
