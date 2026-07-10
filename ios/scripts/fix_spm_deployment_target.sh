#!/usr/bin/env bash
# fix_spm_deployment_target.sh
#
# Workaround para bug do Flutter 3.44+ com Swift Package Manager:
#
# PROBLEMA:
#   O `flutter pub get` gera FlutterGeneratedPluginSwiftPackage/Package.swift
#   com `.iOS("13.0")` hardcoded (valor em darwin.dart:79).
#   O `flutter build ios` chama `SwiftPackageManager.updateMinimumDeployment()`
#   que atualiza o arquivo para o deployment target real do projeto.
#   Mas o `xcode_backend.dart` (Run Script do Xcode) NÃO chama essa função,
#   então um build iniciado diretamente pelo Xcode usa o Package.swift desatualizado
#   e falha com: "firebase-core requires minimum platform version 15.0 but target supports 13.0"
#
# SOLUÇÃO:
#   Este script é executado como a PRIMEIRA Run Script Phase do target Runner.
#   Ele atualiza o Package.swift com o deployment target real do projeto,
#   replicando o que `updateMinimumDeployment()` faria.
#
# REVERSÃO:
#   Remover esta Run Script Phase do target Runner no Xcode.
#   O comportamento original (com o bug) volta imediatamente.
#
# REFERÊNCIAS:
#   - darwin.dart:79 — iOS deployment target padrão hardcoded: Version(13, 0, null)
#   - swift_package_manager.dart:431 — updateMinimumDeployment (NÃO chamado pelo Xcode)
#   - mac.dart:355 — único ponto onde updateMinimumDeployment é chamado (flutter build)
#   - xcode_backend.dart — script do Xcode, sem nenhuma referência a SwiftPackage

set -euo pipefail

PACKAGE_SWIFT="${SRCROOT}/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"

# Garantir que o arquivo existe
if [[ ! -f "$PACKAGE_SWIFT" ]]; then
  echo "warning: fix_spm_deployment_target.sh: Package.swift não encontrado em $PACKAGE_SWIFT"
  exit 0
fi

# Usar o deployment target do ambiente do Xcode (variável passada pelo Xcode ao script)
TARGET_VERSION="${IPHONEOS_DEPLOYMENT_TARGET:-15.0}"

# Ler o valor atual
CURRENT=$(grep -oE '\.iOS\("[0-9]+\.[0-9]+"\)' "$PACKAGE_SWIFT" | head -1 || echo "")

if [[ -z "$CURRENT" ]]; then
  echo "warning: fix_spm_deployment_target.sh: não encontrou .iOS(...) em $PACKAGE_SWIFT"
  exit 0
fi

# Extrair versão atual
CURRENT_VERSION=$(echo "$CURRENT" | grep -oE '[0-9]+\.[0-9]+')

# Comparar versões (usar sort -V para comparação semântica)
LOWER=$(printf '%s\n' "$CURRENT_VERSION" "$TARGET_VERSION" | sort -V | head -1)

if [[ "$LOWER" == "$TARGET_VERSION" && "$CURRENT_VERSION" != "$TARGET_VERSION" ]]; then
  # Target já é maior ou igual ao atual — não há nada a fazer
  echo "fix_spm_deployment_target.sh: Package.swift já em .iOS(\"$CURRENT_VERSION\") >= $TARGET_VERSION — nada a fazer"
  exit 0
fi

if [[ "$CURRENT_VERSION" == "$TARGET_VERSION" ]]; then
  echo "fix_spm_deployment_target.sh: Package.swift já em .iOS(\"$TARGET_VERSION\") — nada a fazer"
  exit 0
fi

# Atualizar para o deployment target do projeto (IPHONEOS_DEPLOYMENT_TARGET do Xcode)
echo "fix_spm_deployment_target.sh: atualizando .iOS(\"$CURRENT_VERSION\") → .iOS(\"$TARGET_VERSION\")"
LC_ALL=C sed -i '' "s/\.iOS(\"${CURRENT_VERSION}\")/\.iOS(\"${TARGET_VERSION}\")/g" "$PACKAGE_SWIFT"

echo "fix_spm_deployment_target.sh: ✅ Package.swift atualizado para iOS $TARGET_VERSION"
