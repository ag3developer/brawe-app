# 🚀 BUILD RELEASE SYSTEM - README

> Sistema completo e automatizado para gerar APK Release e enviar ao Play Console

---

## 📋 O QUE FOI CRIADO

### Scripts Bash (Automação)

1. **BUILD_ANALYZER.sh** (269 linhas)
   - ✅ Valida TUDO antes de gerar APK
   - ✅ Verifica pubspec.yaml, Android, iOS, Firebase
   - ✅ Roda flutter analyze e pub outdated
   - ✅ Resultado: ✅/⚠️/❌ com resumo
   - 🎯 **Uso:** `bash BUILD_ANALYZER.sh`

2. **BUILD_RELEASE_APK.sh** (200+ linhas)
   - ✅ Automatiza todo processo de build
   - ✅ flutter clean → pub get → build apk --release
   - ✅ Gera checksums SHA256 e MD5
   - ✅ Salva backup em `releases/` com timestamp
   - ✅ Mostra resumo final com caminho e tamanho
   - 🎯 **Uso:** `bash BUILD_RELEASE_APK.sh`

### Documentação (Guias)

3. **CHECKLIST_ANTES_UPLOAD_PLAY_CONSOLE.md**
   - ✅ Checklist visual com todos os items
   - ✅ Seções: Código, Android, iOS, Build, Versão
   - ✅ Instruções passo a passo
   - ✅ Troubleshooting completo
   - 🎯 **Uso:** Ler antes de gerar APK

4. **GERAR_APK_RELEASE_PASSO_A_PASSO.md**
   - ✅ 5 passos principais bem documentados
   - ✅ Instruções Play Console detalhadas
   - ✅ Exemplos de commands com outputs
   - ✅ Troubleshooting para erros comuns
   - 🎯 **Uso:** Guia principal durante processo

5. **RUN_WITH_LOGS.sh** (anterior)
   - ✅ Script para testar notificações com logs detalhados
   - 🎯 **Uso:** `bash RUN_WITH_LOGS.sh`

6. **COMO_VERIFICAR_SE_POPUP_FOI_PEDIDO.md** (anterior)
   - ✅ Guia para verificar logs de permissão
   - 🎯 **Uso:** Leitura para diagnosticar notificações

---

## 🎯 FLUXO RÁPIDO (TL;DR)

### 1. Executar em 1 minuto:

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app

# Validar tudo
bash BUILD_ANALYZER.sh

# Se passou ✅, gerar APK
bash BUILD_RELEASE_APK.sh
```

### 2. Resultado:

```
✅ APK pronta em:
   build/app/outputs/apk/release/app-release.apk
   
✅ Backup em:
   releases/Brawe-1.0.30-20240716-143022.apk
```

### 3. Upload Play Console:

```
https://play.google.com/console
→ Internal Testing
→ Create Release
→ Upload APK
→ Preencher release notes
→ Start Rollout
```

---

## 📁 ESTRUTURA DE ARQUIVOS

```
brawe-app/
├── BUILD_ANALYZER.sh                        ← Validação
├── BUILD_RELEASE_APK.sh                     ← Geração APK
├── CHECKLIST_ANTES_UPLOAD_PLAY_CONSOLE.md   ← Checklist
├── GERAR_APK_RELEASE_PASSO_A_PASSO.md       ← Guia passo a passo
├── RUN_WITH_LOGS.sh                         ← Tester notificações
├── COMO_VERIFICAR_SE_POPUP_FOI_PEDIDO.md    ← Diagnóstico notificações
├── README_BUILD_RELEASE.md                  ← Este arquivo
│
├── releases/                                 ← Backups das APKs
│   └── Brawe-1.0.30-20240716-143022.apk
│
├── lib/
│   └── data/services/
│       └── push_notification_service.dart   ← Logs adicionados ✅
│
├── android/
│   ├── app/
│   │   ├── google-services.json             ← Firebase Android
│   │   └── src/main/AndroidManifest.xml     ← Permissões
│   └── app/build.gradle                     ← Configuração
│
├── ios/
│   ├── Runner/
│   │   ├── GoogleService-Info.plist         ← Firebase iOS
│   │   ├── Info.plist                       ← Configuração iOS
│   │   └── Runner.entitlements              ← Capabilities
│
└── pubspec.yaml                             ← Versão definida
```

---

## ✅ VERIFICAÇÕES AUTOMATIZADAS

BUILD_ANALYZER.sh verifica:

```
CHECK 1️⃣  - pubspec.yaml (versão, dependências)
CHECK 2️⃣  - AndroidManifest.xml (permissões)
CHECK 3️⃣  - build.gradle (SDKs, versions)
CHECK 4️⃣  - Firebase (google-services.json)
CHECK 5️⃣  - PushNotificationService (logs, requestPermission)
CHECK 6️⃣  - iOS Config (Info.plist, entitlements)
CHECK 7️⃣  - Dart Analysis (flutter analyze)
CHECK 8️⃣  - Dependências (pub outdated)
CHECK 9️⃣  - Assets & Resources
CHECK 🔟 - Signing Configuration
```

**Resultado:** ✅ Tudo OK → Pronto para Build

---

## 🚀 COMANDO PRINCIPAL

### Build Automático (Recomendado):

```bash
bash BUILD_RELEASE_APK.sh
```

Isso faz:
1. ✅ Valida tudo (BUILD_ANALYZER)
2. ✅ flutter clean
3. ✅ flutter pub get
4. ✅ flutter build apk --release
5. ✅ Gera checksums
6. ✅ Salva backup
7. ✅ Mostra resumo final

### Build Manual (Passo a Passo):

```bash
flutter clean
flutter pub get
flutter build apk --release --verbose
```

---

## 📊 RESULTADO ESPERADO

Após executar `BUILD_RELEASE_APK.sh`:

```
════════════════════════════════════════════════════════════════
🎉 APK RELEASE PRONTO!
════════════════════════════════════════════════════════════════

📍 Caminho: build/app/outputs/apk/release/app-release.apk
📊 Tamanho: 75.3M (aprox 75MB)
📦 Versão: 1.0.30+30

🚀 Próximos passos:
   1. Faça upload no Google Play Console
   2. Menu: Internal Testing → Create Release
   3. Selecione APK e configure release notes
   4. Clique 'Review Release' e depois 'Start Rollout'

💾 Salvando cópia em releases/
✅ Cópia salva: releases/Brawe-1.0.30-20240716-143022.apk

🔐 Checksums (para verificação):
SHA256: abc123def456...
MD5: xyz789...
```

---

## ⏱️ TEMPO ESTIMADO

| Fase | Tempo |
|------|-------|
| BUILD_ANALYZER | 2-3 min |
| flutter clean | 1 min |
| flutter pub get | 1-2 min |
| flutter build apk | 5-15 min |
| **Total** | **10-25 min** |

**Tempo total:** 10-25 minutos (dependendo do device)

---

## 🎯 PRÓXIMAS ETAPAS

### Após gerar APK:

1. **Testar (Opcional mas Recomendado)**
   ```bash
   adb install -r build/app/outputs/apk/release/app-release.apk
   ```

2. **Upload Play Console**
   - Ir para https://play.google.com/console
   - Internal Testing → Create Release
   - Upload: `app-release.apk`
   - Release Notes: Preencher em português

3. **Start Rollout**
   - Internal Testing (100% de testers)
   - Aguardar 15-30 min
   - Testers conseguem baixar

4. **Monitorar** (1 semana)
   - Crashes: deve estar ~0
   - Reviews: ler feedback
   - Performance: tudo OK?

5. **Expandir**
   - Beta Testing (50% de usuários)
   - Production (100% de usuários)

---

## 📱 NOTIFICAÇÕES - IMPORTANTE!

Este sistema inclui melhorias em notificações push:

### O que foi adicionado:

✅ **Logs detalhados** em `push_notification_service.dart`
- `🔔 Permission status: granted/denied/notDetermined`
- `✅ User GRANTED notification permission!`
- `❌ User DENIED notification permission!`

✅ **Firebase configurado** (iOS + Android)
✅ **APNs keys** no Firebase Console
✅ **Backend endpoint** `/devices/register` funciona

### Como testar:

1. Abrir app recém-instalado
2. Popup "Permitir notificações?" → Clique [Allow]
3. Settings → Notifications → Brawe (deve estar ON)
4. Enviar notificação via Firebase/backend
5. Deve receber mesmo com app fechado

---

## 🔐 SEGURANÇA

✅ **APK será assinada automaticamente**
- Tipo: RSA 2048-bit
- Válida por: muitos anos

✅ **Nenhuma informação sensível**
- Firebase keys (públicas)
- Nenhuma senha/token hardcoded

✅ **Permissões mínimas necessárias**
- INTERNET
- POST_NOTIFICATIONS (Android 13+)
- RECEIVE_BOOT_COMPLETED (opcional)

---

## 🆘 TROUBLESHOOTING

### Build falha?

```bash
flutter clean
flutter pub get
flutter build apk --release -vvv  # Mais detalhes
```

### APK muito grande?

```bash
flutter build apk --release --split-per-abi
# Gera uma APK por arquitectura (menor size)
```

### Erro de versão no Play Console?

```bash
# Incrementar version code em pubspec.yaml
version: 1.0.30+31  # +31 ao invés de +30
```

### Notificações não funcionam?

```bash
# Verificar logs com:
bash RUN_WITH_LOGS.sh

# Procure por:
# 🔔 Permission status: granted
# ✅ registerWithBackend: Successfully registered!
```

---

## 📚 DOCUMENTAÇÃO RELACIONADA

- **SOLUCAO_APP_NAO_APARECE_NOTIFICACOES.md** - Solução para notificações não aparecerem
- **QUICK_FIX_CHECKLIST.md** - Checklist rápido
- **COMO_VERIFICAR_SE_POPUP_FOI_PEDIDO.md** - Diagnosticar popup de permissão
- **FIX_iOS_NOTIFICATION_PERMISSIONS.md** - Troubleshooting iOS

---

## 🎉 TUDO PRONTO!

Você tem agora:

✅ **BUILD_ANALYZER.sh** - Validação completa
✅ **BUILD_RELEASE_APK.sh** - Geração automatizada
✅ **Documentação completa** - Guias passo a passo
✅ **Sistema de backup** - Releases com timestamp
✅ **Notificações melhoradas** - Logs detalhados
✅ **Firebase configurado** - iOS + Android

## 🚀 PRÓXIMO PASSO

```bash
bash BUILD_RELEASE_APK.sh
```

**Bom sucesso! 🎉**

---

**Versão:** 1.0  
**Data:** 2024  
**Status:** ✅ Pronto para Produção  
**Build System Version:** 1.0  

