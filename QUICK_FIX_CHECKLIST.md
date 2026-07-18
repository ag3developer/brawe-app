# ✅ QUICK FIX CHECKLIST

> **TL;DR:** App não aparece em Notificações? Você não clicou [Allow] quando perguntou.

---

## 🚀 3 PASSOS PARA RESOLVER

### ✅ PASSO 1: Desinstalar App

```
iPhone:
  1. Segure ícone do Brawe
  2. "Remove App"
  3. "Delete App"
  4. Confirme
  
Resultado: App desaparece do iPhone
```

---

### ✅ PASSO 2: Reinstalar App

```bash
# No Mac Terminal:
cd /Users/josecarlosmartins/Documents/developer/brawe-app
flutter clean
flutter run
```

**Aguarde:** App instala no iPhone

---

### ✅ PASSO 3: Autorizar Notificações

```
iPhone mostra:

┌─────────────────────────────────────┐
│ "Brawe" gostaria de enviar          │
│ notificações?                       │
├─────────────────────────────────────┤
│ [Don't Allow]   [Allow]             │
└─────────────────────────────────────┘

🚨 CLIQUE [Allow] (não clique Don't Allow!)
```

---

## ✨ PRONTO! Agora verificar:

```
iPhone Settings
  → Notifications
    → Brawe App (deve estar aqui)
      → "Allow Notifications" (deve estar ON)
```

---

## 📋 Se você não vê o popup:

1. **Primeira vez nunca apareceu?**
   - iOS só mostra uma vez
   - Solução: desinstale e reinstale

2. **Popup apareceu antes mas você clicou "Don't Allow"?**
   - iOS nunca vai perguntar novamente
   - Solução: desinstale e reinstale

3. **Recusa no Settings também?**
   - Settings > Privacy > Notifications
   - Procure "Brawe"
   - Talvez tenha sido negado lá também

---

## 🎯 O que acontece em cada caso:

| Botão | Resultado |
|-------|-----------|
| ❌ [Don't Allow] | App NÃO aparece em Settings |
| ✅ [Allow] | App APARECE em Settings |

---

## 🔄 Ordem Correta:

```
1. Desinstalar ✓
2. Reinstalar ✓
3. Esperar popup ✓
4. Clique [Allow] ✓
5. Verificar Settings ✓
```

---

## ✓ Verificação Final

- [ ] Desinstalei app
- [ ] Rodei `flutter clean && flutter run`
- [ ] Popup "Permitir notificações?" apareceu
- [ ] Cliquei [Allow]
- [ ] App Brawe aparece em Settings → Notifications
- [ ] "Allow Notifications" está ON

Se tudo ✓ → **Pronto! Funcionando!**

---

## 🆘 Ainda não funciona?

Leia o arquivo completo:
→ `SOLUCAO_APP_NAO_APARECE_NOTIFICACOES.md`

---

**Resumo:** iOS só deixa app aparecer em Notificações se você autorizar. Se não aparece = nunca autorizou.

**Solução:** Desinstale, reinstale, clique [Allow].

**Tempo:** 1 minuto.
