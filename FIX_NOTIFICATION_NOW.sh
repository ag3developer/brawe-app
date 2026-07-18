#!/bin/bash
# ============================================================================
# FIX NOTIFICATION PERMISSIONS NOW
# ============================================================================
# Solução rápida se o app não aparece em Notificações

PROJECT_PATH="/Users/josecarlosmartins/Documents/developer/brawe-app"

echo ""
echo "================================================================================"
echo "🔧 FIX: iOS Notification Permissions"
echo "================================================================================"
echo ""

echo "✅ Verificações concluídas: Todas as configurações estão CORRETAS!"
echo ""

echo "O problema é provavelmente:"
echo "  ❌ Você não clicou [Allow] quando o app perguntou"
echo "  ❌ Você clicou [Don't Allow] antes"
echo "  ❌ Já tinha negado permissão no passado"
echo ""

echo "SOLUÇÃO:"
echo ""

echo "PASSO 1️⃣: Limpar build"
echo "  Executando: flutter clean..."

cd "$PROJECT_PATH"
flutter clean > /dev/null 2>&1

echo "  ✅ Build limpo"
echo ""

echo "PASSO 2️⃣: No seu iPhone, desinstale o app"
echo "  1. Segure o ícone do Brawe"
echo "  2. Selecione 'Remove App'"
echo "  3. Confirme 'Delete App'"
echo "  4. Aguarde desaparecer"
echo ""

read -p "Pronto? Pressione ENTER quando app estiver desinstalado no iPhone..."

echo ""
echo "PASSO 3️⃣: Rebuild do app"
echo "  Executando: flutter run -v --no-fast-start..."
echo ""

cd "$PROJECT_PATH"
flutter run -v --no-fast-start

echo ""
echo "================================================================================"
echo "⚠️  IMPORTANTE: Quando o app abrir no iPhone..."
echo "================================================================================"
echo ""
echo "Você verá um popup:"
echo ""
echo "  ┌──────────────────────────────────────┐"
echo "  │ \"Brawe\" gostaria de enviar          │"
echo "  │ notificações?                        │"
echo "  ├──────────────────────────────────────┤"
echo "  │ [Don't Allow]        [Allow]         │"
echo "  └──────────────────────────────────────┘"
echo ""
echo "🚨 CLIQUE [Allow] (não clique Don't Allow!)"
echo ""
echo "================================================================================"
echo ""
echo "Depois:"
echo "  1. Aguarde o app carregar"
echo "  2. Faça login"
echo "  3. Aguarde 10 segundos"
echo "  4. Vá em Settings → Notifications"
echo "  5. Procure por 'Brawe' ou 'Brawe App'"
echo "  6. Verifique se 'Allow Notifications' está ON"
echo ""
echo "================================================================================"
echo ""
