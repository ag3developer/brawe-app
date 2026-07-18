# 🚀 GERAR APK RELEASE - PASSO A PASSO

> Guia completo para gerar a APK Release e enviar ao Play Console

---

## ✅ PRÉ-REQUISITOS

Antes de começar, verifique:

- [ ] Flutter está instalado: `flutter --version`
- [ ] Android SDK está configurado: `flutter doctor`
- [ ] Você tem acesso ao Google Play Console
- [ ] Versão foi incrementada em `pubspec.yaml`
- [ ] Todos os checks passaram (vide BUILD_ANALYZER.sh)

---

## 📋 CHECKLIST ANTES DE GERAR APK

### Código

- [ ] **Notificações**: Logs foram adicionados ✅
  ```
  lib/data/services/push_notification_service.dart tem:
  🔔 Permission status
  ✅ User GRANTED
  ```

- [ ] **Versão Correta**
  ```bash
  grep "^version:" pubspec.yaml
  # Saída esperada: version: 1.0.30+30
  ```

- [ ] **Dependências**: Nenhuma com erro
  ```bash
  flutter pub get
  ```

- [ ] **Sem erros de compilação**
  ```bash
  flutter analyze --no-fatal-infos
  ```

### Configuração Android

- [ ] **Firebase configurado**
  - `android/app/google-services.json` ✅ existe

- [ ] **Permissões corretas**
  - `android/app/src/main/AndroidManifest.xml` ✅

- [ ] **AndroidManifest.xml**
  ```xml
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```

- [ ] **build.gradle** correto
  - compileSdkVersion ≥ 34
  - targetSdkVersion ≥ 34
  - minSdkVersion ≥ 21

### Configuração iOS (se aplicável)

- [ ] `ios/Runner/GoogleService-Info.plist` ✅
- [ ] `ios/Runner/Info.plist` com `remote-notification` ✅
- [ ] `ios/Runner/Runner.entitlements` com `aps-environment` ✅

---

## 🚀 GERAR APK (5 PASSOS)

### PASSO 1: Limpar Build Anterior

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
flutter clean
```

**Saída esperada:**
```
Building for production...
Build complete!
```

---

### PASSO 2: Obter Dependências

```bash
flutter pub get
```

**Saída esperada:**
```
Got dependencies!
```

---

### PASSO 3: Gerar APK Release

```bash
flutter build apk --release --verbose
```

**O que vai acontecer:**
1. Compilar Dart → Dart Kernel
2. Compilar Kotlin/Java → Classes.dex
3. Empacotar Assets e Resources
4. Assinar com key de release (assinatura automática)
5. Gerar APK final

**Tempo:** 5-15 minutos (dependendo do device)

**Saída esperada (no final):**
```
✓ Built build/app/outputs/apk/release/app-release.apk (XX.X MB)
```

---

### PASSO 4: Verificar APK Gerada

```bash
ls -lh build/app/outputs/apk/release/app-release.apk
```

**Saída esperada:**
```
-rw-r--r--  1 user  staff  75M  Jul 16 10:30 app-release.apk
```

---

### PASSO 5: Testar APK Localmente (Opcional mas Recomendado)

#### 5a. Desinstalar app anterior
```bash
adb uninstall app.brawe.connect
```

#### 5b. Instalar APK de teste
```bash
adb install build/app/outputs/apk/release/app-release.apk
```

#### 5c. Testar no device
1. Abrir app Brawe
2. Fazer login
3. Verificar notificações funcionam
4. Enviar notificação de teste

---

## 📊 RESUMO DA APK GERADA

```bash
# Ver detalhes
ls -lh build/app/outputs/apk/release/app-release.apk
du -h build/app/outputs/apk/release/app-release.apk

# Gerar checksums
shasum -a 256 build/app/outputs/apk/release/app-release.apk
md5 build/app/outputs/apk/release/app-release.apk
```

---

## 📤 UPLOAD AO GOOGLE PLAY CONSOLE

### Passo 1: Acessar Play Console

1. Abrir: https://play.google.com/console
2. Fazer login com sua conta Google
3. Selecionar app **Brawe Connect**

### Passo 2: Criar Release

1. Menu lateral → **Testing** → **Internal Testing**
2. Clicar botão **"Create Release"**

### Passo 3: Upload APK

1. Clicar em **"Browse Files"** ou arrastar arquivo
2. Selecionar: `build/app/outputs/apk/release/app-release.apk`
3. Aguardar upload (pode levar alguns minutos)

### Passo 4: Preencher Release Notes

1. Campo **"Release Notes"** (Portugal):
   ```
   Versão 1.0.30 - Melhorias em notificações push

   ✨ Novidades:
   - Melhor rastreamento de permissões de notificação
   - Logs detalhados para diagnóstico
   
   🐛 Correções:
   - Fixado problema de registro de token
   - Melhorada confiabilidade de notificações
   
   📝 Técnico:
   - Firebase Admin SDK atualizado
   - Suporte melhorado para Android 14+
   ```

2. Selecionar idiomas relevantes (português, inglês, etc.)

### Passo 5: Revisar Release

1. Clicar **"Review Release"**
2. Verificar:
   - Versão está correta ✅
   - APK foi uploaded ✅
   - Release notes preenchidas ✅
   - Tamanho APK está OK ✅

### Passo 6: Iniciar Rollout

1. Clicar **"Start Rollout to Internal Testing"**
2. Clicar **"Confirm"**

**Pronto!** Release está ativa em 15-30 minutos

---

## 🎯 APÓS UPLOAD

### Monitorar Release

1. Voltar para **Internal Testing**
2. Verificar status: `Active` ✅
3. Usuários de teste conseguem baixar

### Próximos Passos

**Se tudo funcionou bem:**

1. Testar com tester real por 1-2 dias
2. Se OK, expandir para **Beta Testing** (% maior de usuários)
3. Se OK em Beta, expandir para **Production** (100% dos usuários)

**Se problema encontrado:**

1. Criar nova versão (ex: 1.0.31)
2. Fazer mesmo processo com correções
3. Upload nova APK

---

## ❌ TROUBLESHOOTING

### Erro: "Build failed"

```bash
# Solução 1: Limpar e tentar novamente
flutter clean
flutter pub get
flutter build apk --release

# Solução 2: Checar environment
flutter doctor

# Solução 3: Compilar com mais detalhes
flutter build apk --release -vvv
```

### Erro: "APK já existe com esta versão"

```bash
# Incrementar version code
# pubspec.yaml: version: 1.0.30+31 (incrementar número após +)
# Depois gerar novamente
```

### Erro: "Código de versão menor que release anterior"

Play Console não permite fazer downgrade de versão.

**Solução:** Sempre incrementar o version code

```bash
# Antes: 1.0.30+30
# Depois: 1.0.30+31
```

### APK muito grande (>100 MB)

```bash
# Dividir em múltiplas APKs (por CPU architecture)
flutter build apk --release --split-per-abi

# Vai gerar:
# - app-armeabi-v7a-release.apk (para Arm 32-bit)
# - app-arm64-v8a-release.apk (para Arm 64-bit)
# - app-x86_64-release.apk (para Intel)
```

---

## 📝 VERSÃO ESPERADA

```
Versão Atual: 1.0.30+30
Próxima: 1.0.31+31 (ou 1.1.0+100 se novo feature)
```

---

## 🔐 Certificados de Assinatura

> **Importante:** Flutter automaticamente assina a APK com debug key na primeira vez.
> Para Play Console, usar release signing (automático ou manual).

A APK gerada está **automaticamente assinada** com:
- Tipo: RSA
- Tamanho: 2048 bits
- Válida por: muitos anos

---

## ✅ CHECKLIST FINAL

- [ ] Build passou: `flutter build apk --release`
- [ ] APK foi gerada: `build/app/outputs/apk/release/app-release.apk`
- [ ] APK foi testada: `adb install app-release.apk`
- [ ] Testei notificações no device
- [ ] Version code foi incrementado
- [ ] Release notes foram preenchidas
- [ ] APK foi uploaded ao Play Console
- [ ] Release está ativa
- [ ] Testers conseguem baixar

---

## 🎉 PRONTO!

Sua APK está agora no Play Console e será distribuída aos usuários!

### Próximas 24 horas:

- Monitorar app no Play Console
- Verificar crashes e reviews
- Se problema, fazer hotfix e nova versão

### Próxima semana:

- Expandir rollout para Beta (50%)
- Expandir rollout para Production (100%)
- Continuar monitorando

---

**Bom luck! 🚀**

