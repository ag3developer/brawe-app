#!/bin/bash
# =============================================================================
# BRAWE APP — Release APK to Cloudflare R2
# =============================================================================
# Uso:
#   ./scripts/release_apk.sh              → Build + upload (release)
#   ./scripts/release_apk.sh --upload-only → Apenas upload do APK existente
#   ./scripts/release_apk.sh --build-only  → Apenas build (sem upload)
#
# Credenciais R2: adicione um arquivo .env.r2 na raiz do projeto:
#   R2_ACCESS_KEY_ID=sua_key
#   R2_SECRET_ACCESS_KEY=seu_secret
#
# Ou exporte as variáveis antes de chamar o script:
#   export R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=... && ./scripts/release_apk.sh
# =============================================================================

set -e

# ── Cores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NC='\033[0m'
log()  { echo -e "${BLUE}[release]${NC} $1"; }
ok()   { echo -e "${GREEN}[  ✅  ]${NC} $1"; }
warn() { echo -e "${YELLOW}[  ⚠️  ]${NC} $1"; }
err()  { echo -e "${RED}[  ❌  ]${NC} $1"; exit 1; }

# ── Config R2 ──────────────────────────────────────────────────────────────
R2_ENDPOINT="https://bdde56b8577854fbb26253f4cdd89771.r2.cloudflarestorage.com"
R2_BUCKET="brawe-media"
CDN_BASE="https://cdn.brawe.io"

# ── Carregar .env.r2 se existir ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env.r2"

if [[ -f "$ENV_FILE" ]]; then
  set -a && source "$ENV_FILE" && set +a
  log "Credenciais carregadas de .env.r2"
fi

# ── Parse args ─────────────────────────────────────────────────────────────
BUILD=true
UPLOAD=true

for arg in "$@"; do
  case $arg in
    --upload-only) BUILD=false ;;
    --build-only)  UPLOAD=false ;;
    --help|-h)
      echo "Uso: ./scripts/release_apk.sh [--upload-only | --build-only]"
      exit 0 ;;
  esac
done

# ── Ler versão do pubspec.yaml ─────────────────────────────────────────────
VERSION=$(grep '^version:' "$PROJECT_DIR/pubspec.yaml" | awk '{print $2}' | cut -d'+' -f1)
BUILD_NUM=$(grep '^version:' "$PROJECT_DIR/pubspec.yaml" | awk '{print $2}' | cut -d'+' -f2)

if [[ -z "$VERSION" ]]; then
  err "Não foi possível ler a versão do pubspec.yaml"
fi

APK_NAME="brawe-v${VERSION}.apk"
APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"

# ── Banner ─────────────────────────────────────────────────────────────────
echo -e "${PURPLE}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   🚀 BRAWE APP — Release APK              ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"
log "Versão:  $VERSION (build $BUILD_NUM)"
log "APK:     $APK_NAME"
log "Bucket:  $R2_BUCKET"
log "CDN:     $CDN_BASE"
echo ""

# ── Step 1: Build ──────────────────────────────────────────────────────────
if [[ "$BUILD" == true ]]; then
  log "Gerando APK release..."
  cd "$PROJECT_DIR"
  flutter build apk --release
  ok "Build concluído: $APK_PATH"
else
  log "Pulando build (--upload-only)"
fi

# Verificar se o APK existe
if [[ ! -f "$APK_PATH" ]]; then
  err "APK não encontrado em: $APK_PATH\nExecute o build primeiro ou use sem --upload-only"
fi

APK_SIZE=$(du -sh "$APK_PATH" | cut -f1)
log "APK encontrado: $APK_SIZE"

# ── Step 2: Upload para R2 ─────────────────────────────────────────────────
if [[ "$UPLOAD" == true ]]; then
  if [[ -z "$R2_ACCESS_KEY_ID" || -z "$R2_SECRET_ACCESS_KEY" ]]; then
    err "Credenciais R2 não configuradas!\nCrie o arquivo .env.r2 com:\n  R2_ACCESS_KEY_ID=sua_key\n  R2_SECRET_ACCESS_KEY=seu_secret"
  fi

  log "Fazendo upload para Cloudflare R2..."

  # Upload com AWS CLI (S3-compatible)
  _upload() {
    local r2_key="$1"
    log "→ $r2_key"
    AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY" \
    aws s3 cp "$APK_PATH" "s3://$R2_BUCKET/$r2_key" \
      --endpoint-url "$R2_ENDPOINT" \
      --region auto \
      --content-type "application/vnd.android.package-archive" \
      --content-disposition "attachment; filename=\"$APK_NAME\"" \
      --no-progress \
      --checksum-algorithm CRC32 2>/dev/null || \
    AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY" \
    aws s3 cp "$APK_PATH" "s3://$R2_BUCKET/$r2_key" \
      --endpoint-url "$R2_ENDPOINT" \
      --region auto \
      --content-type "application/vnd.android.package-archive" \
      --no-progress
    ok "$CDN_BASE/$r2_key"
  }

  # Upload versão específica (backup permanente)
  _upload "downloads/android/$APK_NAME"

  # Atualizar brawe-latest.apk (link "download latest")
  _upload "downloads/android/brawe-latest.apk"

  # Atualizar version.json no R2
  log "Atualizando version.json..."
  VERSION_JSON="{\"version\":\"$VERSION\",\"build\":\"$BUILD_NUM\",\"apk\":\"$CDN_BASE/downloads/android/$APK_NAME\",\"latest\":\"$CDN_BASE/downloads/android/brawe-latest.apk\",\"updatedAt\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
  echo "$VERSION_JSON" | \
    AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY" \
    aws s3 cp - "s3://$R2_BUCKET/downloads/android/version.json" \
      --endpoint-url "$R2_ENDPOINT" \
      --region auto \
      --content-type "application/json" \
      --no-progress 2>/dev/null || warn "version.json não foi atualizado"
  ok "version.json → $CDN_BASE/downloads/android/version.json"
fi

# ── Done ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   ✅ Release $VERSION concluído!           ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo "  📦 Versão:  $CDN_BASE/downloads/android/$APK_NAME"
echo "  🔗 Latest:  $CDN_BASE/downloads/android/brawe-latest.apk"
echo "  📋 Info:    $CDN_BASE/downloads/android/version.json"
echo ""
