#!/bin/bash

# ============================================================================
# BUILD_RELEASE_APK.sh - Constrói APK Release para Play Console
# ============================================================================

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║         🚀 BUILD RELEASE APK - PLAY CONSOLE                       ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# STEP 1: Verificar Build Analyzer
# ============================================================================
echo ""
echo "🔍 STEP 1/6: Rodando Build Analyzer..."
echo "════════════════════════════════════════════════════════════════════"

if [ -f "BUILD_ANALYZER.sh" ]; then
    if bash BUILD_ANALYZER.sh; then
        echo -e "${GREEN}✅ Build Analyzer passou!${NC}"
    else
        echo -e "${RED}❌ Build Analyzer falhou. Corrija os problemas antes de continuar.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  BUILD_ANALYZER.sh não encontrado. Pulando verificação.${NC}"
fi

# ============================================================================
# STEP 2: Flutter Clean
# ============================================================================
echo ""
echo "🧹 STEP 2/6: Limpando build anterior..."
echo "════════════════════════════════════════════════════════════════════"
flutter clean
echo -e "${GREEN}✅ Build limpo${NC}"

# ============================================================================
# STEP 3: Pub Get
# ============================================================================
echo ""
echo "📦 STEP 3/6: Obtendo dependências..."
echo "════════════════════════════════════════════════════════════════════"
flutter pub get
echo -e "${GREEN}✅ Dependências obtidas${NC}"

# ============================================================================
# STEP 4: Verificar versão
# ============================================================================
echo ""
echo "📝 STEP 4/6: Verificando versão..."
echo "════════════════════════════════════════════════════════════════════"

VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
echo -e "${BLUE}Versão: $VERSION${NC}"

# ============================================================================
# STEP 5: Gerar APK Release (bundle seria ideal, mas APK para teste)
# ============================================================================
echo ""
echo "🏗️  STEP 5/6: Construindo APK Release..."
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}Isso pode levar 5-15 minutos...${NC}"
echo ""

flutter build apk --release --verbose

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ APK construído com sucesso!${NC}"
else
    echo -e "${RED}❌ Falha ao construir APK${NC}"
    exit 1
fi

# ============================================================================
# STEP 6: Verificar output
# ============================================================================
echo ""
echo "✅ STEP 6/6: Finalizando..."
echo "════════════════════════════════════════════════════════════════════"

APK_PATH="build/app/outputs/apk/release/app-release.apk"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    APK_SIZE_BYTES=$(ls -lah "$APK_PATH" | awk '{print $5}')
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎉 APK RELEASE PRONTO!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "📍 Caminho: $APK_PATH"
    echo "📊 Tamanho: $APK_SIZE ($APK_SIZE_BYTES)"
    echo "📦 Versão: $VERSION"
    echo ""
    echo "🚀 Próximos passos:"
    echo "   1. Faça upload no Google Play Console"
    echo "   2. Menu: Internal Testing → Create Release"
    echo "   3. Selecione APK e configure release notes"
    echo "   4. Clique 'Review Release' e depois 'Start Rollout'"
    echo ""
    echo "📱 Testar em Device:"
    echo "   adb install -r $APK_PATH"
    echo ""
else
    echo -e "${RED}❌ APK não encontrado em: $APK_PATH${NC}"
    exit 1
fi

# ============================================================================
# Opcional: Criar cópia em diretório de releases
# ============================================================================
echo ""
echo "💾 Salvando cópia em releases/"
echo "════════════════════════════════════════════════════════════════════"

RELEASES_DIR="releases"
mkdir -p "$RELEASES_DIR"

RELEASE_NAME="Brawe-${VERSION}-$(date +%Y%m%d-%H%M%S).apk"
cp "$APK_PATH" "$RELEASES_DIR/$RELEASE_NAME"

echo -e "${GREEN}✅ Cópia salva: $RELEASES_DIR/$RELEASE_NAME${NC}"

# ============================================================================
# Resumo de checksums
# ============================================================================
echo ""
echo "🔐 Checksums (para verificação):"
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "SHA256:"
shasum -a 256 "$APK_PATH"
echo ""
echo "MD5:"
md5 "$APK_PATH"
echo ""

echo -e "${GREEN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ BUILD COMPLETO!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════════${NC}"
