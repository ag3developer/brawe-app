# 🎯 FLUXO VISUAL: Carrinho + Checkout

## 1. ARQUITETURA DE CAMADAS

```mermaid
graph TB
    subgraph UI["🎨 UI LAYER"]
        A["ShopProductPage<br/>/shop/product/:id"]
        B["ShopCartPage<br/>/shop/cart"]
        C["ShopCheckoutPage<br/>/shop/checkout"]
        D["ShopPaymentPage<br/>/shop/checkout/payment/:orderId"]
    end
    
    subgraph Providers["🔄 PROVIDERS LAYER"]
        E["cartNotifierProvider<br/>(Riverpod Notifier)"]
        F["marketplaceRepositoryProvider"]
    end
    
    subgraph Services["🌐 SERVICES LAYER"]
        G["MarketplaceCartService"]
        H["MarketplaceCheckoutService"]
        I["MarketplaceAddressService"]
    end
    
    subgraph Models["📦 MODELS LAYER"]
        J["CartItem, Cart"]
        K["Order, CheckoutRequest"]
        L["ShippingAddress"]
    end
    
    subgraph Backend["🖥️ BACKEND ENDPOINTS"]
        M["GET/POST/DELETE<br/>/marketplace/cart*"]
        N["POST<br/>/marketplace/orders"]
        O["POST<br/>/shopping/payments/create"]
    end
    
    A -->|ref.read<br/>cartNotifierProvider.notifier| E
    B -->|ref.watch<br/>cartNotifierProvider| E
    C -->|ref.watch<br/>cartNotifierProvider| E
    E -->|uses| F
    F -->|uses| G
    F -->|uses| H
    F -->|uses| I
    G -->|REST| M
    H -->|REST| N
    H -->|REST| O
    G -->|expects| J
    H -->|expects| K
    I -->|expects| L

    style A fill:#e1f5ff
    style B fill:#e1f5ff
    style C fill:#e1f5ff
    style D fill:#fff3e0
    style E fill:#f3e5f5
    style F fill:#f3e5f5
    style G fill:#e8f5e9
    style H fill:#e8f5e9
    style I fill:#e8f5e9
    style M fill:#fff9c4
    style N fill:#fff9c4
    style O fill:#fff9c4
```

---

## 2. FLUXO DE DADOS: Add to Cart

```mermaid
sequenceDiagram
    participant User as 👤 Usuário
    participant UI as 🎨 ShopProductPage
    participant Provider as 🔄 cartNotifierProvider
    participant Repo as 📦 Repository
    participant Service as 🌐 CartService
    participant Backend as 🖥️ Backend
    
    User->>UI: Clica "Adicionar ao carrinho"
    
    UI->>Provider: ref.read(cartNotifierProvider.notifier)<br/>.addItem(CartItemRequest)
    
    Provider->>Repo: addToCart(request, sessionId)
    
    Repo->>Service: addItem(request, sessionId)
    
    Service->>Backend: POST /marketplace/cart/items<br/>{product_id, quantity, ...}
    
    Backend-->>Service: CartItem {comissao_rate, comissao_amount}
    
    Service-->>Repo: CartItem
    
    Repo->>Repo: Depois: loadCart(sessionId)
    
    Repo->>Backend: GET /marketplace/cart?session_id=...
    
    Backend-->>Repo: Cart {items[], subtotal, tax, total}
    
    Repo-->>Provider: CartState atualizado
    
    Provider-->>UI: ref.watch() notificado
    
    UI->>User: ✅ Mostra "Item adicionado"
```

---

## 3. FLUXO DE DADOS: Checkout

```mermaid
sequenceDiagram
    participant User as 👤 Usuário
    participant UI as 🎨 ShopCheckoutPage
    participant Provider as 🔄 cartNotifierProvider
    participant Repo as 📦 Repository
    participant Service as 🌐 CheckoutService
    participant Backend as 🖥️ Backend
    
    User->>UI: Preenche formulário<br/>(endereço, cliente, envio, pagamento)
    
    User->>UI: Clica "Confirmar Pedido"
    
    UI->>UI: Valida formulário
    
    UI->>Repo: repository.checkout(CheckoutRequest)
    
    Note over UI,Repo: CheckoutRequest: {<br/>shipping_address,<br/>customer_name,<br/>payment_method,<br/>affiliate_id (se houver)<br/>}
    
    Repo->>Service: checkout(request, affiliateId)
    
    Service->>Backend: POST /marketplace/orders<br/>(CheckoutRequest + affiliate_id)
    
    Backend-->>Service: Order {id, number, status=pending}
    
    Service-->>Repo: Order
    
    Repo-->>UI: Order
    
    UI->>UI: Limpa CartState (opcional)
    
    UI->>UI: Navega para<br/>/shop/checkout/payment/:orderId
    
    UI->>User: ✅ Mostra tela de pagamento
```

---

## 4. FLUXO COMPLETO: Product → Cart → Checkout

```mermaid
graph TD
    Start[("👤 Usuário<br/>em /shop/vitrine")] -->|Clica produto| ProductPage["🎨 ShopProductPage<br/>/shop/product/:id"]
    
    ProductPage -->|Mostra: imagem,<br/>preço, descrição| ProductUI["📱 UI do Produto"]
    
    ProductUI -->|Usuário clica<br/>Adicionar| AddCart["🛒 addToCart<br/>(product_id, quantity)"]
    
    AddCart -->|ref.read<br/>cartNotifierProvider| CartNotifier["🔄 CartNotifier<br/>.addItem()"]
    
    CartNotifier -->|POST /marketplace/cart/items| BackendCart["🖥️ Backend Cart API<br/>POST /marketplace/cart/items"]
    
    BackendCart -->|Retorna CartItem<br/>com comissões| CartItem["📦 CartItem<br/>{comissao_rate, amount}"]
    
    CartItem -->|Depois loadCart| GetCart["🖥️ GET /marketplace/cart<br/>sessionId"]
    
    GetCart -->|Retorna| Cart["📦 Cart<br/>{items[], subtotal, tax}"]
    
    Cart -->|Atualiza estado| CartState["🔄 CartState<br/>isLoading=false"]
    
    CartState -->|ref.watch() notifica| CartPage["🎨 ShopCartPage<br/>/shop/cart"]
    
    CartPage -->|Mostra: itens,<br/>quantidades, preço| CartUI["📱 UI do Carrinho"]
    
    CartUI -->|Usuário clica<br/>Checkout| CheckoutNav["➡️ Navigate to<br/>/shop/checkout"]
    
    CheckoutNav -->|GoRouter| CheckoutPage["🎨 ShopCheckoutPage<br/>/shop/checkout"]
    
    CheckoutPage -->|Mostra: endereço,<br/>cliente, envio,<br/>pagamento| CheckoutForm["📋 Formulário"]
    
    CheckoutForm -->|Usuário preenche<br/>e clica Confirmar| ValidateForm["✓ Valida formulário"]
    
    ValidateForm -->|Cria| CheckoutRequest["📦 CheckoutRequest<br/>{address, customer,<br/>method, affiliate_id}"]
    
    CheckoutRequest -->|repository<br/>.checkout()| Checkout["🔄 Checkout<br/>via Repository"]
    
    Checkout -->|POST /marketplace/orders| BackendCheckout["🖥️ Backend Order API<br/>POST /marketplace/orders"]
    
    BackendCheckout -->|Cria Order<br/>status=pending| Order["📦 Order<br/>{id, number, status,<br/>affiliate_commission}"]
    
    Order -->|Retorna| OrderCreated["✅ Order criada"]
    
    OrderCreated -->|Navigate to| PaymentPage["🎨 ShopPaymentPage<br/>/shop/checkout/payment/:orderId"]
    
    PaymentPage -->|Mostra: PIX mock<br/>QR code placeholder| PaymentUI["⚠️ Mock Payment UI"]
    
    PaymentUI -->|Botão: Meus Pedidos| OrdersList["❌ /shop/orders<br/>Placeholder"]
    
    style Start fill:#ffebee
    style ProductPage fill:#e1f5ff
    style CartNotifier fill:#f3e5f5
    style BackendCart fill:#fff9c4
    style CartPage fill:#e1f5ff
    style CheckoutPage fill:#e1f5ff
    style BackendCheckout fill:#fff9c4
    style PaymentPage fill:#fff3e0
    style OrdersList fill:#ffccbc
```

---

## 5. ESTADO DO CARRINHO (CartState)

```mermaid
graph TD
    A["CartState<br/>(Immutable)"] --> B["cart: Cart?"]
    A --> C["isLoading: bool"]
    A --> D["error: String?"]
    
    B --> B1["id: String"]
    B --> B2["items: CartItem[]"]
    B --> B3["subtotal: double"]
    B --> B4["tax: double"]
    B --> B5["total: double"]
    
    B2 --> B2A["CartItem {"]
    B2A --> B2A1["id: String"]
    B2A --> B2A2["product_id: String"]
    B2A --> B2A3["quantity: int"]
    B2A --> B2A4["unit_price: double"]
    B2A --> B2A5["total_price: double"]
    B2A --> B2A6["affiliate_ref_code?: String<br/>⭐"]
    B2A --> B2A7["room_id?: String<br/>⭐"]
    B2A --> B2A8["comissao_rate?: double<br/>⭐"]
    B2A --> B2A9["comissao_amount?: double<br/>⭐"]
    B2A --> B2A10["}"]
    
    C --> C1["true → Loading spinner"]
    C --> C2["false → Show content"]
    
    D --> D1["null → No error"]
    D --> D2["message → Show error"]
    
    style A fill:#f3e5f5
    style B1 fill:#fff3e0
    style B2 fill:#fff3e0
    style B3 fill:#fff3e0
    style B4 fill:#fff3e0
    style B5 fill:#fff3e0
    style B2A6 fill:#ffccbc
    style B2A7 fill:#ffccbc
    style B2A8 fill:#ffccbc
    style B2A9 fill:#ffccbc
```

---

## 6. SESSÃO ANÔNIMA (CartSession)

```mermaid
graph LR
    A["CartSession<br/>(Static Singleton)"] --> B["_sessionId: String?"]
    
    B -->|null| C["generate()"]
    C -->|now.microsecondsSinceEpoch<br/>+ hashCode| D["'anon_1a2b3c4d'"]
    D -->|return| E["CartSession.id"]
    
    B -->|cached| E
    
    E -->|usado em| F["getCart(sessionId)"]
    E -->|usado em| G["addToCart(sessionId)"]
    E -->|usado em| H["updateCart(sessionId)"]
    
    Note over A,B: ⚠️ Em memória apenas<br/>Perde entre restarts<br/>TODO: shared_preferences
    
    style A fill:#e8f5e9
    style B fill:#fff3e0
    style C fill:#f3e5f5
    style D fill:#c8e6c9
    style E fill:#c8e6c9
    style F fill:#ffeb3b
    style G fill:#ffeb3b
    style H fill:#ffeb3b
```

---

## 7. ROTAS REGISTRADAS

```mermaid
graph TB
    Router["GoRouter<br/>/shop"] --> Vitrine["✅ /vitrine<br/>ShopVitrinnePage"]
    Router --> Product["✅ /product/:id<br/>ShopProductPage"]
    Router --> Cart["✅ /cart<br/>ShopCartPage"]
    Router --> Checkout["✅ /checkout<br/>ShopCheckoutPage"]
    Router --> Orders["❌ /orders<br/>Placeholder"]
    Router --> Partnerships["❌ /partnerships<br/>Placeholder"]
    
    Checkout --> Payment["⚠️ /payment/:orderId<br/>ShopPaymentPage (mock)"]
    Orders --> OrderDetail["❌ /:orderNumber<br/>Placeholder"]
    Partnerships --> Received["❌ /received<br/>Placeholder"]
    Partnerships --> Sent["❌ /sent<br/>Placeholder"]
    
    style Vitrine fill:#c8e6c9
    style Product fill:#c8e6c9
    style Cart fill:#c8e6c9
    style Checkout fill:#c8e6c9
    style Payment fill:#fff3e0
    style Orders fill:#ffccbc
    style OrderDetail fill:#ffccbc
    style Partnerships fill:#ffccbc
    style Received fill:#ffccbc
    style Sent fill:#ffccbc
```

---

## 8. INTEGRAÇÃO DE AFILIADOS

```mermaid
graph TD
    A["👤 Usuário vira afiliado<br/>em /shop/partnerships"] --> B["Clica 'Virar Afiliado'"]
    
    B --> C["App sabe: affiliate_id = X"]
    
    C -->|Usuário entra em Live| D["🔴 Live Stream<br/>room_id = Y"]
    
    D --> E["Mostra link/código<br/>de afiliado"]
    
    E -->|Espectador clica link<br/>com ref_code=Z| F["🛍️ /shop/vitrine<br/>(contexto: ref_code=Z)"]
    
    F -->|Vê produtos| G["Clica produto"]
    
    G -->|Clica Add| H["addToCart({<br/>product_id: X,<br/>quantity: 1,<br/>affiliate_ref_code: Z,<br/>room_id: Y<br/>})"]
    
    H -->|POST /marketplace/cart/items| I["🖥️ Backend calcula:<br/>comissao_rate = 5%<br/>comissao_amount = 50"]
    
    I -->|CartItem retorna| J["CartItem {<br/>comissao_rate: 5,<br/>comissao_amount: 50<br/>}"]
    
    J -->|Checkout| K["checkout({<br/>affiliate_id: X,<br/>...rest<br/>})"]
    
    K -->|POST /marketplace/orders| L["🖥️ Backend cria Order:<br/>affiliate_id: X<br/>affiliate_commission_amount: 50"]
    
    L -->|Order retorna| M["Order salvo<br/>com comissão rastreada"]
    
    style A fill:#e1f5ff
    style D fill:#ffccbc
    style I fill:#fff9c4
    style L fill:#fff9c4
    style M fill:#c8e6c9
```

---

## 9. GAPS E SOLUÇÕES

```mermaid
graph LR
    subgraph Gaps["⚠️ GAPS ATUAIS"]
        G1["Sessão não persiste<br/>entre restarts"]
        G2["Endereços salvos<br/>não integrados"]
        G3["CEP não validado<br/>ViaCEP"]
        G4["Frete sem<br/>preço real"]
        G5["affiliate_id<br/>origem indefinida"]
        G6["Pagamento<br/>é mock"]
        G7["/shop/orders<br/>é Placeholder"]
    end
    
    subgraph Solutions["✅ SOLUÇÕES"]
        S1["shared_preferences"]
        S2["AddressService + UI"]
        S3["ViaCEP API"]
        S4["Melhor Envio API"]
        S5["Provider/localStorage"]
        S6["Wolknow integration"]
        S7["ShopOrdersPage"]
    end
    
    G1 --> S1
    G2 --> S2
    G3 --> S3
    G4 --> S4
    G5 --> S5
    G6 --> S6
    G7 --> S7
    
    style G1 fill:#ffccbc
    style G2 fill:#ffccbc
    style G3 fill:#ffccbc
    style G4 fill:#ffccbc
    style G5 fill:#ffccbc
    style G6 fill:#ffccbc
    style G7 fill:#ffccbc
    
    style S1 fill:#c8e6c9
    style S2 fill:#c8e6c9
    style S3 fill:#c8e6c9
    style S4 fill:#c8e6c9
    style S5 fill:#c8e6c9
    style S6 fill:#c8e6c9
    style S7 fill:#c8e6c9
```

---

## 10. CHECKLIST DE TESTES

```mermaid
graph TD
    Start["🧪 Testes de Fluxo"] --> Test1["1. Adicionar ao carrinho<br/>✓ CartItem aparece<br/>✓ Quantidade mostra corretamente"]
    
    Test1 --> Test2["2. Atualizar quantidade<br/>✓ updateQuantity chamado<br/>✓ Total recalculado"]
    
    Test2 --> Test3["3. Remover item<br/>✓ removeItem chamado<br/>✓ Carrinho atualizado"]
    
    Test3 --> Test4["4. Ir para checkout<br/>✓ CartState observável<br/>✓ Itens mostram em resumo"]
    
    Test4 --> Test5["5. Preencher checkout<br/>✓ Validação de campos<br/>✓ Formulário submete"]
    
    Test5 --> Test6["6. Criar Order<br/>✓ POST /marketplace/orders<br/>✓ Order retorna com ID"]
    
    Test6 --> Test7["7. Navegar para pagamento<br/>✓ /shop/checkout/payment/:orderId<br/>✓ Mock de pagamento mostra"]
    
    Test7 --> End["✅ Fluxo completo OK"]
    
    style Test1 fill:#c8e6c9
    style Test2 fill:#c8e6c9
    style Test3 fill:#c8e6c9
    style Test4 fill:#c8e6c9
    style Test5 fill:#c8e6c9
    style Test6 fill:#c8e6c9
    style Test7 fill:#fff3e0
    style End fill:#c8e6c9
```

---

## LEGENDA

| Símbolo | Significado |
|---------|------------|
| ✅ | Implementado e funcional |
| ⚠️ | Implementado mas com gaps/mock |
| ❌ | Não implementado |
| 🎨 | UI Component |
| 🔄 | Provider/State Management |
| 🌐 | Service/API |
| 📦 | Model/Data |
| 🖥️ | Backend Endpoint |
| ⭐ | Relacionado a afiliados |

