#!/bin/bash
# ============================================================================
# CHECK iOS NOTIFICATION SETUP
# ============================================================================
# Verifica se todos os arquivos e configurações estão corretos

PROJECT_PATH="/Users/josecarlosmartins/Documents/developer/brawe-app"
IOS_PATH="$PROJECT_PATH/ios/Runner"

echo ""
echo "================================================================================"
echo "🔔 iOS NOTIFICATION SETUP CHECKER"
echo "================================================================================"
echo ""

# Check 1: Info.plist tem remote-notification?
echo "CHECK 1️⃣: Info.plist"
echo "--------------------------------------------------------------------------------"
if grep -q "remote-notification" "$IOS_PATH/Info.plist"; then
    echo "✅ remote-notification encontrado em Info.plist"
else
    echo "❌ remote-notification NÃO encontrado em Info.plist"
    echo "   Adicione em Info.plist:"
    echo "   <key>UIBackgroundModes</key>"
    echo "   <array>"
    echo "       <string>remote-notification</string>"
    echo "   </array>"
fi
echo ""

# Check 2: RunnerDebug.entitlements
echo "CHECK 2️⃣: RunnerDebug.entitlements (Development)"
echo "--------------------------------------------------------------------------------"
if [ -f "$IOS_PATH/RunnerDebug.entitlements" ]; then
    if grep -q "aps-environment" "$IOS_PATH/RunnerDebug.entitlements"; then
        echo "✅ aps-environment encontrado"
        if grep -q "development" "$IOS_PATH/RunnerDebug.entitlements"; then
            echo "✅ aps-environment = development (CORRETO)"
        else
            echo "⚠️  aps-environment não é 'development'"
        fi
    else
        echo "❌ aps-environment NÃO encontrado"
        echo "   Adicione:"
        echo "   <key>aps-environment</key>"
        echo "   <string>development</string>"
    fi
else
    echo "⚠️  Arquivo não encontrado: RunnerDebug.entitlements"
fi
echo ""

# Check 3: Runner.entitlements (Production)
echo "CHECK 3️⃣: Runner.entitlements (Production)"
echo "--------------------------------------------------------------------------------"
if [ -f "$IOS_PATH/Runner.entitlements" ]; then
    if grep -q "aps-environment" "$IOS_PATH/Runner.entitlements"; then
        echo "✅ aps-environment encontrado"
        if grep -q "production" "$IOS_PATH/Runner.entitlements"; then
            echo "✅ aps-environment = production (CORRETO)"
        else
            echo "⚠️  aps-environment não é 'production'"
        fi
    else
        echo "❌ aps-environment NÃO encontrado"
        echo "   Adicione:"
        echo "   <key>aps-environment</key>"
        echo "   <string>production</string>"
    fi
else
    echo "⚠️  Arquivo não encontrado: Runner.entitlements"
fi
echo ""

# Check 4: GoogleService-Info.plist
echo "CHECK 4️⃣: GoogleService-Info.plist"
echo "--------------------------------------------------------------------------------"
if [ -f "$IOS_PATH/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist encontrado"
    
    # Verificar BUNDLE_ID
    if grep -q "BUNDLE_ID" "$IOS_PATH/GoogleService-Info.plist"; then
        BUNDLE_ID=$(grep -A 1 "BUNDLE_ID" "$IOS_PATH/GoogleService-Info.plist" | tail -1 | sed 's/<string>//;s/<\/string>//')
        echo "   Bundle ID: $BUNDLE_ID"
    fi
    
    # Verificar PROJECT_ID
    if grep -q "PROJECT_ID" "$IOS_PATH/GoogleService-Info.plist"; then
        PROJECT_ID=$(grep -A 1 "PROJECT_ID" "$IOS_PATH/GoogleService-Info.plist" | tail -1 | sed 's/<string>//;s/<\/string>//')
        echo "   Project ID: $PROJECT_ID"
    fi
else
    echo "❌ GoogleService-Info.plist NÃO encontrado"
    echo "   Ações:"
    echo "   1. Abra Firebase Console"
    echo "   2. Project Settings"
    echo "   3. Download GoogleService-Info.plist"
    echo "   4. Arraste para Xcode (Runner folder)"
fi
echo ""

# Check 5: PushNotificationService.init() está sendo chamado?
echo "CHECK 5️⃣: PushNotificationService - Verificando se init() é chamado"
echo "--------------------------------------------------------------------------------"
if grep -r "PushNotificationService" "$PROJECT_PATH/lib" --include="*.dart" | grep -q "init"; then
    echo "✅ PushNotificationService.init() encontrado no código"
    
    # Mostrar onde é chamado
    echo "   Chamado em:"
    grep -r "\.init()" "$PROJECT_PATH/lib" --include="*.dart" | grep -i notification | head -3
else
    echo "❌ PushNotificationService.init() NÃO está sendo chamado"
    echo "   Adicione em main.dart ou startup do app:"
    echo "   await pushNotificationService.init();"
fi
echo ""

# Check 6: Firebase.initializeApp() está sendo chamado?
echo "CHECK 6️⃣: Firebase Initialization"
echo "--------------------------------------------------------------------------------"
if grep -r "Firebase.initializeApp" "$PROJECT_PATH/lib" --include="*.dart" | grep -q "await"; then
    echo "✅ Firebase.initializeApp() encontrado"
else
    echo "⚠️  Firebase.initializeApp() verificação"
    echo "   Procure em main.dart por:"
    echo "   await Firebase.initializeApp()"
fi
echo ""

# Check 7: requestPermission() está implementado?
echo "CHECK 7️⃣: requestPermission() Implementation"
echo "--------------------------------------------------------------------------------"
if grep -r "requestPermission" "$PROJECT_PATH/lib" --include="*.dart" | grep -q "FirebaseMessaging"; then
    echo "✅ requestPermission() encontrado"
    
    # Verificar os parâmetros
    if grep -r "alert.*true" "$PROJECT_PATH/lib" --include="*.dart" | grep -q "requestPermission"; then
        echo "✅ alert: true"
    fi
    if grep -r "badge.*true" "$PROJECT_PATH/lib" --include="*.dart" | grep -q "requestPermission"; then
        echo "✅ badge: true"
    fi
    if grep -r "sound.*true" "$PROJECT_PATH/lib" --include="*.dart" | grep -q "requestPermission"; then
        echo "✅ sound: true"
    fi
else
    echo "❌ requestPermission() NÃO encontrado"
    echo "   Adicione em PushNotificationService:"
    echo "   await FirebaseMessaging.instance.requestPermission("
    echo "     alert: true,"
    echo "     badge: true,"
    echo "     sound: true,"
    echo "   );"
fi
echo ""

echo "================================================================================"
echo "✅ CHECK COMPLETO"
echo "================================================================================"
echo ""
echo "Próximos passos:"
echo "1. Se há ❌ items acima, corrija-os"
echo "2. Limpe build: flutter clean"
echo "3. Desinstale app do iPhone"
echo "4. Rebuild: flutter run"
echo "5. Quando pedir permissão → clique [Allow]"
echo "6. Verifique em Settings → Notifications"
echo ""
