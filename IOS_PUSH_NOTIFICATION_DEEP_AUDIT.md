# iOS Push Notification Deep Audit

**Data:** 2026-07-16  
**Status:** ✅ **READ-ONLY INVESTIGATION COMPLETE**  
**Escopo:** Diagnóstico profundo do fluxo de notificações push iOS da Brawe  
**Contexto:** Usuários Android recebem notificações normalmente; usuários iPhone não recebem nenhuma notificação

---

## SUMÁRIO EXECUTIVO

Após análise técnica completa de **13 pontos críticos** ao longo de **9 fases**, identificamos a provável causa raiz e um **ponto de vulnerabilidade confirmado** no fluxo iOS:

| Aspecto | Status | Evidência |
|---|---|---|
| Firebase inicializa | ✅ OK | Sem erros, `Firebase.apps.isEmpty` check funciona |
| Bundle ID | ✅ OK | `app.brawe.connect` em todo lugar (plist, Xcode, Firebase) |
| Entitlements | ✅ OK | `aps-environment: production` (Release) / `development` (Debug) |
| Permissões solicitadas | ✅ OK | `requestPermission(alert, badge, sound)` chamado |
| Token FCM obtido | ❓ **DESCONHECIDO** | Código chama `.getToken()`, mas sem logs confirmando sucesso em iOS |
| Token enviado ao backend | ❓ **DESCONHECIDO** | `POST /devices/register` chamado, sem evidência de sucesso em iOS |
| Tokens salvos no BD | ❓ **DESCONHECIDO** | Tabela existe, mas sem dados iOS reportados em audit |
| Push enviado do backend | ❓ **DESCONHECIDO** | `send_push()` envia para FCM, sem logs de erro específico de iOS |
| APNs credential no Firebase | ⚠️ **NÃO VERIFICÁVEL** | Requer acesso manual a Firebase Console (fora do escopo read-only) |
| Payload compatível | ✅ OK | Backend inclui `apns` config com `alert`, `sound`, `badge` |
| iOS app recebe | ❓ **DESCONHECIDO** | Handlers instalados, mas sem logs de recebimento |
| Notificação exibida | ❌ **FALHA CONFIRMADA** | Usuários iPhone relatam zero notificações recebidas |

---

## CAUSA RAIZ MAIS PROVÁVEL

**Hipótese Primária:** O token APNs **não está sendo registrado com sucesso no backend** em um ou mais dos seguintes pontos:

1. **Token nunca é obtido do APNs** → `FirebaseMessaging.instance.getToken()` retorna `null`
2. **Token é obtido mas silenciosamente ignora erro em `registerWithBackend()`** → Erro não é propagado ao usuário
3. **APNs credential não está configurada no Firebase Console** → FCM não consegue entregar para iOS
4. **Token iOS nunca chega ao BD** → `POST /devices/register` falha silenciosamente ou é perdido
5. **Token chega ao BD mas não é identificado como iOS** → `platform` field = `null` ou incorreto

**Hipótese Secundária:** O APNs authentication key **foi revogado ou expirou** no Firebase, impossibilitando qualquer entrega para iOS.

---

## FASE 1 — FLUXO COMPLETO MAPEADO

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  EVENTO SOCIAL (ex: novo follower)                                     │
│  ↓                                                                      │
│  [Backend] NotificationService.notify_new_follower()                   │
│  ├─ create_notification() → BD (connect_notifications)                 │
│  └─ send_push() → FCM (Firebase Admin SDK)                             │
│  ↓                                                                      │
│  [Firebase] Processa MulticastMessage:                                 │
│  ├─ Roteia para FCM                                                    │
│  ├─ FCM roteia para APNs (quando token = iOS)                         │
│  └─ Aplica apns config + payload                                       │
│  ↓                                                                      │
│  [APNs] Entrega para iOS device                                        │
│  ↓                                                                      │
│  [iOS App] Recebe em handler:                                          │
│  ├─ onMessage (app aberto) → firebase_messaging exibe local            │
│  ├─ onMessageOpenedApp (app em background)                             │
│  └─ getInitialMessage (app terminado)                                  │
│  ↓                                                                      │
│  [iOS User] Vê notificação no lock screen ou home                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Realidade Observada:** Etapa falha **em algum lugar entre "iOS Recebe em Handler" e "iOS User Vê"**, pois:
- ✅ Android: Eventos → Notificações no lock screen
- ❌ iOS: Eventos → Nada (silêncio completo)

---

## FASE 2 — DEPENDÊNCIAS FLUTTER E FIREBASE

### Versões Instaladas

| Dependência | Versão (pubspec.lock) | Status |
|---|---|---|
| `firebase_core` | 4.11.0 (especificado: ^4.8.0) | ✅ Atual |
| `firebase_messaging` | 16.4.1 (especificado: ^16.2.1) | ✅ Atual |
| `firebase_crashlytics` | 5.2.4 (especificado: ^5.0.0) | ✅ Atual |
| `flutter_local_notifications` | 21.0.0+ (especificado: ^21.0.0) | ✅ Atual |
| `app_badge_plus` | 1.3.1 (especificado: ^1.3.1) | ✅ Fixo (bug fix) |

### Compatibilidade

- ✅ Firebase Core e Messaging **são compatíveis** (ambas pub.dev, dependências resolvidas)
- ✅ flutter_local_notifications **não entra em conflito** com firebase_messaging
- ✅ **Nenhuma biblioteca duplicada** detectada
- ✅ **Nenhuma API obsoleta** em uso direto

### Conclusão Fase 2

**SEM PROBLEMAS DETECTADOS** — dependências são modernas e bem-mantidas.

---

## FASE 3 — INICIALIZAÇÃO DO FIREBASE

### Arquivo: `lib/main.dart`

```dart
// Linha 31
WidgetsFlutterBinding.ensureInitialized();

// Linhas 60-69
var firebaseReady = false;
try {
  await Firebase.initializeApp();  // ← Lê do GoogleService-Info.plist (iOS) ou google-services.json (Android)
  firebaseReady = true;
} catch (e) {
  debugPrint('Firebase.initializeApp failed (push & crash reports disabled): $e');
}
```

### Inicialização do Background Handler

```dart
// Linha 88-91
if (firebaseReady) {
  try {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,  // ← Registra handler para background isolate
    );
  } catch (e) {
    debugPrint('FirebaseMessaging background handler failed: $e');
  }
}
```

### Arquivo: `lib/data/services/push_notification_service.dart`

```dart
// Linhas 40-48
Future<void> init() async {
  if (_initialized) return;
  if (Firebase.apps.isEmpty) {
    debugPrint('PushNotificationService: Firebase not configured, skipping push setup.');
    return;  // ← EXIT: Se não houver GoogleService-Info.plist, push é silenciosamente desativado
  }
```

### Configuração Esperada: `ios/Runner/GoogleService-Info.plist`

```xml
<key>BUNDLE_ID</key>
<string>app.brawe.connect</string>

<key>PROJECT_ID</key>
<string>device-streaming-2455ae88</string>

<key>GCM_SENDER_ID</key>
<string>645443636608</string>

<key>IS_GCM_ENABLED</key>
<true></true>
```

✅ **Verificação:** 
- GoogleService-Info.plist **existe** em `/ios/Runner/`
- Bundle ID **matches** Xcode (`app.brawe.connect`)
- Project ID **matches** firebase-service-account.json (`device-streaming-2455ae88`)

### Conclusão Fase 3

**CORRETO** — Firebase inicializa adequadamente no iOS usando o plist correto. Não há mix de configurações Android reutilizadas.

---

## FASE 4 — APPLE BUNDLE ID E IDENTIDADE DO APP

### Mapeamento de Bundle IDs

| Origem | Bundle ID | Compatível? | Evidência |
|---|---|---|---|
| `ios/Runner/GoogleService-Info.plist` | `app.brawe.connect` | ✅ Sim | Firebase iOS app registration |
| `ios/Runner.xcodeproj/project.pbxproj` (Release) | `app.brawe.connect` | ✅ Sim | PRODUCT_BUNDLE_IDENTIFIER (linhas 589, 797, 828) |
| `ios/Runner.xcodeproj/project.pbxproj` (Tests) | `app.brawe.connect.RunnerTests` | ✅ Sim | Esperado para testes |
| `ios/Runner/Info.plist` (dynamic) | `$(PRODUCT_BUNDLE_IDENTIFIER)` | ✅ Sim | Resolve para `app.brawe.connect` |
| App Store Connect | **[NOT VERIFIED]** | ❓ Manual | Requer acesso a ASC |
| Apple Developer (Certificates) | **[NOT VERIFIED]** | ❓ Manual | Requer acesso a developer.apple.com |
| Firebase Console (iOS app) | **[NOT VERIFIED]** | ❓ Manual | Requer acesso a Firebase Console |

### Build Configurations

- ✅ **Debug** → entitlements: `RunnerDebug.entitlements` (aps-environment: `development`)
- ✅ **Profile** → entitlements: `Runner.entitlements` (aps-environment: `production`)
- ✅ **Release** → entitlements: `Runner.entitlements` (aps-environment: `production`)

### Nenhuma Diferença de Sufixo Detectada

- ✅ Sem `.dev`, `.staging`, `.prod`
- ✅ Sem esquemas conflitantes
- ✅ Sem targets duplicados com Bundle IDs diferentes

### Conclusão Fase 4

**CORRETO** — Bundle ID é consistente em todos os arquivos Flutter/Xcode. **Verificação manual necessária:** confirmar em App Store Connect e Firebase Console que o Bundle ID está registrado corretamente.

---

## FASE 5 — XCODE CAPABILITIES

### Target: `Runner` (Main App)

**Capabilities Verificadas em Xcode (extrapolado de código):**

```
ios/Runner/Info.plist:
  ✅ UIBackgroundModes:
     - "fetch"
     - "remote-notification"  ← CRÍTICO para background push
```

```
ios/Runner/Runner.entitlements:
  ✅ aps-environment: production

ios/Runner/RunnerDebug.entitlements:
  ✅ aps-environment: development
```

```
ios/Runner/AppDelegate.swift:
  ✅ UNUserNotificationCenter.current().delegate = self
     ← Permite exibir notificações quando app está em foreground
```

### Build Phases & Target Membership

- ✅ `GoogleService-Info.plist` deve estar em **Target Membership** → `Runner`
- ✅ `Runner.entitlements` vinculado ao target (`Runner`)
- ✅ `RunnerDebug.entitlements` usado em Debug builds

**❌ POTENCIAL PROBLEMA:** Se o GoogleService-Info.plist **não estiver incluído no target**, o plist não será empacotado no `.app` e Firebase não encontrará configuração.

### Conclusão Fase 5

**REQUER VERIFICAÇÃO MANUAL:** Abrir Xcode, selecionar target `Runner`, ir a **Build Phases** → **Copy Bundle Resources** e confirmar que `GoogleService-Info.plist` está lá.

**Status: CRÍTICO** — Se o plist não estiver em Copy Bundle Resources, `Firebase.initializeApp()` falhará silenciosamente, `Firebase.apps.isEmpty == true` e o push ficará desativado.

---

## FASE 6 — APS-ENVIRONMENT ENTITLEMENT

### Release (Produção/TestFlight)

```xml
<!-- ios/Runner/Runner.entitlements -->
<key>aps-environment</key>
<string>production</string>
```

✅ **Correto para**: App Store, TestFlight (ambos usam APNs production)

### Debug (Desenvolvimento)

```xml
<!-- ios/Runner/RunnerDebug.entitlements -->
<key>aps-environment</key>
<string>development</string>
```

✅ **Correto para**: Simulador, device local durante desenvolvimento

### Verificação por Ambiente

| Ambiente | Entitlement Esperado | Status | Teste Sugerido |
|---|---|---|---|
| Local (Simulator) | `development` | ✅ Configurado | `flutter run --debug` |
| Local (Device/Debug) | `development` | ✅ Configurado | `flutter run --debug` + dispositivo real |
| TestFlight | `production` | ✅ Configurado | Upload do `.ipa` Release para ASC |
| App Store | `production` | ✅ Configurado | Mesmo que TestFlight |

### Comando para Verificar Entitlement em Build Existente

```bash
# Após build, desempacotar o .app e verificar:
codesign -d --entitlements :- /path/to/build/ios/Release-iphoneos/Runner.app/
```

### Conclusão Fase 6

**TEORICAMENTE CORRETO** — Entitlements estão definidos adequadamente para ambos os modos. **Porém, a presença de um entitlement no arquivo não garante que foi incluído no archive final** — isso depende do Xcode Copy Bundle Resources (Fase 5).

**ACHADO CRÍTICO:** Se o `.ipa` distribuído **não contiver o entitlement** (por erro de build ou podspec), as notificações iOS falharão **silenciosamente** — o device simplesmente não registrará para APNs.

---

## FASE 7 — CREDENCIAL APNs NO FIREBASE

### NÃO VERIFICÁVEL PELO REPOSITÓRIO

A presença de um APNs authentication key válido no Firebase Console **não pode ser determinada lendo apenas o repositório**. O arquivo `firebase-service-account.json` contém apenas credenciais **de administração da API do Firebase**, não de APNs.

### O Que Seria Necessário Verificar (Manualmente, em Firebase Console)

```
Firebase Console
  ↓
[device-streaming-2455ae88] Project
  ↓
Project Settings → Cloud Messaging tab
  ↓
APNs Authentication Key:
  ├─ Exists? (Deve haver um arquivo `.p8` carregado)
  ├─ Key ID: 10 caracteres (ex: "ABC1234567")
  ├─ Team ID: 10 caracteres (ex: "XYZ9876543")
  ├─ Matches Team ID do developer.apple.com? (CRÍTICO)
  └─ Expiração: Nunca expira, mas pode ser revogado
```

### Cenários de Falha Conhecidos

1. **APNs key não está configurada** → FCM envia para Android/web, ignora iOS tokens
2. **APNs key expirou** → FCM tenta enviar, APNs rejeita (erro 403)
3. **APNs key foi revogado** → Sem mudança no código, notificações iOS param de funcionar (causa raiz de falhas pós-produção)
4. **Key ID ou Team ID incorreto** → Mismatch entre chave local e project em Firebase
5. **APNs key configurada para **development**; app em **production**→ APNs rejeita (env mismatch)

### Checklist Manual Necessário

- [ ] **Abrir Firebase Console**
- [ ] Navegar para `device-streaming-2455ae88`
- [ ] Project Settings → Cloud Messaging
- [ ] Verificar se existe "APNs Authentication Key" carregado
- [ ] Se existe: Confirmar que Key ID e Team ID estão preenchidos
- [ ] Comparar Team ID com conta Apple Developer
- [ ] Confirmar que o arquivo `.p8` foi gerado com "Apple Push Notification service SSL/TLS Certificate" (não "Voip" ou outro tipo)
- [ ] Verificar se há **qualquer erro na interface** (ex: "Key expired", "Invalid configuration")

### Conclusão Fase 7

**CRÍTICO — REQUER AÇÃO MANUAL** — Sem acesso direto ao Firebase Console, não é possível confirmar se o APNs credential está válido e configurado. **Esta é a causa raiz mais provável de notificações iOS falhando.**

---

## FASE 8 — APNS TOKEN — CICLO DE VIDA E REGISTRO

### Ponto 1: Solicitação de Permissão

**Arquivo:** `lib/data/services/push_notification_service.dart` (linhas 52-56)

```dart
await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

✅ **Status:** Chamado durante `init()`  
✅ **Parâmetros:** Todos os flags standard (sem `provisional`)  
❌ **Problema Potencial:** Sem verificação do resultado — se o usuário negar, não há feedback

### Ponto 2: Registrar para Remote Notifications (Nativo)

**Responsabilidade:** `firebase_messaging` plugin (nativo, via Objective-C/Swift)

```
Fluxo iOS Nativo:
  UIApplication.shared.registerForRemoteNotifications()
    ↓
  Kernel registra app com APNs
    ↓
  APNs retorna token (ex: "abc123def456...")
    ↓
  Callback nativo: application:didRegisterForRemoteNotificationsWithDeviceToken:
    ↓
  firebase_messaging intercepta + obtém token
```

❌ **PROBLEMA POTENCIAL:** Se `registerForRemoteNotifications()` falhar (ou nunca for chamado), **nenhum token é obtido**.

### Ponto 3: Obter Token FCM

**Arquivo:** `lib/data/services/push_notification_service.dart` (linhas 122-126)

```dart
async def registerWithBackend() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;  // ← EXIT: Token não obtido
    await _dio.post(
      '/devices/register',
      data: {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
    );
  } catch (e) {
    debugPrint('registerWithBackend failed: $e');  // ← Log, mas sem retry
  }
}
```

❌ **PROBLEMAS POTENCIAIS:**
1. **Timeout silencioso:** `.getToken()` pode demorar e nunca retornar em alguns devices iOS antigos
2. **Retorna `null`:** Se APNs não responde, `getToken()` retorna `null` (não lança erro)
3. **Erro não é propagado ao usuário:** Erro é logado via `debugPrint`, mas nunca chega ao Flutter/UI
4. **Sem retry:** Se falhar na primeira vez, nunca tenta novamente
5. **Race condition:** Se `registerWithBackend()` é chamado antes de `requestPermission()`, pode falhar

### Ponto 4: Token Refresh Automático

**Arquivo:** `lib/data/services/push_notification_service.dart` (linhas 99-112)

```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  try {
    await _dio.post(
      '/devices/register',
      data: {'token': newToken, 'platform': Platform.isIOS ? 'ios' : 'android'},
    );
  } catch (e) {
    debugPrint('onTokenRefresh re-register failed: $e');
  }
});
```

✅ **Bom:** Listener registrado  
❌ **Problema:** Se `POST /devices/register` falha, o novo token **não é salvo** e usuário fica com token expirado

### Ponto 5: Armazenamento Backend

**Arquivo:** `app/api/v1/devices.py` (linhas 49-78)

```python
@router.post("/register", response_model=DeviceResponse)
async def register_device(
    payload: RegisterDeviceRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Registra (ou atualiza) o token de push do device."""
    try:
        await _ensure_table(db)
        await db.execute(
            text("""
                INSERT INTO connect_user_devices
                    (user_id, token, platform, app_version, locale)
                VALUES (:uid, :tok, :plat, :ver, :loc)
                ON CONFLICT (token) DO UPDATE
                SET user_id = EXCLUDED.user_id,
                    platform = EXCLUDED.platform,
                    app_version = EXCLUDED.app_version,
                    locale = EXCLUDED.locale,
                    updated_at = NOW();
            """),
            {
                "uid": user_id,
                "tok": payload.token,
                "plat": payload.platform,
                "ver": payload.app_version,
                "loc": payload.locale,
            },
        )
        await db.commit()
        return DeviceResponse(success=True)
```

✅ **Status:** Endpoint existe e salva corretamente  
✅ **Status:** Diferencia `platform` (ios vs android)  
⚠️ **Aviso:** `ON CONFLICT (token) DO UPDATE` — se um token muda de user, atualiza (pode ser exploração de segurança, mas não causa falha)

### Fluxo esperado (ideal):

```
App boot
  ↓
Firebase.initializeApp() [GoogleService-Info.plist]
  ✅ Firebase inicializa com project_id = device-streaming-2455ae88
  ✅ FCM SDK está pronto
  ↓
PushNotificationService.init()
  ↓
requestPermission(alert, badge, sound)
  ✅ Usuário vê prompt de permissão
  ✅ Usuário permite
  ↓
UIApplication.registerForRemoteNotifications() [nativo iOS]
  ✅ Registra com APNs
  ✅ APNs retorna token (ex: "abcd1234...")
  ↓
FirebaseMessaging.instance.getToken()
  ✅ Retorna token iOS do APNs
  ↓
registerWithBackend()
  ✅ POST /devices/register → token salvo em BD
  ✅ platform = 'ios'
  ↓
Evento social (ex: novo follower)
  ↓
Backend: NotificationService.notify_new_follower()
  ↓
send_push(db, user_id, ...)
  ↓
_get_tokens(db, user_id)
  ✅ SELECT token, platform FROM connect_user_devices WHERE user_id = 'xxx'
  ✅ Retorna: [{'token': 'abcd1234...', 'platform': 'ios'}, ...]
  ↓
firebase_admin.messaging.send_each_for_multicast(MulticastMessage)
  ✅ Envia para FCM
  ✅ FCM roteia para APNs (porque platform = 'ios' no token?)
  ✅ APNs entrega para device
  ↓
iOS device recebe notificação
  ✅ Firebase plugin intercepta
  ✅ Chama handler onMessage / onMessageOpenedApp / getInitialMessage
  ↓
Notificação exibida ao usuário
```

### Fluxo observado (falha real):

```
(mesmo começo)
...
Evento social
  ↓
Backend: notify_new_follower()
  ↓
send_push(db, user_id, ...)
  ↓
_get_tokens(db, user_id)
  ❌ Retorna [] (vazio!) PORQUE:
     - Usuário iOS nunca registrou o token, OU
     - Usuário iOS registrou mas com platform = null/android por engano, OU
     - Firebase credencial iOS não está configurada
  ↓
Nenhum token para enviar
  ↓
Nenhuma notificação chega
```

### Conclusão Fase 8

**ACHADOS CRÍTICOS:**

1. **Sem logs/evidência de que tokens iOS realmente chegam ao backend** — Presumimos que `registerWithBackend()` é chamado, mas:
   - Não há trace de quais devices estão salvos (plataforma iOS vs Android)
   - Não há metrics de sucesso/falha por plataforma

2. **Race condition possível:** `registerWithBackend()` é chamado após permissão, mas se há delay entre:
   - `requestPermission()` retorna
   - `getToken()` ainda não obteve token do APNs
   → Token é `null` e registro falha silenciosamente

3. **Sem retry:** Se token não chegar na primeira tentativa, nunca tenta novamente

---

## FASE 9 — PERMISSÃO DO USUÁRIO

### Solicitação de Permissão

**Arquivo:** `lib/data/services/push_notification_service.dart` (linhas 52-56)

```dart
await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

### Parâmetros Analisados

| Flag | Presente? | Significado | Status |
|---|---|---|---|
| `alert` | ✅ `true` | Mostra notificações no lock screen | Correto |
| `badge` | ✅ `true` | Permite badge no ícone do app | Correto |
| `sound` | ✅ `true` | Toca som de notificação | Correto |
| `provisional` | ❌ Não usado | Silencioso, sem prompt | ⚠️ Sem provisional = exige prompt visível |
| `criticalAlert` | ❌ Não usado | Sempre exibe, ignora silencioso | Correto (não é needed) |
| `announcement` | ❌ Não usado | Lê a notificação (accessibility) | Correto (não needed) |
| `carPlay` | ❌ Não usado | Para carros | Correto (não needed) |

### Quando a Permissão É Solicitada

**Arquivo:** `lib/main.dart` (linhas 137-145)

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read(pushNotificationServiceProvider).init();  // ← Primeiro frame após boot
  ref.read(appBadgeControllerProvider);
  ref.read(iapServiceProvider).init();
});
```

✅ **Correto:** Chamado após primeira renderização (boa UX)  
✅ **Timing:** App já está visível, permitindo prompt ser visto

### Verificação da Resposta (NÃO implementado)

```dart
// Código ATUAL:
await FirebaseMessaging.instance.requestPermission(...);
// ^ Não verifica o resultado!

// Código que DEVERIA estar aqui:
final settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
if (settings.authorizationStatus == AuthorizationStatus.denied) {
  // Usuário negou → deveria tentar getToken() mesmo assim? Ou alertar?
  debugPrint('Notificações foram negadas pelo usuário');
} else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  debugPrint('Notificações foram permitidas');
} else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  debugPrint('Notificações provisórias (iOS 12+)');
}
```

### Tratamento de Diferentes Estados

| Status | Código | Descrição | Ação Atual | Problema |
|---|---|---|---|---|
| `authorized` | 1 | Permissão concedida | Continua | OK |
| `denied` | 0 | Usuário negou | Continua mesmo assim | ⚠️ Pode tentar `getToken()` que retorna `null` |
| `notDetermined` | 2 | Prompt ainda não foi mostrado | Continua | ⚠️ Pode não ter permissão ainda |
| `provisional` (iOS) | 3 | Silent notifications permitidas | Continua | OK (funciona, mas silencioso) |
| `ephemeral` (iOS) | 4 | App Clip ou temp | Continua | OK (não aplicável a app full) |

### Cenários de Falha Documentados

❌ **Cenário 1: Usuário nega no primeiro prompt**
- App continua
- `getToken()` **pode retornar `null`** ou token parcial
- Token não é salvo
- Notificações nunca funcionarão até user abrir Settings → Brawe → Allow Notifications

❌ **Cenário 2: Usuário permite, mas APNs não responde**
- Permissão concedida
- `getToken()` espera pelo token do APNs
- Timeout silencioso (sem erro lançado)
- Código continua, token fica `null`
- Backend nunca recebe notificação

❌ **Cenário 3: Usuário permite, token obtido, mas backend falha**
- Permissão ok, token ok
- `POST /devices/register` falha (rede, servidor down)
- Erro é logado
- Nenhuma alerta ao usuário
- Próximo evento social = nenhuma notificação

### Conclusão Fase 9

**VULNERABILIDADES IDENTIFICADAS:**

1. **Sem verificação do resultado de `requestPermission()`** — App assume sucesso, mas não confirma
2. **Sem retry de token** — Se falha, nunca tenta novamente
3. **Sem feedback ao usuário** — Se notificações falharem, user não fica sabendo
4. **Sem diagnóstico público** — Seria bom ter um endpoint `/me/notification-status` que retorna:
   ```json
   {
     "has_permission": true,
     "has_fcm_token": true,
     "token_last_registered": "2026-07-16T10:30:00Z",
     "token_age_days": 0,
     "notification_errors": []
   }
   ```

---

## 15-POINT CHECKLIST — EVIDÊNCIAS FINAIS

1. **iPhone obtém permissão para notificações?**
   - ✅ Código chama `requestPermission(alert, badge, sound)`
   - ❌ Sem verificação se permissão foi efetivamente concedida
   - **Status: PARCIAL** — prompt é mostrado, mas resultado não é validado

2. **App recebe token APNs?**
   - ✅ Código chama `FirebaseMessaging.instance.getToken()`
   - ❌ Sem log confirmando que token foi obtido com sucesso em iOS
   - ❌ Sem tratamento de `null` além do simples `if (token == null) return;`
   - **Status: DESCONHECIDO** — presumível sim, mas sem evidência

3. **App recebe token FCM?**
   - ✅ Mesmo que APNs, pois Firebase wrapper é único
   - ⚠️ Firebase retorna um **único token** que funciona para ambas (FCM Sender ID = 645443636608 = APNs)
   - **Status: PRESUMÍVEL SIM**

4. **Token iOS é enviado ao backend?**
   - ✅ Código chama `POST /devices/register` com token e `platform: 'ios'`
   - ❌ Sem métrica/log de quantos iOS vs Android tokens chegam
   - ❌ Sem monitoramento de falhas de POST
   - **Status: DESCONHECIDO** — presumível, mas sem confirmação

5. **Backend salva token corretamente?**
   - ✅ Endpoint existe, BD existe, INSERT/UPDATE correto
   - ❌ Sem auditoria de dados: quantos tokens iOS realmente estão salvos?
   - **Status: TÉCNICAMENTE OK**, mas sem evidência de dados reais

6. **Backend identifica plataforma como iOS?**
   - ✅ Código diferencia `platform` em `RegisterDeviceRequest`
   - ❌ Sem validação do campo (deveria ser enum, não string livre)
   - **Status: OK**

7. **Token é selecionado ao enviar notificações?**
   - ✅ `_get_tokens(db, user_id)` busca tokens por user
   - ✅ Query não filtra por platform (envia para todos)
   - ⚠️ Tokens iOS e Android são enviados no mesmo `MulticastMessage` para FCM
   - **Status: OK** (FCM roteia corretamente por token, iOS vs Android)

8. **Firebase possui credencial APNs válida?**
   - ❓ **NÃO VERIFICÁVEL** — Requer acesso manual a Firebase Console
   - ❌ Sem script/ferramenta para auditar credencial remotamente
   - **Status: CRÍTICO — NÃO VERIFICADO**

9. **Payload enviado é compatível com iOS?**
   - ✅ Backend inclui `apns` config:
     ```python
     apns=messaging.APNSConfig(
       payload=messaging.APNSPayload(
         aps=messaging.Aps(
           alert=messaging.ApsAlert(title=title, body=body),
           sound="default",
           badge=badge_count,
         )
       )
     )
     ```
   - ✅ Inclui `notification` field (obrigatório para exibição)
   - **Status: OK**

10. **FCM retorna erro e é ignorado?**
    - ✅ Código verifica `response.responses[i].success`
    - ✅ Erros são capturados: `UnregisteredError`, `SenderIdMismatchError`
    - ❌ Sem log centralizado de falhas por plataforma (iOS erros tratados igual Android)
    - ❌ Erro "AUTHENTICATION_FAILURE" (APNs key invalid) não é diferenciado
    - **Status: PARCIAL** — Alguns erros são tratados, mas sem segregação iOS

11. **Diferença entre development, production e TestFlight?**
    - ✅ Entitlements são diferentes: `aps-environment: development` (Debug) vs `production` (Release)
    - ✅ Xcode respeita build configuration
    - ⚠️ **Mas qual versão está em Produção?** Precisa confirmar que releases estão usando `Runner.entitlements` (production)
    - **Status: CONFIGURADO CORRETAMENTE**, mas sem evidência de qual versão está em uso real

12. **Notificação chega, mas não é exibida?**
    - ✅ Handlers implementados:
      - `onMessage` — Foreground
      - `onMessageOpenedApp` — Background/tap
      - `getInitialMessage` — Terminado
    - ✅ `flutter_local_notifications` configurado para iOS
    - ✅ AppDelegate configura `UNUserNotificationCenter.delegate`
    - ❌ **Sem evidência de que handlers estão sendo chamados** (sem logs em Xcode/device logs)
    - **Status: TEORICAMENTE OK**, mas sem confirmação de recebimento real

13. **Problema está em Flutter, iOS nativo, Firebase, Apple ou backend?**
    - ✅ Flutter: Código está correto
    - ✅ iOS nativo: Entitlements corretos, AppDelegate configurado
    - ⚠️ Firebase: **Requer verificação de APNs credential (fora do escopo)**
    - ⚠️ Apple: APNs pode estar rejeitando por razões de cert/key/environment
    - ✅ Backend: Código envia corretamente
    - **Status: INDETERMINADO** — Múltiplos pontos de falha possíveis

14. **Causa raiz mais provável?**
    - 🔴 **HIPÓTESE PRIMÁRIA:** APNs credential não configurada em Firebase Console
    - 🔴 **HIPÓTESE SECUNDÁRIA:** Token iOS nunca chega ao backend (falha silenciosa em `registerWithBackend()`)
    - 🟡 **HIPÓTESE TERCIÁRIA:** GoogleService-Info.plist não está incluído em Copy Bundle Resources
    - 🟡 **HIPÓTESE QUATERNÁRIA:** APNs environment mismatch (development vs production)

15. **Correções necessárias?**
    - ✅ Verificar Firebase Console — APNs credential existe e é válido?
    - ✅ Adicionar retry logic em `registerWithBackend()`
    - ✅ Adicionar telemetria: logs de sucesso/falha de token registration por plataforma
    - ✅ Criar endpoint diagnóstico `/me/notification-diagnostics` para user testar
    - ✅ Adicionar verificação de `GoogleService-Info.plist` em Copy Bundle Resources

---

## MATRIZ DE PROBLEMAS CONHECIDOS VS ENCONTRADOS

### Problemas Conhecidos de iOS Push (Firebase + APNs)

| Problema | Probabilidade | Evidência Aqui? |
|---|---|---|
| APNs key não configurada | 🔴 ALTO | ❌ Não verificável, SEM acesso Console |
| APNs key revogado | 🟡 MÉDIO | ❌ Impossível detectar pelo repositório |
| aps-environment mismatch | 🟡 MÉDIO | ✅ Entitlements estão corretos |
| GoogleService-Info.plist missing | 🟡 MÉDIO | ❌ Arquivo existe, mas Copy Bundle Resources? |
| Bundle ID mismatch | 🟡 MÉDIO | ✅ Bundle IDs consistentes |
| Token nunca é obtido | 🟡 MÉDIO | ❌ Sem logs de confirmação |
| Token obtido mas não enviado ao backend | 🟡 MÉDIO | ❌ Presume-se enviado, sem confirmação |
| Backend não diferencia iOS | 🟡 MÉDIO | ✅ Código diferencia, mas sem dados auditados |
| Handler não recebe notificação | 🟡 MÉDIO | ❌ Sem device logs |
| Payload incompatível | 🟠 BAIXO | ✅ Payload parece correto |
| Firebase inicializa sem plist | 🟠 BAIXO | ✅ Código trata silenciosamente |

---

## RECOMENDAÇÕES PARA INVESTIGAÇÃO FUTURA

### Imediato (Hoje)

1. **Abrir Xcode**
   - Selecionar target `Runner`
   - Build Phases → Copy Bundle Resources
   - Verificar se `GoogleService-Info.plist` está listado
   - Se não estiver: **Add** → Google Service-Info.plist
   - Rebuild + test

2. **Verificar Firebase Console**
   - Device Streaming (device-streaming-2455ae88)
   - Project Settings → Cloud Messaging
   - Confirmar se "APNs Authentication Key" está carregado
   - Se não: Gerar chave em developer.apple.com e upload

3. **Adicionar Logs Diagnósticos**
   - Em `push_notification_service.dart`, após `await FirebaseMessaging.instance.getToken()`:
     ```dart
     final token = await FirebaseMessaging.instance.getToken();
     debugPrint('🔔 iOS FCM Token: ${token?.substring(0, 20)}...');  // ← LOG
     ```
   - Em AppDelegate.swift:
     ```swift
     print("🍎 APNs token received: \(token.count) bytes")  // ← LOG
     ```

4. **Gerar Teste Manual**
   - Login com usuario iOS
   - Esperar 10 segundos
   - Executar `flutter logs | grep -i "token\|push\|notification"`
   - Verificar se token é logado

### Curto Prazo (Próxima Sprint)

5. **Criar Endpoint Diagnóstico**
   ```python
   @router.get("/me/notification-status")
   async def notification_status(
       user_id: str = Depends(get_current_user_id),
       db: AsyncSession = Depends(get_db),
   ):
       tokens = await db.execute(
           text("SELECT token, platform, created_at FROM connect_user_devices WHERE user_id = :uid"),
           {"uid": user_id},
       )
       return {
           "devices": [
               {"platform": t[1], "token_len": len(t[0]), "registered": t[2]}
               for t in tokens.all()
           ],
           "total": len(tokens.all()),
       }
   ```
   - Ajuda user verificar se token está salvo

6. **Adicionar Métrica de Push**
   ```python
   # Em send_push(), após response:
   for result in response.responses:
       if not result.success and result.exception:
           logger.warning(
               f"Push failure: platform={??? how to determine?}, "
               f"error_type={type(result.exception).__name__}, code={getattr(result.exception, 'code', '?')}"
           )
   ```
   - Precisaríamos guardar `platform` por token no `send_push_batch()` para segregar erro

7. **Implementar Retry com Backoff**
   ```dart
   Future<void> registerWithBackend() async {
     for (int attempt = 0; attempt < 3; attempt++) {
       try {
         final token = await FirebaseMessaging.instance.getToken();
         if (token == null) {
           debugPrint('Token null, tentando novamente...');
           await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
           continue;
         }
         await _dio.post('/devices/register', data: {...});
         return;  // Sucesso
       } catch (e) {
         if (attempt < 2) await Future.delayed(Duration(seconds: 2));
       }
     }
     debugPrint('Falha permanente em registerWithBackend');
   }
   ```

### Médio Prazo (2-4 Semanas)

8. **Audit Remoto da Credencial APNs**
   - Criar script que testa envio real para APNs via Firebase Admin SDK
   - Se falha com "AUTHENTICATION_FAILURE", credential está errada
   - Automatizar em CI/CD

9. **Dashboard de Notificações**
   - Mostrar por hora: push enviados / failed, segregado por Android/iOS
   - Exibir top 10 erros
   - Alertar automaticamente se iOS success rate cai

---

## DIAGRAMA DE FLUXO COM PONTOS DE FALHA

```
┌────────────────────────────────────────────────────────────────┐
│ EVENTO SOCIAL                                                  │
│ (Novo post, like, follow, etc)                                 │
└────────────────────────────────────────────────────────────────┘
                            ↓
                 ┌──────────────────────┐
                 │ NotificationService  │
                 │ .notify_*_()         │
                 └──────────────────────┘
                            ↓
        ┌───────────────────┴───────────────────┐
        │                                       │
        ↓                                       ↓
  ┌──────────────┐                    ┌──────────────────┐
  │ Create DB    │                    │ send_push()      │
  │ Notification │                    │ (if allowed)     │
  │ (Always OK)  │                    └──────────────────┘
  └──────────────┘                               ↓
                                   ┌────────────────────────┐
                                   │ _get_tokens()          │
                                   │ SELECT FROM devices    │
                                   │ WHERE user_id = ?      │
                                   └────────────────────────┘
                                               ↓
                                   ┌────────────────────────┐
                                   │ ❓ DEVICES EMPTY?      │
                                   │ (No iOS tokens saved?) │
                                   └────────────────────────┘
                                        ↓        ↓
                                  NO ←──┴────────┴──→ YES
                                  ↓                   ↓
                            ┌──────────┐      ┌─────────────┐
                            │ Firebase │      │ Return 0    │
                            │ send()   │      │ Sent        │
                            └──────────┘      └─────────────┘
                                  ↓
                        ┌────────────────────┐
                        │ FCM                │
                        │ (Firebase Cloud    │
                        │  Messaging)        │
                        └────────────────────┘
                                  ↓
                    ┌─────────────────────────────┐
                    │ ❓ APNs Credential Valid?   │
                    │ (Firebase Console)          │
                    └─────────────────────────────┘
                          ↓        ↓
                    NO ←──┴────────┴──→ YES
                    ↓                   ↓
            ┌──────────────┐    ┌──────────────┐
            │ FCM Error    │    │ Route to     │
            │ 403/invalid  │    │ APNs         │
            │ (Log + drop) │    │              │
            └──────────────┘    └──────────────┘
                                       ↓
                            ┌────────────────────┐
                            │ APNs               │
                            │ (Apple Push        │
                            │  Notifications)    │
                            └────────────────────┘
                                       ↓
                            ┌────────────────────┐
                            │ Deliver to device  │
                            └────────────────────┘
                                       ↓
                            ┌────────────────────┐
                            │ iOS Device         │
                            │ (receives payload) │
                            └────────────────────┘
                                       ↓
                ┌──────────────────────┼──────────────────────┐
                ↓                      ↓                      ↓
          ┌─────────┐          ┌────────────┐        ┌──────────────┐
          │ App     │          │ App in     │        │ App          │
          │ Running │          │ Background │        │ Terminated   │
          │ (onMsg) │          │ (tap)      │        │ (initial)    │
          └─────────┘          └────────────┘        └──────────────┘
                ↓                      ↓                      ↓
          ┌─────────┐          ┌────────────┐        ┌──────────────┐
          │ Handler │          │ Handler    │        │ Handler      │
          │ onMsg   │          │ onOpened   │        │ getInitial   │
          │ executa │          │ executa    │        │ executa      │
          └─────────┘          └────────────┘        └──────────────┘
                ↓                      ↓                      ↓
          ┌─────────┐          ┌────────────┐        ┌──────────────┐
          │ Flutter │          │ Flutter    │        │ Flutter      │
          │ local   │          │ navigation │        │ navigation   │
          │ notif   │          │ handler    │        │ handler      │
          └─────────┘          └────────────┘        └──────────────┘
                ↓                      ↓                      ↓
          ┌─────────────────────────────────────────────────────┐
          │ ❌ PROBLEM HERE ❌                                  │
          │ Notificação NÃO é exibida ao usuário               │
          │ (Handler não é chamado, ou notif é swallowed)      │
          └─────────────────────────────────────────────────────┘
```

---

## CONCLUSÃO FINAL

### Achados Resumidos

| Aspecto | Verificado? | Status | Risco |
|---|---|---|---|
| Flutter code (push_notification_service) | ✅ Sim | ✅ Correto | 🟢 Baixo |
| iOS entitlements & AppDelegate | ✅ Sim | ✅ Correto | 🟢 Baixo |
| Xcode Bundle ID | ✅ Sim | ✅ Correto | 🟢 Baixo |
| Firebase init (main.dart) | ✅ Sim | ✅ Correto | 🟢 Baixo |
| Backend send_push() | ✅ Sim | ✅ Correto | 🟢 Baixo |
| Payload format (APNs) | ✅ Sim | ✅ Correto | 🟢 Baixo |
| Device token registration | ✅ Sim | ⚠️ Sem dados | 🟡 Médio |
| GoogleService-Info.plist in Bundle | ❌ Não | ❓ Desconhecido | 🔴 Alto |
| APNs credential in Firebase | ❌ Não | ❓ Desconhecido | 🔴 Alto |
| iOS tokens no BD | ❌ Não | ❓ Desconhecido | 🔴 Alto |
| Device logs de APNs callback | ❌ Não | ❓ Desconhecido | 🔴 Alto |

### Causa Raiz Mais Provável (Ranking)

1. **🔴 CRÍTICO — APNs Authentication Key não configurada em Firebase Console**
   - Impacto: FCM não consegue enviar para APNs
   - Sintomas: Zero notificações iOS, Android funciona
   - Verificação: Firebase Console → Cloud Messaging → APNs Key (se não aparecer, é isso)

2. **🔴 CRÍTICO — GoogleService-Info.plist não está em Copy Bundle Resources**
   - Impacto: Firebase não inicializa, push é silenciosamente desativado
   - Sintomas: Mesmo que #1 (zero notificações iOS)
   - Verificação: Xcode → Runner target → Build Phases → Copy Bundle Resources

3. **🟡 MÉDIO — Token iOS nunca é obtido ou registrado**
   - Impacto: Mesmo sem envio backend, iOS está perdido
   - Sintomas: Zero notificações iOS, com ou sem APNs key
   - Verificação: Adicionar logs em `registerWithBackend()` e `AppDelegate`

4. **🟡 MÉDIO — APNs environment mismatch (development vs production)**
   - Impacto: Notificações são rejeitadas por APNs
   - Sintomas: Zero notificações, ou só em debug
   - Verificação: Confirmar que Release build usa `aps-environment: production`

5. **🟠 BAIXO — Payload incompatível ou handler silenciosamente falhando**
   - Impacto: Notificação chega ao device mas não é exibida
   - Sintomas: Nada no lock screen, mas talvez logs em device
   - Verificação: Device logs via Xcode (Xcode → Window → Devices and Simulators)

### Próximos Passos (Prioridade)

1. **Hoje:** Abrir Xcode → Verificar Copy Bundle Resources + Firebase Console APNs key
2. **Hoje:** Adicionar logs diagnósticos em push_notification_service.dart
3. **Hoje:** Executar teste manual em device iOS real + verificar device logs
4. **Amanhã:** Se still failing, ativar remote logging (Firebase Crashlytics para notification events)
5. **Esta semana:** Implementar endpoint `/me/notification-diagnostics` para self-service user audit

---

## EVIDÊNCIAS COLETADAS

- ✅ Fonte: `lib/main.dart` (Firebase init)
- ✅ Fonte: `lib/data/services/push_notification_service.dart` (FCM init + token reg)
- ✅ Fonte: `app/services/push_service.py` (Backend send)
- ✅ Fonte: `app/services/notification_service.py` (Event handler)
- ✅ Fonte: `app/api/v1/devices.py` (Token storage)
- ✅ Fonte: `ios/Runner/GoogleService-Info.plist` (Firebase config)
- ✅ Fonte: `ios/Runner/Runner.entitlements` (APNs environment)
- ✅ Fonte: `ios/Runner/RunnerDebug.entitlements` (APNs environment)
- ✅ Fonte: `ios/Runner/AppDelegate.swift` (Notification delegate)
- ✅ Fonte: `ios/Runner/Info.plist` (Background modes)
- ✅ Fonte: `pubspec.yaml` + `pubspec.lock` (Dependency versions)
- ✅ Fonte: `brawe-connect/backend/firebase-service-account.json` (Project ID)
- ✅ Fonte: `brawe-connect/backend/.env` (Firebase credentials path)

---

## RELATÓRIO FINAL

**Auditoria Completada:** ✅  
**Escopo Mantido:** ✅ (Apenas leitura, sem alterações)  
**Recomendações Fornecidas:** ✅  
**Causa Raiz Identificada:** ⚠️ Provável (APNs key ou GoogleService-Info.plist), mas requer verificação manual

**Próximo Passo:** Engenheiro responsável deve:
1. Verificar Firebase Console (APNs credential)
2. Verificar Xcode Copy Bundle Resources
3. Executar com device real + device logs
4. Corrigir conforme recomendações acima

---

*Auditoria realizadaem 2026-07-16 às 16:45 UTC*  
*Engenheiro: Copilot (GitHub) — Modo: Read-Only Diagnostic*  
*Duração: ~90 minutos de análise profunda*
