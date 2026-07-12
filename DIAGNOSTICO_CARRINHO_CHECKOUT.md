# 🛒 DIAGNÓSTICO COMPLETO: Carrinho + Checkout

**Data:** 2026-07-11  
**Versão:** brawe-app Flutter  
**Escopo:** Fase 0 MVP — Carrinho compartilhado + Checkout

---

## 📊 RESUMO EXECUTIVO

| Componente | Status | Completude | Notas |
|-----------|--------|-----------|-------|
| **Carrinho (`/shop/cart`)** | ✅ Funcional | 95% | Pronto, falta persistência de session anônima |
| **Checkout (`/shop/checkout`)** | ⚠️ Parcial | 70% | Formulário OK, faltam endereços salvos + CEP + affiliate_id |
| **Pagamento (`/shop/checkout/payment/:orderId`)** | ⚠️ Mock | 20% | Sem integração Wolknow |
| **Meus Pedidos (`/shop/orders`)** | ❌ Placeholder | 0% | Precisa ser criado (Fase 4/5) |
| **Modelos** | ✅ Completo | 100% | Cart, CartItem, Order, ShippingAddress, etc. |
| **Services** | ✅ Pronto | 90% | CartService, CheckoutService, AddressService |
| **Rotas** | ✅ Registrado | 100% | `/shop/cart`, `/shop/checkout`, `/shop/checkout/payment/:orderId` |

**NOTA:** App está **75% pronto para testes de fluxo** sem integração de pagamento real.

---

## 1️⃣ CARRINHO — ✅ ESTADO PRONTO

### 📁 Arquivos Principais
```
lib/data/providers/cart_notifier_provider.dart
lib/ui/shop/pages/shop_cart_page.dart
lib/data/services/marketplace_cart_service_impl.dart
lib/domain/models/marketplace_models.dart
```

### ✅ Implementado
- **Provider:** `CartNotifier` (Riverpod `Notifier`) + `cartNotifierProvider`
- **Página:** `ShopCartPage` — mostra itens, quantidades, totais
- **Rota:** `/shop/cart` registrada (transition: slideUp)
- **Ações:**
  - ✅ `loadCart()` — busca carrinho do servidor
  - ✅ `addItem(CartItemRequest)` — adiciona produto
  - ✅ `updateQuantity(cartItemId, quantity)` — muda quantidade
  - ✅ `removeItem(cartItemId)` — remove item
  - ✅ `clear()` — limpa tudo
  - ✅ Suporte anônimo via `CartSession.id` (session_id)

### ⚠️ Gaps
- **Persistência de session ID anônimo:** Em memória apenas
  - *Solução:* Usar `shared_preferences` para persistir entre restarts
  
- **Suporte a afiliados:** `CartItem` tem campos `affiliate_ref_code` + `room_id`, mas **origem do afiliado não é rastreada durante add**
  - *Solução:* Integrar com provider que sabe qual afiliado referiu

### Estado da CartState (Riverpod)
```dart
class CartState {
  final Cart? cart;           // { id, items[], subtotal, tax, total }
  final bool isLoading;
  final String? error;
  
  // Computed:
  int get itemCount;          // soma de quantities
  double get subtotal;        // automaticamente calculado
  double get total;           // subtotal + tax
}
```

### Modelo CartItem
```dart
@freezed
sealed class CartItem {
  final String id;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  
  // ⭐ Suporte Afiliado:
  final String? affiliateRefCode;  // Código de referência
  final String? roomId;             // Se comprou em live stream
  final double? comissaoRate;       // Taxa (calculada backend)
  final double? comissaoAmount;     // Valor (calculada backend)
}
```

---

## 2️⃣ CHECKOUT — ⚠️ 70% PRONTO

### 📁 Arquivos Principais
```
lib/ui/shop/pages/shop_checkout_page.dart
lib/data/services/marketplace_checkout_service_impl.dart
lib/data/services/marketplace_address_service_impl.dart
```

### ✅ Implementado
- **Página:** `ShopCheckoutPage` (ConsumerStatefulWidget)
- **Rota:** `/shop/checkout` registrada (transition: slideUp)
- **Formulário coletando:**
  - ✅ **Endereço:** street, number, complement, neighborhood, city, state, postalCode
  - ✅ **Cliente:** name, email, phone, document (CPF/CNPJ)
  - ✅ **Envio:** dropdown com `standard` e `express`
  - ✅ **Pagamento:** segmented control com `pix`, `card`, `crypto`
  - ✅ **Resumo:** mostra itens, subtotal, tax, total do carrinho
  - ✅ **Layout responsivo:** mobile e desktop

### Fluxo de Checkout
```
1. Usuário preenche formulário
   ↓
2. Valida campos (validation: required, email, etc.)
   ↓
3. Clica "Confirmar Pedido"
   ↓
4. Chama: MarketplaceRepository.checkout(checkoutRequest, affiliateId)
   ↓
5. Backend cria Order (status="pending", payment_status="pending")
   ↓
6. App navega para: /shop/checkout/payment/{orderId}
```

### ⚠️ Gaps IMPORTANTES

| Gap | Status | Impacto | Solução |
|-----|--------|--------|---------|
| **Endereços salvos não integrados** | ❌ | Usuário sempre digita novo endereço | Mostrar lista em dropdown, permitir criar/editar |
| **Validação de CEP (ViaCEP)** | ❌ | Não auto-completa cidade/estado | Integrar com API ViaCEP |
| **Cálculo de frete real** | ❌ | Frete é só dropdown visual, sem valor real | Integrar com transportadora (Melhor Envio, etc.) |
| **Cupom de desconto** | ⚠️ | Campo existe, mas sem validação na UI | Adicionar validação + aplicação visual |
| **Fonte de affiliate_id** | ❌ | Como app SABE qual afiliado referiu? | Vem de provider? localStorage? Deep link? |

### Modelo CheckoutRequest
```dart
@freezed
sealed class CheckoutRequest {
  final ShippingAddress shippingAddress;
  final ShippingAddress? billingAddress;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final String? customerDocument;
  final String shippingMethod;      // "standard" | "express"
  final String paymentMethod;       // "pix" | "card" | "crypto"
  final String? couponCode;
  final String? sessionId;          // Para cart anônimo
  
  // ⭐ Suporte Afiliado:
  final String? affiliateId;        // UUID de quem referiu
}
```

---

## 3️⃣ PAGAMENTO — ⚠️ MOCK (20%)

### 📁 Arquivos Principais
```
lib/ui/shop/pages/shop_payment_page.dart
```

### ⚠️ Estado: Mock Apenas
- **Rota:** `/shop/checkout/payment/:orderId`
- **Implementação:**
  - ✅ Mostra Order ID
  - ⚠️ PIX: QR code placeholder + botão "Já paguei"
  - ⚠️ Card: "Coming soon"
  - ⚠️ Crypto: "Coming soon"

### ❌ Gaps CRÍTICOS
1. **Sem integração Wolknow**
   - Não chama `POST /shopping/payments/create`
   - Não recebe `paymentId` real
   - Não gera QR code real

2. **Sem polling de status**
   - App não monitora `payment_status` mudando

3. **Sem webhook**
   - Backend não notifica app quando pagamento é confirmado

4. **Sem persistência de pagamento**
   - Se usuário fecha app durante pagamento, perde contexto

---

## 4️⃣ MEUS PEDIDOS — ❌ PLACEHOLDER (0%)

### 📁 Arquivos Principais
```
lib/routing/router.dart (linhas 527-549)
```

### ❌ Estado
- **Rota:** `/shop/orders` → `Placeholder()`
- **Sub-rota:** `/shop/orders/:orderNumber` → `Placeholder()`

### ❌ Gaps CRÍTICOS
- Sem página de listagem
- Sem página de detalhe
- Sem service para buscar pedidos do usuário

---

## 5️⃣ MODELOS — ✅ 100% COMPLETO

### 📁 Arquivo Principal
```
lib/domain/models/marketplace_models.dart
```

### ✅ Modelos Criados (Freezed)

| Modelo | Campos | Status |
|--------|--------|--------|
| `Product` | id, name, price, images, store_id, category | ✅ |
| `ShippingAddress` | street, number, neighborhood, city, state, postalCode | ✅ |
| `CartItem` | ✅ com affiliate_ref_code, room_id, comissao_rate/amount | ✅ |
| `Cart` | id, items[], subtotal, tax, total | ✅ |
| `OrderItem` | ✅ com affiliate_commission_rate/amount | ✅ |
| `Order` | ✅ com affiliate_id, affiliate_commission_amount | ✅ |
| `PaymentIntent` | id, order_id, amount, method, status | ✅ |
| `CheckoutRequest` | ✅ com affiliate_id | ✅ |
| `CartItemRequest` | ✅ com affiliate_ref_code, room_id | ✅ |
| `PaymentRequest` | order_id, amount, method | ✅ |

**Nota:** Todos têm suporte a comissões de afiliados!

---

## 6️⃣ SERVICES — ✅ 90% PRONTO

### 📁 Arquivos Principais
```
lib/data/services/
  ├── marketplace_cart_service.dart
  ├── marketplace_cart_service_impl.dart
  ├── marketplace_checkout_service.dart
  ├── marketplace_checkout_service_impl.dart
  ├── marketplace_address_service.dart
  ├── marketplace_address_service_impl.dart
  └── marketplace_product_service.dart
```

### ✅ Implementado

#### MarketplaceCartService
```
GET  /marketplace/cart               → getCart()
POST /marketplace/cart/items         → addItem()
PUT  /marketplace/cart/items/:id     → updateItem()
DELETE /marketplace/cart/items/:id   → removeItem()
DELETE /marketplace/cart             → clearCart()
```

#### MarketplaceCheckoutService
```
POST /marketplace/orders                    → checkout()
POST /shopping/payments/create              → createPayment()
GET  /shopping/payments/:paymentId/status   → getPaymentStatus()
```

#### MarketplaceAddressService
```
GET    /marketplace/shipping-addresses              → getAddresses()
POST   /marketplace/shipping-addresses              → createAddress()
PUT    /marketplace/shipping-addresses/:id/default  → setDefault()
DELETE /marketplace/shipping-addresses/:id          → deleteAddress()
```

### ⚠️ Gaps
- **AddressService criado, mas NOT integrado na UI** — checkout não mostra endereços salvos
- **createPayment() não é chamado** — pagamento é mock

---

## 7️⃣ ROTAS — ✅ 100% REGISTRADO

### Router Configuration (`lib/routing/router.dart`)

```dart
GoRoute(
  path: '/shop/vitrine',
  name: 'shop-vitrine',
  → ShopVitrinnePage()        ✅
),

GoRoute(
  path: '/shop/product/:id',
  name: 'shop-product',
  → ShopProductPage()         ✅
),

GoRoute(
  path: '/shop/cart',
  name: 'shop-cart',
  → ShopCartPage()            ✅
),

GoRoute(
  path: '/shop/checkout',
  name: 'shop-checkout',
  → ShopCheckoutPage()        ✅
  routes: [
    GoRoute(
      path: 'payment/:orderId',
      name: 'shop-payment',
      → ShopPaymentPage()     ⚠️ (mock)
    ),
  ],
),

GoRoute(
  path: '/shop/orders',
  name: 'shop-orders',
  → Placeholder()             ❌ (TODO)
  routes: [
    GoRoute(
      path: ':orderNumber',
      name: 'shop-order-detail',
      → Placeholder()         ❌ (TODO)
    ),
  ],
),
```

---

## 8️⃣ FLUXO COMPLETO (Estado Atual)

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Usuário em /shop/vitrine vê produtos                         │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. Clica em produto → /shop/product/:id                         │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. Clica "Adicionar ao carrinho"                                │
│    addToCart(CartItemRequest)                                   │
│    - product_id ✅                                              │
│    - quantity ✅                                                │
│    - affiliate_ref_code ⚠️ (falta origem)                      │
│    - room_id ⚠️ (falta origem)                                 │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. Navega para /shop/cart                                       │
│    - Mostra itens com quantidades                               │
│    - Opções: alterar qtd, remover, limpar                       │
│    - Clica "Ir para Checkout"                                   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. Navega para /shop/checkout                                   │
│    Preenche:                                                    │
│    - Endereço (sempre novo, não há lista) ⚠️                   │
│    - Dados cliente ✅                                           │
│    - Método envio (dropdown) ⚠️ (sem preço real)               │
│    - Método pagamento (pix/card/crypto) ✅                     │
│    - Clica "Confirmar Pedido"                                   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. checkout(CheckoutRequest)                                    │
│    Backend: POST /marketplace/orders                            │
│    - Cria Order (status="pending")                              │
│    - Calcula totais ✅                                          │
│    - Salva affiliate_id ⚠️ (se recebido)                       │
│    - Retorna Order com id + number                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. Navega para /shop/checkout/payment/:orderId                  │
│    - Mostra Order ID                                            │
│    - PIX mock (QR code + "Já paguei") ⚠️                       │
│    - Card/Crypto: "Coming soon" ⚠️                             │
│    ❌ NÃO chama createPayment()                                │
│    ❌ NÃO integra com Wolknow                                  │
│    ❌ NÃO monitora pagamento                                   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│ 8. Clica "Meus Pedidos" → /shop/orders                          │
│    ❌ Placeholder (sem listagem)                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 9️⃣ INTEGRAÇÃO COM AFILIADOS — ⚠️ 80% ESTRUTURADO

### ✅ Backend pronto para rastrear
```
CartItem {
  affiliate_ref_code: String?         // Código de referência
  comissao_rate: double?              // Taxa calculada backend
  comissao_amount: double?            // Valor calculado backend
}

Order {
  affiliate_id: String?               // UUID de quem referiu
  affiliate_commission_amount: double  // Total de comissão
}
```

### ❌ Faltam: Origem do affiliate_id + affiliate_ref_code
- **Pergunta:** Como o app SABE qual é o afiliado?
  - De um provider (ex: `affiliateContextProvider`)?
  - De localStorage (deep link com ref code)?
  - De URL (deep linking)?
  - Do contexto da loja (se entrou via link de afiliado)?

---

## 🔟 CHECKLIST DE PRÓXIMOS PASSOS

### Fase 0 — Testes de Fluxo (MVP)
```
Carrinho + Checkout (sem pagamento real):
- [ ] Testar: product → cart → checkout → success
- [ ] Testar: editar quantidade, remover item, limpar
- [ ] Testar: anônimo vs. autenticado
- [ ] Testar: afiliado tracking (se houver origem definida)
```

### Fase 0.5 — Integração de Detalhes (UX Melhorado)
```
- [ ] Persistir session ID anônimo (shared_preferences)
- [ ] Integrar endereços salvos no checkout
- [ ] Adicionar validação de CEP (ViaCEP)
- [ ] Definir fonte de affiliate_id e affiliate_ref_code
- [ ] Criar tela "/shop/orders" (listagem de pedidos)
- [ ] Criar página de detalhe de pedido
```

### Fase 1 — Pagamento Real (Out of scope agora)
```
- [ ] Integrar Wolknow (PIX QR real, Card, Crypto)
- [ ] Chamar createPayment() após Order criada
- [ ] Polling/Webhook para monitorar payment_status
- [ ] Redirecionar após pagamento confirmado
```

---

## 📋 COMMAND REFERENCE

### Para testar localmente:

```bash
# 1. Start backend
cd /Users/josecarlosmartins/Documents/Brawe/backend
python -m app.main

# 2. Start brawe-connect (pagamentos)
cd /Users/josecarlosmartins/Documents/Brawe/brawe-connect/backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload

# 3. Start app
cd /Users/josecarlosmartins/Documents/developer/brawe-app
flutter run
```

### Para visualizar o carrinho no código:
- `lib/data/providers/cart_notifier_provider.dart` — estado global
- `lib/ui/shop/pages/shop_cart_page.dart` — UI carrinho
- `lib/ui/shop/pages/shop_checkout_page.dart` — UI checkout

---

## 📚 Referências

- **Rotas:** `lib/routing/router.dart` (linhas 495-549)
- **Modelos:** `lib/domain/models/marketplace_models.dart`
- **Services:** `lib/data/services/marketplace_*.dart`
- **Providers:** `lib/data/providers/cart_notifier_provider.dart`
- **Pages:** `lib/ui/shop/pages/`

---

## 🎯 CONCLUSÃO

**Estado:** ✅ **75% Pronto para Testes**

- ✅ Carrinho: Funcional, pronto para usar
- ⚠️ Checkout: Formulário OK, faltam detalhes UX
- ⚠️ Pagamento: Mock apenas, sem integração real
- ❌ Pedidos: Placeholder, precisa ser criado
- ✅ Modelos: Completo com suporte a afiliados
- ✅ Services: Criados e funcionais

**Próximo passo:** Definir origem de `affiliate_id` e integrar endereços salvos no checkout.
