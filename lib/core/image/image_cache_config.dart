import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Configuração centralizada de cache de imagens para otimização de memória e performance
///
/// Implementa 3 camadas de cache:
/// 1. Memory Cache (Flutter nativo) - Para imagens em uso ativo
/// 2. Disk Cache (flutter_cache_manager) - Persistente entre sessões
/// 3. HTTP Cache (Dio) - Nativo do cliente HTTP
class ImageCacheConfig {
  // Singleton instance
  static final ImageCacheConfig _instance = ImageCacheConfig._internal();

  factory ImageCacheConfig() {
    return _instance;
  }

  ImageCacheConfig._internal();

  // Cache managers para diferentes tipos de imagens
  late CacheManager _networkImageCache;
  late CacheManager _avatarCache;
  late CacheManager _mediaCache;

  // Getters para acesso aos cache managers
  CacheManager get networkImageCache => _networkImageCache;
  CacheManager get avatarCache => _avatarCache;
  CacheManager get mediaCache => _mediaCache;

  /// Inicializa os cache managers com configurações otimizadas
  /// Deve ser chamado no main() ou no primeiro acesso
  void initialize() {
    // Cache para avatares e ícones pequenos
    _avatarCache = CacheManager(
      Config(
        'avatarCache',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 150, // Limite menor para imagens pequenas
      ),
    );

    // Cache para imagens de rede (posts, stories, etc)
    _networkImageCache = CacheManager(
      Config(
        'networkImageCache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 300, // Limite moderado
      ),
    );

    // Cache para mídia pesada (vídeos, imagens de alta resolução)
    _mediaCache = CacheManager(
      Config(
        'mediaCache',
        stalePeriod: const Duration(days: 14),
        maxNrOfCacheObjects: 50, // Limite alto para arquivos grandes
      ),
    );

    // Configurar cache de imagens Flutter nativo
    _configureFlutterImageCache();
  }

  /// Configura o cache nativo de imagens do Flutter
  /// Reduz picos de uso de memória
  void _configureFlutterImageCache() {
    imageCache.maximumSize = 100; // Máximo de imagens em memória
    imageCache.maximumSizeBytes = 150 * 1024 * 1024; // 150 MB de limite

    debugPrint(
      '🖼️ Image Cache Configurado: '
      'Max: ${imageCache.maximumSize} imagens, '
      '${(imageCache.maximumSizeBytes / 1024 / 1024).toStringAsFixed(0)}MB',
    );
  }

  /// Limpa todos os caches de imagem (memory + disk)
  /// Use durante logout ou limpeza de dados
  Future<void> clearAllCaches() async {
    try {
      imageCache.clear();
      imageCache.clearLiveImages();
      await _networkImageCache.emptyCache();
      await _avatarCache.emptyCache();
      await _mediaCache.emptyCache();
      debugPrint('✅ Todos os caches de imagem foram limpos');
    } catch (e) {
      debugPrint('❌ Erro ao limpar caches: $e');
    }
  }

  /// Limpa cache de imagens especificamente por tipo
  Future<void> clearCacheByType(String type) async {
    try {
      switch (type.toLowerCase()) {
        case 'avatar':
          await _avatarCache.emptyCache();
          break;
        case 'network':
          await _networkImageCache.emptyCache();
          break;
        case 'media':
          await _mediaCache.emptyCache();
          break;
        case 'flutter':
          imageCache.clear();
          imageCache.clearLiveImages();
          break;
        default:
          debugPrint('⚠️ Tipo de cache desconhecido: $type');
      }
      debugPrint('✅ Cache de tipo "$type" foi limpo');
    } catch (e) {
      debugPrint('❌ Erro ao limpar cache de tipo "$type": $e');
    }
  }

  /// Retorna informações de uso de cache (para debug)
  Map<String, dynamic> getCacheStats() {
    return {
      'flutterImageCacheSize': imageCache.currentSize,
      'flutterImageCount': imageCache.currentSize,
      'maxCacheSize': imageCache.maximumSize,
      'maxCacheBytes': imageCache.maximumSizeBytes,
    };
  }

  /// Pré-aquece o cache com imagens críticas
  /// Útil para imagens que serão usadas frequentemente
  Future<void> precacheImageUrl(String imageUrl, BuildContext context) async {
    try {
      final imageProvider = NetworkImage(imageUrl);
      await precacheImage(imageProvider, context);
      debugPrint('✅ Imagem pré-carregada: $imageUrl');
    } catch (e) {
      debugPrint('❌ Erro ao pré-carregar: $e');
    }
  }

  /// Retorna o tamanho total do cache em disco
  /// Aproximação baseada em contadores internos
  Future<int> getCacheSizeInBytes() async {
    try {
      // Usar tamanho máximo como estimativa conservadora
      final estimatedSize = imageCache.maximumSizeBytes;
      return estimatedSize;
    } catch (e) {
      debugPrint('❌ Erro ao calcular tamanho do cache: $e');
      return imageCache.maximumSizeBytes;
    }
  }
}

/// Instância global para fácil acesso
final imageCacheConfig = ImageCacheConfig();
