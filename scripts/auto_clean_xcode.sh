#!/bin/bash

###############################################################################
#                                                                             #
#  🧹 AUTO CLEAN XCODE CACHE - Solução Inteligente Automática               #
#                                                                             #
#  Este script limpa automaticamente os caches obsoletos do Xcode            #
#  e garante que as configurações do projeto sejam sempre lidas corretamente #
#                                                                             #
#  USO:                                                                       #
#    ./scripts/auto_clean_xcode.sh                                           #
#                                                                             #
#  OU adicione a um Git Hook para executar automaticamente                   #
#                                                                             #
###############################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XCODE_CACHES_DIR="$HOME/Library/Developer/Xcode"
XCODE_PREFS_DIR="$HOME/Library/Preferences"
SPM_CACHE_DIR="$HOME/.swiftpm"
IOS_DIR="$PROJECT_DIR/ios"
START_TIME=$(date +%s)

# Função para logging
log_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

# Função para calcular tempo decorrido
elapsed_time() {
    END_TIME=$(date +%s)
    echo $((END_TIME - START_TIME))
}

# Header
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          🧹 AUTO CLEAN XCODE CACHE - Limpeza Automática       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 1. Detectar se Xcode está aberto
log_info "Verificando se Xcode está aberto..."
if pgrep -q Xcode; then
    log_warning "Xcode está aberto! Fechando..."
    pkill -9 Xcode 2>/dev/null || true
    sleep 2
    log_success "Xcode fechado"
else
    log_success "Xcode não está aberto"
fi

echo ""

# 2. Limpeza de Derived Data
log_info "Limpando Derived Data..."
if [ -d "$XCODE_CACHES_DIR/DerivedData" ]; then
    DERIVED_SIZE=$(du -sh "$XCODE_CACHES_DIR/DerivedData" 2>/dev/null | cut -f1)
    rm -rf "$XCODE_CACHES_DIR/DerivedData"/*
    log_success "Derived Data limpo ($DERIVED_SIZE liberados)"
else
    log_success "Derived Data já está vazio"
fi

# 3. Limpeza de Archives
log_info "Limpando Archives..."
if [ -d "$XCODE_CACHES_DIR/Archives" ]; then
    ARCHIVES_SIZE=$(du -sh "$XCODE_CACHES_DIR/Archives" 2>/dev/null | cut -f1)
    rm -rf "$XCODE_CACHES_DIR/Archives"/*
    log_success "Archives limpo ($ARCHIVES_SIZE liberados)"
else
    log_success "Archives já está vazio"
fi

# 4. Limpeza de Caches gerais
log_info "Limpando caches gerais do Xcode..."
if [ -d "$XCODE_CACHES_DIR/Caches" ]; then
    CACHE_SIZE=$(du -sh "$XCODE_CACHES_DIR/Caches" 2>/dev/null | cut -f1)
    rm -rf "$XCODE_CACHES_DIR/Caches"/*
    log_success "Caches gerais limpos ($CACHE_SIZE liberados)"
else
    log_success "Caches gerais já estão vazios"
fi

# 5. Limpeza de preferências do Xcode
log_info "Resetando preferências do Xcode..."
if [ -f "$XCODE_PREFS_DIR/com.apple.dt.Xcode.plist" ]; then
    rm -f "$XCODE_PREFS_DIR/com.apple.dt.Xcode.plist"
    log_success "Preferências do Xcode resetadas"
else
    log_success "Preferências do Xcode já estão limpas"
fi

# 6. Limpeza de Swift Package Manager
log_info "Limpando SPM cache..."
if [ -d "$SPM_CACHE_DIR" ]; then
    SPM_SIZE=$(du -sh "$SPM_CACHE_DIR" 2>/dev/null | cut -f1)
    rm -rf "$SPM_CACHE_DIR"
    log_success "SPM cache limpo ($SPM_SIZE liberados)"
else
    log_success "SPM cache já está vazio"
fi

echo ""

# 7. iOS - Limpar Pods e Podfile.lock
log_info "Limpando dependências iOS..."
if [ -d "$IOS_DIR/Pods" ]; then
    PODS_SIZE=$(du -sh "$IOS_DIR/Pods" 2>/dev/null | cut -f1)
    rm -rf "$IOS_DIR/Pods"
    log_success "Pods removido ($PODS_SIZE liberados)"
else
    log_success "Pods já está vazio"
fi

if [ -f "$IOS_DIR/Podfile.lock" ]; then
    rm -f "$IOS_DIR/Podfile.lock"
    log_success "Podfile.lock removido"
else
    log_success "Podfile.lock já foi removido"
fi

echo ""

# 8. Deintegrate CocoaPods
log_info "Deintegrando CocoaPods..."
cd "$IOS_DIR"
pod deintegrate 2>/dev/null || true
log_success "CocoaPods deintegrado"

echo ""

# 9. Reinstalar CocoaPods
log_info "Reinstalando CocoaPods (isso pode levar um tempo)..."
cd "$IOS_DIR"
pod install --repo-update 2>&1 | grep -E "^(Pod installation|Installing)" | tail -5
log_success "CocoaPods reinstalado com sucesso"

echo ""

# 10. Flutter clean
log_info "Executando Flutter clean..."
cd "$PROJECT_DIR"
flutter clean > /dev/null 2>&1
log_success "Flutter clean concluído"

echo ""

# 11. Flutter pub get
log_info "Executando Flutter pub get..."
cd "$PROJECT_DIR"
flutter pub get > /dev/null 2>&1
log_success "Flutter pub get concluído"

echo ""

# 12. FIX DEFINITIVO: corrigir Package.swift ANTES de abrir o Xcode
# ─────────────────────────────────────────────────────────────────
# BUG CONHECIDO (Flutter 3.44+): `flutter pub get` sempre regera
# ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift
# com `.iOS("13.0")` HARDCODED (darwin.dart:79), mesmo que o projeto seja 15.0+.
# O Xcode resolve os pacotes SPM (Resolve Package Versions) NO MOMENTO em que
# abre o .xcworkspace — ANTES de qualquer Run Script Phase (incluindo o nosso
# fix_spm_deployment_target.sh) ter chance de rodar. Resultado: mesmo com o
# script de Build Phase existente, o Xcode já "trava" a resolução errada e
# mostra erro tipo "firebase-core requires 15.0 but target supports 13.0".
#
# SOLUÇÃO: chamar o MESMO script aqui, direto no terminal, imediatamente
# depois do `flutter pub get` e ANTES de qualquer abertura do Xcode.
# Assim o Package.swift já está correto quando o Xcode for aberto.
log_info "Corrigindo deployment target do Swift Package Manager..."
export IPHONEOS_DEPLOYMENT_TARGET="15.0"
if [ -f "$IOS_DIR/scripts/fix_spm_deployment_target.sh" ]; then
    SRCROOT="$IOS_DIR" bash "$IOS_DIR/scripts/fix_spm_deployment_target.sh" || true
    log_success "Package.swift corrigido para iOS 15.0"
else
    log_warning "fix_spm_deployment_target.sh não encontrado, pulando"
fi

# 13. Limpar cache de resolução SPM que pode ter travado a versão errada
log_info "Limpando cache de resolução do Swift Package Manager..."
rm -rf "$IOS_DIR/Runner.xcworkspace/xcshareddata/swiftpm" 2>/dev/null || true
rm -rf "$IOS_DIR/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" 2>/dev/null || true
rm -rf "$IOS_DIR/.swiftpm" 2>/dev/null || true
log_success "Cache de resolução SPM limpo"

echo ""

# 14. Verificação final
log_info "Verificando configurações..."
PLATFORM_VERSION=$(grep "^platform :ios" "$IOS_DIR/Podfile" | awk '{print $NF}' | tr -d "'" | tr -d "," | tr -d "'")
log_success "iOS Deployment Target (Podfile): $PLATFORM_VERSION"

SPM_PACKAGE="$IOS_DIR/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"
if [ -f "$SPM_PACKAGE" ]; then
    SPM_VERSION=$(grep -oE '\.iOS\("[0-9]+\.[0-9]+"\)' "$SPM_PACKAGE" | head -1)
    log_success "iOS Deployment Target (Package.swift): $SPM_VERSION"
fi

echo ""

# Resumo final
ELAPSED=$(elapsed_time)
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                     ✅ LIMPEZA CONCLUÍDA!                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
log_success "Tempo total: ${ELAPSED}s"
echo ""
echo "📝 Próximos passos:"
echo "   1. Abra o Xcode:     open $IOS_DIR/Runner.xcworkspace"
echo "   2. Clean Build:      Product → Clean Build Folder"
echo "   3. Build:            Product → Build"
echo ""
