#!/bin/bash

# ============================================================================
# RUN_WITH_LOGS.sh - Executa app com logs detalhados para notificações
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║   🔔 RUNNING BRAWE APP WITH PUSH NOTIFICATION LOGS                ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "O que vai acontecer:"
echo "  1. App vai desinstalar (se já estiver)"
echo "  2. App vai compilar"
echo "  3. App vai rodar no iPhone"
echo "  4. LOGS VÃO MOSTRAR:"
echo "     - Se popup de permissão foi pedido"
echo "     - Se você clicou [Allow] ou [Don't Allow]"
echo "     - Se token foi registrado no backend"
echo ""
echo "Procure por:"
echo "  ✅ Linhas com: 🔔 (informações)"
echo "  ✅ Linhas com: ✅ (sucesso)"
echo "  ❌ Linhas com: ❌ (erro)"
echo "  ⚠️  Linhas com: ⚠️ (aviso)"
echo ""

# Limpar
echo "🧹 Limpando build anterior..."
flutter clean

# Desinstalar do device
echo ""
echo "📱 Desinstalando app do iPhone..."
flutter uninstall -y 2>/dev/null || true

# Rodar com logs verbosos
echo ""
echo "🚀 Iniciando app com Flutter run (logs verbosos)..."
echo ""
echo "====== FLUTTER RUN LOGS (COM NOTIFICAÇÕES) ======"
echo ""

flutter run -v --no-fast-start | grep -E "(🔔|✅|❌|⚠️|authorizationStatus|Permission|registerWithBackend|token|platform|granted|denied|notDetermined)"

echo ""
echo "====== FIM DOS LOGS ======"
echo ""
echo "Se você viu:"
echo "  ✅ '✅ PushNotificationService: User GRANTED' → Permissão foi autorizada!"
echo "  ❌ '❌ PushNotificationService: User DENIED'  → Permissão foi rejeitada!"
echo "  ⚠️  '⚠️ Permission not determined'             → Nunca foi perguntado!"
echo ""
