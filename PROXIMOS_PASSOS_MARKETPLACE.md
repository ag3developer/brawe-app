# 🗂️ Próximos Passos — Marketplace (Continuidade 2026-07-11)

**Data:** 11 de Julho de 2026  
**Status Atual:** Fase 1A.2 ✅ Completa  
**Desenvolvedor:** [Você]  
**Próxima Tarefa:** Fase 1B (Descoberta de Marcas) OU Fase 3 (Carrinho)

---

## 📊 Resumo do que foi feito até agora

### ✅ Fase 0 — Fundação (Completa)
- ✅ Models freezed (Product, Store, Cart, CartItem, Order, ShippingAddress, PaymentIntent)
- ✅ Services Dio para marketplace
- ✅ Repositories + Providers Riverpod
- ✅ Rotas registradas no GoRouter

### ✅ Fase 1A — Vitrine do Perfil (MVP - Completa)
- ✅ **1A.1** Aba Vitrine no perfil (produtos do parceiro agregados)
- ✅ **1A.2** Detalhe do Produto + Carrossel + Preço + Store Card (SEM comissão visível)

---

## 🎯 Recomendação para continuidade

Com base na análise, há **2 caminhos possíveis**:

### 🔴 Opção A: **Fase 1B — Descoberta de Marcas** (1.5-2 dias)
**Recomendado se:** você quer completar a **navegação/descoberta** antes de fazer compras

**O que será feito:**
1. **1B.1** - Tela `/shop` (Descobrir Marcas)
   - Grid de lojas/marcas
   - Busca por nome
   - Filtros (categoria, rating)
   
2. **1B.2** - Detalhe da Marca `/shop/store/:slug`
   - Banner da loja
   - Grid de produtos
   - Badge de parceria
   
3. **1B.3** - Pontos de entrada
   - Segmento "Marcas" no Explore
   - CTA na vitrine
   - Atalho na Home

4. **1B.4** - Internacionalização (pt/en/es)
5. **1B.5** - QA (2 temas × 3 idiomas)

**Arquivos a criar:** ~6-8 arquivos (pages + widgets)  
**Agentes necessários:** 🎨 UI Builder (principal) + 🌐 i18n + 🧪 QA  
**Status da API:** ✅ Backend pronto (`GET /marketplace/stores`)

---

### 🟢 Opção B: **Fase 3 — Carrinho + Checkout** (5-6 dias)
**Recomendado se:** você quer **fechar o loop de compra completo** (produto → carrinho → checkout)

**O que será feito:**
1. **3.1** - Carrinho compartilhado `/shop/cart`
   - Add/remove/update quantidade
   - Agrupado por loja
   - Cupom de desconto
   - Badge global

2. **3.2** - Atribuição de comissão por item
   - Enviar `room_id`/`ref_code` no checkout
   - Registro de afiliado no pedido

3. **3.5** - Endereço de entrega
   - Listar endereços salvos
   - Criar novo
   - Selecionar para checkout

4. **3.6** - Checkout
   - Resumo por loja
   - `POST /marketplace/checkout`
   - Criar pedido

5. **3.3** - Badge global do carrinho
   - Vitrine
   - Live
   - Shop

6. **3.8** - Internacionalização (pt/en/es)
7. **3.9** - QA + validação de fluxo

**Arquivos a criar:** ~8-10 arquivos (pages + widgets + services)  
**Agentes necessários:** 🎨 UI Builder + 🔌 Integrador (dados) + 🧭 Arquiteto (gate de comissão) + 🌐 i18n + 🧪 QA  
**Status da API:** ✅ Backend pronto (`POST /marketplace/checkout`, `POST /marketplace/cart`)  
**Risco:** ⚠️ Comissão diferida (item adicionado na live, checkout depois) — precisa validação

---

## 💡 Minha recomendação

**Vá com Opção B (Carrinho + Checkout)** porque:

1. **Fecha o MVP de compra** — vitrine → produto → carrinho → checkout funciona end-to-end
2. **Mais valor** — usuários podem realmente comprar, não só navegar
3. **Desbloqueador** — o carrinho é pré-requisito para Fase 4 (Pagamento)
4. **Fase 1B pode ser paralela** — se tiver outro dev, pode rodar Descoberta enquanto você faz checkout
5. **Atrasará menos a entrega** — Descoberta (1B) é nice-to-have; Carrinho é essencial

---

## 📋 Plano de Execução (Opção B - Carrinho)

Se você escolher Fase 3, segue este plano:

### **Dia 1 — Estrutura + Carrinho**

| Tarefa | Agente | Arquivo |
|--------|--------|---------|
| 1️⃣ Mapear endpoint real `/marketplace/cart` | 🔎 Explorador | — |
| 2️⃣ Model `CartItem` com atribuição `room_id`/`ref_code` | 🔌 Integrador | `domain/models/shop/cart_item.dart` |
| 3️⃣ Service `CartService` (add/remove/update/get) | 🔌 Integrador | `data/services/shop/cart_service.dart` |
| 4️⃣ Provider `CartNotifier` (Riverpod) | 🔌 Integrador | `features/shop/providers/cart_provider.dart` |
| 5️⃣ Page `/shop/cart` (UI estrutura) | 🎨 UI Builder | `lib/ui/shop/pages/shop_cart_page.dart` |
| 6️⃣ Widget `CartItemTile` | 🎨 UI Builder | `lib/ui/shop/widgets/cart_item_tile.dart` |

### **Dia 2 — Endereço + Checkout**

| Tarefa | Agente | Arquivo |
|--------|--------|---------|
| 7️⃣ Model `ShippingAddress` | 🔌 Integrador | `domain/models/shop/shipping_address.dart` |
| 8️⃣ Service + Provider para endereços | 🔌 Integrador | `data/services/shop/address_service.dart` |
| 9️⃣ Page `/shop/checkout` (formulário inline) | 🎨 UI Builder | `lib/ui/shop/pages/shop_checkout_page.dart` |
| 🔟 Widget `AddressSelector` + `AddressForm` | 🎨 UI Builder | `lib/ui/shop/widgets/address_*` |
| 1️⃣1️⃣ Lógica de `POST /marketplace/checkout` | 🔌 Integrador | cart service |
| 1️⃣2️⃣ Validação de estoque/erros 409 | 🧭 Arquiteto | — |

### **Dia 3 — Badge Global + i18n + QA**

| Tarefa | Agente | Arquivo |
|--------|--------|---------|
| 1️⃣3️⃣ Badge global do carrinho (ShopProductPage, outras telas) | 🎨 UI Builder | widgets |
| 1️⃣4️⃣ Strings pt/en/es (20 chaves aprox.) | 🌐 i18n | `.arb` (3 arquivos) |
| 1️⃣5️⃣ QA: 2 temas × 3 idiomas + fluxo completo | 🧪 QA | — |

---

## 🚀 Como começar (próximo passo)

Você quer começar com **Opção A (Descoberta)** ou **Opção B (Carrinho)**?

**Assim que confirmar, farei:**

1. ✅ Diagnóstico da API actual (endpoints reais, payloads)
2. ✅ Mapa de arquivos a criar
3. ✅ Primeira tarefa pronta para você executar
4. ✅ Templates de código (models, services, pages)

---

## 📌 Checklist de pré-requisitos

Antes de começar, confirme:

- [ ] App Flutter iniciado localmente (`./start-app.sh`)
- [ ] `lib/routing/router.dart` com rotas `/shop` + `/shop/cart` + `/shop/checkout` (stubs)
- [ ] Backend endpoints documentados
- [ ] Não há merge conflicts no repositório
- [ ] `dart analyze` retorna 0 erros

---

**Qual opção você prefere? 🎯**

- 🔴 **A** — Fase 1B (Descoberta de Marcas)
- 🟢 **B** — Fase 3 (Carrinho + Checkout)
- 🔵 **Outro** — quer fazer algo diferente?
