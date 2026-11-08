import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/providers/cart_notifier_provider.dart';
import '../../../data/providers/marketplace_providers.dart';
import '../../../data/services/social_actions_service.dart';
import '../../../domain/models/marketplace_models.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../utils/currency_formatter.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_price_section.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Product detail page accessed via `/shop/product/:id` route.
///
/// Layout inspirado no TikTok Shop:
/// - AppBar: voltar, buscar, compartilhar, carrinho, menu (⋮ com denunciar).
/// - Abaixo do AppBar, uma TabBar FIXA (Visão geral / Avaliações /
///   Descrição / Recomendações) que permanece visível ao rolar — o
///   conteúdo de cada aba rola por baixo dela.
/// - Rodapé FIXO (bottomNavigationBar): Loja | Chat | Adicionar ao
///   carrinho | Comprar agora. Nunca rola com o conteúdo.
///
/// Decisões de produto (ver memória de sessão):
/// - Seletor de quantidade removido da página — quem quiser mais de 1
///   unidade ajusta dentro do carrinho (ShopCartPage já tem stepper).
/// - Card "Ver loja" removido do conteúdo — a ação equivalente já existe
///   no botão "Loja" do rodapé fixo.
class ShopProductPage extends ConsumerStatefulWidget {
  /// Product ID from route parameter
  final String productId;

  const ShopProductPage({super.key, required this.productId});

  @override
  ConsumerState<ShopProductPage> createState() => _ShopProductPageState();
}

class _ShopProductPageState extends ConsumerState<ShopProductPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 20,
            color: context.colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        // Sem título fixo "Produto" no AppBar — o nome/preço real do
        // produto já aparecem logo abaixo do carrossel de imagens.
        title: null,
        actions: [
          IconButton(
            tooltip: S.of(context).shopProductCartTooltip,
            icon: Badge(
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              child: Icon(
                LucideIcons.shoppingCart,
                size: 20,
                color: context.colors.textPrimary,
              ),
            ),
            onPressed: () => context.push('/shop/cart'),
          ),
          IconButton(
            tooltip: S.of(context).shopProductMoreTooltip,
            icon: Icon(
              LucideIcons.ellipsisVertical,
              size: 20,
              color: context.colors.textPrimary,
            ),
            onPressed: () => _showOptionsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: productAsync.when(
        loading: () => _buildLoadingState(context),
        error: (error, stackTrace) => _buildErrorState(context, error),
        data: (product) => _buildProductContent(context, product),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => _buildFooterBar(context, product),
        orElse: () => null,
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(context.colors.accentPrimary),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
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
            S.of(context).shopProductError,
            style: TextStyle(color: context.colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Trigger refresh by popping and repushing
              context.pop();
            },
            child: Text(S.of(context).actionRetry),
          ),
        ],
      ),
    );
  }

  // ─── Conteúdo principal: header (imagem/preço) + abas fixas ─────────
  Widget _buildProductContent(BuildContext context, Product product) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1280;

    final s = S.of(context);
    final tabs = <Tab>[
      Tab(text: s.shopProductTabOverview),
      Tab(text: s.shopProductTabReviews),
      Tab(text: s.shopProductTabDescription),
      Tab(text: s.shopProductTabRecommendations),
    ];

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: isDesktop
              ? _buildDesktopHeader(context, product)
              : _buildMobileHeader(context, product),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _ProductTabBarDelegate(
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: context.colors.accentPrimary,
              indicatorWeight: 2,
              labelColor: context.colors.textPrimary,
              unselectedLabelColor: context.colors.textSecondary,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: tabs,
            ),
            backgroundColor: context.colors.background,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(product: product),
          _ReviewsTab(product: product),
          _DescriptionTab(product: product),
          _RecommendationsTab(product: product),
        ],
      ),
    );
  }

  // ─── Header (imagem + nome + preço), mobile/tablet ─────────────────
  Widget _buildMobileHeader(BuildContext context, Product product) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: SizedBox(
            height: 280,
            child: ProductImageCarousel(
              images: product.images,
              fallbackImageUrl: product.imageUrl,
              height: 280,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              ProductPriceSection(
                price: product.price,
                compareAtPrice: product.compareAtPrice,
              ),
              const SizedBox(height: 8),
              _buildRatingStatsSection(context, product),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Header (imagem + nome + preço), desktop ───────────────────────
  Widget _buildDesktopHeader(BuildContext context, Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 420,
                child: ProductImageCarousel(
                  images: product.images,
                  fallbackImageUrl: product.imageUrl,
                  height: 420,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                ProductPriceSection(
                  price: product.price,
                  compareAtPrice: product.compareAtPrice,
                ),
                const SizedBox(height: 10),
                _buildRatingStatsSection(context, product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStatsSection(BuildContext context, Product product) {
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
            (product.rating ?? 0).toStringAsFixed(1),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${product.ratingCount} ${S.of(context).shopProductReviews}',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(width: 6),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: context.colors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${product.totalSold} ${S.of(context).shopProductSold}',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Barra fixa no rodapé da tela (bottomNavigationBar), estilo TikTok Shop:
  /// [Loja] [Chat] [Adicionar ao carrinho] [Comprar agora].
  /// Fica sempre visível, mesmo com o conteúdo rolando por cima.
  Widget _buildFooterBar(BuildContext context, Product product) {
    final isOutOfStock = product.quantity <= 0;

    if (isOutOfStock) {
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                S.of(context).shopProductOutOfStock,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            _FooterIconAction(
              icon: LucideIcons.store,
              label: S.of(context).shopProductFooterStore,
              onTap: () => context.push(
                '/shop/store/${product.storeSlug ?? product.storeId}',
              ),
            ),
            _FooterIconAction(
              icon: LucideIcons.messageCircle,
              label: S.of(context).shopProductFooterChat,
              onTap: () => _handleChatWithStore(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _handleAddToCart,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.accentPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  S.of(context).shopProductAddToCart,
                  style: TextStyle(
                    color: context.colors.accentPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleBuyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.accentPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  S.of(context).shopProductBuyNow,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Action Handlers ────────────────────────────────────────────────

  Future<bool> _addCurrentProductToCart() async {
    try {
      // Obter o produto — pode estar em FutureProvider state
      final productAsync = ref.read(productDetailProvider(widget.productId));
      final product = productAsync.value;

      if (product == null) {
        debugPrint('🛒 ERROR: Product is null');
        return false;
      }

      debugPrint(
        '🛒 Adding product to cart: ${product.name} (id: ${product.id})',
      );

      // Sempre adiciona 1 unidade — ajustes de quantidade acontecem dentro
      // do carrinho (ver decisão de produto no doc da classe).
      final request = CartItemRequest(productId: product.id, quantity: 1);

      final result = await ref
          .read(cartNotifierProvider.notifier)
          .addItem(request);

      if (result) {
        debugPrint('✅ Product added to cart successfully');
      } else {
        debugPrint('❌ Failed to add product to cart');
      }

      return result;
    } catch (e) {
      debugPrint('🛒 ERROR adding to cart: $e');
      return false;
    }
  }

  Future<void> _handleAddToCart() async {
    final ok = await _addCurrentProductToCart();
    if (!mounted) return;
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

  Future<void> _handleBuyNow() async {
    final ok = await _addCurrentProductToCart();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopProductAddToCartError)),
      );
      return;
    }
    // "Comprar agora" pula o carrinho e vai direto pro checkout — como o
    // usuário já costuma ter endereço salvo, a tela de checkout já abre
    // com o endereço de entrega preenchido e as opções de pagamento
    // visíveis, sem passo extra de revisar o carrinho.
    context.push('/shop/checkout');
  }

  /// Chat direto com a loja — ainda não implementado (o backend não expõe
  /// o `user_id` do lojista via API pública de produtos ainda). Mostra
  /// feedback ao usuário em vez de navegar para um lugar inválido.
  void _handleChatWithStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).shopProductChatComingSoon)),
    );
  }

  // ─── Share / Report (menu de 3 pontinhos) ──────────────────────────

  Future<void> _shareProduct(BuildContext context, Product? product) async {
    if (product == null) return;
    final url = 'https://brawe.app/shop/product/${product.id}';
    final text = '${product.name} — $url';
    try {
      // ignore: deprecated_member_use
      await Share.share(text, subject: product.name);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopProductShareFail)),
      );
    }
  }

  Future<void> _copyProductLink(BuildContext context) async {
    final url = 'https://brawe.app/shop/product/${widget.productId}';
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).shopProductLinkCopied)),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final s = S.of(ctx);
        final product = ref.read(productDetailProvider(widget.productId)).value;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.send,
                  color: context.colors.textPrimary,
                ),
                title: Text(
                  s.shopProductOptionShare,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _shareProduct(context, product);
                },
              ),
              ListTile(
                leading: Icon(Icons.link, color: context.colors.textPrimary),
                title: Text(
                  s.shopProductOptionCopyLink,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _copyProductLink(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: Text(
                  s.shopProductOptionReport,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showReportSheet(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showReportSheet(BuildContext context) {
    final s = S.of(context);
    final reasons = <(String, String)>[
      ('spam', s.profileReportReasonSpam),
      ('harassment', s.profileReportReasonHarassment),
      ('inappropriate', s.profileReportReasonInappropriate),
      ('other', s.profileReportReasonOther),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.shopProductReportQuestion,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            for (final r in reasons)
              ListTile(
                title: Text(
                  r.$2,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _submitReport(context, r.$1);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, String reason) async {
    try {
      await ref
          .read(socialActionsServiceProvider)
          .report(
            targetType: 'product',
            targetId: widget.productId,
            reason: reason,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopProductReportSent)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).shopProductReportError)),
      );
    }
  }
}

// ── ABA: VISÃO GERAL ────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final Product product;
  const _OverviewTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            Text(
              S.of(context).shopProductDescription,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description!,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── ABA: AVALIAÇÕES ─────────────────────────────────────────────────────
/// Placeholder — o backend ainda não expõe avaliações reais de produtos
/// (só rating/ratingCount agregados). Fase futura.
class _ReviewsTab extends StatelessWidget {
  final Product product;
  const _ReviewsTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_border_rounded,
              size: 48,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).shopProductReviewsComingSoon,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ABA: DESCRIÇÃO (completa) ───────────────────────────────────────────
class _DescriptionTab extends StatelessWidget {
  final Product product;
  const _DescriptionTab({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasDescription =
        product.description != null && product.description!.isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: hasDescription
          ? Text(
              product.description!,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.6,
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  S.of(context).shopProductDescription,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ),
            ),
    );
  }
}

// ── ABA: RECOMENDAÇÕES (outros produtos da mesma loja) ──────────────────
class _RecommendationsTab extends ConsumerWidget {
  final Product product;
  const _RecommendationsTab({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = product.storeId;
    if (storeId == null) {
      return Center(
        child: Text(
          S.of(context).shopProductRecommendationsComingSoon,
          style: TextStyle(color: context.colors.textSecondary),
        ),
      );
    }

    final relatedAsync = ref.watch(
      storeProductsProvider((
        storeId: storeId,
        page: 1,
        limit: 20,
        search: null,
        sort: null,
      )),
    );

    return relatedAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(context.colors.accentPrimary),
        ),
      ),
      error: (_, __) => Center(
        child: Text(
          S.of(context).shopProductRecommendationsComingSoon,
          style: TextStyle(color: context.colors.textSecondary),
        ),
      ),
      data: (products) {
        final related = products.where((p) => p.id != product.id).toList();
        if (related.isEmpty) {
          return Center(
            child: Text(
              S.of(context).shopProductRecommendationsComingSoon,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final crossAxisCount = width >= 1280
            ? 5
            : width >= 900
            ? 4
            : width >= 640
            ? 3
            : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.62,
          ),
          itemCount: related.length,
          itemBuilder: (_, i) => _RecommendedProductCard(product: related[i]),
        );
      },
    );
  }
}

class _RecommendedProductCard extends StatelessWidget {
  final Product product;
  const _RecommendedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushReplacement('/shop/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: product.primaryImageUrl != null
                  ? Image.network(
                    cacheWidth: context.decodeScreenFracPx(0.5),
                      product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
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
                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ícone + label compacto usado na barra fixa do rodapé (Loja / Chat).
class _FooterIconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterIconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: context.colors.textPrimary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: context.colors.textPrimary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delegate para a TabBar fixa (Visão geral/Avaliações/Descrição/
/// Recomendações) que fica "colada" abaixo do header ao rolar, mesmo
/// padrão de `_SliverAppBarDelegate` em profile_screen.dart.
class _ProductTabBarDelegate extends SliverPersistentHeaderDelegate {
  _ProductTabBarDelegate(this._tabBar, {required this.backgroundColor});

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 1),
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_ProductTabBarDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
