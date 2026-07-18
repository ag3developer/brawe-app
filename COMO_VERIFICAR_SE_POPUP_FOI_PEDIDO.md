# 🔍 COMO VERIFICAR SE POPUP FOI PEDIDO

> Não tem certeza se iOS pediu permissão? Use este guia para verificar nos logs.

---

## 🎯 Solução Rápida

**Execute:**

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
bash RUN_WITH_LOGS.sh
```

Ou manualmente:

```bash
flutter clean
flutter run -v --no-fast-start
```

---

## 📋 O que procurar nos logs

Após executar `flutter run`, procure por estas linhas:

### ✅ SE VOCÊ VER:

```
🔔 PushNotificationService: Requesting notification permission...
🔔 Permission status: granted
🔔 Alert: true
🔔 Badge: true
🔔 Sound: true
✅ PushNotificationService: User GRANTED notification permission!
```

**Significado:** ✅ iOS PEDIU e você CLICOU [Allow]

---

### ❌ SE VOCÊ VER:

```
🔔 PushNotificationService: Requesting notification permission...
🔔 Permission status: denied
🔔 Alert: false
🔔 Badge: false
🔔 Sound: false
⚠️ PushNotificationService: User DENIED notification permission!
```

**Significado:** ❌ iOS PEDIU e você CLICOU [Don't Allow]

**O que fazer:** Desinstale app e reinstale, clicando [Allow] desta vez

---

### ⚠️ SE VOCÊ VER:

```
🔔 PushNotificationService: Requesting notification permission...
🔔 Permission status: notDetermined
⚠️ PushNotificationService: Permission not determined (first time)
```

**Significado:** ⚠️ iOS NUNCA PEDIU ou você está na primeira vez

**O que fazer:** Pode ser que:
- App tenha crasheado antes de pedir
- iOS não pediu (raro)
- Você parou a instalação antes de terminar

Tente reinstalar

---

## 🚀 PASSO A PASSO COMPLETO

### Passo 1: Desinstalar app

```bash
# No iPhone:
Segure ícone → Remove App → Delete App
```

### Passo 2: Executar com logs

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
flutter clean
flutter run -v --no-fast-start
```

### Passo 3: Aguardar app abrir

Deixe app compilar e abrir no iPhone. Você vai ver muitos logs no terminal.

### Passo 4: Procurar por palavras-chave

Terminal vai exibir logs. **Procure por:**

```
🔔  = informação sobre permissão
✅  = sucesso
❌  = erro
⚠️  = aviso
```

### Passo 5: Procurar a linha de status

Procure pela linha:

```
🔔 Permission status: XXX
```

Onde XXX pode ser:

| Status | Significado |
|--------|------------|
| `granted` | ✅ iOS pediu e você clicou [Allow] |
| `denied` | ❌ iOS pediu e você clicou [Don't Allow] |
| `notDetermined` | ⚠️ Ainda não foi pedido |
| `provisional` | ℹ️ iOS 12 - pode receber notificações silenciosas |

---

## 📱 O que deve acontecer no iPhone

### Se é primeira vez:

1. App abre
2. iOS mostra popup no topo:
   ```
   "Brawe" gostaria de enviar notificações?
   [Don't Allow]   [Allow]
   ```
3. Você clica [Allow]
4. App continua

### Se já foi pedido antes:

Não vai mostrar popup novamente (iOS só pergunta uma vez)

---

## 🔎 DEBUGAR NO XCODE (Avançado)

Se quiser ver logs ainda mais detalhados:

```bash
# 1. Abrir Xcode
open ios/Runner.xcworkspace

# 2. Selecionar seu iPhone na parte superior
# 3. Menu: Product → Scheme → Edit Scheme
# 4. Run → Pre-actions
# 5. Rodar app
# 6. View → Debug Area → Show Console
```

Vai aparecer console com todos os logs do app.

---

## ✅ Verificação Manual no iPhone

Depois de rodar app, vá para:

```
iPhone Settings
  → Notifications
    → Procure "Brawe"
```

**Se app aparece:**
- ✅ Permissão foi CONCEDIDA
- ✅ "Allow Notifications" deve estar ON

**Se app NÃO aparece:**
- ❌ Permissão foi NEGADA
- ❌ Desinstale e reinstale

---

## 🎯 Resumo

| Você vê no log | No iPhone Settings | Ação |
|---|---|---|
| `✅ User GRANTED` | App aparece com ON | ✅ Pronto! |
| `❌ User DENIED` | App não aparece | ❌ Desinstale e reinstale |
| `⚠️ Not determined` | App não aparece | ⚠️ Tente novamente |

---

## 📚 Logs Completos (Exemplo Real)

Aqui está um exemplo do que você deve ver:

```
flutter: 🔔 PushNotificationService: Requesting notification permission...
flutter: 🔔 Permission status: granted
flutter: 🔔 Alert: true
flutter: 🔔 Badge: true
flutter: 🔔 Sound: true
flutter: ✅ PushNotificationService: User GRANTED notification permission!
flutter: 🔔 registerWithBackend: Getting FCM token...
flutter: 🔔 registerWithBackend: Got token: AIzaSyDx3...
flutter: 🔔 registerWithBackend: Registering on backend (platform: ios)
flutter: ✅ registerWithBackend: Successfully registered!
```

Se você ver algo assim = **SUCESSO! Tudo funcionando!**

---

## 🆘 Problema: Logs não aparecem

Se logs não aparecem com 🔔 ou ✅:

```bash
# Tente rodar sem filtro
flutter run -v --no-fast-start 2>&1 | tee flutter_run.log

# Depois procure no arquivo
grep -i "permission\|granted\|denied\|notdetermined" flutter_run.log
```

---

**Resumo:** Execute `flutter run -v`, procure por `🔔 Permission status:` e veja se é `granted`, `denied` ou `notDetermined`.
