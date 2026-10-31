import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// A carousel/PageView for displaying product images.
///
/// - If [images] is not empty: show PageView with dots indicator
/// - If [images] is empty but [fallbackImageUrl] exists: show single image
/// - If no images: show placeholder icon
class ProductImageCarousel extends StatefulWidget {
  /// List of image URLs (e.g., Product.images or similar)
  final List<String> images;

  /// Fallback image URL if [images] is empty (e.g., Product.imageUrl)
  final String? fallbackImageUrl;

  /// Height of the carousel (responsive)
  final double height;

  const ProductImageCarousel({
    super.key,
    required this.images,
    this.fallbackImageUrl,
    this.height = 300,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isNotEmpty
        ? widget.images
        : (widget.fallbackImageUrl != null ? [widget.fallbackImageUrl!] : []);

    if (images.isEmpty) {
      return _buildPlaceholder(context);
    }

    return Stack(
      children: [
        // PageView with images
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemCount: images.length,
          itemBuilder: (context, index) => _buildImageTile(images[index]),
        ),

        // Dots indicator (only if multiple images)
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildDotsIndicator(images.length),
          ),
      ],
    );
  }

  Widget _buildImageTile(String imageUrl) {
    // BoxFit.contain (não .cover) — produtos (embalagens, frascos, etc)
    // não podem ser cortados nas bordas; preferimos ver a foto inteira
    // com uma leve margem de respiro em vez de cortar o produto.
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.all(20),
      child: CachedNetworkImage(
        memCacheWidth: context.decodeScreenPx,
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: context.colors.surface,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(context.colors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: context.colors.surface,
      child: Center(
        child: Icon(
          LucideIcons.imageOff,
          size: 48,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: widget.height,
      color: context.colors.surface,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDotsIndicator(int count) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _currentPage == index ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: _currentPage == index
                  ? context.colors.accentPrimary
                  : context.colors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
