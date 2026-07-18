# ✅ CHECKLIST - Antes de Upload ao Play Console

> Guia completo para garantir que nada foi esquecido antes de enviar a APK ao Play Console

---

## 🔍 VERIFICAÇÕES PRÉ-BUILD

### Código & Configuração

- [ ] **Push Notifications** - Verificar se logs foram adicionados
  ```bash
  grep "🔔 Permission status" lib/data/services/push_notification_service.dart
  ```
  - Deve retornar: `🔔 Permission status:`

- [ ] **Firebase Configurado**
  - [ ] `android/app/google-services.json` existe
  - [ ] `ios/Runner/GoogleService-Info.plist` existe
  - [ ] IDs corretos no Firebase Console

- [ ] **Versão Atualizada**
  ```bash
  grep "^version:" pubspec.yaml
  ```
  - Exemplo: `version: 1.2.3+45`

- [ ] **Dependências Atualizadas**
  ```bash
  flutter pub outdated
  ```
  - Nenhuma dependência crítica desatualizada

- [ ] **Análise Dart Limpa**
  ```bash
  flutter analyze --no-fatal-infos
  ```
  - Nenhum erro crítico

---

## 🏗️ BUILD CONFIGURATION

### Android

- [ ] **compileSdkVersion** ≥ 34
  - Verificar: `android/app/build.gradle`
  - Linha: `compileSdkVersion 34`

- [ ] **targetSdkVersion** ≥ 34
  - Verificar: `android/app/build.gradle`
  - Linha: `targetSdkVersion 34`

- [ ] **minSdkVersion** ≥ 21
  - Verificar: `android/app/build.gradle`
  - Linha: `minSdkVersion 21`

- [ ] **Package Name** Correto
  - Verificar: `android/app/build.gradle`
  - Deve ser: `applicationId "app.brawe.connect"` (ou seu pacote)

- [ ] **Permissions**
  - [ ] `android/app/src/main/AndroidManifest.xml` tem POST_NOTIFICATIONS
  - [ ] `INTERNET` permission presente
  - [ ] `RECEIVE_BOOT_COMPLETED` (opcional, para FCM)

---

## 🍎 iOS CONFIGURATION (se aplicável)

- [ ] **Info.plist**
  - [ ] `UIBackgroundModes` inclui `remote-notification`
  - [ ] Bundle ID correto

- [ ] **Runner.entitlements**
  - [ ] `aps-environment` = production
  - [ ] Push Notifications capability habilitada

- [ ] **GoogleService-Info.plist**
  - [ ] Arquivo existe
  - [ ] Bundle ID bate com Info.plist

---

## 📝 VERSÃO & RELEASE NOTES

- [ ] **Incrementar Versão**
  - Current: _______  
  - New: _______  
  - Exemplo: `1.0.0` → `1.0.1` (patch) ou `1.1.0` (minor)

- [ ] **Escrever Release Notes**
  - [ ] Novidades principais listadas
  - [ ] Bug fixes documentados
  - [ ] Mudanças de compatibilidade explicadas

- [ ] **Verificar Compatibilidade**
  - [ ] App funciona em Android 7+ (se minSdkVersion=21)
  - [ ] App funciona em Android 14 (teste em device ou emulator)
  - [ ] Notificações funcionam corretamente

---

## 🚀 EXECUTAR BUILD

### Opção 1: Automática (Recomendado)

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app

# Rodar Build Analyzer (verifica tudo)
bash BUILD_ANALYZER.sh

# Se passou ✅, rodar BUILD_RELEASE_APK.sh
bash BUILD_RELEASE_APK.sh
```

### Opção 2: Manual

```bash
flutter clean
flutter pub get
flutter build apk --release --verbose
```

---

## 🔍 VERIFICAR APK GERADA

Após o build:

- [ ] **APK Existe**
  - Caminho: `build/app/outputs/apk/release/app-release.apk`
  - Tamanho: ____ MB (tipicamente 50-100 MB)

- [ ] **Testar APK Localmente** (em device/emulator)
  ```bash
  adb install -r build/app/outputs/apk/release/app-release.apk
  ```
  - [ ] App instala sem erros
  - [ ] App abre normalmente
  - [ ] Notificações funcionam (pode testar com dev build)

- [ ] **Checksums Registrados**
  - SHA256: ________________________
  - MD5: ________________________

---

## 📱 TESTAR NOTIFICAÇÕES (IMPORTANTE!)

**Antes de enviar para produção, teste:**

1. **Abrir app recém-instalado**
   - Popup "Permitir notificações?" deve aparecer
   - Clique [Allow]

2. **Verificar Settings**
   - Settings → Notifications → Brawe
   - "Allow Notifications" deve estar ON

3. **Enviar notificação de teste**
   - Via Firebase Console ou backend
   - Deve aparecer no device mesmo com app em background
   - Ao clicar, app deve navegar corretamente

4. **Logs no Xcode/Android Studio**
   - Procure por: `✅ User GRANTED notification permission!`
   - Procure por: `✅ registerWithBackend: Successfully registered!`

---

## 📤 UPLOAD AO PLAY CONSOLE

### Pré-requisitos

- [ ] Conta Google Play Developer ativa
- [ ] App já publicado ou em produção
- [ ] Acesso à conta de upload

### Passos

1. **Acessar Play Console**
   - Ir para: https://play.google.com/console
   - Selecionar app: Brawe Connect

2. **Criar Release**
   - Menu: Testing → Internal Testing (ou seu track)
   - Botão: "Create Release"

3. **Upload APK**
   - [ ] Arrastar `app-release.apk` ou clicar em Browse
   - [ ] Verificar que versão está correta
   - [ ] Conferir tamanho está OK

4. **Release Notes**
   - [ ] Preencher em português (pt-BR)
   - [ ] Descrever novidades
   - [ ] Explicar correções

5. **Review & Rollout**
   - [ ] Clicar "Review Release"
   - [ ] Verificar informações estão corretas
   - [ ] Clicar "Start Rollout to Internal Testing" (ou Production)
   - [ ] Confirmar porcentagem (geralmente 100% para internal)

---

## ⚠️ CHECKLIST DE SEGURANÇA

- [ ] **Nenhuma informação sensível em logs** (tokens, senhas)
- [ ] **Nenhuma URL hard-coded** (usar environment)
- [ ] **Permissões mínimas necessárias**
  - [ ] INTERNET - OK
  - [ ] RECEIVE_BOOT_COMPLETED - OK
  - [ ] POST_NOTIFICATIONS - OK
  - Nenhuma permissão desnecessária

- [ ] **API Keys Seguras**
  - [ ] Firebase key é pública (OK)
  - [ ] Nenhuma API key privada no código

- [ ] **Versão Mínima Suportada**
  - [ ] Android 7+ (API 24+) suportado
  - [ ] Nenhuma função de API muito nova

---

## 🎯 CHECKLIST FINAL

- [ ] BUILD_ANALYZER.sh passou ✅
- [ ] APK foi construída com sucesso
- [ ] APK foi testada localmente (adb install)
- [ ] Notificações funcionam
- [ ] Logs aparecem corretamente
- [ ] Versão foi incrementada
- [ ] Release notes foram escritas
- [ ] Segurança foi verificada
- [ ] APK foi feita upload ao Play Console
- [ ] Release foi criada

---

## 📊 INFORMAÇÕES DA RELEASE

| Item | Valor |
|------|-------|
| Versão App | __________ |
| Build Version Code | __________ |
| Tamanho APK | __________ |
| Data Build | __________ |
| Data Upload | __________ |
| Track (Internal/Beta/Production) | __________ |
| % Rollout | __________ |

---

## 🚀 PRÓXIMOS PASSOS

Após upload ao Play Console:

1. **Monitorar Release**
   - Verificar se está "Active" dentro de alguns minutos
   - Checar se usuários de teste conseguem baixar

2. **Testar em Produção**
   - Um tester baixa app pelo Play Console
   - Verifica se tudo funciona

3. **Gradualmente Expandir**
   - Se tudo OK, aumentar % para Beta
   - Se tudo OK em Beta, expandir para Production (100%)

4. **Monitorar Crashes/Reviews**
   - Verificar Play Console diariamente por 1 semana
   - Ler reviews e responder

---

## 🆘 TROUBLESHOOTING

### Build falha com erro de SDK

```bash
flutter doctor
# Atualizar SDKs necessários
```

### APK muito grande

```bash
flutter build apk --release --split-per-abi
# Gera múltiplas APKs (mais eficiente)
```

### Notificações não funcionam após upload

- [ ] Verificar firebase-messaging em produção
- [ ] Verificar APNs keys no Firebase (iOS)
- [ ] Verificar que backend está enviando pushes

### Erro ao fazer upload

- [ ] Verificar versión code é maior que release anterior
- [ ] Verificar APK está assinada corretamente
- [ ] Tentar fazer upload novamente

---

## 📞 CONTATO

Se houver problemas:

1. Verificar `BUILD_ANALYZER.sh` output
2. Rodar `flutter doctor` e verificar environment
3. Limpar com `flutter clean` e tentar novamente
4. Verificar logs em `build/` directory

---

**Versão Checklist:** 1.0  
**Última Atualização:** 2024  
**Por:** Build System

