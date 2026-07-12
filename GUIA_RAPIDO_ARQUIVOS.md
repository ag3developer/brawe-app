# 📂 GUIA RÁPIDO: Onde Encontrar O Quê?

## 🗺️ MAPA DE ARQUIVOS

### 1. ESTADO DO CARRINHO (Riverpod)
```
📁 lib/data/providers/cart_notifier_provider.dart

class CartState {                    ← Estado imutável do carrinho
  Cart? cart;
  bool isLoading;
  String? error;
  int get itemCount;                ← Computed: soma de quantities
  double get total;                 ← Computed: total price
}

class CartNotifier extends Notifier<CartState> {
  build()                            ← Carrega carrinho inicial
  loadCart({sessionId})              ← GET /marketplace/cart
  addItem(request)                   ← POST /marketplace/cart/items
  updateQuantity(id, quantity)       ← PUT /marketplace/cart/items/:id
  removeItem(id)                     ← DELETE /marketplace/cart/items/:id
  clear()                            ← DELETE /marketplace/cart
}

final cartNotifierProvider = NotifierProvider(CartNotifier.new)
final cartItemCountProvider = Provider((ref) => itemCount)
```

**Como usar:**
```dart
// No build():
final cartState = ref.watch(cartNotifierProvider);
cartState.items        // List<CartItem>
cartState.total        // double
cartState.isLoading    // bool
cartState.error        // String?

// Para ações:
ref.read(cartNotifierProvider.notifier).addItem(request);
ref.read(cartNotifierProvider.notifier).removeItem(id);

// Para badge:
final count = ref.watch(cartItemCountProvider);
```

---

### 2. UI DO CARRINHO
```
📁 lib/ui/shop/pages/shop_cart_page.dart

class ShopCartPage extends ConsumerWidget {
  build()                            ← Main scaffold
  _buildBody()                       ← Loading/empty/items
  _buildEmptyState()                 ← Mostra "Carrinho vazio"
  _buildFooter()                     ← Totais + botão checkout
  _confirmClearCart()                ← Dialog para limpar tudo
}

class _CartItemTile extends ConsumerWidget {
  build()                            ← Um item do carrinho
  _buildQuantityControls()           ← +/- e input
  _buildRemoveButton()               ← Botão remover
}
```

**Como estilizar:**
```dart
// Cores:
context.colors.background           // Fundo da página
context.colors.surface              // Cards/itens
context.colors.textPrimary          // Texto principal
context.colors.accentPrimary        // Botões/destaques

// Localizações:
S.of(context).shopCartTitle
S.of(context).shopCartEmpty
S.of(context).shopCartCheckout
```

**Como adicionar lógica:**
```dart
// Ao clicar botão de checkout:
context.push('/shop/checkout')

// Ao remover item:
ref.read(cartNotifierProvider.notifier).removeItem(cartItemId)

// Ao atualizar quantidade:
ref.read(cartNotifierProvider.notifier).updateQuantity(itemId, newQty)
```

---

### 3. SERVIÇO DE CARRINHO
```
📁 lib/data/services/marketplace_cart_service.dart      ← Interface
📁 lib/data/services/marketplace_cart_service_impl.dart  ← Implementação

abstract class MarketplaceCartService {
  getCart({sessionId})               ← GET /marketplace/cart
  addItem(request, sessionId)        ← POST /marketplace/cart/items
  updateItem(id, request)            ← PUT /marketplace/cart/items/:id
  removeItem(id)                     ← DELETE /marketplace/cart/items/:id
  clearCart()                        ← DELETE /marketplace/cart
}

// Implementação usa: Dio (_dio)
// Converte JSON → CartItem/Cart (Freezed models)
// Trata DioException → AppException
```

**Endpoints:**
```
GET    /marketplace/cart?session_id=anon_xxx
POST   /marketplace/cart/items
       {product_id, quantity, affiliate_ref_code?, room_id?}
PUT    /marketplace/cart/items/{cartItemId}
       {quantity}
DELETE /marketplace/cart/items/{cartItemId}
DELETE /marketplace/cart
```

---

### 4. CHECKOUT - PÁGINA
```
📁 lib/ui/shop/pages/shop_checkout_page.dart

class ShopCheckoutPage extends ConsumerStatefulWidget {
  build()                            ← Scaffold + form
  _buildMobileLayout()               ← Single column
  _buildDesktopLayout()              ← Left form, right summary
}

class _ShopCheckoutPageState extends ConsumerState {
  // Controllers:
  _nameController
  _emailController
  _phoneController
  _documentController
  _streetController
  _numberController
  _complementController
  _neighborhoodController
  _cityController
  _stateController
  _postalCodeController
  
  // State:
  _selectedAddress
  _shippingMethod         ← _ShippingMethod.standard/express
  _paymentMethod          ← _PaymentMethod.pix/card/crypto
  _isSubmitting
  _isSavingAddress
  
  // Métodos:
  _buildAddressSection()  ← Endereço entrega (nova ou salva)
  _buildCustomerSection() ← Nome, email, telefone, documento
  _buildShippingSection() ← Método envio (dropdown)
  _buildPaymentSection()  ← Método pagamento (segmented)
  _buildSummarySection()  ← Resumo de itens + totais
  _buildConfirmButton()   ← Botão "Confirmar Pedido"
  _submitCheckout()       ← Valida + chama checkout()
}
```

**Como adicionar validação de CEP:**
```dart
// Adicionar após preencher CEP:
final address = await ViaCepService.getAddress(_postalCodeController.text);
if (address != null) {
  _cityController.text = address.city;
  _stateController.text = address.state;
  _neighborhoodController.text = address.neighborhood;
}
```

**Como integrar endereços salvos:**
```dart
// No build:
final savedAddresses = ref.watch(addressesProvider);

// Em _buildAddressSection:
if (savedAddresses.isNotEmpty) {
  // Mostrar dropdown com endereços
  // Permitir criar novo
}
```

---

### 5. CHECKOUT - SERVIÇO
```
📁 lib/data/services/marketplace_checkout_service.dart      ← Interface
📁 lib/data/services/marketplace_checkout_service_impl.dart  ← Implementação

abstract class MarketplaceCheckoutService {
  checkout(request, affiliateId?)    ← POST /marketplace/orders
  createPayment(request)             ← POST /shopping/payments/create
  getPaymentStatus(paymentId)        ← GET /shopping/payments/:id/status
}

// Usa: _mainDio (Main Backend), _connectDio (Connect Backend)
// checkout() usa Main Backend
// createPayment() usa Connect Backend
```

**Endpoints:**
```
POST /marketplace/orders
     {shipping_address, customer_name, customer_email,
      shipping_method, payment_method, affiliate_id?, session_id?}
     → Order {id, number, status, payment_status, affiliate_commission_amount}

POST /shopping/payments/create
     {order_id, amount, method, metadata?}
     → PaymentIntent {id, status, payment_url?}

GET /shopping/payments/{paymentId}/status
     → PaymentIntent {status, error?}
```

---

### 6. ENDEREÇOS
```
📁 lib/data/services/marketplace_address_service.dart      ← Interface
📁 lib/data/services/marketplace_address_service_impl.dart  ← Implementação

abstract class MarketplaceAddressService {
  getAddresses()                     ← GET /marketplace/shipping-addresses
  createAddress(request)             ← POST /marketplace/shipping-addresses
  setDefault(addressId)              ← PUT /marketplace/shipping-addresses/:id/default
  deleteAddress(addressId)           ← DELETE /marketplace/shipping-addresses/:id
}
```

**Endpoints:**
```
GET    /marketplace/shipping-addresses
POST   /marketplace/shipping-addresses
       {street, number, neighborhood, city, state, postalCode, ...}
PUT    /marketplace/shipping-addresses/{id}/default
DELETE /marketplace/shipping-addresses/{id}
```

**⚠️ NOTA:** Service criado mas **NÃO integrado no UI do checkout** ainda.

---

### 7. MODELS (Freezed)
```
📁 lib/domain/models/marketplace_models.dart

@freezed sealed class Product { ... }
@freezed sealed class ShippingAddress { ... }
@freezed sealed class CartItem { ... }
@freezed sealed class Cart { ... }
@freezed sealed class OrderItem { ... }
@freezed sealed class Order { ... }
@freezed sealed class PaymentIntent { ... }
@freezed sealed class CheckoutRequest { ... }
@freezed sealed class CartItemRequest { ... }
@freezed sealed class PaymentRequest { ... }

// Gera automaticamente:
// - Constructor com named parameters
// - .copyWith()
// - .toString()
// - .==(), .hashCode
// - .fromJson(), .toJson()
```

**Enums:**
```dart
enum OrderStatus { pending, confirmed, processing, shipped, delivered, ... }
enum PaymentStatus { pending, awaitingPayment, paid, failed, refunded }
enum ApplicationStatus { pending, approved, rejected, cancelled }
```

---

### 8. REPOSITORY
```
📁 lib/data/repositories/marketplace_repository.dart

class MarketplaceRepository {
  // Agregador de services:
  storeShowcaseService
  productService
  cartService
  checkoutService
  addressService
  
  // Métodos:
  getCart()                      ← Chama cartService.getCart()
  addToCart()                    ← Chama cartService.addItem()
  updateCartItem()               ← Chama cartService.updateItem()
  removeFromCart()               ← Chama cartService.removeItem()
  clearCart()                    ← Chama cartService.clearCart()
  
  checkout()                     ← Chama checkoutService.checkout()
  createPayment()                ← Chama checkoutService.createPayment()
  getPaymentStatus()             ← Chama checkoutService.getPaymentStatus()
  
  getAddresses()                 ← Chama addressService.getAddresses()
  createAddress()                ← Chama addressService.createAddress()
  setDefaultAddress()            ← Chama addressService.setDefault()
  deleteAddress()                ← Chama addressService.deleteAddress()
}

// Provider:
final marketplaceRepositoryProvider = Provider((ref) => MarketplaceRepository(...))
```

**Como usar:**
```dart
final repo = ref.watch(marketplaceRepositoryProvider);

// Carrinho:
await repo.getCart(sessionId: sessionId);
await repo.addToCart(request, sessionId: sessionId);

// Checkout:
final order = await repo.checkout(checkoutRequest, affiliateId: affiliateId);
final payment = await repo.createPayment(paymentRequest);

// Endereços:
final addresses = await repo.getAddresses();
await repo.createAddress(addressRequest);
```

---

### 9. PAGAMENTO (Mock)
```
📁 lib/ui/shop/pages/shop_payment_page.dart

class ShopPaymentPage extends ConsumerWidget {
  orderId                            ← Recebe via route param
  build()                            ← Mostra mock de pagamento
  _buildPixMock()                    ← QR code placeholder + confirmação
}

// Mostra:
// - Order ID
// - PIX: QR code + "Já paguei"
// - Card/Crypto: "Coming soon"
```

**⚠️ TODO:**
- Integrar Wolknow (real QR code)
- Chamar createPayment()
- Polling de payment_status
- Sucesso/erro handling

---

### 10. ROTAS
```
📁 lib/routing/router.dart (linhas ~495-549)

GoRoute(
  path: '/shop/vitrine',
  → ShopVitrinnePage()
)

GoRoute(
  path: '/shop/product/:id',
  → ShopProductPage(productId: id)
)

GoRoute(
  path: '/shop/cart',
  → ShopCartPage()
)

GoRoute(
  path: '/shop/checkout',
  → ShopCheckoutPage()
  routes: [
    GoRoute(
      path: 'payment/:orderId',
      → ShopPaymentPage(orderId: orderId)
    )
  ]
)

GoRoute(
  path: '/shop/orders',
  → Placeholder()  ❌ TODO
  routes: [
    GoRoute(
      path: ':orderNumber',
      → Placeholder()  ❌ TODO
    )
  ]
)
```

---

## 🔍 COMO ENCONTRAR...

### "Onde está o carrinho?"
→ `lib/data/providers/cart_notifier_provider.dart` (estado)  
→ `lib/ui/shop/pages/shop_cart_page.dart` (UI)

### "Como adiciono item ao carrinho?"
→ `lib/ui/shop/pages/shop_product_page.dart` linha ~442  
→ Chama: `ref.read(cartNotifierProvider.notifier).addItem(request)`

### "Onde está o formulário de checkout?"
→ `lib/ui/shop/pages/shop_checkout_page.dart` (Todo o formulário)

### "Onde é criado o Order?"
→ `lib/data/services/marketplace_checkout_service_impl.dart` linha ~30  
→ Endpoint: `POST /marketplace/orders`

### "Como as rotas são registradas?"
→ `lib/routing/router.dart` linhas ~495-549

### "Onde estão os models?"
→ `lib/domain/models/marketplace_models.dart` (Freezed)

### "Como adiciono validação de CEP?"
→ Seria em `lib/ui/shop/pages/shop_checkout_page.dart`  
→ Após preencher `_postalCodeController`, chamar ViaCEP API  
→ Auto-completar cidade, estado, bairro

### "Como integro endereços salvos?"
→ Service já existe: `lib/data/services/marketplace_address_service.dart`  
→ Falta: Adicionar provider + mostrar dropdown em checkout

### "Como faço polling de pagamento?"
→ Service: `lib/data/services/marketplace_checkout_service_impl.dart`  
→ Método: `getPaymentStatus(paymentId)`  
→ Falta: Implementar no ShopPaymentPage (atualmente é mock)

---

## 🛠️ PADRÕES DE CÓDIGO

### Adicionar nova ação ao carrinho

```dart
// 1. Adicionar método em CartNotifier:
Future<bool> novoMetodo() async {
  state = state.copyWith(isLoading: true, clearError: true);
  try {
    await _repo.metodoDoRepository();
    await loadCart();  // Recarregar
    return true;
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
    return false;
  }
}

// 2. Usar em UI:
ref.read(cartNotifierProvider.notifier).novoMetodo();
```

### Observar estado do carrinho

```dart
// Observar tudo:
final state = ref.watch(cartNotifierProvider);

// Observar só erro:
final error = ref.watch(cartNotifierProvider.select((s) => s.error));

// Observar só itens:
final items = ref.watch(cartNotifierProvider.select((s) => s.items));
```

### Fazer POST com Dio

```dart
final response = await _dio.post(
  '/marketplace/cart/items',
  data: request.toJson(),
  queryParameters: {'session_id': sessionId},
);
final data = extractMap(response.data);
return CartItem.fromJson(data);
```

---

## ✅ CHECKLIST RÁPIDO

- [ ] **Testar fluxo:** Product → Cart → Checkout → Payment mock
- [ ] **Definir affiliate_id origin:** Provider? localStorage? URL?
- [ ] **Persistir session ID:** Integrar `shared_preferences`
- [ ] **Endereços salvos:** Integrar AddressService no checkout UI
- [ ] **Validação de CEP:** Chamar ViaCEP API
- [ ] **Criar /shop/orders:** Listar orders do usuário
- [ ] **Integrar Wolknow:** Real payment (fora de scope agora)

---

## 📞 REFERÊNCIAS RÁPIDAS

| Preciso de... | Arquivo | O quê |
|---------------|---------|-------|
| Estado carrinho | `cart_notifier_provider.dart` | CartState, CartNotifier |
| UI carrinho | `shop_cart_page.dart` | ShopCartPage |
| Ações carrinho | `cart_notifier_provider.dart` | addItem, updateQuantity, removeItem |
| Formulário checkout | `shop_checkout_page.dart` | Todos os controllers + campos |
| Criar Order | `marketplace_checkout_service_impl.dart` | checkout() |
| Models | `marketplace_models.dart` | Todos (Freezed) |
| Repository | `marketplace_repository.dart` | Agregador de services |
| Rotas | `router.dart` | GoRoute definitions |
| Endereços | `marketplace_address_service.dart` | getAddresses, createAddress |
| Pagamento | `shop_payment_page.dart` | Mock payment UI |

---

**Última atualização:** 2026-07-11
