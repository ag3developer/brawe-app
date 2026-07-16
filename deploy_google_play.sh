#!/bin/bash

# Script para fazer upload do AAB para Google Play Console
# Requer: bundletool (download em https://github.com/google/bundletool/releases)

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build/app/outputs/bundle/release"
AAB_FILE="$BUILD_DIR/app-release.aab"

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════╗"
echo "║  🚀 Brawe — Google Play Console Deploy       ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar se AAB existe
if [ ! -f "$AAB_FILE" ]; then
    echo -e "${RED}❌ ERRO: AAB não encontrado em $AAB_FILE${NC}"
    echo -e "${YELLOW}Execute primeiro: flutter build appbundle --release${NC}"
    exit 1
fi

# Informações do arquivo
AAB_SIZE=$(ls -lh "$AAB_FILE" | awk '{print $5}')
echo -e "${GREEN}✓ AAB encontrado${NC}"
echo "  📦 Arquivo: app-release.aab"
echo "  📊 Tamanho: $AAB_SIZE"
echo ""

# Informações da versão
echo -e "${BLUE}📋 Versão:${NC}"
VERSION=$(grep "^version:" "$PROJECT_DIR/pubspec.yaml" | awk '{print $2}')
echo "  $VERSION"
echo ""

# Instruções
echo -e "${YELLOW}📖 INSTRUÇÕES - Google Play Console:${NC}"
echo ""
echo "1️⃣  Acesse: https://play.google.com/console"
echo "2️⃣  Selecione app: 'Brawe'"
echo "3️⃣  Vá para: Release > Production"
echo "4️⃣  Clique: 'Create new release'"
echo ""
echo -e "${BLUE}5️⃣  Upload do AAB:${NC}"
echo "    • Caminho: $AAB_FILE"
echo "    • Tamanho: $AAB_SIZE"
echo ""
echo -e "${BLUE}6️⃣  Preencha os campos:${NC}"
echo "    • Version Name: $(echo $VERSION | cut -d+ -f1)"
echo "    • Version Code: $(echo $VERSION | cut -d+ -f2)"
echo ""
echo -e "${BLUE}7️⃣  Release Notes (PT-BR):${NC}"
cat << 'EOF'
    ✨ Novidades v1.0.28:
    • Perfil: data de criação real, indicador online em tempo real
    • Posts: exibe texto, fotos e vídeos unificados
    • Vídeos: grid com proporção 3:4, overlay com melhor visibilidade
    • Live: categorias validadas e funcionando na página Explore
    • Correções: navegação após salvar perfil, sincronização de dados
EOF
echo ""
echo -e "${BLUE}8️⃣  Clique: 'Save' > 'Review release' > 'Release to Production'${NC}"
echo ""
echo -e "${GREEN}✅ O app será revisado pelo Google Play em 1-3 horas${NC}"
echo ""
echo -e "${YELLOW}💡 Dica: Você pode copiar o caminho do AAB:${NC}"
echo -e "${GREEN}  $AAB_FILE${NC}"
echo ""
echo -e "${BLUE}📊 Comandos úteis:${NC}"
echo "  • Verificar tamanho: ls -lh \"$AAB_FILE\""
echo "  • Abrir pasta: open \"$BUILD_DIR\""
echo "  • Ver pubspec: cat \"$PROJECT_DIR/pubspec.yaml\" | grep version"
echo ""
