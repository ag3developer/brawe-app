# 🛒 RESUMO RÁPIDO: Cart + Checkout

## ✅ O QUE JÁ ESTÁ PRONTO

### Carrinho (`/shop/cart`)
```
✅ CartNotifier (Riverpod Notifier)
✅ ShopCartPage (UI completa)
✅ Rota /shop/cart registrada
✅ Ações: loadCart, addItem, updateQuantity, removeItem, clear
✅ Suporte anônimo (CartSession.id)
✅ Mostra: itens, quantidade, preço unitário/total, subtotal, tax, total
✅ Integração com marketplace_repository
```

### Checkout (`/shop/checkout`)
```
✅ ShopCheckoutPage (ConsumerStatefulWidget)
✅ Rota /shop/checkout registrada
✅ Coleta: endereço, dados cliente, método envio, método pagamento
✅ Validação de formulário
✅ Layout responsivo (mobile/desktop)
✅ Resumo de pedido na mesma página
✅ Chama: repository.checkout(checkoutRequest)
✅ Navega para: /shop/checkout/payment/:orderId
```

### Pagamento (Mock)
```
⚠️ ShopPaymentPage (/shop/checkout/payment/:orderId)
⚠️ Mostra Order ID
⚠️ PIX mock (QR code placeholder)
❌ Sem integração Wolknow real
```

### Modelos (Freezed)
```
✅ Product, Cart, CartItem
✅ ShippingAddress, Order, OrderItem
✅ PaymentIntent, CheckoutRequest, CartItemRequest
✅ Todos com suporte a afiliados (comissao_rate, comissao_amount, affiliate_id)
```

### Services
```
✅ MarketplaceCartService (GET/POST/PUT/DELETE /marketplace/cart*)
✅ MarketplaceCheckoutService (POST /marketplace/orders + /shopping/payments)
✅ MarketplaceAddressService (GET/POST/PUT/DELETE /marketplace/shipping-addresses)
✅ Tudo implementado em _impl.dart
```

### Rotas
```
✅ /shop/vitrine                     → ShopVitrinnePage
✅ /shop/product/:id                 → ShopProductPage
✅ /shop/cart                        → ShopCartPage
✅ /shop/checkout                    → ShopCheckoutPage
✅ /shop/checkout/payment/:orderId   → ShopPaymentPage (mock)
❌ /shop/orders                      → Placeholder
❌ /shop/orders/:orderNumber         → Placeholder
```

---

## ⚠️ GAPS IMPORTANTES

### Carrinho
| Gap | Impacto | Solução |
|-----|---------|---------|
| Session ID não persiste entre restarts | Usuário anônimo perde carrinho ao fechar app | Usar `shared_preferences` |
| affiliate_ref_code vem de onde? | Rastreamento incompleto | Definir fonte (provider, localStorage, URL) |

### Checkout
| Gap | Impacto | Solução |
|-----|---------|---------|
| Endereços salvos não integrados | Usuário digita mesmo endereço sempre | Mostrar lista de endereços salvos + permitir criar novo |
| CEP não é validado (ViaCEP) | Dados potencialmente incorretos | Integrar com ViaCEP para auto-completar |
| Frete é dropdown sem preço real | Shipping não é realista | Integrar com transportadora (Melhor Envio) |
| affiliate_id vem de onde? | Comissão não é rastreada | Definir origem (provém de qual provider/contexto?) |

### Pagamento
| Gap | Impacto | Solução |
|-----|---------|---------|
| Sem integração Wolknow | Pagamento é só mock | Integrar Wolknow (PIX QR real, Card, Crypto) |
| Sem createPayment() real | Order criada mas sem Payment Intent | Chamar createPayment() após Order criada |
| Sem polling/webhook | Não sabe quando pagamento foi confirmado | Implementar polling ou webhook |

### Pedidos
| Gap | Impacto | Solução |
|-----|---------|---------|
| `/shop/orders` é Placeholder | Usuário não consegue ver seus pedidos | Criar ShopOrdersPage + ShopOrderDetailPage |
| Sem service de listagem | App não pode buscar orders do user | Criar endpoint + service + provider |

---

## 📂 ESTRUTURA DE ARQUIVOS

```
lib/
├── domain/models/
│   └── marketplace_models.dart          ✅ Todos os models (Freezed)
├── data/
│   ├── services/
│   │   ├── marketplace_cart_service.dart
│   │   ├── marketplace_cart_service_impl.dart
│   │   ├── marketplace_checkout_service.dart
│   │   ├── marketplace_checkout_service_impl.dart
│   │   ├── marketplace_address_service.dart
│   │   └── marketplace_address_service_impl.dart
│   ├── providers/
│   │   └── cart_notifier_provider.dart  ✅ CartNotifier + cartNotifierProvider
│   └── repositories/
│       └── marketplace_repository.dart  ✅ Agregador de services
├── ui/shop/
│   ├── pages/
│   │   ├── shop_vitrine_page.dart       ✅ Showcase
│   │   ├── shop_product_page.dart       ✅ Detalhes produto
│   │   ├── shop_cart_page.dart          ✅ Carrinho
│   │   ├── shop_checkout_page.dart      ✅ Checkout
│   │   ├── shop_payment_page.dart       ⚠️ Mock
│   │   └── shop_store_page.dart         ✅
│   ├── widgets/                         (Componentes reutilizáveis)
│   └── utils/
│       └── currency_formatter.dart      (Formatação de moedas)
└── routing/
    └── router.dart                      ✅ Rotas registradas
```

---

## 🚀 FLUXO DE USO ATUAL

```
1. Usuário vê produto em /shop/vitrine
2. Clica → /shop/product/:id
3. Clica "Adicionar ao carrinho"
   └─ Chama: addToCart(CartItemRequest(product_id, quantity))
4. Clica carrinho → /shop/cart
   └─ Mostra: itens, quantidade, preço
5. Clica "Ir para Checkout" → /shop/checkout
   └─ Preenche: endereço, cliente, envio, pagamento
6. Clica "Confirmar" → checkout(CheckoutRequest)
   └─ Backend: POST /marketplace/orders → Order criada
7. App navega → /shop/checkout/payment/:orderId
   └─ Mostra: mock de pagamento (PIX placeholder)
8. Clica "Meus Pedidos" → /shop/orders
   └─ ❌ Placeholder (não implementado)
```

---

## 🔑 PROVIDER REFERENCES

```dart
// Usar no build():
final cartState = ref.watch(cartNotifierProvider);
// cartState.items, .subtotal, .total, .isEmpty, .itemCount, .isLoading, .error

// Para ler notifier:
ref.read(cartNotifierProvider.notifier).addItem(request)
ref.read(cartNotifierProvider.notifier).loadCart()
ref.read(cartNotifierProvider.notifier).removeItem(id)

// Para badge de quantidade:
final count = ref.watch(cartItemCountProvider);
```

---

## 📊 CHECKLIST DE INTEGRAÇÃO

### Fase 0 — Fluxo Básico (Agora)
- [x] Carrinho funciona
- [x] Checkout funciona (sem payment real)
- [ ] **Testar fluxo completo** (product → cart → checkout → mock payment)
- [ ] **Définir affiliate_id origin**
- [ ] **Persistir session ID anônimo**

### Fase 0.5 — UX Melhorado
- [ ] Integrar endereços salvos
- [ ] Validação de CEP (ViaCEP)
- [ ] Criar `/shop/orders` (listagem)
- [ ] Criar detalhe de pedido

### Fase 1 — Pagamento Real
- [ ] Integrar Wolknow
- [ ] Chamar createPayment()
- [ ] Polling/Webhook de status
- [ ] Sucesso/erro handling

---

## 🎯 PRÓXIMA AÇÃO RECOMENDADA

1. **Definir origem de affiliate_id**
   - Será vindo de um provider?
   - De localStorage/deep link?
   - De contexto da loja?

2. **Integrar endereços salvos no checkout**
   - Service já existe (`MarketplaceAddressService`)
   - Falta adicionar à UI do checkout

3. **Testar fluxo completo**
   - Começar com produto "dummy"
   - Seguir até tela de pagamento mock
   - Verificar se Order é criada no backend

---

## 📞 REFERÊNCIAS RÁPIDAS

| O que preciso... | Arquivo | Linha |
|------------------|---------|-------|
| Adicionar ao carrinho | `shop_product_page.dart` | ~442 |
| Ver estado do carrinho | `cart_notifier_provider.dart` | ~40 |
| Formulário checkout | `shop_checkout_page.dart` | ~150 |
| Criar pedido | `marketplace_checkout_service_impl.dart` | ~30 |
| Rotas do shop | `router.dart` | ~495-549 |
| Models Freezed | `marketplace_models.dart` | Início |

---

**Status:** ✅ 75% pronto para testes. Gaps = detalhes UX + afiliados + pagamento real.
