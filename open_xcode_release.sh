#!/bin/bash
# Script para abrir o projeto Xcode em modo Release para envio à App Store

set -e

echo "🎬 Abrindo Xcode para submissão à App Store..."
echo ""

# Caminho para o projeto
PROJECT_DIR="/Users/josecarlosmartins/Documents/developer/brawe-app"
XCODE_PROJECT="$PROJECT_DIR/ios/Runner.xcworkspace"

# Verificar se o workspace existe
if [ ! -d "$XCODE_PROJECT" ]; then
    echo "❌ ERRO: Workspace não encontrado em $XCODE_PROJECT"
    echo "Certifique-se de que já rodou: flutter clean && flutter pub get"
    exit 1
fi

echo "📂 Projeto: $XCODE_PROJECT"
echo ""
echo "✅ Abrindo Xcode..."
echo ""

# Abrir Xcode
open "$XCODE_PROJECT"

echo ""
echo "🎯 Próximos passos no Xcode:"
echo "═════════════════════════════════════════════════════════════"
echo ""
echo "1️⃣  Selecione o target 'Runner'"
echo "2️⃣  Selecione 'Any iOS Device (arm64)' no Product > Destination"
echo "3️⃣  Build: Product > Build (ou Cmd+B)"
echo "4️⃣  Archive: Product > Archive"
echo "5️⃣  Distribua: Archives > Distribute App"
echo "   → Select 'App Store Connect'"
echo "   → Siga os passos"
echo ""
echo "═════════════════════════════════════════════════════════════"
echo ""
echo "💡 Dica: Se pedir certificado/provisioning profile, use:"
echo "   • Xcode > Preferences > Accounts"
echo "   • Selecione sua Apple ID"
echo "   • Clique 'Manage Certificates...'"
echo ""
echo "✨ Build concluído! Xcode aberto."
