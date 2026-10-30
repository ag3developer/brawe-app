import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
import '../utils/currency_formatter.dart';
import '../widgets/shop_pill_button.dart';
import '../widgets/shop_promotion_badge.dart';
import '../widgets/vitrine_sort_sheet.dart';

/// Grid vs. list display for the vitrine's product catalog — same toggle
/// pattern as TikTok Shop's minimalist grid/list icon.
enum VitrineViewMode { grid, list }

/// Dedicated, fullscreen storefront page for a specific creator/partner.
///
/// Accessed via `/shop/creator/:userId` (route name `shop-creator-vitrine`).
/// This page is INTENTIONALLY never shown as a tab alongside posts/videos/
/// gallery in the profile — commerce and the social feed are different
/// contexts, so the vitrine always opens as its own fullscreen page (same
/// pattern as TikTok Shop), reachable via the storefront icon in the
/// profile's AppBar.
///
/// Usa o endpoint público `GET /marketplace/affiliate/{userId}/storefront`
/// (via [storefrontProductsProvider]) — funciona tanto para o próprio
/// usuário logado quanto para o perfil de qualquer outra pessoa, sem exigir
/// autenticação nem candidatura própria.
class ShopVitrinePage extends ConsumerStatefulWidget {
  final String userId;

  const ShopVitrinePage({super.key, required this.userId});

  @override
  ConsumerState<ShopVitrinePage> createState() => _ShopVitrinePageState();
}

class _ShopVitrinePageState extends ConsumerState<ShopVitrinePage> {
  VitrineSortOption _sortOption = VitrineSortOption.creatorChoice;
  VitrineViewMode _viewMode = VitrineViewMode.grid;

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final isMe = currentUserId == widget.userId;
    final profileState = ref.watch(profileViewModelProvider(widget.userId));

    final storefrontAsync = ref.watch(
      storefrontProductsProvider(widget.userId),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _VitrineAppBar(userId: widget.userId, cartVisible: true),
            Expanded(
              child: storefrontAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.braweBlue,
                  ),
                ),
                error: (_, _) => _EmptyStorefront(isMe: isMe),
                data: (products) {
                  final sorted = _sortProducts(products);
                  return CustomScrollView(
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
                      else ...[
                        SliverToBoxAdapter(
                          child: _VitrineFilterBar(
                            sortOption: _sortOption,
                            viewMode: _viewMode,
                            onSortTap: () => _openSortSheet(context),
                            onViewModeToggle: () => setState(() {
                              _viewMode = _viewMode == VitrineViewMode.grid
                                  ? VitrineViewMode.list
                                  : VitrineViewMode.grid;
                            }),
                          ),
                        ),
                        if (_viewMode == VitrineViewMode.grid)
                          _ProductsSliverGrid(products: sorted)
                        else
                          _ProductsSliverList(products: sorted),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = [...products];
    switch (_sortOption) {
      case VitrineSortOption.creatorChoice:
      case VitrineSortOption.bestSelling:
        sorted.sort((a, b) => b.totalSold.compareTo(a.totalSold));
      case VitrineSortOption.newest:
        sorted.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      case VitrineSortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case VitrineSortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
    }
    return sorted;
  }

  Future<void> _openSortSheet(BuildContext context) async {
    final result = await VitrineSortSheet.show(context, selected: _sortOption);
    if (result != null && mounted) {
      setState(() => _sortOption = result);
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          _CircleIconButton(
            icon: Icons.search,
            tooltip: S.of(context).shopVitrineSearchTooltip,
            onPressed: () {}, // TODO: busca dentro da vitrine (fase futura)
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.shopping_cart_outlined,
            tooltip: S.of(context).shopProductCartTooltip,
            badgeCount: cartItemCount,
            onPressed: () => context.push('/shop/cart'),
          ),
        ],
      ),
    );
  }
}

/// Circular, elevated icon button — consistent premium touch target used
/// across the shop module's top bars.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final int badgeCount;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: context.colors.surfaceElevated,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: context.colors.textPrimary),
        ),
      ),
    );

    final withBadge = badgeCount > 0
        ? Badge(label: Text('$badgeCount'), child: button)
        : button;

    // Semantics em vez de Tooltip — mesmo motivo documentado em
    // _VitrineFilterBar/_QuickActionButton (evita overlay de semântica
    // próprio que pode ser destruído durante uma transição de navegação).
    return tooltip != null
        ? Semantics(button: true, label: tooltip, child: withBadge)
        : withBadge;
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9500).withValues(alpha: 0.16),
            AppColors.braweBlue.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                color: Colors.white,
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
                  colors: [AppColors.braweBlue, AppColors.braweSky],
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
              ShopPillButton(
                label: S.of(context).profileShowcaseJoinCreatorNetwork,
                icon: const Icon(Icons.rocket_launch, size: 18),
                onPressed: () => context.push('/creator/intro'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── BARRA DE FILTRO (chip "Escolha do criador" + toggle grade/lista) ──────
/// Minimalist filter bar: tapping the chip opens [VitrineSortSheet]
/// ("Classificar por"); the icon on the right toggles grid ↔ list —
/// same interaction pattern as TikTok Shop's storefront.
class _VitrineFilterBar extends StatelessWidget {
  final VitrineSortOption sortOption;
  final VitrineViewMode viewMode;
  final VoidCallback onSortTap;
  final VoidCallback onViewModeToggle;

  const _VitrineFilterBar({
    required this.sortOption,
    required this.viewMode,
    required this.onSortTap,
    required this.onViewModeToggle,
  });

  String _label(BuildContext context) {
    final s = S.of(context);
    return switch (sortOption) {
      VitrineSortOption.creatorChoice => s.shopVitrineSortCreatorChoice,
      VitrineSortOption.bestSelling => s.shopVitrineSortBestSelling,
      VitrineSortOption.newest => s.shopVitrineSortNewest,
      VitrineSortOption.priceAsc => s.shopVitrineSortPriceAsc,
      VitrineSortOption.priceDesc => s.shopVitrineSortPriceDesc,
    };
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ Usa [Semantics] em vez de [Tooltip] de propósito: este widget vive
    // dentro do CustomScrollView/sliver da vitrine — um `Tooltip` cria seu
    // próprio nó de overlay/semântica, que pode ser descartado no meio de
    // uma transição de navegação (ao tocar num produto e a lista ser
    // desmontada) e disparava `Failed assertion:
    // '!semantics.parentDataDirty'`. `Semantics` só anota a árvore
    // existente, sem overlay, então não sofre desse problema — mesma
    // correção já aplicada em `_QuickActionButton`.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: S.of(context).shopVitrineFilterTooltip,
            child: Material(
              color: context.colors.surfaceHighest,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onSortTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.slidersHorizontal,
                        size: 14,
                        color: context.colors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _label(context),
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: S.of(context).shopVitrineViewModeTooltip,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onViewModeToggle,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    viewMode == VitrineViewMode.grid
                        ? LucideIcons.layoutList
                        : LucideIcons.layoutGrid,
                    size: 18,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
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

class _VitrineProductCard extends ConsumerWidget {
  final Product product;
  const _VitrineProductCard({required this.product});

  bool get _isSoldOut => product.quantity == 0;
  bool get _isLowStock => product.quantity > 0 && product.quantity <= 5;

  /// Build promotion badge widget (free shipping) by fetching store details
  Widget _buildPromotionBadge(BuildContext context, WidgetRef ref) {
    // If storeId is not available, return empty
    if (product.storeId == null) {
      return const SizedBox.shrink();
    }

    // Fetch store details using the new storeByIdProvider
    final storeAsync = ref.watch(storeByIdProvider(product.storeId!));

    return storeAsync.when(
      data: (store) {
        // If store is null or doesn't have free shipping threshold, hide badge
        if (store == null || store.freeShippingThreshold == null) {
          return const SizedBox.shrink();
        }

        // Show free shipping badge with threshold
        return ShopPromotionBadge.freeShippingThreshold(
          store.freeShippingThreshold!,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/shop/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
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
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Promotion badge (free shipping) — top right
                  if (product.storeId != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _buildPromotionBadge(context, ref),
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
                    style: TextStyle(
                      color: context.colors.accentPrimary,
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

// ── LISTA DE PRODUTOS (estilo TikTok Shop) ────────────────────────────────
/// Single-column list layout — each row shows a larger thumbnail, name,
/// price/sold-count and compact cart/buy shortcuts, mirroring the TikTok
/// Shop reference the user shared (list view with quick add-to-cart and
/// buy actions per row, instead of only opening the product page).
class _ProductsSliverList extends StatelessWidget {
  final List<Product> products;
  const _ProductsSliverList({required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      sliver: SliverList.separated(
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _VitrineProductListCard(product: products[i]),
      ),
    );
  }
}

class _VitrineProductListCard extends ConsumerWidget {
  final Product product;
  const _VitrineProductListCard({required this.product});

  bool get _isSoldOut => product.quantity == 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/shop/product/${product.id}'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.primaryImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: product.primaryImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: context.colors.background),
                            errorWidget: (_, _, _) => Container(
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    S.of(context).shopVitrineSoldOnline('${product.totalSold}'),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          formatBRL(product.price),
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isSoldOut) ...[
                        _QuickActionButton(
                          icon: LucideIcons.shoppingCart,
                          tooltip: S.of(context).shopProductAddToCart,
                          onTap: () => _quickAddToCart(context, ref),
                        ),
                        const SizedBox(width: 6),
                        _QuickActionButton(
                          icon: LucideIcons.shoppingBag,
                          filled: true,
                          tooltip: S.of(context).shopProductBuyNow,
                          onTap: () => _quickBuyNow(context, ref),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickAddToCart(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(cartNotifierProvider.notifier)
        .addItem(CartItemRequest(productId: product.id, quantity: 1));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? S.of(context).shopProductAddedToCart
              : S.of(context).shopProductAddToCartError,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// "Comprar agora" direto da lista: adiciona ao carrinho e pula para o
  /// checkout — mesmo comportamento de `_handleBuyNow` em
  /// `shop_product_page.dart`, só sem precisar abrir a página do produto.
  Future<void> _quickBuyNow(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(cartNotifierProvider.notifier)
        .addItem(CartItemRequest(productId: product.id, quantity: 1));
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopProductAddToCartError)),
      );
      return;
    }
    context.push('/shop/checkout');
  }
}

/// Minimalist round icon shortcut used in the list view's row — quick
/// "add to cart" (outlined) and "buy now" (filled, accent color).
///
/// ⚠️ Usa [Semantics] (label estático) em vez de [Tooltip] de propósito:
/// `Tooltip` cria um `OverlayEntry`/nó de semântica próprio que, dentro de
/// uma lista rolável (`SliverList`), pode ser descartado no meio de uma
/// transição de navegação (`context.push` ao tocar no item) e disparava
/// `Failed assertion: '!semantics.parentDataDirty'` ao voltar pra tela.
/// `Semantics` só anota a árvore existente, sem overlay, então não sofre
/// desse problema.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final String? tooltip;

  const _QuickActionButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: filled ? context.colors.accentPrimary : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: filled
              ? null
              : BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.border),
                ),
          child: Icon(
            icon,
            size: 15,
            color: filled
                ? context.colors.textOnAccent
                : context.colors.textPrimary,
          ),
        ),
      ),
    );

    return tooltip != null
        ? Semantics(button: true, label: tooltip, child: button)
        : button;
  }
}
