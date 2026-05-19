# 🤖 Brawe App — Checklist de Release Android

> **Status atual:** ~85% pronto. Roda em debug, mas tem 3 bloqueadores para release publicável e alguns ajustes de produção pendentes.

Última atualização: 19/05/2026

---

## 📊 Sumário executivo

| Categoria | Status | Bloqueia release? |
|-----------|--------|-------------------|
| Build Gradle / Kotlin / SDK | ✅ Ok | Não |
| AndroidManifest (permissões, deep links) | ✅ Ok | Não |
| **Firebase (Crashlytics + FCM)** | 🔴 Faltando | **SIM** |
| **Signing config release** | 🔴 Faltando | **SIM** |
| **`minSdk` explícito** | 🟡 Herdado do Flutter | Não, mas vai dar dor |
| Live streaming (RTMP) | 🟡 Não validado | Validar antes |
| Notification channel default | 🟡 Faltando | Não, mas UX ruim |
| Ícones launcher Android | 🟡 Padrão Flutter | Não, mas marketing |
| Splash nativa Android | 🟡 Não validada | Não |
| App Links (assetlinks.json) | 🟡 Servidor não serve | Não, fallback abre browser |
| Foreground service (camera 14+) | 🟡 Faltando | Validar em A14+ |

---

## 🎯 ETAPA 1 — Firebase no Android (BLOQUEADOR)

**Por quê:** `firebase_core`, `firebase_messaging` e `firebase_crashlytics` já estão no `pubspec.yaml` e inicializam no `main.dart`. Sem o `google-services.json`, o app crasha no boot Android (`Default FirebaseApp is not initialized`).

### 1.1 — Criar/configurar projeto Firebase para Android
- [ ] Acessar [Firebase Console](https://console.firebase.google.com/) → projeto **brawe**
- [ ] Adicionar aplicativo Android com `applicationId = app.brawe.connect`
- [ ] Baixar `google-services.json`
- [ ] Colocar em `android/app/google-services.json`
- [ ] Adicionar `android/app/google-services.json` ao `.gitignore` se contiver secrets (opcional — Google recomenda commitar)

### 1.2 — Plugin Google Services no Gradle
**Arquivo:** `android/settings.gradle.kts` — adicionar plugin
```kotlin
plugins {
    // ...existing...
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.google.firebase.crashlytics") version "3.0.2" apply false
}
```

**Arquivo:** `android/app/build.gradle.kts` — aplicar
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}
```

### 1.3 — SHA-1/SHA-256 (para Google Sign-In e App Links)
- [ ] Rodar `keytool -list -v -keystore ~/.android/debug.keystore` (debug)
- [ ] Adicionar SHA-1 + SHA-256 no Firebase Console (debug + release depois)

---

## 🎯 ETAPA 2 — Signing Config Release (BLOQUEADOR)

**Por quê:** `release { signingConfig = signingConfigs.getByName("debug") }` faz APK assinado com debug key — **Google Play rejeita**.

### 2.1 — Gerar keystore de upload
```bash
keytool -genkey -v -keystore ~/brawe-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias brawe-upload
```
- [ ] Guardar `brawe-upload-keystore.jks` em local seguro (1Password, cofre, etc.)
- [ ] Anotar a senha em local seguro

### 2.2 — `android/key.properties` (NÃO commitar)
```properties
storePassword=<senha>
keyPassword=<senha>
keyAlias=brawe-upload
storeFile=/caminho/absoluto/para/brawe-upload-keystore.jks
```
- [ ] Adicionar `android/key.properties` ao `.gitignore`

### 2.3 — Atualizar `android/app/build.gradle.kts`
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...existing...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 2.4 — Criar `android/app/proguard-rules.pro`
Manter regras para Flutter, Firebase, video_player, camera, rtmp_broadcaster.

---

## 🎯 ETAPA 3 — `minSdk` explícito + multidex

**Por quê:** muitas libs (firebase 4.x, flutter_local_notifications 21, permission_handler 11) exigem `minSdk 23+`. Firebase + camera + video_player passam de 64K métodos → precisa multidex.

### 3.1 — Atualizar `android/app/build.gradle.kts`
```kotlin
defaultConfig {
    applicationId = "app.brawe.connect"
    minSdk = 24                  // ← explícito (era flutter.minSdkVersion = 21)
    targetSdk = 35               // ← explícito (Play exige 34+ em 2025)
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    multiDexEnabled = true       // ← novo
}
```

---

## 🎯 ETAPA 4 — Notification Channel default (FCM)

**Por quê:** Android 8+ exige channel. Sem isso, push chega mas sem som/heads-up/importância configurável.

### 4.1 — Adicionar metadata no `AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="brawe_default" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/brawe_purple" />
```

### 4.2 — Criar canal em runtime
No `main.dart` (ou em `NotificationsService`), após `Firebase.initializeApp`:
```dart
const channel = AndroidNotificationChannel(
  'brawe_default',
  'Notificações Brawe',
  description: 'Lives, mensagens, vendas e novidades',
  importance: Importance.high,
);
await FlutterLocalNotificationsPlugin()
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
```

### 4.3 — Criar `ic_notification` monocromático
Android exige ícone branco transparente para notification bar. Gerar via [romannurik.github.io/AndroidAssetStudio](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html) e colocar em `android/app/src/main/res/drawable-*/ic_notification.png`.

---

## 🎯 ETAPA 5 — Ícones e splash

### 5.1 — Launcher icons
- [ ] Garantir bloco `flutter_launcher_icons` no `pubspec.yaml` com `android: true`
- [ ] Rodar `dart run flutter_launcher_icons`
- [ ] Verificar `android/app/src/main/res/mipmap-*/ic_launcher.png` atualizados

### 5.2 — Splash nativa
- [ ] Conferir `flutter_native_splash.yaml`
- [ ] Rodar `dart run flutter_native_splash:create`
- [ ] Validar tema `LaunchTheme` em `android/app/src/main/res/values/styles.xml`

---

## 🎯 ETAPA 6 — Foreground service (Android 14+)

**Por quê:** Stories gravando vídeo (`story_composer_screen.dart`) e Live streaming usam câmera + mic. Em A14+, se o app puder ir pra background gravando, precisa de foreground service tipado.

### 6.1 — Permissões no `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CAMERA"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
```

### 6.2 — Decisão de design
Opções:
- (a) Bloquear gravação ao mandar app pra background (mais simples)
- (b) Implementar foreground service para Live + Stories (mais robusto, complexo)

**Recomendação:** (a) para v1, (b) numa v1.1.

---

## 🎯 ETAPA 7 — Live streaming (RTMP) — VALIDAR

**Por quê:** `rtmp_broadcaster: ^2.3.4` tem histórico ruim no Android (NDK, A14+, câmera flipada). iOS usa HaishinKit nativo robusto.

### 7.1 — Plano de teste
- [ ] Build debug em device Android real (não emulador!)
- [ ] Iniciar live → checar:
  - [ ] Preview aparece sem espelho invertido
  - [ ] Áudio captura
  - [ ] RTMP conecta no servidor
  - [ ] Sem crash ao parar
  - [ ] Sem crash ao trocar câmera durante live

### 7.2 — Fallbacks se quebrar
- `apivideo_live_stream` (mais ativo, MIT)
- `flutter_webrtc` + servidor SFU (mais complexo, melhor qualidade)
- Implementação nativa via MethodChannel

---

## 🎯 ETAPA 8 — App Links (deep links HTTPS)

**Por quê:** Manifest tem `autoVerify="true"` para `brawe.app`, mas só funciona se servidor servir `assetlinks.json` com SHA da chave de release.

### 8.1 — Após gerar keystore release (Etapa 2)
- [ ] Extrair SHA-256 da release keystore
- [ ] Gerar JSON via `https://developers.google.com/digital-asset-links/tools/generator`
- [ ] Servidor `brawe.app` precisa servir `https://brawe.app/.well-known/assetlinks.json` (status 200, content-type `application/json`)
- [ ] Testar via `adb shell pm verify-app-links --re-verify app.brawe.connect`

---

## 🎯 ETAPA 9 — Smoke tests em device real

Antes de subir pro Play Console (interno):

- [ ] Login (email/senha + biometria)
- [ ] Feed scrolla, vídeo inline toca, autoplay funciona
- [ ] For You vertical swipe
- [ ] Likes / comments / shares persistem
- [ ] Story composer: foto + vídeo + multi-segmento + repost
- [ ] Story viewer: pinch zoom, comentário, navegação
- [ ] Live: iniciar, transmitir 30s, parar (CRÍTICO)
- [ ] Push: token registra, recebe notificação com app aberto/fechado
- [ ] Deep link: clicar `https://brawe.app/post/X` abre o app
- [ ] Crash provocado: aparece no Crashlytics dashboard em < 5min

---

## 🎯 ETAPA 10 — Build release e Play Console

### 10.1 — Gerar bundle
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### 10.2 — Upload Play Console
- [ ] Criar app no [Play Console](https://play.google.com/console)
- [ ] Track interno → adicionar testers internos
- [ ] Upload AAB
- [ ] Preencher: privacy policy, data safety, content rating
- [ ] Screenshots Android (phone + tablet)

---

## 📅 Ordem de execução sugerida

1. ⚡ **Etapas 2 + 3 + 5** (signing + minSdk + ícones) — pure config, sem dependências externas
2. 🔥 **Etapa 1** (Firebase) — precisa do `google-services.json` que **você baixa** no Firebase Console
3. 🔔 **Etapa 4** (notification channel)
4. 📱 **Etapa 6** (foreground service decisão)
5. 🎥 **Etapa 7** (testar RTMP em device real)
6. 🔗 **Etapa 8** (app links — depende de etapa 2)
7. ✅ **Etapa 9** (smoke test)
8. 🚀 **Etapa 10** (release)

---

## ✋ O que **EU** posso fazer agora (sem você)

- [x] Documentar este checklist
- [x] Etapa 2: gerar `key.properties.example`, atualizar `build.gradle.kts` com signing config (você só precisa gerar a keystore + criar `key.properties` real)
- [x] Etapa 3: pinar `minSdk = 24`, `targetSdk = 35`, `multiDexEnabled = true`
- [x] Etapa 4: adicionar metadata FCM no manifest + criar drawable placeholder + apontar `PushNotificationService` para o novo ícone
- [x] Etapa 5.1: ajustado `min_sdk_android: 24` em `flutter_launcher_icons`
- [x] Etapa 6.1: adicionar permissões `FOREGROUND_SERVICE_*` no manifest
- [x] Adicionar `key.properties` e keystores ao `.gitignore`
- [x] Criar `android/app/proguard-rules.pro` com regras seguras
- [x] Plugins Google Services + Crashlytics no `settings.gradle.kts`
- [x] `coreLibraryDesugaring` habilitado (necessário pra Firebase 4.x + minSdk 24)

## 🤚 O que **VOCÊ** precisa fazer

- [ ] Etapa 1.1: baixar `google-services.json` do Firebase Console
- [ ] Etapa 2.1: rodar `keytool` e gerar a keystore real
- [ ] Etapa 2.2: criar `android/key.properties` com os caminhos/senhas
- [ ] Etapa 7: testar live em device Android real (eu não tenho acesso)
- [ ] Etapa 8: configurar servidor para servir `assetlinks.json`
- [ ] Etapa 10: criar app no Play Console
