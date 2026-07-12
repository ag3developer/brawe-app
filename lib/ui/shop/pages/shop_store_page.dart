import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/providers/marketplace_providers.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../domain/models/marketplace_models.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../utils/currency_formatter.dart';

/// Public storefront page accessed via `/shop/store/:slug` route.
///
/// Premium, single-purpose e-commerce header: banner, logo overlapping the
/// banner (Instagram/TikTok Shop style), verified badge, rating, description
/// and a single CTA — "Falar com a loja" — that opens the in-app chat with
/// the store owner. No external contact icons (WhatsApp/Instagram/etc.):
/// every interaction with a brand stays inside Brawe.
///
/// ⚠️ CRITICAL BUSINESS RULE: `Store.defaultAffiliateCommission` is
/// intentionally NEVER read or rendered anywhere in this file. Commission is
/// internal information between the store owner and the partner — it must
/// never be visible on the public storefront.
class ShopStorePage extends ConsumerWidget {
  /// Store slug from route parameter.
  final String storeSlug;

  const ShopStorePage({super.key, required this.storeSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeDetailProvider(storeSlug));

    return Scaffold(
      backgroundColor: context.colors.background,
      body: storeAsync.when(
        loading: () => _ShopStoreSkeleton(onBack: () => context.pop()),
        error: (error, stackTrace) => _ShopStoreErrorState(
          onBack: () => context.pop(),
          onRetry: () => ref.invalidate(storeDetailProvider(storeSlug)),
        ),
        data: (store) => _StoreContent(store: store),
      ),
    );
  }
}

/// Floating circular back button — always legible over any banner/theme.
class _FloatingBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ─── Loading skeleton ──────────────────────────────────────────────────────
class _ShopStoreSkeleton extends StatelessWidget {
  final VoidCallback onBack;
  const _ShopStoreSkeleton({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 220, color: context.colors.surfaceHighest),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 160,
                      height: 20,
                      color: context.colors.surfaceHighest,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: context.colors.surfaceHighest,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 220,
                      height: 14,
                      color: context.colors.surfaceHighest,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            child: _FloatingBackButton(onTap: onBack),
          ),
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ───────────────────────────────────────────────────────────
class _ShopStoreErrorState extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRetry;
  const _ShopStoreErrorState({required this.onBack, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).shopStoreError,
                    style: TextStyle(color: context.colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: Text(S.of(context).actionRetry),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: _FloatingBackButton(onTap: onBack),
          ),
        ],
      ),
    );
  }
}

/// Main content once the [Store] has loaded successfully.
class _StoreContent extends ConsumerWidget {
  final Store store;
  const _StoreContent({required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1280 ? 4 : (width >= 640 ? 3 : 2);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _StoreBannerHeader(store: store)),
            SliverToBoxAdapter(child: _StoreInfo(store: store)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.shoppingBag,
                      size: 18,
                      color: context.colors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).shopStoreProductsSection,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StoreProductsSliver(
              storeId: store.id,
              crossAxisCount: crossAxisCount,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: _FloatingBackButton(onTap: () => context.pop()),
          ),
        ),
      ],
    );
  }
}

// ─── Banner + overlapping logo (Instagram/TikTok Shop style header) ───────
class _StoreBannerHeader extends StatefulWidget {
  final Store store;
  const _StoreBannerHeader({required this.store});

  @override
  State<_StoreBannerHeader> createState() => _StoreBannerHeaderState();
}

class _StoreBannerHeaderState extends State<_StoreBannerHeader> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const double _bannerHeight = 220;
  static const double _logoSize = 84;
  static const double _logoOverlap = _logoSize / 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _logoOverlap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: SizedBox(
              height: _bannerHeight,
              width: double.infinity,
              child: _buildBanner(context),
            ),
          ),
          // Subtle bottom gradient for legibility where the logo overlaps.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 64,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          // Logo — overlaps the bottom edge of the banner.
          Positioned(
            left: 16,
            bottom: -_logoOverlap,
            child: _StoreLogo(store: widget.store, size: _logoSize),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final banners = widget.store.banners ?? const <StoreBanner>[];

    if (banners.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: context.colors.surface),
                errorWidget: (context, url, error) => _fallback(context),
              );
            },
          ),
          if (banners.length > 1)
            Positioned(
              bottom: 76,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _currentPage == i ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: _currentPage == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (widget.store.bannerUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.store.bannerUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: context.colors.surface),
        errorWidget: (context, url, error) => _fallback(context),
      );
    }

    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.accentPrimary,
            context.colors.accentSecondary,
          ],
        ),
      ),
    );
  }
}

class _StoreLogo extends StatelessWidget {
  final Store store;
  final double size;
  const _StoreLogo({required this.store, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: store.logoUrl != null
            ? CachedNetworkImage(
                imageUrl: store.logoUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: context.colors.surfaceHighest,
      child: Icon(
        LucideIcons.store,
        size: size * 0.4,
        color: context.colors.textSecondary,
      ),
    );
  }
}

// ─── Store info: name, verified badge, rating, description, categories ────
class _StoreInfo extends ConsumerStatefulWidget {
  final Store store;
  const _StoreInfo({required this.store});

  @override
  ConsumerState<_StoreInfo> createState() => _StoreInfoState();
}

class _StoreInfoState extends ConsumerState<_StoreInfo> {
  bool _descriptionExpanded = false;
  bool _openingChat = false;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        store.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (store.isVerified) ...[
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Icon(
                          LucideIcons.badgeCheck,
                          size: 18,
                          color: context.colors.accentPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _RatingPill(store: store),
              if (store.isPremium)
                _Badge(
                  label: s.shopStorePremiumBadge,
                  icon: LucideIcons.crown,
                  color: context.colors.accentGold,
                ),
              if (store.hasBrawePass)
                _Badge(
                  label: s.shopStoreBravePassBadge,
                  icon: LucideIcons.sparkles,
                  color: context.colors.accentPrimary,
                ),
            ],
          ),
          if (store.location != null && store.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  LucideIcons.mapPin,
                  size: 14,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  store.location!,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          if (store.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildDescription(context, store),
          ],
          if (store.categories.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: store.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = store.categories[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceHighest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 18),
          _buildChatCta(context, store),
          const SizedBox(height: 4),
          Divider(color: context.colors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _buildChatCta(BuildContext context, Store store) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: _openingChat ? null : () => _openStoreChat(context, store),
        style: FilledButton.styleFrom(
          backgroundColor: context.colors.accentPrimary,
          foregroundColor: context.colors.textOnAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _openingChat
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    context.colors.textOnAccent,
                  ),
                ),
              )
            : const Icon(LucideIcons.messageCircle, size: 18),
        label: Text(
          S.of(context).shopStoreChatCta,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _openStoreChat(BuildContext context, Store store) async {
    final s = S.of(context);
    final ownerId = store.ownerUserId;
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.shopStoreChatUnavailable)));
      return;
    }

    setState(() => _openingChat = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final convId = await ref
          .read(chatRepositoryProvider)
          .startConversation(participantId: ownerId);
      if (!context.mounted) return;
      context.push(
        '/chat/$convId',
        extra: {
          'participantName': store.name,
          'participantAvatarUrl': store.logoUrl,
          'participantId': ownerId,
        },
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.shopStoreChatError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  Widget _buildDescription(BuildContext context, Store store) {
    final description = store.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: TextStyle(color: context.colors.textSecondary, height: 1.4),
          maxLines: _descriptionExpanded ? null : 3,
          overflow: _descriptionExpanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () =>
              setState(() => _descriptionExpanded = !_descriptionExpanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _descriptionExpanded
                  ? S.of(context).shopStoreReadLess
                  : S.of(context).shopStoreReadMore,
              style: TextStyle(
                color: context.colors.accentPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rating pill — always shown for consistent premium look, even at 0.0.
class _RatingPill extends StatelessWidget {
  final Store store;
  const _RatingPill({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.star, size: 13, color: context.colors.accentGold),
          const SizedBox(width: 4),
          Text(
            store.rating.toStringAsFixed(1),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            S.of(context).shopStoreRatingCount('${store.ratingCount}'),
            style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Small pill/chip used for "Premium" and "Brawe Pass" badges.
class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Badge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Products grid (sliver) ────────────────────────────────────────────────
class _StoreProductsSliver extends ConsumerWidget {
  final String storeId;
  final int crossAxisCount;

  const _StoreProductsSliver({
    required this.storeId,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      storeProductsProvider((
        storeId: storeId,
        page: 1,
        limit: 20,
        search: null,
        sort: null,
      )),
    );

    return productsAsync.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.all(32),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(context.colors.accentPrimary),
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => SliverPadding(
        padding: const EdgeInsets.all(32),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).shopStoreProductsError,
                  style: TextStyle(color: context.colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(
                    storeProductsProvider((
                      storeId: storeId,
                      page: 1,
                      limit: 20,
                      search: null,
                      sort: null,
                    )),
                  ),
                  child: Text(S.of(context).actionRetry),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.all(32),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.packageOpen,
                      size: 48,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      S.of(context).shopStoreEmptyProducts,
                      style: TextStyle(color: context.colors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _StoreProductCard(product: products[index]),
              childCount: products.length,
            ),
          ),
        );
      },
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  final Product product;
  const _StoreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/shop/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: product.primaryImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: context.colors.surface),
                      errorWidget: (context, url, error) =>
                          _buildImagePlaceholder(context),
                    )
                  : _buildImagePlaceholder(context),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatBRL(product.price),
                    style: TextStyle(
                      color: context.colors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (product.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.star,
                          size: 12,
                          color: context.colors.accentGold,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
