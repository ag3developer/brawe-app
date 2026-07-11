# 🗺️ Vitrine — Roadmap de Execução + Rotas + Agentes de IA

> Companheiro do `VITRINE_AFILIADO_IMPLEMENTACAO.md`. Aqui está o **plano
> operacional**: o que executar, em que ordem, **quais rotas** criar e **qual
> agente de IA** usar em cada tarefa (para desenvolvimento mais barato e paralelo).
>
> ⚠️ **Dois módulos, em ordem**: **Módulo A — Vitrine** (Fases 0→5) executa
> primeiro; **Módulo B — Itens pinados em Live** vem depois, reaproveitando o
> carrinho/checkout do Módulo A. **MVP prioritário: Fase 1A** (vitrine do
> perfil) — usuário segue parceiros já aprovados e compra, sem esperar a
> descoberta de marcas (1B) nem o fluxo de aprovação no app (Fase 2).
>
> ⚠️ **Terminologia**: a UI nunca mostra "afiliado"/"affiliate" — sempre
> "Parceiro"/"Parceria". `affiliate` só em nomes internos (rotas de API, classes).
> **Comissão nunca é exibida ao comprador** — é informação interna entre loja
> e parceiro (removida da UI de compra em 2026-07-11).
>
> Data: 2026-07-10 · **Última atualização: 2026-07-11** · Status: **Em
> execução — Fase 0, Fase 1A (1/2), Fase 3 (parcial) e parte da Fase 4/5
> concluídas. Ver §0 para status detalhado por tarefa.**

---

## 0. Status atual (2026-07-11) — o que já foi feito

> Legenda: ✅ feito · ⚠️ feito parcial/mock · ❌ não iniciado

| # | Tarefa (rota) | Status | Nota |
|---|---|---|---|
| 0.1-0.8 | Fase 0 completa (models/services/providers/rotas) | ✅ | `dart analyze` clean |
| Backend P1 | `POST /marketplace/orders` aceita `affiliate_id` | ✅ | Já existia, validado |
| Backend P3 | `GET /marketplace/affiliate/showcase` | ✅ | Já existia |
| Backend P4 | `CartItem`/`OrderItem` com `affiliate_ref_code`+`room_id` | ✅ | Migration 021, PR mergeada, aplicada em produção |
| Backend (gap) | `comissao_rate`/`comissao_amount` preview em `cart_items` | ✅ | Migration 022, aplicada em produção (2026-07-11) |
| 1A.1 | Vitrine do perfil (aba "Vitrine"/"Loja") | ✅ | `myStorefrontProductsProvider` + `profile_screen.dart` |
| 1A.2 | Detalhe do Produto (`/shop/product/:id`) | ✅ | `ShopProductPage` + carrossel/preço/store card — **sem comissão visível** |
| 1B.1 | Descobrir Marcas (`/shop`) | ❌ | Rota ainda `Placeholder()` |
| 1B.2 | Detalhe da Marca (`/shop/store/:slug`) | ✅ | `ShopStorePage` — banner, header, contatos, grid produtos |
| 1B.3 | Pontos de entrada (Explore/Home) para `/shop` | ❌ | Não iniciado |
| 2.x | Fluxo de Parceria (apply/aprovar no app) | ❌ | Adiável — segue via backend/web |
| 3.1 | Carrinho (`/shop/cart`) | ✅ | `ShopCartPage` + `CartNotifier` (Riverpod `Notifier`) |
| 3.2 | Atribuição por item (`room_id`/`ref_code`) | ✅ | Backend pronto; app ainda não envia `room_id` real (só via `CartItemRequest`, sem UI de live ainda) |
| 3.3 | Badge global do carrinho | ⚠️ | Só no AppBar do `ShopProductPage` — falta em outras telas |
| 3.4 | Integração na Live ("Loja ao vivo") | ❌ | Módulo B — não iniciado |
| 3.5 | Endereço de entrega | ✅ | Formulário inline no `ShopCheckoutPage` (cria/lista, sem tela dedicada) |
| 3.6 | Checkout (resumo + criar pedido) | ⚠️ | `ShopCheckoutPage` existe, mas **não agrupa por loja** (1 `CheckoutRequest` único mesmo com itens de lojas diferentes) — ver §11 |
| 3.7 | Guards de estoque/erros (409) | ❌ | Checkout só trata erro genérico |
| 4.1-4.4 | Seleção de método + PIX/cripto/card | ⚠️ | `ShopPaymentPage` é **mock** (QR placeholder, sem gateway real) |
| 4.5 | Polling de status de pagamento | ❌ | `paymentStatusProvider` existe mas não é chamado |
| 4.6 | Tela de sucesso | ⚠️ | Botão "Ver Meus Pedidos" existe, mas `/shop/orders` é `Placeholder()` |
| 5.1 | Meus Pedidos (`/shop/orders`) | ❌ | Rota `Placeholder()` |
| 5.2 | Ganhos do parceiro | ❌ | Não iniciado |
| 5.3 | Gerar link de parceria | ❌ | Não iniciado |
| 5.4 | Lado lojista (Solicitações Recebidas) | ❌ | Adiável — existe na web |
| 5.5 | Auditoria final 6 combinações (2 temas × 3 idiomas) | ❌ | Não iniciado — telas feitas têm i18n/tema desde a criação, mas falta auditoria formal |
| B.1-B.6 | Módulo B (itens pinados em live) | ❌ | Não iniciado — depende de A completo |

**Resumo objetivo**: dá pra navegar Vitrine do perfil → Produto → Loja →
Carrinho → Checkout → "Pagamento" (mock) hoje. **Falta para ficar 100%**:
página `/shop` (descobrir marcas), `/shop/orders`, `/shop/partnerships`,
gateway de pagamento real, checkout multi-loja, e toda a Fase 2 (parceria) e
Módulo B. Ver checklist detalhado no documento principal, §9.

---

## 1. Estratégia de agentes (custo × capacidade)

Cada tarefa é rotulada com um **tipo de agente**. Use o modelo mais barato que
resolve bem a tarefa — reserve os modelos caros para arquitetura e fluxos críticos.

| Agente (papel) | Quando usar | Modelo sugerido (custo) | Autonomia |
|---|---|---|---|
| **🧭 Arquiteto** | Decisões de estrutura, contratos, revisão de PR crítico, fluxos de pagamento/atribuição | Modelo topo (Claude Opus / GPT-5 alto raciocínio) — **caro, pouco uso** | Alta |
| **🎨 UI Builder** | Criar telas/componentes Flutter **modernos** (ver §4), animações, tema, responsivo | Modelo forte em código+visão (Claude Sonnet / GPT-5) — **médio** | Média |
| **🔌 Integrador (dados)** | Models freezed, services Dio, repositories, providers — trabalho mecânico "de molde" | Modelo médio/barato (Sonnet / Haiku / GPT-5-mini) — **barato** | Média |
| **🌐 i18n/Locale** | Extrair strings, gerar `.arb` pt/en/es, plural/moeda/data | Modelo barato (Haiku / mini) — **muito barato** | Alta |
| **🧪 QA/Test** | Testes de widget, checagem 2 temas × 3 idiomas, `dart analyze`, revisão de acessibilidade | Modelo médio/barato — **barato** | Média |
| **🔎 Explorador** | Buscar no código, mapear endpoints, achar padrões (read-only) | Modelo barato/rápido (subagent Explore) — **muito barato** | Alta |

> **Regra de ouro de custo**: **Explorador → Integrador → UI Builder → QA** fazem
> ~85% do volume com modelos baratos/médios. O **Arquiteto** entra só nos gates
> (início de fase, checkout, pagamento, atribuição de comissão) e revisão final.

### Como o router "chama" os agentes
O roteamento de agentes é o próprio fluxo de trabalho: cada tarefa abaixo indica
o agente. Na prática, dispare **subagentes** (ex.: `Explore` para pesquisa) e use
o agente principal com o modelo indicado para a execução. Tarefas independentes
(§3) rodam **em paralelo**.

---

## 2. Mapa de ROTAS (GoRouter)

Todas dentro do `ShellRoute` (com `HomeBottomNav`), padrão `BraweTransitions`.

| Rota | Tela | Fase | Módulo | Canal |
|---|---|---|---|---|
| **aba do perfil** | Vitrine (produtos do parceiro) | **1A (MVP)** | A | vitrine |
| `/shop/product/:id` | Detalhe do Produto | 1A | A | ambos |
| `/shop` | Descobrir Marcas (lista de lojas) | 1B | A | descoberta |
| `/shop/store/:slug` | Detalhe da Marca (+ solicitar parceria) | 1B/2 | A | descoberta |
| `/shop/cart` | 🛒 Carrinho compartilhado | 3 | A | ambos |
| `/shop/checkout` | Checkout | 3 | A | ambos |
| `/shop/checkout/payment/:orderId` | Pagamento (PIX/cripto) | 4 | A | ambos |
| `/shop/orders` | Meus Pedidos | 5 | A | comprador |
| `/shop/orders/:orderNumber` | Detalhe/rastreio do pedido | 5 | A | comprador |
| `/shop/partnerships` | Minhas Parcerias (status) | 2 | A | parceiro |
| `/shop/partnerships/received` | Solicitações Recebidas (lojista) | 2 (adiável) | A | lojista |
| **overlay** (sem rota) | "Loja ao vivo" drawer (todos os produtos + carrinho) | B | B | live |

> Deep links: `/shop/store/:slug` e `/shop/product/:id` devem funcionar por link
> externo (compartilhamento pelo parceiro).

---

## 3. Roadmap por fase (com agente por tarefa)

Legenda de agente: 🧭 Arquiteto · 🎨 UI · 🔌 Integrador · 🌐 i18n · 🧪 QA · 🔎 Explorador
· `∥` = paralelizável.

### FASE 0 — Fundação (2-3 dias)
| # | Tarefa | Agente | Rota/arquivo |
|---|---|---|---|
| 0.1 | Mapear endpoints reais + payloads (confirmar contratos) | 🔎 | — |
| 0.2 | Definir contratos Dart (interfaces dos services) | 🧭 | `data/services/shop/` |
| 0.3 ∥ | Models freezed (`Store, Product, PartnershipApplication, Cart, CartItem, Order, ShippingAddress, PaymentIntent`, enums) — nomes de classe sem "affiliate" (interno só nas rotas) | 🔌 | `domain/models/shop/` |
| 0.4 ∥ | Services Dio (main + connect) | 🔌 | `data/services/shop/` |
| 0.5 | Repositories + providers Riverpod | 🔌 | `data/repositories/shop/` |
| 0.6 | Registrar rotas no GoRouter (stubs) | 🔌 | `routing/router.dart` |
| 0.7 | Corrigir `product_service.getUserProducts` (endpoint quebrado) | 🔌 | `data/services/product_service.dart` |
| 0.8 | Gate de arquitetura + `dart analyze` | 🧭 🧪 | — |

**Gate 🧭**: revisar contrato de `CartItem` (campo de atribuição `room_id`/`ref_code` por item) — crítico p/ comissão diferida.

### FASE 1A — Vitrine do perfil (MVP 🎯) (1.5-2 dias)
> Prioridade máxima — entrega o caso de uso da capa: seguir parceiro já
> aprovado (via backend/web) e comprar pela vitrine dele.
| # | Tarefa | Agente | Rota |
|---|---|---|---|
| 1A.1 | Aba Vitrine do perfil (produtos agregados reais / CTA "Descubra marcas") | 🎨 | perfil |
| 1A.2 ∥ | Card de produto + Detalhe do Produto ("Comprar") | 🎨 | `/shop/product/:id` |
| 1A.3 ∥ | Strings pt/en/es (texto sempre "Parceiro", nunca "afiliado") | 🌐 | `.arb` |
| 1A.4 | QA: 2 temas × 3 idiomas | 🧪 | — |

### FASE 1B — Descoberta de marcas (pode rodar em paralelo/depois) (1.5-2 dias)
| # | Tarefa | Agente | Rota |
|---|---|---|---|
| 1B.1 | Tela Descobrir Marcas (grid, busca, filtros) | 🎨 | `/shop` |
| 1B.2 ∥ | Detalhe da Marca (banner, produtos, badge parceria) | 🎨 | `/shop/store/:slug` |
| 1B.3 | Pontos de entrada: segmento "Marcas" no Explore + CTA Vitrine + atalho Home | 🎨 | `/explore`, `/home` |
| 1B.4 ∥ | Strings pt/en/es | 🌐 | `.arb` |
| 1B.5 | QA: 2 temas × 3 idiomas | 🧪 | — |

### FASE 2 — Parceria (3-4 dias) — adiável, não bloqueia o MVP
| # | Tarefa | Agente | Rota |
|---|---|---|---|
| 2.1 | Sheet "Solicitar Parceria" (pitch + amostra) | 🎨 | `/shop/store/:slug` |
| 2.2 | Minhas Parcerias (lista + status + cancelar) | 🎨 | `/shop/partnerships` |
| 2.3 | Lógica de apply/cancel/status | 🔌 | service |
| 2.4 ∥ | Badges de status + notificações push | 🎨 | — |
| 2.5 ∥ | Strings pt/en/es | 🌐 | `.arb` |
| 2.6 | QA | 🧪 | — |

### FASE 3 — Carrinho compartilhado + Checkout (5-6 dias) ⭐ central
| # | Tarefa | Agente | Rota |
|---|---|---|---|
| 3.1 | Carrinho compartilhado (add/update/remove/cupom, agrupado por loja) | 🎨🔌 | `/shop/cart` |
| 3.2 | **Atribuição por item** (`room_id`/`ref_code` na origem) | 🧭🔌 | cart service |
| 3.3 | Badge global do carrinho (vitrine/live/shop) | 🎨 | — |
| 3.4 | **Canal A — evoluir "Loja ao vivo"** (todos os produtos + add carrinho/comprar já, live tocando atrás) | 🎨 | overlay live (`products_drawer.dart`) |
| 3.5 | Endereço de entrega (listar/criar/selecionar) | 🎨🔌 | `/shop/checkout` |
| 3.6 | Checkout (resumo por loja) → `POST /shopping/checkout` | 🎨🔌 | `/shop/checkout` |
| 3.7 | Guards de estoque/erros (409, esgotado) | 🔌 | — |
| 3.8 ∥ | Strings pt/en/es | 🌐 | `.arb` |
| 3.9 | Gate 🧭 + QA (fluxo live→carrinho→checkout diferido) | 🧭🧪 | — |

**Gate 🧭**: validar que item adicionado na live credita o criador mesmo com
checkout posterior (comissão diferida).

### FASE 4 — Pagamento no app (Wolknow) (4-5 dias)
| # | Tarefa | Agente | Rota |
|---|---|---|---|
| 4.1 | Seleção de método (`payment-config` + flags da loja) | 🎨🔌 | `/shop/checkout/payment/:orderId` |
| 4.2 | Criar pagamento → `POST /shopping/payments/create` | 🔌 | — |
| 4.3 | PIX: QR + copia-e-cola + expiração | 🎨 | — |
| 4.4 ∥ | Cripto: endereço + valor + QR | 🎨 | — |
| 4.5 | **Polling de status** (timeout/retry) → sucesso | 🧭🔌 | — |
| 4.6 | Tela de sucesso + ir para pedido | 🎨 | — |
| 4.7 ∥ | Strings pt/en/es | 🌐 | `.arb` |
| 4.8 | Gate 🧭 (fluxo de pagamento) + QA | 🧭🧪 | — |

### FASE 5 — Pedidos + comissões + polimento (3-4 dias)
| # | Tarefa | Agente | Rota |
|---|---|---|---|
| 5.1 | Meus Pedidos + rastreio | 🎨🔌 | `/shop/orders` |
| 5.2 | Ganhos do parceiro (integrar carteira/creator) | 🎨🔌 | — |
| 5.3 | Gerar link de parceria (compartilhar produto) | 🔌 | — |
| 5.4 | (adiável) Lado lojista: Solicitações Recebidas + pedidos | 🎨🔌 | `/shop/partnerships/received` |
| 5.5 | Auditoria final 6 combinações (2 temas × 3 idiomas) | 🧪 | — |
| 5.6 | Testes de widget dos fluxos críticos | 🧪 | — |

---

### MÓDULO B — Itens pinados em Live (3-4 dias, DEPOIS do Módulo A)
> Evolui `PinnedProductBar` + `products_drawer.dart` (hoje só exibem) para
> integrar com o carrinho/checkout já construídos no Módulo A. Reaproveita
> serviços/telas de checkout e pagamento — não recria nada.

| # | Tarefa | Agente | Rota/arquivo |
|---|---|---|---|
| B.1 | Drawer "Loja ao vivo" lista **todos** os produtos do criador (pinados em destaque + storefront agregado) | 🎨🔌 | `products_drawer.dart` |
| B.2 | Botões "Adicionar ao carrinho" / "Comprar já" por produto (reusa `CartService`) | 🎨🔌 | overlay live |
| B.3 | Badge de carrinho na overlay da live | 🎨 | `pinned_product_bar.dart` |
| B.4 | Herdar `room_id` + `ref_code` de origem ao adicionar (usa contrato do Ponto 4, §3.7) | 🔌 | cart service |
| B.5 ∥ | Strings pt/en/es | 🌐 | `.arb` |
| B.6 | Gate 🧭 (comissão diferida ao vivo) + QA | 🧭🧪 | — |

---

## 4. Padrão de UI MODERNA (2026 — nada de 2014) 🎨

> Regras que o **agente 🎨 UI Builder** deve seguir em toda tela/componente.
> Objetivo: visual premium tipo TikTok Shop / Instagram Shop 2026.

**Fundamentos:**
- **Material 3** (`useMaterial3: true`) — sem widgets legados estilo 2014
  (nada de `RaisedButton`, `FlatButton`; usar `FilledButton`, `FilledButton.tonal`,
  `SegmentedButton`, `NavigationBar`, `Card` M3).
- **Tema do projeto sempre** (`context.colors.*`) — 2 temas obrigatórios (§2.5 do
  doc principal). Zero cor hardcoded.
- **Tipografia hierárquica** (títulos bold, secundário `textSecondary`),
  espaçamento generoso (8-pt grid), cantos arredondados consistentes (12-16).

**Interações modernas:**
- **Skeletons/shimmer** no loading (não spinner cru no meio da tela).
- **Bottom sheets arrastáveis** (`DraggableScrollableSheet`) para carrinho, apply,
  detalhes rápidos — padrão do drawer de live já existente.
- **Animações sutis**: `AnimatedSwitcher`, `Hero` (produto → detalhe),
  transições `BraweTransitions` (já no projeto), micro-feedback com `HapticFeedback`.
- **Imagens** com `CachedNetworkImage` + placeholder shimmer + fallback.
- **Empty states** ilustrados e com CTA (não tela em branco).
- **Badges/pills** para status (parceria, estoque, comissão) com cor semântica
  (`success/warning/danger`).

**Comércio-específico:**
- Cards de produto estilo grid 2-col com preço, preço riscado (`compareAtPrice`),
  selo de comissão, e botão "+carrinho" flutuante.
- **Carrinho** com swipe-to-remove, stepper de quantidade animado, resumo fixo
  no rodapé (sticky) com total e CTA.
- **Checkout** em etapas claras (resumo → endereço → pagamento), com progress.
- **PIX**: QR grande, botão "copiar código" com feedback, contador de expiração.

**Qualidade/acessibilidade:**
- Responsivo (telas pequenas e tablets), sem overflow.
- `Semantics`/labels para leitores de tela; alvos de toque ≥ 48px.
- Testar dark/light e pt/en/es antes do merge (DoD §2.5).

> **Anti-padrões proibidos**: cor hardcoded, string literal, spinner solitário,
> `ListView` sem `CachedNetworkImage`, botões Material 2, telas sem empty/error state.

---

## 5. Paralelização (para baratear/acelerar)

Tarefas com `∥` podem rodar **em paralelo** por agentes diferentes:
- Enquanto 🔌 monta models/services (Fase 0), 🔎 mapeia endpoints e 🌐 prepara chaves.
- Na Fase 1, 🎨 constrói telas em paralelo (Descobrir / Detalhe Marca / Produto).
- 🌐 e 🧪 rodam ao final de cada fase, baratos.
- 🧭 entra só nos **gates** (Fase 0 fim, Fase 3 atribuição, Fase 4 pagamento).

**Distribuição de custo estimada:**
| Agente | % das tarefas | Modelo |
|---|---|---|
| 🔎 Explorador | ~10% | barato |
| 🔌 Integrador | ~30% | barato/médio |
| 🎨 UI Builder | ~40% | médio |
| 🌐 i18n | ~8% | muito barato |
| 🧪 QA | ~8% | barato |
| 🧭 Arquiteto | ~4% | caro (só gates) |

> ~76% do trabalho em modelos **baratos/médios**; caro só ~4%.

---

## 6. Ordem de execução recomendada (sprints)

> Módulo A primeiro (Fases 0→5); Módulo B só depois de A estar de pé.

1. **Sprint 1** (Fase 0 + Fase 1A): fundação + **Vitrine do perfil (MVP 🎯)** —
   já dá pra seguir parceiro aprovado e comprar.
2. **Sprint 2** (Fase 1B + Fase 2, podem rodar em paralelo): Descobrir Marcas +
   fluxo de Parceria (solicitar/aprovar) no app.
3. **Sprint 3** (Fase 3): carrinho compartilhado + checkout.
4. **Sprint 4** (Fase 4): pagamento Wolknow ponta-a-ponta.
5. **Sprint 5** (Fase 5): pedidos, comissões, lado lojista (opcional), polimento.
6. **Sprint 6** (Módulo B): itens pinados em live — reaproveita tudo de A.

**Início imediato**: disparar 🔎 (mapear payloads) + 🧭 (contratos) → liberar 🔌
para a Fase 0, seguido direto da **Fase 1A** (MVP).
