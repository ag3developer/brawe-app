#!/bin/bash

###############################################################################
#                                                                             #
#  🔧 SETUP GIT HOOKS - Configuração Automática                             #
#                                                                             #
#  Este script configura os Git Hooks para limpeza automática de cache       #
#                                                                             #
#  USO:                                                                       #
#    ./scripts/setup_git_hooks.sh                                            #
#                                                                             #
###############################################################################

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GIT_HOOKS_DIR="$PROJECT_DIR/.githooks"
GIT_CONFIG_DIR="$PROJECT_DIR/.git"

echo ""
echo "${BLUE}🔧 Configurando Git Hooks...${NC}"
echo ""

# 1. Criar diretório de hooks se não existir
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    mkdir -p "$GIT_HOOKS_DIR"
    echo "📁 Diretório .githooks criado"
fi

# 2. Configurar Git para usar o diretório de hooks customizado
echo "⚙️  Configurando Git..."
git config core.hooksPath "$GIT_HOOKS_DIR"

# 3. Tornar scripts executáveis
chmod +x "$GIT_HOOKS_DIR/post-merge" 2>/dev/null || true
chmod +x "$GIT_HOOKS_DIR/post-checkout" 2>/dev/null || true
chmod +x "$PROJECT_DIR/scripts/auto_clean_xcode.sh"

echo "${GREEN}✅ Git Hooks configurados com sucesso!${NC}"
echo ""
echo "📋 Hooks ativados:"
echo "   • post-merge  → Executa após git pull/merge"
echo "   • post-checkout → Executa após git checkout"
echo ""
echo "🎯 O que acontece automaticamente:"
echo "   • Detecta mudanças em pubspec.yaml ou Podfile"
echo "   • Limpa caches obsoletos do Xcode"
echo "   • Reinstala dependências"
echo "   • Garante que Xcode sempre lê a configuração correta"
echo ""
echo "💡 Para testar manualmente:"
echo "   ./scripts/auto_clean_xcode.sh"
echo ""
