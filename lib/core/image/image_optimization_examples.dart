///
/// 🖼️ Image Optimization Examples
///
/// Este arquivo demonstra como usar os novos widgets otimizados
/// para substituir Image.network() e reduzir uso de memória.
///

import 'package:flutter/material.dart';
import 'brawe_network_image.dart';

// ============================================================================
// EXEMPLO 1: Substituição Simples
// ============================================================================

class Example1_SimpleReplacement extends StatelessWidget {
  const Example1_SimpleReplacement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const imageUrl = 'https://example.com/image.jpg';

    return Column(
      children: [
        // ❌ ANTES (sem cache, re-download toda vez)
        // Image.network(
        //   imageUrl,
        //   width: 200,
        //   height: 150,
        //   fit: BoxFit.cover,
        // ),

        // ✅ DEPOIS (com cache automático)
        BraweNetworkImage(imageUrl, width: 200, height: 150, fit: BoxFit.cover),

        // ✅ OU com extension method
        imageUrl.toBraweImage(width: 200, height: 150),
      ],
    );
  }
}

// ============================================================================
// EXEMPLO 2: Avatares Circulares
// ============================================================================

class Example2_AvatarCircle extends StatelessWidget {
  const Example2_AvatarCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const userAvatarUrl = 'https://example.com/avatar.jpg';

    return ListView(
      children: [
        // ❌ ANTES (implementação manual complexa)
        // Container(
        //   width: 48,
        //   height: 48,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     border: Border.all(color: Colors.grey),
        //   ),
        //   child: ClipOval(
        //     child: Image.network(
        //       userAvatarUrl,
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),

        // ✅ DEPOIS (uma linha)
        BraweCircleNetworkImage(userAvatarUrl, size: 48),

        // ✅ OU com extension
        userAvatarUrl.toAvatarImage(size: 48),

        // Exemplo: Lista de avatares com cache automático
        ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            final userAvatar = 'https://example.com/user_$index.jpg';
            return ListTile(
              leading: userAvatar.toAvatarImage(size: 40),
              title: Text('User $index'),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// EXEMPLO 3: GIFs Otimizados (ChatDetail)
// ============================================================================

class Example3_OptimizedGif extends StatelessWidget {
  const Example3_OptimizedGif({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const gifUrl = 'https://example.com/animation.gif';

    return Column(
      children: [
        // ❌ ANTES (re-download toda visualização)
        // Image.network(
        //   gifUrl,
        //   width: 200,
        //   height: 150,
        //   fit: BoxFit.cover,
        //   errorBuilder: (_, _, _) => Container(
        //     width: 200,
        //     height: 150,
        //     color: Colors.grey[300],
        //     child: const Center(child: Icon(Icons.image_not_supported)),
        //   ),
        // ),

        // ✅ DEPOIS (cache automático + otimizações)
        BraweGifNetworkImage(
          gifUrl,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          onImageLoaded: () => debugPrint('GIF carregado do cache'),
        ),

        // ✅ OU com extension
        gifUrl.toGifImage(width: 200, height: 150),
      ],
    );
  }
}

// ============================================================================
// EXEMPLO 4: Cards de Posts com Imagens
// ============================================================================

class Example4_PostCard extends StatelessWidget {
  final String postImageUrl;
  final String userAvatarUrl;
  final String userName;

  const Example4_PostCard({
    Key? key,
    required this.postImageUrl,
    required this.userAvatarUrl,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header com avatar otimizado
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar circular com cache
                userAvatarUrl.toAvatarImage(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '2 hours ago',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Imagem do post otimizada
          BraweCardNetworkImage(
            postImageUrl,
            width: double.infinity,
            height: 300,
            borderRadius: BorderRadius.zero,
            onTap: () => debugPrint('Imagem tapped'),
            onImageLoaded: () => debugPrint('Imagem carregada'),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(Icons.favorite_outline),
                const Icon(Icons.chat_bubble_outline),
                const Icon(Icons.share_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXEMPLO 5: Grid de Imagens (Stories, Marketplace)
// ============================================================================

class Example5_ImageGrid extends StatelessWidget {
  const Example5_ImageGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = List.generate(12, (i) => 'https://example.com/grid_$i.jpg');

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return BraweCardNetworkImage(
          images[index],
          borderRadius: BorderRadius.circular(8),
          onTap: () => debugPrint('Image $index tapped'),
        );
      },
    );
  }
}

// ============================================================================
// EXEMPLO 6: Com Placeholder Customizado
// ============================================================================

class Example6_CustomPlaceholder extends StatelessWidget {
  const Example6_CustomPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BraweNetworkImage(
      'https://example.com/image.jpg',
      width: 200,
      height: 150,
      fit: BoxFit.cover,

      // Placeholder customizado enquanto carrega
      placeholder: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),

      // Error widget customizado se falhar
      errorWidget: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text('Erro ao carregar', style: TextStyle(color: Colors.red[300])),
          ],
        ),
      ),

      borderRadius: BorderRadius.circular(8),
    );
  }
}

// ============================================================================
// EXEMPLO 7: Gerenciamento de Cache (Login/Logout)
// ============================================================================

class Example7_CacheManagement extends StatelessWidget {
  const Example7_CacheManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _clearCacheOnLogout(context),
          child: const Text('Logout & Clear Cache'),
        ),
        ElevatedButton(
          onPressed: () => _getCacheStats(context),
          child: const Text('Show Cache Stats'),
        ),
      ],
    );
  }

  Future<void> _clearCacheOnLogout(BuildContext context) async {
    // Implementar lógica de logout
    // await authService.logout();

    // ✅ Limpar todos os caches de imagem
    // await imageCacheConfig.clearAllCaches();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cache cleared on logout')));
  }

  Future<void> _getCacheStats(BuildContext context) async {
    // ✅ Obter estatísticas de cache
    // final stats = imageCacheConfig.getCacheStats();
    // final sizeInBytes = await imageCacheConfig.getCacheSizeInBytes();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache stats shown in debugger')),
    );
  }
}

// ============================================================================
// EXEMPLO 8: Migração em Arquivo Real (chat_detail_screen.dart pattern)
// ============================================================================

class Example8_ChatDetailPattern extends StatelessWidget {
  const Example8_ChatDetailPattern({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dados do chat
    const gifUrl = 'https://example.com/gif.gif';
    const userAvatar = 'https://example.com/user.jpg';

    return Column(
      children: [
        // Pattern 1: GIF em chat com border radius
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BraweGifNetworkImage(
            gifUrl,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 16),

        // Pattern 2: Avatar de usuário
        Row(
          children: [
            userAvatar.toAvatarImage(size: 40),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('João Silva'),
                  Text('Online', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// EXEMPLO 9: Performance Monitoring
// ============================================================================

class Example9_PerformanceMonitoring extends StatefulWidget {
  const Example9_PerformanceMonitoring({Key? key}) : super(key: key);

  @override
  State<Example9_PerformanceMonitoring> createState() =>
      _Example9_PerformanceMonitoringState();
}

class _Example9_PerformanceMonitoringState
    extends State<Example9_PerformanceMonitoring> {
  String _cacheInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _updateCacheInfo();
  }

  Future<void> _updateCacheInfo() async {
    // TODO: Implementar após integrar ImageCacheConfig
    // final stats = imageCacheConfig.getCacheStats();
    // final totalSize = await imageCacheConfig.getCacheSizeInBytes();

    setState(() {
      _cacheInfo =
          'Cache stats: 100 images, 45.2MB\n'
          'Max: 100 images, 150MB\n'
          'Hit rate: 85%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Cache Performance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_cacheInfo),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _updateCacheInfo,
            child: const Text('Refresh Stats'),
          ),
        ],
      ),
    );
  }
}
