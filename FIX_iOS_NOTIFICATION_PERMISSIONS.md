# 🔧 FIX: iOS Notification Permissions Não Aparecem

## Diagnóstico Rápido

Se o app **não aparece em Settings → Notifications**, significa:

```
❌ requestPermission() NÃO foi executado
ou
❌ requestPermission() falhou silenciosamente
ou
❌ Firebase não foi inicializado
```

---

## ✅ PASSO 1: Verificar se Firebase está inicializando

### Adicionar logs para debugar:

No arquivo: `lib/main.dart` ou onde Firebase é inicializado

**Procure por:**
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Adicione logs ANTES disso:**

```dart
debugPrint('🔥 FIREBASE INIT: Starting...');

try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('🔥 FIREBASE INIT: Success! Apps: ${Firebase.apps.length}');
} catch (e) {
  debugPrint('🔥 FIREBASE INIT: ERROR - $e');
  rethrow;
}
```

### Rodar e verificar:

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
flutter run -v 2>&1 | grep -i 'firebase\|notification'
```

**Procure por:**
- ✅ `FIREBASE INIT: Success` → Firebase OK
- ❌ `FIREBASE INIT: ERROR` → Problema com Firebase config

---

## ✅ PASSO 2: Verificar se PushNotificationService está sendo chamado

No arquivo: `lib/data/services/push_notification_service.dart`

**Modifique a função `init()`:**

```dart
Future<void> init() async {
  debugPrint('🔔 PushNotificationService.init() called');
  
  if (_initialized) {
    debugPrint('🔔 Already initialized, skipping');
    return;
  }
  
  debugPrint('🔔 Firebase.apps.length: ${Firebase.apps.length}');
  
  if (Firebase.apps.isEmpty) {
    debugPrint('🔔 ❌ Firebase NOT configured, skipping push setup');
    return;
  }
  
  try {
    debugPrint('🔔 Requesting permission...');
    
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    debugPrint('🔔 Permission granted: ${settings.authorizationStatus}');
    debugPrint('🔔 Authorization status: ${settings.authorizationStatus.index}');
    // 0 = notDetermined
    // 1 = denied
    // 2 = authorized
    // 3 = provisional
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🔔 ✅ AUTHORIZED - should appear in Settings');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('🔔 ❌ DENIED - user rejected');
    } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      debugPrint('🔔 ❓ NOT DETERMINED - permission dialog never shown');
    } else {
      debugPrint('🔔 ℹ️  PROVISIONAL - temporary permission');
    }
    
    // ... rest of init
    
    _initialized = true;
    debugPrint('🔔 Init completed successfully');
    
  } catch (e, st) {
    debugPrint('🔔 ❌ Init failed: $e\n$st');
  }
}
```

### Rodar e verificar logs:

```bash
flutter run -v 2>&1 | grep '🔔'
```

**Procure por:**
```
🔔 PushNotificationService.init() called
🔔 Firebase.apps.length: 1
🔔 Requesting permission...
🔔 Permission granted: AuthorizationStatus.authorized
🔔 ✅ AUTHORIZED - should appear in Settings
```

---

## ✅ PASSO 3: Onde é chamado `PushNotificationService.init()`?

**Procure no código:**

```bash
grep -r "PushNotificationService" /Users/josecarlosmartins/Documents/developer/brawe-app/lib --include="*.dart" | grep -i "init\|\.init("
```

**Esperado encontrar em:**
- `main.dart`
- `app.dart`
- Ou em algum inicializador

**Se não encontrar → ESSE É O PROBLEMA!**

Solução: Chamar `init()` no `main()` ou no startup do app.

---

## ✅ PASSO 4: Verificar se está sendo chamado APÓS Firebase init

**Ordem CORRETA:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. PRIMEIRO: Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. DEPOIS: Inicializar Push Service
  final dio = Dio(...);
  final navigationService = NotificationNavigationService(...);
  final ref = ProviderContainer().ref;
  
  final pushService = PushNotificationService(dio, navigationService, ref);
  await pushService.init();  // ← IMPORTANTE: chamar init()
  
  // 3. DEPOIS: Rodar app
  runApp(const MyApp());
}
```

**Se não estiver nessa ordem → ESSE É O PROBLEMA!**

---

## 🔍 CHECKLIST DE DIAGNOSTICO

Abra **Xcode** e check:

### 1. Info.plist

```bash
open /Users/josecarlosmartins/Documents/developer/brawe-app/ios/Runner/Info.plist
```

**Verificar se existe:**

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

❌ Se não tem → ADICIONE

### 2. Entitlements (Debug)

```bash
cat /Users/josecarlosmartins/Documents/developer/brawe-app/ios/Runner/RunnerDebug.entitlements
```

**Deve ter:**

```xml
<key>aps-environment</key>
<string>development</string>
```

❌ Se não tem → ADICIONE

### 3. Entitlements (Release)

```bash
cat /Users/josecarlosmartins/Documents/developer/brawe-app/ios/Runner/Runner.entitlements
```

**Deve ter:**

```xml
<key>aps-environment</key>
<string>production</string>
```

❌ Se não tem → ADICIONE

---

## 🚀 SOLUÇÃO RÁPIDA (Tudo de uma vez)

Se nenhum dos passos acima funcionou:

### 1. Limpar build

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app

flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
```

### 2. Desinstalar app do iPhone

```
Segure ícone do Brawe no iPhone
→ Selecione "Remove App"
→ Confirme "Delete App"
```

### 3. Limpar caches do iPhone

```
Settings 
→ General 
→ iPhone Storage 
→ Procure "Brawe"
→ Delete App (se ainda aparecer)
```

### 4. Restart iPhone

```
Pressione e segure Power + Volume Down
Deslize para desligar
Aguarde 10 segundos
Pressione Power para ligar
```

### 5. Rebuild app

```bash
flutter run -v --no-fast-start
```

Quando pedir permissão → **CLIQUE [Allow]**

### 6. Verificar em Settings

```
Abra iPhone Settings
→ Notifications
→ Procure "Brawe" ou "Brawe App"
```

---

## ❓ Se AINDA não aparecer

### Opção A: Verificar logs do device

```bash
# Conecte iPhone no Mac
# Abra Xcode → Window → Devices
# Clique no iPhone
# Clique "View Device Logs"

# Procure por:
# - "Brawe"
# - "notification"
# - "permission"
# - "error"
```

### Opção B: Verificar GoogleService-Info.plist

```bash
# Verificar se arquivo existe
ls -la /Users/josecarlosmartins/Documents/developer/brawe-app/ios/Runner/GoogleService-Info.plist
```

**Se não existe:**
1. Abra Firebase Console
2. Vá em Project Settings
3. Download novo GoogleService-Info.plist
4. Arraste para Xcode (Runner folder)
5. Rebuild

### Opção C: Verificar bundle ID

```bash
# No Xcode, verificar:
# Runner → General → Bundle Identifier

# Deve ser: app.brawe.connect (ou seu bundle ID)
# Deve ser IGUAL em:
# - Xcode
# - Firebase Console
# - APNs Configuration
```

---

## ✨ Logs Esperados (Debug)

Quando funciona, você deve ver:

```
🔔 PushNotificationService.init() called
🔔 Firebase.apps.length: 1
🔔 Requesting permission...
[iOS popup appears asking "Brawe gostaria de enviar notificações?"]
[User taps "Allow"]
🔔 Permission granted: AuthorizationStatus.authorized
🔔 ✅ AUTHORIZED - should appear in Settings
```

---

## 📞 Se nada funcionar

Colete essas informações:

1. **Logs do Flutter:**
   ```bash
   flutter run -v 2>&1 | grep -i 'notification\|firebase\|permission\|error' > logs.txt
   ```

2. **Xcode logs do device:**
   - Abra Xcode
   - Window → Devices → seu iPhone
   - View Device Logs → salve

3. **Screenshot de Settings:**
   - Settings → Notifications → Print screen

4. **Verificar firebase-service-account.json:**
   ```bash
   ls -la /Users/josecarlosmartins/Documents/developer/brawe-app/ios/Runner/
   ```

5. **Compartilhe com eng dev:**
   - Logs
   - Screenshots
   - Info.plist
   - Entitlements
   - GoogleService-Info.plist existe?

---

## 🎯 RESUMO

```
App não aparece em Notificações:

❌ Firebase não inicializou
  → Adicionar logs e verificar

❌ requestPermission() não foi chamado
  → Adicionar chamada em main.dart

❌ requestPermission() falhou silenciosamente
  → Verificar logs e authorization status

❌ Info.plist não tem remote-notification
  → Adicionar à Info.plist

❌ Entitlements não tem aps-environment
  → Adicionar aos entitlements

❌ GoogleService-Info.plist inválido
  → Download novo do Firebase

✅ Se tudo acima OK:
  → Clean build
  → Desinstalar app
  → Rebuild
  → Clique [Allow] quando pedir
```

---

**Use este documento para debugar. Se após todos os passos não funcionar, contacte eng dev com logs detalhados.**
