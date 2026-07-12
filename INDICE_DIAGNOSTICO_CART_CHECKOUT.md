# 📚 ÍNDICE: DIAGNÓSTICO DE CARRINHO + CHECKOUT

## 🎯 Comece por aqui

Este diagnóstico foi criado em **2026-07-11** para documentar o estado atual do sistema de carrinho e checkout do brawe-app.

**Status Geral:** ✅ **75% PRONTO PARA TESTES**

---

## 📖 DOCUMENTOS CRIADOS

### 1. 🏃 DIAGNÓSTICO EXECUTIVO (COMECE AQUI)
**Arquivo:** `DIAGNOSTICO_EXECUTIVO.txt`  
**Tempo de leitura:** 3-5 minutos  
**Conteúdo:**
- Resumo em 30 segundos
- Fluxo atual E2E
- Arquivos principais
- Endpoints do backend
- Gaps e prioridades
- Como testar agora
- Próximos passos

**→ Leia isto PRIMEIRO se não tem muito tempo**

---

### 2. 📊 RESUMO RÁPIDO (TABELAS & CHECKLISTS)
**Arquivo:** `RESUMO_RAPIDO_CART_CHECKOUT.md`  
**Tempo de leitura:** 5-10 minutos  
**Conteúdo:**
- O que já está pronto
- Gaps organizados em tabelas
- Estrutura de arquivos
- Fluxo de uso atual
- Provider references
- Checklist de integração

**→ Perfeito para overview visual com tabelas**

---

### 3. 🎨 FLUXO VISUAL (MERMAID DIAGRAMS)
**Arquivo:** `FLUXO_VISUAL_CART_CHECKOUT.md`  
**Tempo de leitura:** 10-15 minutos  
**Conteúdo:**
- Arquitetura de camadas (UI → Providers → Services → Backend)
- Sequence diagram: Add to Cart
- Sequence diagram: Checkout
- Fluxo completo: Product → Cart → Checkout
- Visualização de CartState
- CartSession (anonymous)
- Rotas registradas
- Integração de afiliados
- Gaps e soluções
- Checklist de testes

**→ Ideal para entender fluxo de dados visualmente**

---

### 4. 📝 DIAGNÓSTICO COMPLETO (DETALHADO)
**Arquivo:** `DIAGNOSTICO_CARRINHO_CHECKOUT.md`  
**Tempo de leitura:** 20-30 minutos  
**Conteúdo:**
- Estado geral com completude %
- Carrinho: implementado, gaps, dependências
- Checkout: implementado, fluxo, gaps
- Pagamento: estado mock, gaps críticos
- Meus Pedidos: placeholder, gaps
- Modelos criados (Freezed)
- Services de marketplace
- Rotas registradas
- Fluxo completo
- Integração com afiliados
- Checklist de integração (Fase 0, 0.5, 1)
- Resumo executivo

**→ Leia para entender TODOS os detalhes**

---

### 5. 🔍 GUIA RÁPIDO DE ARQUIVOS (REFERÊNCIA)
**Arquivo:** `GUIA_RAPIDO_ARQUIVOS.md`  
**Tempo de leitura:** Consultar conforme necessário  
**Conteúdo:**
- Mapa de arquivos com location
- Code snippets de cada arquivo principal
- Como usar CartNotifier
- Como usar ShopCheckoutPage
- Endpoints de cada service
- Como encontrar coisas específicas
- Padrões de código
- Checklist rápido
- Tabela de referências

**→ Consulte quando precisar saber onde está algo ou como usá-lo**

---

## 🗺️ ROTAS DE LEITURA POR PERFIL

### Para Gerente / Product Manager
1. Leia: `DIAGNOSTICO_EXECUTIVO.txt` (3 min)
2. Veja: Tabelas em `RESUMO_RAPIDO_CART_CHECKOUT.md` (5 min)
3. Pronto! Você sabe o status geral.

### Para Desenvolvedor que vai implementar
1. Leia: `DIAGNOSTICO_EXECUTIVO.txt` (5 min)
2. Veja: `FLUXO_VISUAL_CART_CHECKOUT.md` - Diagramas (10 min)
3. Leia: `DIAGNOSTICO_CARRINHO_CHECKOUT.md` - Seções de interesse (20 min)
4. Use: `GUIA_RAPIDO_ARQUIVOS.md` como referência conforme necessário

### Para QA / Testador
1. Leia: `RESUMO_RAPIDO_CART_CHECKOUT.md` - Checklist de Testes (5 min)
2. Veja: `FLUXO_VISUAL_CART_CHECKOUT.md` - Seção "Fluxo Completo" (5 min)
3. Siga: Instruções em `DIAGNOSTICO_EXECUTIVO.txt` - "Como testar agora" (10 min)
4. Execute: Teste E2E (produto → cart → checkout → payment)

### Para Arquiteto / Senior
1. Leia: `FLUXO_VISUAL_CART_CHECKOUT.md` - Arquitetura de camadas (5 min)
2. Leia: `DIAGNOSTICO_CARRINHO_CHECKOUT.md` - Gaps importantes (10 min)
3. Leia: Seção de afiliados em ambos os documentos (5 min)
4. Tome decisões sobre: affiliate_id origin, próximos passos

---

## 🎯 DECISÕES CRÍTICAS NECESSÁRIAS

Ler documentação não é suficiente. **Estas decisões precisam ser tomadas:**

### 1. 🔴 ORIGEM DO AFFILIATE_ID
**Pergunta:** Como o app SABE qual afiliado referiu o comprador?

**Opções:**
- [ ] Vem de um `Provider` (ex: `affiliateContextProvider`)
- [ ] Vem de localStorage (deep link com ref code)
- [ ] Vem de URL (deep linking quando entra via link de afiliado)
- [ ] Vem do contexto da loja (se entrou via /shop/store/:slug de um afiliado)
- [ ] Vem do contexto de live (room_id + affiliate_id da live)

**Impacto:** Define como rastrear comissões de afiliados end-to-end

---

### 2. 🔴 INTEGRAÇÃO DE ENDEREÇOS SALVOS
**Pergunta:** Quem e quando integra o AddressService na UI do checkout?

**Opções:**
- [ ] Mostrar dropdown de endereços salvos
- [ ] Permitir criar novo endereço
- [ ] Editar endereço existente
- [ ] Tudo acima

**Impacto:** UX do checkout + reusabilidade

---

### 3. 🔴 PERSISTÊNCIA DE SESSION ANÔNIMO
**Pergunta:** SessionID deve persistir entre restarts?

**Opções:**
- [ ] Sim: usar `shared_preferences` (recomendado para carts que custam dinheiro)
- [ ] Não: em memória é suficiente

**Impacto:** Usuários anônimos perdem carrinho se fecharem app

---

### 4. 🟡 PAGAMENTO REAL (Pode ser adiado)
**Pergunta:** Quando integrar Wolknow?

**Opções:**
- [ ] Fase 1 (próxima)
- [ ] Fase 2 (depois)
- [ ] Será fornecido por outro time

**Impacto:** Tempo para pagamento real funcionar

---

## ✅ CHECKLIST DE LEITURA

Marque enquanto lê:

- [ ] Li `DIAGNOSTICO_EXECUTIVO.txt`
- [ ] Vi `FLUXO_VISUAL_CART_CHECKOUT.md` - diagramas
- [ ] Li `RESUMO_RAPIDO_CART_CHECKOUT.md` - tabelas
- [ ] Entendo fluxo: Produto → Cart → Checkout → Payment
- [ ] Identifiquei os 3 gaps maiores
- [ ] Sei onde fica cada arquivo principal
- [ ] Entendo como CartNotifier funciona
- [ ] Entendo como CheckoutPage funciona
- [ ] Sei que pagamento é mock (Wolknow não integrado)
- [ ] Sei que /shop/orders é placeholder
- [ ] Compreendo estrutura de afiliados
- [ ] Tenho decisões críticas identificadas

---

## 📞 REFERÊNCIAS RÁPIDAS

### Preciso saber...
| O quê | Onde procurar | Tempo |
|------|---|---|
| Status geral em 30 seg | DIAGNOSTICO_EXECUTIVO.txt | 1 min |
| Fluxo visual | FLUXO_VISUAL_CART_CHECKOUT.md | 10 min |
| Implementação de carrinho | GUIA_RAPIDO_ARQUIVOS.md + código | 20 min |
| Como testar | DIAGNOSTICO_EXECUTIVO.txt (fim) | 10 min |
| Gaps e prioridades | RESUMO_RAPIDO_CART_CHECKOUT.md | 5 min |
| Afiliados end-to-end | DIAGNOSTICO_CARRINHO_CHECKOUT.md seção 9 | 10 min |
| Arquivo específico | GUIA_RAPIDO_ARQUIVOS.md (início) | 2 min |

---

## 🔗 ESTRUTURA DE PASTAS (FYI)

```
brawe-app/
├── DIAGNOSTICO_EXECUTIVO.txt              ← Comece aqui (3 min)
├── RESUMO_RAPIDO_CART_CHECKOUT.md         ← Tabelas (5 min)
├── FLUXO_VISUAL_CART_CHECKOUT.md          ← Diagramas (10 min)
├── DIAGNOSTICO_CARRINHO_CHECKOUT.md       ← Completo (20 min)
├── GUIA_RAPIDO_ARQUIVOS.md                ← Referência (consulte)
├── INDICE_DIAGNOSTICO_CART_CHECKOUT.md    ← Este arquivo
│
└── lib/
    ├── data/
    │   ├── providers/
    │   │   └── cart_notifier_provider.dart      ← CartNotifier (Riverpod)
    │   ├── services/
    │   │   ├── marketplace_cart_service_impl.dart
    │   │   ├── marketplace_checkout_service_impl.dart
    │   │   └── marketplace_address_service_impl.dart
    │   └── repositories/
    │       └── marketplace_repository.dart      ← Agregador de services
    ├── domain/models/
    │   └── marketplace_models.dart              ← Todos os models (Freezed)
    ├── ui/shop/
    │   ├── pages/
    │   │   ├── shop_cart_page.dart              ← UI Carrinho
    │   │   ├── shop_checkout_page.dart          ← UI Checkout
    │   │   ├── shop_payment_page.dart           ← UI Pagamento (mock)
    │   │   └── shop_product_page.dart           ← UI Produto
    │   └── utils/
    │       └── currency_formatter.dart
    └── routing/
        └── router.dart                          ← Rotas registradas
```

---

## 🚀 PRÓXIMO PASSO RECOMENDADO

1. **Se você é gerente:**
   → Leia `DIAGNOSTICO_EXECUTIVO.txt` (3 min)
   → Tome decisões sobre: affiliate_id origin, address integration, payment real

2. **Se você é desenvolvedor:**
   → Leia `FLUXO_VISUAL_CART_CHECKOUT.md` (10 min)
   → Rode teste E2E (instruções em DIAGNOSTICO_EXECUTIVO.txt)
   → Comece com um dos gaps (ex: persistência de session)

3. **Se você é QA:**
   → Leia `RESUMO_RAPIDO_CART_CHECKOUT.md` - Checklist
   → Siga "Como testar agora" em DIAGNOSTICO_EXECUTIVO.txt
   → Teste o fluxo completo

---

## 📊 MÉTRICAS DE IMPLEMENTAÇÃO

| Componente | % Completo | Pronto para | Bloqueia |
|-----------|----------|-----------|----------|
| Carrinho | 95% | Testes | Persistência session |
| Checkout | 70% | Testes parciais | Endereços salvos, affiliate_id origin |
| Pagamento | 20% | Visualização | Integração Wolknow |
| Pedidos | 0% | Nada | Precisa ser criado |
| Modelos | 100% | Produção | Nada |
| Services | 90% | Produção | Pagamento real |
| Rotas | 100% | Produção | Nada |
| **GERAL** | **~75%** | **TESTES** | **Ver decisões críticas** |

---

## 📝 HISTÓRICO DE DOCUMENTAÇÃO

- **2026-07-11:** Documentação criada
  - DIAGNOSTICO_EXECUTIVO.txt (overview)
  - RESUMO_RAPIDO_CART_CHECKOUT.md (tabelas)
  - FLUXO_VISUAL_CART_CHECKOUT.md (mermaid diagrams)
  - DIAGNOSTICO_CARRINHO_CHECKOUT.md (detalhado)
  - GUIA_RAPIDO_ARQUIVOS.md (referência)
  - INDICE_DIAGNOSTICO_CART_CHECKOUT.md (este arquivo)

---

## ✨ CONCLUSÃO

Você tem tudo que precisa para entender o estado atual do sistema de carrinho e checkout. 

**Comece por:** `DIAGNOSTICO_EXECUTIVO.txt` (3 minutos)

**Depois escolha sua próxima leitura** baseado em seu perfil (gerente, dev, QA, arquiteto).

**Decisões críticas precisam ser tomadas** sobre affiliate_id origin, address integration e payment real.

---

**Status:** ✅ 75% Pronto | ⚠️ Precisa decisões | ❌ Faltam 3 coisas

**Próximo:** Leia DIAGNOSTICO_EXECUTIVO.txt (comece agora!)
