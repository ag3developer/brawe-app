#!/usr/bin/env bash
# Remove slices de simulador (x86_64, i386) de frameworks embedados.
# Para frameworks SIMULATOR-ONLY (binário com apenas x86_64), o framework
# é REMOVIDO inteiro do .app, pois não deveria estar no build de device.
#
# Causa raiz: alguns Dart packages (ex.: objective_c) distribuem
# .framework com slice de simulador, e o Xcode não strippa
# automaticamente durante o archive — o que faz a App Store rejeitar
# com "Unsupported Architectures" e "Missing 64-bit support".

set -e

# Só roda em builds de device (não simulator)
if [ "$PLATFORM_NAME" != "iphoneos" ]; then
  echo "[strip] skip — not iphoneos ($PLATFORM_NAME)"
  exit 0
fi

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
FRAMEWORKS_DIR="${APP_PATH}/Frameworks"

if [ ! -d "$FRAMEWORKS_DIR" ]; then
  echo "[strip] no Frameworks dir at $FRAMEWORKS_DIR — skipping"
  exit 0
fi

find "$FRAMEWORKS_DIR" -name '*.framework' -type d | while read -r FRAMEWORK; do
  FRAMEWORK_NAME=$(basename "$FRAMEWORK" .framework)
  BIN="$FRAMEWORK/$FRAMEWORK_NAME"
  [ ! -f "$BIN" ] && continue

  ARCHS=$(lipo -info "$BIN" 2>/dev/null | sed -E 's/.*architectures? (in the fat file: )?[^:]*: //' | tr -s ' ')
  echo "[strip] $FRAMEWORK_NAME archs: $ARCHS"

  HAS_ARM64=$(echo "$ARCHS" | grep -wq "arm64" && echo 1 || echo 0)
  HAS_X86_64=$(echo "$ARCHS" | grep -wq "x86_64" && echo 1 || echo 0)
  HAS_I386=$(echo "$ARCHS" | grep -wq "i386" && echo 1 || echo 0)

  # Caso 1: framework é simulator-only (sem arm64) → REMOVE o framework inteiro
  if [ "$HAS_ARM64" = "0" ]; then
    echo "[strip] ❌ $FRAMEWORK_NAME é SIMULATOR-ONLY (sem arm64) — removendo framework do .app"
    rm -rf "$FRAMEWORK"
    # Também remove de BUILT_PRODUCTS_DIR caso esteja sendo re-embedado
    if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -d "${BUILT_PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework" ]; then
      rm -rf "${BUILT_PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework"
    fi
    # Remove dSYM correspondente (evita "did not include a dSYM" no Upload Symbols)
    if [ -n "$DWARF_DSYM_FOLDER_PATH" ]; then
      DSYM_PATH="${DWARF_DSYM_FOLDER_PATH}/${FRAMEWORK_NAME}.framework.dSYM"
      if [ -d "$DSYM_PATH" ]; then
        echo "[strip] removendo dSYM órfão: $DSYM_PATH"
        rm -rf "$DSYM_PATH"
      fi
    fi
    if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -d "${BUILT_PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework.dSYM" ]; then
      rm -rf "${BUILT_PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework.dSYM"
    fi
    continue
  fi

  # Caso 2: fat binary com arm64 + simulator → strip slices de simulador
  for SIM_ARCH in x86_64 i386; do
    if echo "$ARCHS" | grep -wq "$SIM_ARCH"; then
      echo "[strip] removendo $SIM_ARCH de $FRAMEWORK_NAME"
      lipo -remove "$SIM_ARCH" "$BIN" -output "$BIN" || {
        echo "[strip] lipo -remove $SIM_ARCH falhou em $FRAMEWORK_NAME — removendo framework"
        rm -rf "$FRAMEWORK"
        break
      }
    fi
  done

  # Gera dSYM para frameworks pré-compilados (ex.: objective_c) que não têm
  # dSYM incluído — sem isso Crashlytics avisa "did not include a dSYM".
  if [ -n "$DWARF_DSYM_FOLDER_PATH" ] && [ -f "$BIN" ]; then
    DSYM_DEST="${DWARF_DSYM_FOLDER_PATH}/${FRAMEWORK_NAME}.framework.dSYM"
    if [ ! -d "$DSYM_DEST" ]; then
      echo "[strip] gerando dSYM para $FRAMEWORK_NAME → $DSYM_DEST"
      xcrun dsymutil "$BIN" -o "$DSYM_DEST" 2>&1 || echo "[strip] dsymutil falhou para $FRAMEWORK_NAME (sem debug info — ignorando)"
    fi
  fi
done

echo "[strip] done"
