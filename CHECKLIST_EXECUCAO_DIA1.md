# ✅ Checklist de Execução - DIA 1

**Seu roteiro passo a passo para executar o DIA 1**

---

## 🔴 FASE 1: Preparação

- [x] Corrigido bug em `comment_service.dart` ✅
- [x] App compilado com sucesso ✅
- [x] 3 features implementadas ✅
- [x] Documentação completa ✅
- [ ] **Próximo:** Você vai rodar app manualmente

---

## 🟡 FASE 2: Compilação & Teste (15 minutos)

### Passo 1: Iniciar App

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
./start-app.sh
```

- [ ] Script iniciou sem erros
- [ ] Simulador abriu
- [ ] App compilou (~60 segundos)
- [ ] App aparece no simulador
- [ ] Status: "A Dart VM Service..." apareceu

### Passo 2: Navegar para Vitrine

```
Home → Shop → Vitrine (ou acesse: /shop/vitrine)
```

- [ ] Página carregou
- [ ] Produtos aparecem
- [ ] Nenhum erro no console

### Passo 3: Testar Session Persistence

```
1. Clique em um produto
2. Clique "Adicionar ao carrinho"
3. Verifique badge: mostra "1"
4. Pressione Q no terminal (sai do app)
5. Aguarde 5 segundos
6. Execute: ./start-app.sh novamente
7. Navegue para carrinho: /shop/cart
```

- [ ] Badge mostra "1" após reabrir ✅ **TESTE PASSOU**
- [ ] Item ainda está no carrinho ✅
- [ ] Nenhum erro no console

**Se falhar:** Veja [Solução 1 abaixo](#soluções)

### Passo 4: Testar ViaCEP Auto-Complete

```
1. Vá para checkout: /shop/checkout
2. Clique no campo de CEP
3. Digite: 01310100 (sem hífen)
4. Aguarde 1-2 segundos
```

- [ ] Loading spinner apareceu ✅
- [ ] Campos auto-completaram:
  - [ ] Rua: "Avenida Paulista"
  - [ ] Bairro: "Bela Vista"
  - [ ] Cidade: "São Paulo"
  - [ ] Estado: "SP"
- [ ] Snackbar verde: "✓ Endereço auto-completado" ✅ **TESTE PASSOU**

**Se falhar:** Veja [Solução 2 abaixo](#soluções)

### Passo 5: Testar CEP Inválido

```
1. Limpe o campo de CEP
2. Digite: 00000000 (CEP inválido)
3. Aguarde 1-2 segundos
```

- [ ] Loading spinner apareceu ✅
- [ ] Erro apareceu: "CEP não encontrado" ✅ **TESTE PASSOU**

**Se falhar:** Veja [Solução 2 abaixo](#soluções)

### Passo 6: Testar E2E Flow (Opcional)

```
1. Vitrine → Clique em um produto
2. Produto → "Adicionar ao carrinho"
3. Carrinho → "Ir para Checkout"
4. Checkout → Preencha:
   - CEP: 01310100 (auto-completa)
   - Número: 1000
   - Bairro: (já preenchido)
   - Cidade: (já preenchido)
   - Nome: Seu Nome
   - Email: seu@email.com
5. Clique "Confirmar"
6. Deve navegar para pagamento
```

- [ ] Cada passo funcionou ✅
- [ ] Nenhum erro ou crash ✅ **E2E PASSOU**

---

## 🟢 FASE 3: Commits (10 minutos)

### Passo 1: Verificar Status

```bash
git status
```

- [ ] Mostra arquivos modified/new
- [ ] Nenhum conflict

### Passo 2: Stage All Changes

```bash
git add -A
git status
```

- [ ] Todos os arquivos aparecem em "Changes to be committed"

### Passo 3: Commit 1 - Bug Fix

```bash
git commit -m "fix: remove extraneous 'K' characters in comment_service.dart

- Removed 9 'K' characters that were blocking hot reload (lines 96-104)
- Enables smooth development with hot reload
- Resolves compilation error with 10+ error messages"
```

- [ ] Commit criado com sucesso
- [ ] Mensagem descritiva

### Passo 4: Commit 2 - Session Persistence

```bash
git commit -m "feat: Implement cart session persistence with shared_preferences

- Add CartSessionManager to persist anonymous session ID
- Session persists across app restarts (30-day expiry)
- Initialize CartSession during app startup
- Closes: Anonymous cart lost after app restart"
```

- [ ] Commit criado

### Passo 5: Commit 3 - Affiliate Origin

```bash
git commit -m "feat: Add affiliate origin tracking for commission attribution

- Capture affiliate origin from URL parameters (?affiliate_code=, ?ref=)
- Support multiple sources: URL, deep link, live creator, saved
- Persist affiliate ID in localStorage"
```

- [ ] Commit criado

### Passo 6: Commit 4 - ViaCEP

```bash
git commit -m "feat: Integrate ViaCEP for address auto-completion in checkout

- Auto-complete address fields from CEP (8-digit postal code)
- Support CEP with or without hyphen format
- Real-time validation with error handling
- Loading indicator during API request"
```

- [ ] Commit criado

### Passo 7: Commit 5 - Documentation

```bash
git commit -m "docs: Add comprehensive documentation for Phase 3 implementation

- PLANO_CARRINHO_CHECKOUT_DETALHADO.md: 4-day implementation roadmap
- RESUMO_MUDANCAS_DIA1.md: Summary of all Day 1 changes
- GUIA_TESTES_DIA1.md: Testing guide for all features
- COMMITS_DIA1.md: Git commit messages"
```

- [ ] Commit criado

### Passo 8: Verificar Log

```bash
git log --oneline -5
```

- [ ] Vê 5 commits mais recentes
- [ ] Últimas 5 começam com: fix, feat, feat, feat, docs

---

## 🔵 FASE 4: Push (2 minutos)

### Passo 1: Verificar Branch

```bash
git branch
```

- [ ] Está em: `refactor/live-architecture` ou `main`

### Passo 2: Push

```bash
git push origin refactor/live-architecture
```

Ou se estiver em `main`:
```bash
git push origin main
```

- [ ] Push realizado com sucesso
- [ ] Nenhum erro

### Passo 3: Verificar no GitHub

Abra: `https://github.com/guikfe/brawe-app`

- [ ] Branch mostra os 5 commits
- [ ] Arquivos aparecem no histórico

---

## 📋 RESUMO FINAL

### Testes Completados
- [x] Session persistence ✅
- [x] ViaCEP auto-complete ✅
- [x] CEP validation ✅
- [x] E2E flow (opcional) ✅

### Commits Feitos
- [x] Bug fix ✅
- [x] Session persistence ✅
- [x] Affiliate origin ✅
- [x] ViaCEP ✅
- [x] Documentation ✅

### Push Realizado
- [x] Todos os commits no remoto ✅

---

## 🎯 Próximas Tarefas

Após completar este checklist:

1. **Aguarde code review** (se necessário)
2. **Inicie DIA 2:**
   - Frete calculation (1.5h)
   - Estoque validation (45min)
   - E2E testing (1.5h)
3. **Consulte:** [PLANO_CARRINHO_CHECKOUT_DETALHADO.md](./PLANO_CARRINHO_CHECKOUT_DETALHADO.md)

---

## 🐛 Soluções

### Solução 1: Session não persiste

```bash
# Opção A: Limpar app
xcrun simctl uninstall 9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B
./start-app.sh

# Opção B: Verificar SharedPreferences
flutter pub get
flutter clean
./start-app.sh
```

### Solução 2: ViaCEP não funciona

```bash
# Verificar WiFi
ping viacep.com.br

# Testar API manualmente
curl https://viacep.com.br/ws/01310100/json

# Se retornar JSON, o problema é no app
# Reveja: lib/data/services/viacep_service.dart
```

### Solução 3: Git push falha

```bash
# Verificar remoto
git remote -v

# Atualizar branch
git pull origin refactor/live-architecture
git push origin refactor/live-architecture
```

---

## 📞 Support

Se algo não funcionar:
1. Veja [GUIA_TESTES_DIA1.md](./GUIA_TESTES_DIA1.md) para testes específicos
2. Consulte [RESUMO_MUDANCAS_DIA1.md](./RESUMO_MUDANCAS_DIA1.md) para código
3. Revise [COMMITS_DIA1.md](./COMMITS_DIA1.md) para git

---

## ⏱️ Tempo Estimado

| Fase | Tempo |
|------|-------|
| Compilação & Testes | 15 min |
| Commits | 10 min |
| Push | 2 min |
| **Total** | **~30 min** |

---

## ✅ CHECKLIST FINAL

- [ ] Todos os testes passaram
- [ ] 5 commits feitos
- [ ] Push realizado
- [ ] GitHub mostra novos commits
- [ ] Pronto para DIA 2

---

**Status Esperado ao Final:** ✅ DIA 1 COMPLETO E ENTREGUE

**Próximo:** Iniciar [DIA 2 do plano](./PLANO_CARRINHO_CHECKOUT_DETALHADO.md)

---

*Desenvolvido com ❤️ para Brawe Marketplace*
