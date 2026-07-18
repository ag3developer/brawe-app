#!/bin/bash

###############################################################################
#                                                                             #
#  🚀 OPEN XCODE - Abre o Xcode SEMPRE com o deployment target correto      #
#                                                                             #
#  PROBLEMA QUE ISSO RESOLVE:                                                #
#    `flutter pub get` regera Package.swift com .iOS("13.0") hardcoded       #
#    (bug conhecido do Flutter 3.44+). O Xcode resolve os pacotes SPM no     #
#    momento em que abre o projeto — ANTES de qualquer Run Script Phase      #
#    rodar. Isso causa o erro:                                               #
#      "firebase-core requires minimum platform version 15.0 but target     #
#       supports 13.0"                                                      #
#    mesmo com o projeto configurado corretamente para iOS 15.0+.            #
#                                                                             #
#  SOLUÇÃO:                                                                   #
#    Este script corrige o Package.swift ANTES de abrir o Xcode, então o    #
#    Xcode nunca vê a versão errada.                                        #
#                                                                             #
#  USO:                                                                       #
#    ./scripts/open_xcode.sh                                                 #
#                                                                             #
###############################################################################

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$PROJECT_DIR/ios"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}ℹ${NC}  Corrigindo deployment target do Swift Package Manager..."
export IPHONEOS_DEPLOYMENT_TARGET="15.0"
if [ -f "$IOS_DIR/scripts/fix_spm_deployment_target.sh" ]; then
    SRCROOT="$IOS_DIR" bash "$IOS_DIR/scripts/fix_spm_deployment_target.sh" || true
fi
echo -e "${GREEN}✅${NC} Package.swift corrigido para iOS 15.0"

echo -e "${BLUE}ℹ${NC}  Abrindo Xcode..."
open "$IOS_DIR/Runner.xcworkspace"
echo -e "${GREEN}✅${NC} Xcode abrindo com configuração correta!"
