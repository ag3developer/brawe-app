import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget otimizado para carregamento de imagens de rede com cache automático
///
/// Substitui Image.network() com:
/// - Cache automático em disco
/// - Fade-in animation ao carregar
/// - Placeholder customizável
/// - Error widget customizável
/// - Redução automática de resolução
/// - Gerenciamento de memória
class BraweNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isRounded;
  final double? borderRadiusValue;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onImageLoaded;
  final Duration fadeInDuration;
  final String? cacheKey;

  const BraweNetworkImage(
    this.imageUrl, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isRounded = false,
    this.borderRadiusValue = 8.0,
    this.placeholder,
    this.errorWidget,
    this.onImageLoaded,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.cacheKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildImage();
  }

  Widget _buildImage() {
    final borderRadius = isRounded
        ? BorderRadius.circular(borderRadiusValue ?? 8.0)
        : this.borderRadius ?? BorderRadius.zero;

    // IMPORTANTE: octo_image (usado internamente pelo cached_network_image)
    // NÃO permite `placeholder` e `progressIndicatorBuilder` definidos ao
    // mesmo tempo — dispara um Failed assertion em runtime que quebra TODA
    // a árvore de widgets (causa das fotos/avatares não carregarem no feed).
    // Regra: se um placeholder customizado foi passado, usamos só ele.
    // Caso contrário, usamos o indicador de progresso padrão.
    final hasCustomPlaceholder = placeholder != null;

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheKey: cacheKey,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: const Duration(milliseconds: 200),
        placeholder: hasCustomPlaceholder
            ? (context, url) => _buildPlaceholder()
            : null,
        progressIndicatorBuilder: hasCustomPlaceholder
            ? null
            : (context, url, progress) {
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.progress,
                    strokeWidth: 2.0,
                  ),
                );
              },
        errorWidget: (context, url, error) => _buildErrorWidget(),
        imageBuilder: (context, imageProvider) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onImageLoaded?.call();
          });
          return Image(
            image: imageProvider,
            fit: fit,
            width: width,
            height: height,
          );
        },
        memCacheHeight: height?.toInt(),
        memCacheWidth: width?.toInt(),
        maxHeightDiskCache: (height ?? 500).toInt(),
        maxWidthDiskCache: (width ?? 500).toInt(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[600],
          size: 40,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.broken_image, color: Colors.red[300], size: 40),
      ),
    );
  }
}

/// Builder para imagens circulares otimizadas (avatares, etc)
class BraweCircleNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Border? border;
  final VoidCallback? onImageLoaded;
  final String? cacheKey;

  const BraweCircleNetworkImage(
    this.imageUrl, {
    Key? key,
    this.size = 48.0,
    this.border,
    this.onImageLoaded,
    this.cacheKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ?? Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: BraweNetworkImage(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(size / 2),
        cacheKey: cacheKey,
        onImageLoaded: onImageLoaded,
        placeholder: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: size * 0.5,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

/// Builder para imagens em grid/card (posts, stories, etc)
class BraweCardNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onImageLoaded;

  const BraweCardNetworkImage(
    this.imageUrl, {
    Key? key,
    this.width,
    this.height = 200,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.onTap,
    this.onImageLoaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BraweNetworkImage(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
        onImageLoaded: onImageLoaded,
        placeholder: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: borderRadius,
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
    );
  }
}

/// Builder para GIFs otimizados (chat, stories, etc)
class BraweGifNetworkImage extends StatelessWidget {
  final String gifUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final VoidCallback? onImageLoaded;
  final Widget? placeholder;
  final Widget? errorWidget;

  const BraweGifNetworkImage(
    this.gifUrl, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.onImageLoaded,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BraweNetworkImage(
      gifUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 500),
      onImageLoaded: onImageLoaded,
      placeholder:
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.gif_box, color: Colors.grey)),
          ),
      errorWidget:
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
    );
  }
}

/// Extension para facilitar uso em imagens de perfil
extension BraweImageExtension on String {
  /// Retorna um widget otimizado para esta URL de imagem
  Widget toBraweImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return BraweNetworkImage(
      this,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
    );
  }

  /// Retorna um widget otimizado para avatar circular
  Widget toAvatarImage({double size = 48, Border? border}) {
    return BraweCircleNetworkImage(this, size: size, border: border);
  }

  /// Retorna um widget otimizado para card/post
  Widget toCardImage({
    double? width,
    double? height,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) {
    return BraweCardNetworkImage(
      this,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  /// Retorna um widget otimizado para GIF
  Widget toGifImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return BraweGifNetworkImage(this, width: width, height: height, fit: fit);
  }
}
