import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/providers/marketplace_providers.dart';
import '../../../domain/models/marketplace_models.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../utils/currency_formatter.dart';

/// Public storefront page accessed via `/shop/store/:slug` route.
///
/// Displays the store's banner, header info (logo, name, rating,
/// description, categories), contact/social links and a responsive grid of
/// its products.
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
        loading: () => _buildLoadingState(context),
        error: (error, stackTrace) => _buildErrorState(context, ref),
        data: (store) => _StoreContent(store: store),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: context.colors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  context.colors.accentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: context.colors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      S.of(context).shopStoreError,
                      style: TextStyle(color: context.colors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(storeDetailProvider(storeSlug)),
                    child: Text(S.of(context).actionRetry),
                  ),
                ],
              ),
            ),
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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: context.colors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          expandedHeight: 200,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            store.name,
            style: TextStyle(color: context.colors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _StoreBanner(store: store),
          ),
        ),
        SliverToBoxAdapter(child: _StoreHeader(store: store)),
        SliverToBoxAdapter(child: _StoreContactRow(store: store)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              S.of(context).shopStoreProductsSection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _StoreProductsSliver(storeId: store.id, crossAxisCount: crossAxisCount),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─── Banner ──────────────────────────────────────────────────────────────
class _StoreBanner extends StatefulWidget {
  final Store store;
  const _StoreBanner({required this.store});

  @override
  State<_StoreBanner> createState() => _StoreBannerState();
}

class _StoreBannerState extends State<_StoreBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.store.banners;

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
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == i
                          ? context.colors.accentPrimary
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
    return Container(
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
      child: Center(
        child: widget.store.logoUrl != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.store.logoUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(
                    LucideIcons.store,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              )
            : const Icon(LucideIcons.store, size: 48, color: Colors.white),
      ),
    );
  }
}

// ─── Header (logo, name, badges, rating, description, categories) ────────
class _StoreHeader extends StatefulWidget {
  final Store store;
  const _StoreHeader({required this.store});

  @override
  State<_StoreHeader> createState() => _StoreHeaderState();
}

class _StoreHeaderState extends State<_StoreHeader> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              ClipOval(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: store.logoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: store.logoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _buildLogoPlaceholder(context),
                        )
                      : _buildLogoPlaceholder(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (store.isPremium)
                          _Badge(
                            label: S.of(context).shopStorePremiumBadge,
                            icon: LucideIcons.crown,
                            color: context.colors.accentGold,
                          ),
                        if (store.hasBrawePass)
                          _Badge(
                            label: S.of(context).shopStoreBravePassBadge,
                            icon: LucideIcons.sparkles,
                            color: context.colors.accentPrimary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.star,
                          size: 16,
                          color: context.colors.accentGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          S
                              .of(context)
                              .shopStoreRatingCount('${store.ratingCount}'),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (store.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDescription(context, store),
          ],

          if (store.categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: store.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = store.categories[index];
                  return Chip(
                    label: Text(category),
                    labelStyle: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 12,
                    ),
                    backgroundColor: context.colors.surfaceHighest,
                    side: BorderSide(color: context.colors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
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

  Widget _buildLogoPlaceholder(BuildContext context) {
    return Container(
      color: context.colors.surfaceHighest,
      child: Icon(
        LucideIcons.store,
        size: 28,
        color: context.colors.textSecondary,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

// ─── Contact / social icons row ───────────────────────────────────────────
class _StoreContactRow extends StatelessWidget {
  final Store store;
  const _StoreContactRow({required this.store});

  bool get _hasAnyContact =>
      (store.contactWhatsapp != null && store.contactWhatsapp!.isNotEmpty) ||
      (store.socialInstagram != null && store.socialInstagram!.isNotEmpty) ||
      (store.socialFacebook != null && store.socialFacebook!.isNotEmpty) ||
      (store.socialTiktok != null && store.socialTiktok!.isNotEmpty) ||
      (store.contactEmail != null && store.contactEmail!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyContact) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).shopStoreContactSection,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (store.contactWhatsapp != null &&
                  store.contactWhatsapp!.isNotEmpty)
                _ContactIcon(
                  iconWidget: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 16,
                    color: Color(0xFF25D366),
                  ),
                  tooltip: S.of(context).shopStoreWhatsappTooltip,
                  onTap: () => _launch(
                    context,
                    'https://wa.me/${_digitsOnly(store.contactWhatsapp!)}',
                  ),
                ),
              if (store.socialInstagram != null &&
                  store.socialInstagram!.isNotEmpty)
                _ContactIcon(
                  iconWidget: const FaIcon(
                    FontAwesomeIcons.instagram,
                    size: 16,
                    color: Color(0xFFE1306C),
                  ),
                  tooltip: S.of(context).shopStoreInstagramTooltip,
                  onTap: () => _launch(
                    context,
                    'https://instagram.com/${_stripHandle(store.socialInstagram!)}',
                  ),
                ),
              if (store.socialFacebook != null &&
                  store.socialFacebook!.isNotEmpty)
                _ContactIcon(
                  iconWidget: const FaIcon(
                    FontAwesomeIcons.facebook,
                    size: 16,
                    color: Color(0xFF1877F2),
                  ),
                  tooltip: S.of(context).shopStoreFacebookTooltip,
                  onTap: () => _launch(
                    context,
                    'https://facebook.com/${_stripHandle(store.socialFacebook!)}',
                  ),
                ),
              if (store.socialTiktok != null && store.socialTiktok!.isNotEmpty)
                _ContactIcon(
                  iconWidget: FaIcon(
                    FontAwesomeIcons.tiktok,
                    size: 16,
                    color: context.colors.textPrimary,
                  ),
                  tooltip: S.of(context).shopStoreTiktokTooltip,
                  onTap: () => _launch(
                    context,
                    'https://www.tiktok.com/@${_stripHandle(store.socialTiktok!)}',
                  ),
                ),
              if (store.contactEmail != null && store.contactEmail!.isNotEmpty)
                _ContactIcon(
                  iconWidget: Icon(
                    Icons.mail_outline,
                    size: 18,
                    color: context.colors.textSecondary,
                  ),
                  tooltip: S.of(context).shopStoreEmailTooltip,
                  onTap: () => _launch(context, 'mailto:${store.contactEmail}'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static String _stripHandle(String value) =>
      value.startsWith('@') ? value.substring(1) : value;

  static Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).shopStoreLinkError)));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ContactIcon extends StatelessWidget {
  final Widget iconWidget;
  final String tooltip;
  final VoidCallback onTap;

  const _ContactIcon({
    required this.iconWidget,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surfaceHighest,
            border: Border.all(color: context.colors.border),
          ),
          child: iconWidget,
        ),
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
