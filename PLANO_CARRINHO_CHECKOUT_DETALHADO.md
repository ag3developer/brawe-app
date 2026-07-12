# 🛒 Plano Detalhado: Carrinho + Checkout (Fase 3)

**Data:** 11 de Julho de 2026  
**Status:** Iniciando implementação  
**Tempo Estimado:** 3-4 dias  
**Prioridade:** 🔴 ALTA (fecha o loop de compra)

---

## 📊 Estado Atual (75% pronto)

### ✅ JÁ EXISTE:

**Models (Freezed):**
- ✅ `Cart` - carrinho principal
- ✅ `CartItem` - item no carrinho
- ✅ `ShippingAddress` - endereço de entrega
- ✅ `Order` - pedido
- ✅ `OrderItem` - item no pedido
- ✅ `PaymentIntent` - intenção de pagamento
- ✅ `CheckoutRequest` - payload do checkout

**Services:**
- ✅ `MarketplaceCartService` - GET/POST/PUT/DELETE cart items
- ✅ `MarketplaceAddressService` - GET/POST/PUT/DELETE endereços
- ✅ `MarketplaceCheckoutService` - POST ordem + GET pagamento

**Pages:**
- ✅ `ShopCartPage` (`/shop/cart`) - UI completa
- ✅ `ShopCheckoutPage` (`/shop/checkout`) - formulário
- ✅ `ShopPaymentPage` (`/shop/checkout/payment/:orderId`) - mock

**Providers:**
- ✅ `CartNotifier` (Riverpod)
- ✅ `cartNotifierProvider`

**Rotas:**
- ✅ `/shop/cart` registrada
- ✅ `/shop/checkout` registrada
- ✅ `/shop/checkout/payment/:orderId` registrada

---

## ⚠️ GAPS A CORRIGIR:

### 🔴 CRÍTICOS (Bloqueia fluxo):

1. **Session ID não persiste** (⏱️ 30min)
   - Problema: Usuário anônimo perde carrinho ao fechar app
   - Solução: Usar `shared_preferences` para persistir `cartSession.id`
   - Arquivo: `lib/data/providers/cart_notifier_provider.dart`

2. **`affiliate_id` origin indefinida** (⏱️ 1h)
   - Problema: Como saber qual afiliado referiu o usuário?
   - Cenários:
     - Deep link: `/shop/product/123?ref=affiliate-123`
     - Live: Criador adicionou produto ao carrinho (room_id = live session)
     - URL: `?affiliate_code=ABC123`
   - Solução: Criar provider que capture origem + salve em localStorage

3. **Validação de estoque não funciona** (⏱️ 45min)
   - Problema: Checkout não valida 409 Conflict (estoque esgotado)
   - Solução: Adicionar error handling no `checkout(CheckoutRequest)`

### 🟡 IMPORTANTES (Melhora UX):

4. **Endereços salvos não integrados** (⏱️ 2h)
   - Service existe, UI não mostra
   - Solução: Integrar lista de endereços no checkout + opção criar novo

5. **CEP sem validação (ViaCEP)** (⏱️ 1h)
   - Problema: Usuário digita CEP inválido
   - Solução: Auto-completar com ViaCEP (`https://viacep.com.br/ws/{cep}/json`)

6. **Frete sem cálculo real** (⏱️ 1.5h)
   - Problema: Dropdown visual sem preço
   - Solução: Integrar CorreiosService ou Melhor Envio (MVP: só visual)

### 🟠 FUTUROS (Fase 1 - Pagamento):

7. **Pagamento é mock**
   - PIX: QR code placeholder
   - Card/Crypto: "Coming soon"
   - Solução: Integração Wolknow (próxima fase)

8. **Sem `/shop/orders`** (⏱️ 2h)
   - Placeholder que não lista pedidos
   - Solução: Implementar listagem + detalhe de pedidos

---

## 🚀 PLANO DE EXECUÇÃO (3-4 dias)

### DIA 1 — Fundação + Session

#### Tarefa 1.1: Persistência de Session ID (30min)
**Arquivo:** `lib/data/providers/cart_notifier_provider.dart`

```dart
// ANTES (perde ao restart):
final cartSession = CartSession.create();

// DEPOIS (persiste):
final prefs = await SharedPreferences.getInstance();
final savedSessionId = prefs.getString('cart_session_id');
final cartSession = savedSessionId != null 
    ? CartSession(id: savedSessionId) 
    : CartSession.create();
// Salvar novo ID também
```

**Checklist:**
- [ ] Adicionar `shared_preferences` em pubspec.yaml
- [ ] Criar `CartSessionManager` com get/set
- [ ] Testar: fechar + abrir app = carrinho persiste

---

#### Tarefa 1.2: Definir Affiliate Origin (1h)
**Arquivo:** Novo provider `lib/data/providers/affiliate_origin_provider.dart`

```dart
// Provider que captura origem do afiliado
final affiliateOriginProvider = FutureProvider<String?>((ref) async {
  // 1. Verificar URL/deep link (?ref=, ?affiliate_code=)
  // 2. Verificar localStorage (afiliadoSalvo)
  // 3. Se em live, pegar creatorId
  // 4. Se nada, retorna null (comprador direto)
});
```

**Checklist:**
- [ ] Criar provider
- [ ] Capturar de URL (GoRouter.of(context).location)
- [ ] Salvar em shared_preferences
- [ ] Usar no `CartItem` → `affiliate_id`

---

#### Tarefa 1.3: Integrar Endereços Salvos (2h)
**Arquivo:** `lib/ui/shop/pages/shop_checkout_page.dart` (modificar)

```dart
// ANTES (sem endereços salvos):
TextFormField(
  initialValue: '',
  decoration: InputDecoration(label: Text('Endereço')),
)

// DEPOIS (com dropdown + criar novo):
ref.watch(userShippingAddressesProvider).when(
  data: (addresses) => Column(
    children: [
      DropdownButton(
        items: addresses.map((addr) => addr.formatted).toList(),
        onChanged: (selected) => _selectAddress(selected),
      ),
      TextButton(
        onPressed: () => _showAddressForm(),
        child: Text('+ Novo endereço'),
      ),
    ],
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Erro ao carregar endereços'),
)
```

**Checklist:**
- [ ] Criar `userShippingAddressesProvider`
- [ ] Chamar `MarketplaceAddressService.getAddresses()`
- [ ] Adicionar dropdown na UI
- [ ] Opção "Criar novo" inline (form modal ou expandir)
- [ ] Salvar selecionado no `CheckoutRequest`

---

### DIA 2 — Validações + Cálculos

#### Tarefa 2.1: Validação de CEP (ViaCEP) (1h)
**Arquivo:** Novo service `lib/data/services/viacep_service.dart`

```dart
class ViaCepService {
  Future<Address> searchCep(String cep) async {
    final response = await Dio().get(
      'https://viacep.com.br/ws/$cep/json',
    );
    if (response.data['erro'] == true) {
      throw Exception('CEP inválido');
    }
    return Address.fromViaCepJson(response.data);
  }
}
```

**Integração no checkout:**
```dart
TextFormField(
  onChanged: (cep) async {
    if (cep.length == 8) {
      final address = await ref.read(viaCepServiceProvider)
          .searchCep(cep);
      // Auto-preenche rua, cidade, estado
      setState(() {
        _street = address.rua;
        _city = address.localidade;
        _state = address.uf;
      });
    }
  },
)
```

**Checklist:**
- [ ] Criar ViaCepService
- [ ] Integrar no campo de CEP
- [ ] Validar e auto-completar
- [ ] Erro handling (CEP inválido)

---

#### Tarefa 2.2: Cálculo de Frete (Visual) (1.5h)
**Arquivo:** `lib/ui/shop/pages/shop_checkout_page.dart`

```dart
// Dropdown com opções de frete (visual por enquanto)
DropdownButton<ShippingMethod>(
  items: [
    DropdownMenuItem(
      value: ShippingMethod.standard,
      child: Text('Padrão - R\$ 15,00 (5-7 dias)'),
    ),
    DropdownMenuItem(
      value: ShippingMethod.express,
      child: Text('Expresso - R\$ 35,00 (2-3 dias)'),
    ),
  ],
  onChanged: (method) {
    setState(() {
      _shippingMethod = method;
      _shippingCost = method == ShippingMethod.express ? 35 : 15;
    });
  },
)

// Resumo atualiza com shipping cost
_buildOrderSummary() {
  final shippingCost = _shippingMethod == ShippingMethod.express ? 35.0 : 15.0;
  return Column(
    children: [
      Text('Subtotal: R\$ ${cart.subtotal}'),
      Text('Frete: R\$ $shippingCost'),
      Text('Total: R\$ ${cart.subtotal + shippingCost}'),
    ],
  );
}
```

**Checklist:**
- [ ] Criar enum `ShippingMethod`
- [ ] Adicionar dropdown na UI
- [ ] Calcular `shippingCost`
- [ ] Atualizar resumo em tempo real
- [ ] Enviar no `CheckoutRequest`

---

#### Tarefa 2.3: Validação de Estoque (45min)
**Arquivo:** `lib/data/services/marketplace_checkout_service_impl.dart`

```dart
Future<Order> checkout(CheckoutRequest request) async {
  try {
    final response = await dio.post(
      '/marketplace/orders',
      data: request.toJson(),
    );
    return Order.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 409) {
      // Estoque esgotado
      throw OutOfStockException(
        message: e.response?.data['message'] ?? 'Produto esgotado',
      );
    }
    rethrow;
  }
}
```

**Integração na UI:**
```dart
onPressed: () async {
  try {
    final order = await ref.read(checkoutServiceProvider)
        .checkout(checkoutRequest);
    // Navegar para pagamento
    context.push('/shop/checkout/payment/${order.id}');
  } on OutOfStockException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ ${e.message}')),
    );
  }
}
```

**Checklist:**
- [ ] Criar `OutOfStockException`
- [ ] Capturar 409 do backend
- [ ] Mostrar erro ao usuário
- [ ] Opção de remover item ou voltar

---

### DIA 3 — Integração Final

#### Tarefa 3.1: Testar Fluxo Completo (1.5h)
**Cenários:**

1. ✅ Vitrine → Clica "Adicionar ao carrinho" → Aparece no carrinho
2. ✅ Carrinho → Atualiza quantidade → Total recalcula
3. ✅ Carrinho → Remove item → Desaparece
4. ✅ Carrinho → "Ir para Checkout" → Abre checkout
5. ⏳ Checkout → Preenche endereço + CEP (ViaCEP) → Auto-completa
6. ⏳ Checkout → Seleciona frete → Total atualiza
7. ⏳ Checkout → "Confirmar" → Backend cria Order
8. ⏳ Pagamento → Mostra mock (PIX QR)
9. ❌ `/shop/orders` → Ainda placeholder

**Checklist:**
- [ ] Testar cada cenário
- [ ] Verificar logs no Flutter
- [ ] Registrar bugs encontrados

---

#### Tarefa 3.2: Criar `/shop/orders` (2h)
**Arquivo:** Novo `lib/ui/shop/pages/shop_orders_page.dart`

```dart
class ShopOrdersPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Meus Pedidos')),
      body: ordersAsync.when(
        data: (orders) => ListView(
          children: orders.map((order) => OrderTile(order)).toList(),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Erro ao carregar')),
      ),
    );
  }
}

// Tile mostrando: OrderID, Data, Status, Total, botão "Ver Detalhes"
class OrderTile extends StatelessWidget {
  final Order order;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Pedido #${order.orderNumber}'),
      subtitle: Text('${order.createdAt} • R\$ ${order.total}'),
      trailing: Chip(label: Text(order.status)),
      onTap: () => context.push('/shop/orders/${order.id}'),
    );
  }
}
```

**Provider + Service:**
```dart
// marketplace_order_service.dart
Future<List<Order>> getUserOrders() async {
  final response = await dio.get('/marketplace/orders');
  return (response.data as List).map((o) => Order.fromJson(o)).toList();
}

// marketplace_providers.dart
final userOrdersProvider = FutureProvider<List<Order>>((ref) async {
  return ref.watch(marketplaceOrderServiceProvider).getUserOrders();
});
```

**Checklist:**
- [ ] Criar ShopOrdersPage
- [ ] Criar OrderTile widget
- [ ] Criar userOrdersProvider
- [ ] Registrar rota `/shop/orders`
- [ ] Testar listagem (deve mostrar pedidos do usuário)

---

#### Tarefa 3.3: Internacionalização (1h)
**Arquivo:** `.arb` (pt/en/es)

```json
"shopCartTitle": "Carrinho",
"shopCartEmpty": "Seu carrinho está vazio",
"shopCartSubtotal": "Subtotal",
"shopCartShipping": "Frete",
"shopCartTotal": "Total",
"shopCheckoutTitle": "Checkout",
"shopCheckoutDeliveryAddress": "Endereço de Entrega",
"shopCheckoutShippingMethod": "Método de Envio",
"shopCheckoutStandard": "Padrão",
"shopCheckoutExpress": "Expresso",
"shopOrdersTitle": "Meus Pedidos",
"shopOrderEmpty": "Você ainda não fez pedidos",
"shopOrderStatus": "Status do Pedido",
"shopOrderStatusPending": "Pendente",
"shopOrderStatusConfirmed": "Confirmado",
"shopOrderStatusShipped": "Enviado",
"shopOrderStatusDelivered": "Entregue"
```

**Checklist:**
- [ ] Adicionar 20+ chaves em app_pt.arb
- [ ] Traducir para app_en.arb
- [ ] Traducir para app_es.arb
- [ ] Usar `AppLocalizations.of(context)!.shopCartTitle` na UI

---

### DIA 4 — QA + Polimento

#### Tarefa 4.1: QA - 2 Temas × 3 Idiomas (1.5h)

**Checklist:**
- [ ] Light mode (English) → Passar por fluxo completo
- [ ] Dark mode (English) → Verificar contraste
- [ ] Light mode (Portuguese) → Strings truncadas?
- [ ] Dark mode (Portuguese) → Cores OK?
- [ ] Light mode (Spanish) → Layout breaks?
- [ ] Dark mode (Spanish) → Responsivo?

---

#### Tarefa 4.2: Testes de Widget (1h)

```dart
testWidgets('Cart adds item correctly', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navegar para produto
  await tester.tap(find.byType(ProductTile));
  await tester.pumpAndSettle();
  
  // Clicar "Adicionar ao carrinho"
  await tester.tap(find.byKey(Key('add-to-cart-button')));
  await tester.pumpAndSettle();
  
  // Verificar que item apareceu no carrinho
  expect(find.text('Carrinho (1)'), findsOneWidget);
});
```

**Checklist:**
- [ ] Teste: Add item ao carrinho
- [ ] Teste: Remover item
- [ ] Teste: Atualizar quantidade
- [ ] Teste: Checkout com endereço
- [ ] Teste: Error handling (409 estoque)

---

#### Tarefa 4.3: Documentação + Git Commit

**Arquivo:** Atualizar `PROXIMOS_PASSOS_MARKETPLACE.md`

```markdown
## ✅ FASE 3 COMPLETA (11 de Julho - 15 de Julho)

### Implementado:
- ✅ Carrinho compartilhado com persistência
- ✅ Checkout com validação de CEP
- ✅ Cálculo de frete
- ✅ Endereços salvos integrados
- ✅ Validação de estoque (409)
- ✅ `/shop/orders` listagem
- ✅ Internacionalização completa (pt/en/es)
- ✅ QA - 6 combinações (temas × idiomas)

### Fluxo E2E Funcional:
Produto → Carrinho → Checkout → Pagamento (mock) → Pedidos

### Próximos: Fase 4 (Pagamento Real - Wolknow)
```

**Checklist:**
- [ ] Git commit com mensagem descritiva
- [ ] Atualizar documentação
- [ ] Registrar o que foi feito

---

## 📚 Referências de Código

| O que preciso | Arquivo | Linha |
|---------------|---------|-------|
| Ver modelo do Cart | `lib/domain/models/marketplace_models.dart` | ~200 |
| Provider do carrinho | `lib/data/providers/cart_notifier_provider.dart` | ~40 |
| Page do carrinho | `lib/ui/shop/pages/shop_cart_page.dart` | ~100 |
| Page do checkout | `lib/ui/shop/pages/shop_checkout_page.dart` | ~150 |
| Service de checkout | `lib/data/services/marketplace_checkout_service_impl.dart` | ~30 |
| Rotas | `lib/routing/router.dart` | ~495-549 |

---

## 🎯 Ordem de Prioridade (se tempo aperta)

### MVP (1 dia):
1. ✅ Session persistence
2. ✅ Affiliate origin
3. ✅ Validação estoque (409)
4. ✅ `/shop/orders` básico

### Nice-to-have (se sobrar tempo):
5. ViaCEP integration
6. Frete calculation
7. QA completo
8. Testes widget

---

## 💡 Dicas de Desenvolvimento

- Use `ref.watch()` para estado reativo
- Sempre fazer `CartNotifier.loadCart()` ao iniciar app
- Mostrar erros com `ScaffoldMessenger.showSnackBar()`
- Testar offline: desligar WiFi = erro de conexão esperado
- Session ID: usar UUID v4 (`Uuid().v4()`)

---

**Status:** 🚀 Pronto para começar!

Quer que eu comece pela **Tarefa 1.1 (Session Persistence)**?
