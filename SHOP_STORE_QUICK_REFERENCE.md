# 🏪 Shop Store Page - Quick Reference Guide

## 📍 Localização dos Arquivos

```
lib/
├─ ui/shop/pages/
│  └─ shop_store_page.dart ⭐ (arquivo principal, 940 linhas)
│
├─ ui/shop/widgets/
│  └─ product_store_card.dart (card da loja com "Ver Loja" button)
│
├─ domain/models/
│  └─ marketplace_models.dart (modelo Store @freezed)
│
├─ data/
│  ├─ services/
│  │  ├─ store_showcase_service.dart (interface)
│  │  └─ store_showcase_service_impl.dart (implementação)
│  │
│  ├─ repositories/
│  │  └─ marketplace_repository.dart (agregação de serviços)
│  │
│  └─ providers/
│     └─ marketplace_providers.dart (storeDetailProvider, storeProductsProvider)
│
└─ routing/
   └─ router.dart (rota /shop/store/:slug)
```

---

## 🚀 FLUXO EM 3 PASSOS

### 1. **NAVEGAÇÃO**
```dart
context.push('/shop/store/$storeSlug')
// ou
context.pushNamed('shop-store', pathParameters: {'slug': slug})
```

### 2. **CARREGAMENTO**
```dart
final storeAsync = ref.watch(storeDetailProvider(storeSlug));
// GET /marketplace/affiliate/showcase/:slug
```

### 3. **EXIBIÇÃO**
```dart
ShopStorePage → _StoreContent
  ├─ _StoreBanner (banners com PageView)
  ├─ _StoreHeader (logo, nome, badges, rating)
  ├─ _StoreContactRow (contatos/redes)
  └─ _StoreProductsSliver (grid de produtos)
```

---

## 📊 DADOS ESTRUTURA

```dart
Store {
  String slug          // ← Chave para rota /shop/store/:slug
  String name          // Exibido no header
  String description   // Expandível
  String? logoUrl      // Circular avatar
  String? bannerUrl    // FlexibleSpaceBar
  List<StoreBanner> banners  // PageView carousel
  List<String> categories    // Chips horizontais
  double rating        // ⭐ Avaliações
  int ratingCount      // Número de reviews
  bool isPremium       // Badge 👑
  bool hasBrawePass    // Badge ✨
  String? contactEmail // Links de contato
  String? contactWhatsapp
  String? socialInstagram
  String? socialFacebook
  String? socialTiktok
  
  double defaultAffiliateCommission ❌ NUNCA EXIBIR!
}
```

---

## 🔗 ENDPOINTS

| Método | Endpoint | Uso |
|--------|----------|-----|
| GET | `/marketplace/affiliate/showcase/{slug}` | Carregar loja |
| GET | `/marketplace/products/store/{storeId}` | Carregar produtos |

**Query Params (produtos)**:
- `page`: int (default 1)
- `limit`: int (default 20)
- `search`: String? (filtrar)
- `sort`: String? (ordenar)

---

## 🎯 WIDGETS & NAVEGAÇÃO

### ProductStoreCard → ShopStorePage
```
┌─────────────────────────┐
│  ProductStoreCard       │
│  ├─ Logo               │
│  ├─ Store Name         │
│  └─ [Ver Loja] ──┐    │
└─────────────────│────┘
                  │
                  ↓
             context.push(
              '/shop/store/$storeSlug'
             )
                  │
                  ↓
       ┌──────────────────────┐
       │  ShopStorePage       │
       │  (storeSlug: slug)   │
       └──────────────────────┘
```

### ShopStorePage → ShopProductPage
```
       ┌──────────────────────┐
       │  _StoreProductCard   │
       │  ├─ Image           │
       │  ├─ Name            │
       │  ├─ Price           │
       │  └─ [onTap] ─────┐  │
       └──────────────────┼──┘
                          │
                          ↓
                   context.push(
                    '/shop/product/${product.id}'
                   )
                          │
                          ↓
                ┌──────────────────────┐
                │  ShopProductPage     │
                │  (productId: id)     │
                └──────────────────────┘
```

---

## 🔒 SEGURANÇA

### ⚠️ NUNCA Exibir
```dart
Store.defaultAffiliateCommission  // Comissão padrão
CartItem.comissaoRate              // Taxa de comissão
CartItem.comissaoAmount            // Valor da comissão
Order.affiliateCommissionAmount    // Comissão total do pedido
```

**Por quê?** Comissão é informação privada entre loja e afiliado. Comprador não deve ver.

---

## 📱 RESPONSIVE DESIGN

```dart
// Grid columns baseado em width
final width = MediaQuery.of(context).size.width;
final crossAxisCount = width >= 1280 ? 4 
                     : (width >= 640 ? 3 
                     : 2);

// Mobile (< 640px): 2 colunas
// Tablet (640-1280px): 3 colunas  
// Desktop (> 1280px): 4 colunas
```

---

## 🎨 COMPONENTES VISUAIS

### States
| Estado | Exibe |
|--------|-------|
| **Loading** | Spinner circular |
| **Error** | Ícone erro + botão Retry |
| **Empty** | Ícone pacote vazio |
| **Data** | Conteúdo completo |

### Banners
- PageView com múltiplas imagens
- Indicadores de página (dots) na base
- Fallback: gradiente com logo

### Header
- Logo circular (ClipOval)
- Nome com max 2 linhas
- Badges Premium (👑) e BrawePass (✨)
- Rating com ⭐ e contagem

### Descrição
- Exibe 3 linhas por padrão
- "Ler Mais" → expande para completo
- "Ler Menos" → volta para 3 linhas

### Categorias
- Horizontal ListView com Chips
- Cada chip: label com categoria

### Contatos
- Ícones circulares em Wrap
- WhatsApp 💬 → wa.me/
- Instagram 📷 → instagram.com/
- Facebook 👥 → facebook.com/
- TikTok 🎵 → tiktok.com/
- Email ✉️ → mailto:

### Produtos
- Grid responsivo (2-4 colunas)
- Cada card: imagem, nome, preço, rating
- Clique abre `/shop/product/{id}`

---

## 💻 CÓDIGO CHAVE

### Rota GoRouter
```dart
// routing/router.dart (line 479)
GoRoute(
  path: '/shop/store/:slug',
  name: 'shop-store',
  pageBuilder: (context, state) {
    final slug = state.pathParameters['slug']!;
    return BraweTransitions.slideUp(
      key: state.pageKey,
      child: ShopStorePage(storeSlug: slug),
    );
  },
)
```

### Provider (FutureProvider)
```dart
// data/providers/marketplace_providers.dart
final storeDetailProvider = FutureProvider.family<Store, String>((
  ref,
  slug,
) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return await repo.getStoreBySlug(slug) as Store;
});
```

### Uso em Widget
```dart
// ui/shop/pages/shop_store_page.dart
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
```

### Navegação
```dart
// ui/shop/widgets/product_store_card.dart
OutlinedButton(
  onPressed: () => context.push('/shop/store/$storeSlug'),
  child: Text(S.of(context).shopProductViewStore),
)

// ui/shop/pages/shop_store_page.dart
GestureDetector(
  onTap: () => context.push('/shop/product/${product.id}'),
  child: // card do produto
)
```

---

## ✅ CHECKLIST

- ✅ Rota `/shop/store/:slug` registrada
- ✅ Slug como parâmetro de rota
- ✅ storeDetailProvider carrega Store
- ✅ Banner com PageView
- ✅ Logo, nome, badges, rating
- ✅ Descrição expandível
- ✅ Categorias em chips
- ✅ Links de contato (5 tipos)
- ✅ Grid responsivo de produtos
- ✅ Loading/Error/Empty states
- ✅ Navegação para /shop/product/{id}
- ✅ Modelo Store @freezed completo
- ✅ API endpoints documentados
- ✅ Comissão de afiliado NUNCA exibida

---

## 📞 LINKS DE CONTATO (Tratamento)

```dart
// WhatsApp: remove tudo menos dígitos
"(11) 98765-4321" → "5511987654321" → wa.me/5511987654321

// Instagram: remove @ se existir
"@brawe.official" → "brawe.official" → instagram.com/brawe.official

// Facebook: remove @ se existir
"@brawe.official" → "brawe.official" → facebook.com/brawe.official

// TikTok: remove @ se existir
"@brawe" → "brawe" → tiktok.com/@brawe

// Email: direto
"contact@brawe.io" → mailto:contact@brawe.io
```

**Implementação**:
```dart
static String _digitsOnly(String value) =>
    value.replaceAll(RegExp(r'[^0-9]'), '');

static String _stripHandle(String value) =>
    value.startsWith('@') ? value.substring(1) : value;
```

---

## 🎯 PONTOS DE EXTENSÃO FUTUROS

1. **Paginação de Produtos**
   - Adicionar "Load More" button ou infinite scroll
   - Modificar `_StoreProductsSliver` para suportar multiple pages

2. **Filtros**
   - Dropdown/chips para filtrar por categoria
   - Search bar para buscar produtos

3. **Reviews**
   - Seção de comentários/avaliações da loja
   - Formulário para deixar review

4. **Seguir Loja**
   - Botão "Seguir" com estado
   - Salvar em favoritos

5. **Analytics**
   - Tracking de visualizações
   - Tracking de cliques em contato
   - Tracking de cliques em produtos

---

**Última atualização**: 2026-07-11
**Status**: ✅ PRONTO PARA PRODUÇÃO
