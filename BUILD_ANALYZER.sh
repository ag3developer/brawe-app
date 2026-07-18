#!/bin/bash

# ============================================================================
# BUILD_ANALYZER.sh - Analisa se tudo está pronto para APK Release
# ============================================================================

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║        🔍 BUILD ANALYZER - VERIFICAÇÃO COMPLETA PARA RELEASE      ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNINGS=0

# Função para log
check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((CHECKS_WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ============================================================================
# CHECK 1: Verificar pubspec.yaml
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 1️⃣  - PUBSPEC.YAML"
echo "═══════════════════════════════════════════════════════════════════"

if [ -f "pubspec.yaml" ]; then
    check_pass "pubspec.yaml existe"
    
    # Verificar versão
    VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
    if [ ! -z "$VERSION" ]; then
        check_pass "Version definida: $VERSION"
    else
        check_fail "Version não encontrada em pubspec.yaml"
    fi
    
    # Verificar firebase_messaging
    if grep -q "firebase_messaging:" pubspec.yaml; then
        FM_VERSION=$(grep "firebase_messaging:" pubspec.yaml | awk '{print $2}')
        check_pass "firebase_messaging: $FM_VERSION"
    else
        check_fail "firebase_messaging não encontrado"
    fi
    
    # Verificar flutter_local_notifications
    if grep -q "flutter_local_notifications:" pubspec.yaml; then
        FLN_VERSION=$(grep "flutter_local_notifications:" pubspec.yaml | awk '{print $2}')
        check_pass "flutter_local_notifications: $FLN_VERSION"
    else
        check_fail "flutter_local_notifications não encontrado"
    fi
else
    check_fail "pubspec.yaml não encontrado"
fi

# ============================================================================
# CHECK 2: Verificar AndroidManifest.xml
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 2️⃣  - ANDROID MANIFEST"
echo "═══════════════════════════════════════════════════════════════════"

MANIFEST="android/app/src/main/AndroidManifest.xml"

if [ -f "$MANIFEST" ]; then
    check_pass "AndroidManifest.xml encontrado"
    
    # Verificar package name
    if grep -q 'package=' "$MANIFEST"; then
        check_pass "Package name definido"
    else
        check_fail "Package name não encontrado"
    fi
    
    # Verificar permissões de notificação
    if grep -q "POST_NOTIFICATIONS" "$MANIFEST"; then
        check_pass "POST_NOTIFICATIONS permission presente"
    else
        check_warn "POST_NOTIFICATIONS permission não explícita (Android 13+)"
    fi
else
    check_fail "AndroidManifest.xml não encontrado"
fi

# ============================================================================
# CHECK 3: Verificar build.gradle
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 3️⃣  - BUILD.GRADLE"
echo "═══════════════════════════════════════════════════════════════════"

BUILD_GRADLE="android/app/build.gradle"

if [ -f "$BUILD_GRADLE" ]; then
    check_pass "build.gradle encontrado"
    
    # Verificar compileSdkVersion
    if grep -q "compileSdkVersion" "$BUILD_GRADLE"; then
        SDK=$(grep "compileSdkVersion" "$BUILD_GRADLE" | head -1 | awk '{print $NF}')
        if [ "$SDK" -ge 34 ]; then
            check_pass "compileSdkVersion: $SDK (✅ Android 14+)"
        else
            check_warn "compileSdkVersion: $SDK (⚠️ Considere atualizar para 34+)"
        fi
    else
        check_fail "compileSdkVersion não encontrado"
    fi
    
    # Verificar targetSdkVersion
    if grep -q "targetSdkVersion" "$BUILD_GRADLE"; then
        TARGET=$(grep "targetSdkVersion" "$BUILD_GRADLE" | head -1 | awk '{print $NF}')
        if [ "$TARGET" -ge 34 ]; then
            check_pass "targetSdkVersion: $TARGET (✅ Android 14+)"
        else
            check_warn "targetSdkVersion: $TARGET (⚠️ Considere atualizar para 34+)"
        fi
    else
        check_fail "targetSdkVersion não encontrado"
    fi
    
    # Verificar minSdkVersion
    if grep -q "minSdkVersion" "$BUILD_GRADLE"; then
        MIN=$(grep "minSdkVersion" "$BUILD_GRADLE" | head -1 | awk '{print $NF}')
        check_pass "minSdkVersion: $MIN"
    else
        check_fail "minSdkVersion não encontrado"
    fi
else
    check_fail "build.gradle não encontrado"
fi

# ============================================================================
# CHECK 4: Verificar GoogleService (Firebase)
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 4️⃣  - FIREBASE CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════════"

# Android
GS_ANDROID="android/app/google-services.json"
if [ -f "$GS_ANDROID" ]; then
    check_pass "google-services.json (Android) encontrado"
else
    check_fail "google-services.json (Android) não encontrado"
fi

# iOS
GS_IOS="ios/Runner/GoogleService-Info.plist"
if [ -f "$GS_IOS" ]; then
    check_pass "GoogleService-Info.plist (iOS) encontrado"
else
    check_fail "GoogleService-Info.plist (iOS) não encontrado"
fi

# ============================================================================
# CHECK 5: Verificar PushNotificationService
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 5️⃣  - PUSH NOTIFICATION SERVICE"
echo "═══════════════════════════════════════════════════════════════════"

PUSH_SERVICE="lib/data/services/push_notification_service.dart"

if [ -f "$PUSH_SERVICE" ]; then
    check_pass "push_notification_service.dart encontrado"
    
    # Verificar logs
    if grep -q "🔔 PushNotificationService: Requesting" "$PUSH_SERVICE"; then
        check_pass "Logs de permissão adicionados ✅"
    else
        check_warn "Logs de permissão não encontrados"
    fi
    
    # Verificar requestPermission
    if grep -q "requestPermission" "$PUSH_SERVICE"; then
        check_pass "requestPermission() implementado"
    else
        check_fail "requestPermission() não encontrado"
    fi
    
    # Verificar registerWithBackend
    if grep -q "registerWithBackend" "$PUSH_SERVICE"; then
        check_pass "registerWithBackend() implementado"
    else
        check_fail "registerWithBackend() não encontrado"
    fi
else
    check_fail "push_notification_service.dart não encontrado"
fi

# ============================================================================
# CHECK 6: Verificar iOS Configuration
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 6️⃣  - iOS CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════════"

# Info.plist
INFO_PLIST="ios/Runner/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    check_pass "Info.plist encontrado"
    
    if grep -q "remote-notification" "$INFO_PLIST"; then
        check_pass "UIBackgroundModes com remote-notification"
    else
        check_fail "remote-notification não encontrado em Info.plist"
    fi
else
    check_fail "Info.plist não encontrado"
fi

# Runner.entitlements
ENTITLEMENTS="ios/Runner/Runner.entitlements"
if [ -f "$ENTITLEMENTS" ]; then
    check_pass "Runner.entitlements encontrado"
    
    if grep -q "aps-environment" "$ENTITLEMENTS"; then
        APS=$(grep -A1 "aps-environment" "$ENTITLEMENTS" | tail -1 | sed 's/<string>//;s/<\/string>//')
        check_pass "aps-environment: $APS"
    else
        check_fail "aps-environment não encontrado"
    fi
else
    check_fail "Runner.entitlements não encontrado"
fi

# ============================================================================
# CHECK 7: Verificar Dart Analysis
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 7️⃣  - DART ANALYSIS"
echo "═══════════════════════════════════════════════════════════════════"

info "Rodando 'flutter analyze'..."
if flutter analyze --no-pub --no-fatal-infos 2>&1 | grep -q "No issues found"; then
    check_pass "Análise Dart sem erros críticos"
else
    check_warn "Análise Dart pode ter problemas (verificar manualmente)"
fi

# ============================================================================
# CHECK 8: Verificar Dependências
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 8️⃣  - DEPENDÊNCIAS"
echo "═══════════════════════════════════════════════════════════════════"

info "Verificando dependências Flutter..."
if flutter pub outdated --no-color 2>&1 | grep -q "dependencies are all on the latest"; then
    check_pass "Todas as dependências estão atualizadas"
else
    check_warn "Algumas dependências podem ter updates disponíveis"
fi

# ============================================================================
# CHECK 9: Verificar Assets
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 9️⃣  - ASSETS & RESOURCES"
echo "═══════════════════════════════════════════════════════════════════"

if [ -d "assets" ]; then
    ASSET_COUNT=$(find assets -type f | wc -l)
    check_pass "Pasta assets existe com $ASSET_COUNT arquivos"
else
    check_warn "Pasta assets não encontrada"
fi

if [ -d "assets/images" ]; then
    check_pass "Pasta assets/images encontrada"
else
    check_warn "Pasta assets/images não encontrada"
fi

# ============================================================================
# CHECK 10: Verificar Signaturas
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "CHECK 🔟  - SIGNING CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════════"

SIGNING_CONFIG="android/app/build.gradle"
if grep -q "signingConfigs" "$SIGNING_CONFIG"; then
    check_pass "Signing configuration presente"
else
    check_warn "Signing configuration pode estar ausente"
fi

if [ -f "$HOME/.android/debug.keystore" ]; then
    check_pass "Debug keystore encontrado"
else
    check_warn "Debug keystore não encontrado"
fi

# ============================================================================
# RESUMO FINAL
# ============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                          📊 RESUMO FINAL                          ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "✅ Checks Passados:    ${GREEN}$CHECKS_PASSED${NC}"
echo -e "⚠️  Avisos:            ${YELLOW}$CHECKS_WARNINGS${NC}"
echo -e "❌ Checks Falhados:    ${RED}$CHECKS_FAILED${NC}"
echo ""

# Decisão final
if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎉 SUCESSO! Tudo pronto para gerar APK Release!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════${NC}"
    exit 0
else
    echo -e "${RED}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}⚠️  PROBLEMAS ENCONTRADOS! Corrija os erros antes de gerar APK.${NC}"
    echo -e "${RED}════════════════════════════════════════════════════════════════════${NC}"
    exit 1
fi
