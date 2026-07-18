# 📱 BRAWE NO iOS - CONFIGURAÇÃO DE NOTIFICAÇÕES

Guia completo sobre como as notificações são solicitadas e configuradas no iPhone.

---

## ✅ O APP DEVE APARECER EM CONFIGURAÇÕES

**SIM, o Brawe deve aparecer em:**
```
Settings → Notifications → Brawe App
```

Se não aparecer, significa que as permissões nunca foram solicitadas ao user.

---

## 🔄 FLUXO DE PERMISSÃO

### 1️⃣ Primeira vez que abre o app

```
┌─────────────────────────────────────────────────────┐
│  "Brawe" gostaria de enviar notificações?            │
├─────────────────────────────────────────────────────┤
│  [ Don't Allow ]        [ Allow ]                    │
└─────────────────────────────────────────────────────┘
```

**Código que mostra isso:**

```dart
// lib/data/services/push_notification_service.dart
await FirebaseMessaging.instance.requestPermission(
  alert: true,    // Mostrar alerta na tela
  badge: true,    // Badge no ícone do app (número)
  sound: true,    // Som ao receber
);
```

### 2️⃣ Se clicou "Allow" (correto ✅)

```
✅ Permissão concedida
✅ App aparece em Settings → Notifications
✅ Token é obtido
✅ Token é enviado ao backend (/devices/register)
✅ Notificações podem chegar
```

### 3️⃣ Se clicou "Don't Allow" (problema ❌)

```
❌ Permissão negada
❌ Token NÃO é obtido
❌ Token NÃO é enviado ao backend
❌ Notificações NÃO chegam
```

**Solução:** Ir em Settings e reconhecer permissão manualmente.

---

## 🔧 COMO VERIFICAR CONFIGURAÇÕES

### Em Settings no iPhone

**Caminho:**
```
Settings 
  → Notifications 
    → Brawe App (ou Brawe Connect para production)
```

**Você deveria ver:**

```
✅ Allow Notifications         [TOGGLE]
✅ Sounds                       [TOGGLE]
✅ Badges                       [TOGGLE]
✅ Show previews                Always
✅ Show on lock screen          [TOGGLE]
✅ Show as banners              [TOGGLE]
✅ Critical Alerts              [TOGGLE]
```

---

## ❓ BRAWE NÃO APARECE? Possibilidades:

### Opção 1: Nunca foi solicitada permissão

**Sintomas:**
- App não pede "Allow Notifications" ao abrir
- Brawe não aparece em Settings → Notifications

**Causa:** `requestPermission()` nunca foi executado ou falhou silenciosamente

**Solução:**
```dart
// Forçar solicitação novamente (só aparece uma vez)
// Nas Settings do iPhone, vá em Brawe e reconheça
```

### Opção 2: Permissão foi negada

**Sintomas:**
- Brawe APARECE em Settings → Notifications
- Mas "Allow Notifications" está **OFF**

**Causa:** User clicou "Don't Allow" quando perguntado

**Solução:** 
1. Abra Settings → Notifications → Brawe App
2. Liga "Allow Notifications" para ON
3. Volte ao app

### Opção 3: Build em development vs production

**Se está testando com Debug build:**
- Bundle ID: `app.brawe.connect.debug` (ou similar)
- Settings → Notifications → procure por esse nome

**Se está testando com Release build:**
- Bundle ID: `app.brawe.connect`
- Settings → Notifications → procure por esse nome

---

## 📝 O QUE ESTÁ IMPLEMENTADO

### ✅ Já existe:

```dart
// 1. Solicita permissão
await FirebaseMessaging.instance.requestPermission(
  alert: true,    // Notificação visual
  badge: true,    // Badge no ícone
  sound: true,    // Som
);

// 2. Configura apresentação em foreground
await FirebaseMessaging.instance
    .setForegroundNotificationPresentationOptions(
      alert: true,    // Mostrar alerta mesmo com app aberto
      badge: true,    // Atualizar badge
      sound: true,    // Tocar som
    );

// 3. Obtém token
final token = await FirebaseMessaging.instance.getToken();

// 4. Envia ao backend
await _dio.post(
  '/devices/register',
  data: {'token': token, 'platform': 'ios'},
);

// 5. Handlers de notificação
FirebaseMessaging.onMessage.listen(...)           // App aberto
FirebaseMessaging.onMessageOpenedApp.listen(...)  // App em background
FirebaseMessaging.instance.getInitialMessage()... // App terminado
```

### ✅ Info.plist (correto)

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>  ← Permite receber push em background
</array>
```

### ✅ Entitlements (correto)

**Debug:**
```xml
<key>aps-environment</key>
<string>development</string>
```

**Release:**
```xml
<key>aps-environment</key>
<string>production</string>
```

---

## 🎯 TESTE COMPLETO

### Passo 1: Reinstale o app (para limpar estado)

```bash
# No device iOS:
1. Abra App Store → Brawe
2. Desinstale (se já tiver)
3. Reinstale
4. Abra o app
```

### Passo 2: Conceda permissão

```
App abrirá e perguntará:
"Brawe gostaria de enviar notificações?"
→ Clique [Allow]
```

### Passo 3: Faça login

```
1. Abra app
2. Faça login
3. Aguarde 10 segundos (deixe app aberto)
4. Token será registrado
```

### Passo 4: Verifique em Settings

```
1. Abra Settings do iPhone
2. Vá em Notifications
3. Procure por "Brawe" ou "Brawe App"
4. Verifique se está com "Allow Notifications" ligado
```

### Passo 5: Teste notificação

```
1. Com app iOS aberto → envie mensagem via web
   → Deve aparecer banner/alerta no topo
   
2. Com app iOS em background → envie mensagem
   → Deve aparecer no lock screen
   
3. Com app iOS terminado → envie mensagem
   → Deve chegar via APNs (som/vibração)
```

---

## 🔴 SE AINDA NÃO FUNCIONAR

### Checklist de diagnóstico:

- [ ] App aparece em Settings → Notifications?
  - ❌ Se não → `requestPermission()` não foi executado
  - ✅ Se sim → prossiga

- [ ] "Allow Notifications" está ligado?
  - ❌ Se não → Clique para ligar
  - ✅ Se sim → prossiga

- [ ] Token foi registrado no backend?
  - Verificar: `ssh root@146.190.231.156 'psql -U brawe -d brawe_db -c "SELECT COUNT(*) FROM connect_user_devices WHERE platform='"'"'ios'"'"';"'`
  - ❌ Se 0 → token não foi registrado (erro no registerWithBackend)
  - ✅ Se > 0 → prossiga

- [ ] APNs key foi configurada no Firebase?
  - Verificar: Firebase Console → Cloud Messaging → APNs Authentication Key
  - ❌ Se vazio → upload `.p8` file
  - ✅ Se presente → prossiga

- [ ] Notificação foi criada no BD?
  - Verificar: `psql -U brawe -d brawe_db -c "SELECT * FROM connect_notifications ORDER BY created_at DESC LIMIT 1;"`
  - ❌ Se não aparece → problema no backend (não criou notificação)
  - ✅ Se aparece → prossiga

- [ ] Backend tentou enviar push?
  - Verificar: `ssh root@146.190.231.156 'tail -20 /var/log/brawe-connect/push.log'`
  - ❌ Se vazio/erro → backend pode não estar rodando
  - ✅ Se OK → verificar Firebase console

---

## 💡 DICAS

### Token null?

Se `getToken()` retorna `null`:
- Verificar: Brawe tem permissão em Settings → Notifications?
- Verificar: Info.plist tem `remote-notification` em `UIBackgroundModes`?
- Verificar: Entitlements tem `aps-environment` correto?

### Notificação chegou no BD mas não chega no device?

- APNs key pode estar inválida no Firebase
- Device pode estar offline
- Certificado APNs pode estar expirado

### Apenas Android recebe, iOS não?

- Confirmar: Token iOS está no BD
- Confirmar: APNs production key está em Firebase
- Confirmar: Bundle ID no entitlements é igual ao em Firebase

---

## 📋 RESUMO

| Situação | O que fazer |
|----------|------------|
| App não pede permissão | Reinstale app (requestPermission só aparece 1x) |
| Brawe não em Settings | Permissão nunca foi solicitada |
| Brawe em Settings mas OFF | Clique para ligar "Allow Notifications" |
| Permissão OK mas sem tokens | Verificar registerWithBackend() código |
| Tokens OK mas sem notificação | Verificar APNs key no Firebase |
| Notificação no BD mas não chega | Verificar Firebase logs |

---

**Última atualização:** 2026-07-16  
**Versão:** 1.0
