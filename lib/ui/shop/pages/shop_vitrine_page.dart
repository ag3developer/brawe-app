import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/cart_notifier_provider.dart';
import '../../../data/providers/marketplace_providers.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/marketplace_models.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/profile_state.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/view_models/profile_view_model.dart';

/// Dedicated, fullscreen storefront page for a specific creator/partner.
///
/// Accessed via `/shop/creator/:userId` (route name `shop-creator-vitrine`).
/// This page is INTENTIONALLY never shown as a tab alongside posts/videos/
/// gallery in the profile — commerce and the social feed are different
/// contexts, so the vitrine always opens as its own fullscreen page (same
/// pattern as TikTok Shop), reachable via the storefront icon in the
/// profile's AppBar.
///
/// ⚠️ Gap de backend conhecido: só há dados reais de parceria/produtos para
/// o PRÓPRIO usuário logado (`myStorefrontProductsProvider` usa o endpoint
/// "my-applications"). Para o perfil de outra pessoa, mostramos o mesmo
/// empty state até existir um endpoint público de vitrine por `userId`
/// (`GET /marketplace/affiliate/{user_id}/storefront`, ainda não criado).
class ShopVitrinePage extends ConsumerWidget {
  final String userId;

  const ShopVitrinePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final isMe = currentUserId == userId;
    final profileState = ref.watch(profileViewModelProvider(userId));

    final storefrontAsync = isMe
        ? ref.watch(myStorefrontProductsProvider)
        : const AsyncValue<List<Product>>.data(<Product>[]);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _VitrineAppBar(userId: userId, cartVisible: true),
            Expanded(
              child: storefrontAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.electricPurple,
                  ),
                ),
                error: (_, __) => _EmptyStorefront(isMe: isMe),
                data: (products) => CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _VitrineHeader(
                        profileState: profileState,
                        productsCount: products.length,
                      ),
                    ),
                    if (products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyStorefront(isMe: isMe),
                      )
                    else
                      _ProductsSliverGrid(products: products),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── APP BAR ──────────────────────────────────────────────────────────────
class _VitrineAppBar extends ConsumerWidget {
  final String userId;
  final bool cartVisible;
  const _VitrineAppBar({required this.userId, required this.cartVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemCount = ref.watch(cartItemCountProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.search, color: context.colors.textPrimary),
            tooltip: S.of(context).shopVitrineSearchTooltip,
            onPressed: () {}, // TODO: busca dentro da vitrine (fase futura)
          ),
          IconButton(
            tooltip: S.of(context).shopProductCartTooltip,
            icon: Badge(
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              child: Icon(
                Icons.shopping_cart_outlined,
                color: context.colors.textPrimary,
              ),
            ),
            onPressed: () => context.push('/shop/cart'),
          ),
        ],
      ),
    );
  }
}

// ── HEADER (avatar + nome + seguidores + produtos) ─────────────────────────
class _VitrineHeader extends StatelessWidget {
  final ProfileState profileState;
  final int productsCount;
  const _VitrineHeader({
    required this.profileState,
    required this.productsCount,
  });

  @override
  Widget build(BuildContext context) {
    return profileState.profile.when(
      loading: () => const SizedBox(height: 96),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) => _buildHeader(context, profile),
    );
  }

  Widget _buildHeader(BuildContext context, Profile profile) {
    final stats = profileState.stats.asData?.value;
    final displayName =
        profile.displayName ??
        profile.username ??
        S.of(context).profileUserFallback;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.colors.surfaceElevated,
                backgroundImage: profile.avatarUrl != null
                    ? CachedNetworkImageProvider(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Icon(Icons.person, color: context.colors.textSecondary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  S.of(context).shopVitrineTitle(displayName),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatItem(
                value: _fmt(stats?.followersCount ?? 0),
                label: S.of(context).profileStatFollowers,
              ),
              const SizedBox(width: 20),
              _StatItem(
                value: '$productsCount',
                label: S.of(context).profileShopAllProducts,
              ),
            ],
          ),
          if (productsCount > 0) ...[
            const SizedBox(height: 14),
            _PartnerBadge(productsCount: productsCount),
          ],
        ],
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

/// Badge "Parceiro verificado" — mostrado APENAS dentro da vitrine dedicada
/// (nunca no perfil social). Indica que o criador é um parceiro aprovado
/// de pelo menos uma marca e exibe quantos itens ele promove.
class _PartnerBadge extends StatelessWidget {
  final int productsCount;
  const _PartnerBadge({required this.productsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9500).withValues(alpha: 0.2),
            AppColors.electricPurple.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9500).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Color(0xFFFF9500), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).profileSellerVerified,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  S.of(context).profileSellerSubtitle,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              S.of(context).shopVitrinePartnerItemsCount(productsCount),
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ESTADO VAZIO ─────────────────────────────────────────────────────────
/// Convida o criador a se tornar parceiro de marcas (quando é o próprio
/// perfil) ou informa que o criador ainda não tem produtos (perfil de
/// terceiros).
class _EmptyStorefront extends StatelessWidget {
  final bool isMe;
  const _EmptyStorefront({required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.electricPurple, AppColors.hotPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isMe
                  ? S.of(context).profileShowcaseEmptyTitleMe
                  : S.of(context).profileShowcaseEmptyTitleOther,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isMe
                  ? S.of(context).profileShowcaseEmptySubtitleMe
                  : S.of(context).profileShowcaseEmptySubtitleOther,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (isMe) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/creator/intro'),
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: Text(S.of(context).profileShowcaseJoinCreatorNetwork),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.electricPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── GRID DE PRODUTOS (responsivo) ───────────────────────────────────────
class _ProductsSliverGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductsSliverGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    // Ordena por mais vendidos primeiro (heurística simples para MVP, já
    // que o backend não expõe um campo "isFeatured").
    final sorted = [...products]
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

    // Grid responsivo: mais colunas em telas largas (tablet/desktop),
    // mesmo padrão de breakpoints usado em shop_store_page.dart.
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1280
        ? 5
        : width >= 900
        ? 4
        : width >= 640
        ? 3
        : 2;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _VitrineProductCard(product: sorted[i]),
          childCount: sorted.length,
        ),
      ),
    );
  }
}

class _VitrineProductCard extends StatelessWidget {
  final Product product;
  const _VitrineProductCard({required this.product});

  bool get _isSoldOut => product.quantity == 0;
  bool get _isLowStock => product.quantity > 0 && product.quantity <= 5;

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
            // Usa Expanded (em vez de AspectRatio fixo) para que a imagem
            // ocupe o espaço restante da célula do grid, evitando overflow
            // ou espaço morto quando o childAspectRatio/breakpoint muda.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.primaryImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: context.colors.background),
                          errorWidget: (_, __, ___) => Container(
                            color: context.colors.background,
                            child: Icon(
                              Icons.image_outlined,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        )
                      : Container(
                          color: context.colors.background,
                          child: Icon(
                            Icons.image_outlined,
                            color: context.colors.textSecondary,
                          ),
                        ),
                  if (_isSoldOut)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).profileProductSoldOutUppercase,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else if (_isLowStock)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          S
                              .of(context)
                              .profileProductLastStock(product.quantity),
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.coolCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    S.of(context).profileProductSoldCount(product.totalSold),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
