#!/bin/bash

###############################################################################
# 🚀 Script para Iniciar o App Brawe Localmente
# 
# Uso: ./start-app.sh [uuid_simulador]
# 
# Exemplos:
#   ./start-app.sh                                    (usa iPhone 17 Pro Max por padrão)
#   ./start-app.sh "F2522C76-152F-4F1A-AAD4-85191C450EB8"  (usa iPhone 17 Pro)
#
# UUIDs disponíveis:
#   - iPhone 17 Pro Max: 9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B
#   - iPhone 17 Pro:     F2522C76-152F-4F1A-AAD4-85191C450EB8
#   - iPhone 17:         B850A910-0B97-45FE-8DA8-CBDB778461EF
#   - iPhone Air:        FFBD1BD2-EA3D-41ED-BA19-75B32A346882
#   - iPhone 16e:        F5F732BF-E2D9-4301-B32C-44B90E53290C
#
###############################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
PROJECT_DIR="/Users/josecarlosmartins/Documents/developer/brawe-app"
DEFAULT_SIMULATOR_UUID="9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"
DEFAULT_SIMULATOR_NAME="iPhone 17 Pro Max"
SIMULATOR_UUID="${1:-$DEFAULT_SIMULATOR_UUID}"

# Função para imprimir com cores
print_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
}

print_info() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Início do script
print_header "🚀 Iniciando App Brawe"

# Step 1: Verificar se estamos no diretório correto
print_info "Navegando para: $PROJECT_DIR"
if ! cd "$PROJECT_DIR"; then
    print_error "Falha ao navegar para $PROJECT_DIR"
    exit 1
fi

# Step 2: Verificar se pubspec.yaml existe
if [ ! -f "pubspec.yaml" ]; then
    print_error "Arquivo pubspec.yaml não encontrado em $PROJECT_DIR"
    exit 1
fi
print_info "Projeto encontrado em: $(pwd)"

# Step 3: Obter dependências
print_header "📦 Obtendo Dependências"
echo "Executando: flutter pub get"
if flutter pub get > /dev/null 2>&1; then
    print_info "Dependências obtidas com sucesso"
else
    print_warn "Houve um aviso ao obter dependências, mas continuando..."
fi

# Step 4: Verificar se o simulador está disponível
print_header "📱 Verificando Simulador"
if xcrun simctl list devices | grep -q "$SIMULATOR_UUID"; then
    SIMULATOR_INFO=$(xcrun simctl list devices available | grep "$SIMULATOR_UUID")
    print_info "Simulador encontrado: $SIMULATOR_INFO"
else
    print_error "Simulador com UUID $SIMULATOR_UUID não encontrado"
    echo ""
    echo "Simuladores disponíveis:"
    xcrun simctl list devices available | grep -i "iPhone" | sed 's/^/  /'
    exit 1
fi

# Step 5: Iniciar o simulador
print_header "🔧 Iniciando Simulador"
echo "Executando: xcrun simctl boot $SIMULATOR_UUID"
if xcrun simctl boot "$SIMULATOR_UUID" 2>/dev/null; then
    print_info "Simulador iniciado com sucesso"
    sleep 3  # Aguardar um pouco para o simulador ficar pronto
else
    # Se o simulador já estava ligado, xcrun retorna erro, mas isso é ok
    if xcrun simctl list | grep "$SIMULATOR_UUID" | grep -q "(Booted)"; then
        print_info "Simulador já estava ligado"
    else
        print_warn "Houve um aviso ao iniciar o simulador, continuando..."
    fi
fi

# Step 6: Abrir a janela do Simulator
print_header "🖥️ Abrindo Janela do Simulator"
echo "Executando: open -a 'Simulator'"
open -a "Simulator" &
print_info "Janela do Simulator aberta em background"
sleep 2

# Step 7: Executar Flutter
print_header "🚀 Executando App Flutter"
echo ""
echo "Executando: flutter run -d $SIMULATOR_UUID"
echo ""
echo -e "${YELLOW}Dicas durante a execução:${NC}"
echo "  r  - Hot reload (recarrega o código)"
echo "  R  - Hot restart (reinicia a app)"
echo "  q  - Quit (sair)"
echo "  d  - Detach (desanexar do debugger)"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
echo ""

# Executar flutter run
flutter run -d "$SIMULATOR_UUID"

# Se chegou aqui, significa que o flutter run foi encerrado
print_header "✅ Script Finalizado"
print_info "App foi encerrada"
