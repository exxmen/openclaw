#!/usr/bin/env bash
# Verify all skill binaries are installed correctly in the Docker image
set -euo pipefail

echo "=== OpenClaw Binary Verification ==="
echo ""

MISSING=0

check_binary() {
    local name="$1"
    local path="$2"
    if command -v "$path" &> /dev/null; then
        echo "[OK] $name: $(which $path)"
    else
        echo "[MISSING] $name: $path not found"
        MISSING=$((MISSING + 1))
    fi
}

echo "--- APT Packages ---"
check_binary "curl" "curl"
check_binary "jq" "jq"
check_binary "ripgrep" "rg"
check_binary "ffmpeg" "ffmpeg"
check_binary "tmux" "tmux"
check_binary "sqlite3" "sqlite3"
check_binary "python3" "python3"
check_binary "GitHub CLI" "gh"
check_binary "1Password CLI" "op"

echo ""
echo "--- Go Binaries ---"
check_binary "eightctl" "eightctl"
check_binary "gifgrep" "gifgrep"

echo ""
echo "--- Pre-built Binaries ---"
check_binary "gog (gogcli)" "gog"
check_binary "goplaces" "goplaces"
check_binary "himalaya" "himalaya"
check_binary "blu (blucli)" "blu"
check_binary "ordercli" "ordercli"
check_binary "sonoscli" "sonoscli"
check_binary "blogwatcher" "blogwatcher"

echo ""
echo "--- Sherpa-ONNX TTS ---"
if [ -d "/opt/sherpa-onnx" ]; then
    echo "[OK] sherpa-onnx: /opt/sherpa-onnx"
    if [ -f "/opt/sherpa-onnx/bin/sherpa-onnx-offline-tts" ]; then
        echo "[OK] sherpa-onnx-offline-tts binary found"
    else
        echo "[MISSING] sherpa-onnx-offline-tts binary"
        MISSING=$((MISSING + 1))
    fi
else
    echo "[MISSING] sherpa-onnx directory"
    MISSING=$((MISSING + 1))
fi

echo ""
echo "--- npm Global Tools ---"
check_binary "clawdhub" "clawdhub"
check_binary "mcporter" "mcporter"
check_binary "oracle" "oracle"
check_binary "bird" "bird"

echo ""
echo "--- Language Tools ---"
check_binary "bun" "bun"
check_binary "uv" "uv"

echo ""
echo "--- QMD Models (optional) ---"
if [ -d "${QMD_MODELS_DIR:-/home/openclaw/.qmd/models}" ]; then
    echo "[OK] QMD models directory exists"
    ls -la "${QMD_MODELS_DIR:-/home/openclaw/.qmd/models}"/*.gguf 2>/dev/null || echo "[INFO] No GGUF models found (slim image)"
else
    echo "[INFO] QMD models directory not found (slim image)"
fi

echo ""
echo "=== Summary ==="
if [ $MISSING -eq 0 ]; then
    echo "All binaries verified successfully!"
    exit 0
else
    echo "WARNING: $MISSING binaries missing!"
    exit 1
fi
