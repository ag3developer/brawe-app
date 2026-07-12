# 🧪 Guia de Testes - DIA 1

**Objetivo:** Validar as 3 tarefas implementadas  
**Tempo:** ~15 minutos  
**Pré-requisito:** App compilado e rodando no simulador

---

## ✅ TESTE 1: Session Persistence

### Cenário: Carrinho Persiste Após Restart

**Passos:**

1. **Adicionar item ao carrinho**
   - Navegar para vitrine de produtos
   - Clicar em um produto (ex: em mabuk-cosmetics)
   - Clicar "Adicionar ao carrinho"
   - Verificar que o badge do carrinho mostra "1"

2. **Fechar completamente o app**
   - Pressionar `q` no terminal Flutter (sai do hot reload)
   - Esperar 2 segundos
   - Obs: Hot reload não testa persistência!

3. **Reabrir o app**
   ```bash
   ./start-app.sh
   ```
   - Aguardar compilação (45-60s)

4. **Verificar carrinho**
   - Navegar para `/shop/cart`
   - ✅ **ESPERADO:** Item deve estar lá! (não vazio)
   - ❌ **PROBLEMA:** Se carrinho vazio → implementação falhou

### Debug (se falhar)

```bash
# Verificar se session ID foi salvo:
flutter attach # conectar debugger
# No console: 
# flutter: CartSession ID = anon_abc123... (deve ser sempre o mesmo ao reabrir)
```

### Log Esperado

```
flutter: Initialize cart session persistence
flutter: CartSessionManager created
flutter: CartSession initialized with ID: anon_a1b2c3d4e5f6g7h8
flutter: loadCart() called with session: anon_a1b2c3d4e5f6g7h8
```

---

## ✅ TESTE 2: Affiliate Origin Capture

### Cenário A: Capturar via URL Parameter

**Passos:**

1. **Iniciar app com URL parameter**
   ```bash
   # Simular deep link com affiliate code:
   # (nota: requer GoRouter estar configurado para receber)
   ```

2. **Abrir link com affiliate_code**
   - Simular: `app://shop/product/123?affiliate_code=partner-001`
   - Ou via browser: `https://brawe.io/shop/product/123?ref=affiliate-123`

3. **Adicionar ao carrinho**
   - Clicar "Adicionar ao carrinho"
   - Ir para checkout
   
4. **Verificar affiliate ID**
   - Abrir console Flutter
   - Buscar log: `Affiliate ID captured: partner-001` ✅

### Cenário B: Persistência entre Sessions

**Passos:**

1. **Fazer compra com affiliate**
   - Seguir Cenário A
   - Completar checkout

2. **Fechar app e reabrir**
   ```bash
   q  # sair
   ./start-app.sh  # reabrir
   ```

3. **Verificar localStorage**
   - Abrir checkout novamente
   - Affiliate ID deve ser reutilizado ✅

### Debug (se falhar)

```dart
// No checkout, adicionar debug:
final affiliateId = ref.watch(affiliateIdForCartProvider);
affiliateId.whenData((id) {
  debugPrint('🔗 Affiliate ID: $id');
});
```

---

## ✅ TESTE 3: ViaCEP Auto-Complete

### Cenário: CEP 01310-100 (Avenida Paulista)

**Passos:**

1. **Navegar para checkout**
   - Cart → "Ir para Checkout"
   - Ou `/shop/checkout`

2. **Preencher campo CEP**
   - Clique no campo de CEP
   - Digitar: `01310100` (SEM hífen)
   - **Esperado:** Loading spinner aparece

3. **Verificar auto-complete (1-2 segundos)**
   - ✅ **Rua:** "Avenida Paulista"
   - ✅ **Bairro:** "Bela Vista"
   - ✅ **Cidade:** "São Paulo"
   - ✅ **Estado:** "SP"
   - ✅ **Snackbar:** "✓ Endereço auto-completado"

4. **Tentar CEP com hífen**
   - Limpar campo
   - Digitar: `01310-100` (COM hífen)
   - **Esperado:** Mesma funcionalidade (deve remover hífen)

### Cenário: CEP Inválido

**Passos:**

1. **Digitar CEP inválido**
   - Digitar: `12345` (menos de 8 dígitos)
   - **Esperado:** Nenhuma ação (spinner não aparece)

2. **Digitar CEP que não existe**
   - Digitar: `00000000`
   - **Esperado:** 
     - Loading spinner aparece
     - Desaparece em 1-2s
     - Mensagem de erro: "CEP 00000000 não encontrado"

3. **Digitar CEP genérico** (sem logradouro específico)
   - Digitar: `01000000` (Praça da Sé, genérico)
   - **Esperado:** Erro "CEP não possui endereço específico"

### Validação Final

- ✅ Campo obrigatório: tentar submit sem CEP → erro
- ✅ Formatação: CEP `01310-100` é aceito como `01310100`
- ✅ Sem spinner antes de 8 dígitos
- ✅ Spinner desaparece após busca (sucesso ou erro)

### Debug (se falhar)

```dart
// Logs esperados:
flutter: ✓ ViaCEP request to https://viacep.com.br/ws/01310100/json
flutter: ✓ Address auto-completed: Avenida Paulista, Bela Vista, São Paulo, SP
```

---

## 🔄 Teste E2E Completo (Opcional)

**Cenário:** Fluxo completo vitrine → carrinho → checkout

**Passos:**

1. Navegar para vitrine
2. Clicar em uma loja (ex: mabuk-cosmetics)
3. Clicar em um produto
4. Clicar "Adicionar ao carrinho"
5. Ir para carrinho
6. Clicar "Ir para Checkout"
7. Preencher:
   - ✅ CEP: `01310100` (auto-completa)
   - ✅ Número: `1000`
   - ✅ Nome: seu nome
   - ✅ Email: seu@email.com
   - ✅ Telefone: seu telefone
   - ✅ Método de envio: Padrão
   - ✅ Método de pagamento: PIX
8. Clicar "Confirmar"
9. ✅ Deve navegar para `/shop/checkout/payment/:orderId`

---

## 📋 Checklist de Testes

- [ ] **Session Persistence:** Carrinho persiste após restart
- [ ] **Affiliate Origin:** Affiliate code capturado de URL
- [ ] **ViaCEP Valid:** CEP `01310100` auto-completa corretamente
- [ ] **ViaCEP Invalid:** CEP inválido mostra erro
- [ ] **ViaCEP Format:** CEP com hífen é aceito
- [ ] **E2E Flow:** Vitrine → Carrinho → Checkout → Pagamento

---

## 🐛 Bugs Conhecidos (Esperados)

1. **Firebase não configurado** → OK, apenas aviso
2. **Payment page é mock** → OK, próxima fase
3. **Endereços salvos vazios** → OK, só adicionar novo
4. **Sem shipping real** → OK, visual apenas

---

## 📞 Se Algo Não Funcionar

1. **Erro de compilação?**
   ```bash
   flutter clean
   flutter pub get
   ./start-app.sh
   ```

2. **Session não persiste?**
   - Verificar se `shared_preferences` está em pubspec.yaml ✅
   - Remover app do simulador: `xcrun simctl uninstall 9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B`
   - Reinstalar

3. **ViaCEP não responde?**
   - Verificar WiFi do Mac
   - Testar manualmente: `curl https://viacep.com.br/ws/01310100/json`

4. **Hot reload está lento?**
   - Fazer hot **restart** (R) ao invés de reload (r)

---

## 🎯 Próxima Fase (após testes passarem)

- ✅ Commit com mensagem: "feat: Cart session persistence + ViaCEP integration"
- → Prosseguir para **Tarefa 2.1** (Frete + Estoque)

---

**Tempo Total de Testes:** ~15 minutos ⏱️  
**Esperado:** Todos os testes passarem ✅
