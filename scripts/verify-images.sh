#!/bin/bash
# verify-openclaw-images.sh
# Run this script on a Linux AMD64 machine to verify the OpenClaw images

set -e

SLIM_IMAGE="ghcr.io/exxmen/openclaw:slim"
FULL_IMAGE="ghcr.io/exxmen/openclaw:full"

echo "=============================================="
echo "OpenClaw Docker Image Verification Script"
echo "=============================================="
echo ""

# Check if we're on AMD64
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "⚠️  Warning: This script should be run on linux/amd64."
    echo "   Current architecture: $ARCH"
    echo "   The images are built for linux/amd64 and won't run on $ARCH."
    echo ""
fi

echo "=== Step 1: Pulling slim image ==="
docker pull "$SLIM_IMAGE"
echo ""

echo "=== Step 2: Verifying slim image ==="
echo "Image ID: $(docker images -q $SLIM_IMAGE)"
echo "Size: $(docker images --format '{{.Size}}' $SLIM_IMAGE)"
echo ""

echo "=== Step 3: Testing slim image runs ==="
echo "Running: docker run --rm $SLIM_IMAGE --version"
if docker run --rm "$SLIM_IMAGE" --version 2>/dev/null; then
    echo "✅ Slim image runs successfully"
else
    echo "⚠️  Could not run --version (may need different command)"
    echo "   Trying to list available commands..."
    docker run --rm "$SLIM_IMAGE" ls /usr/local/bin/ | head -20
fi
echo ""

echo "=== Step 4: Checking binaries in slim image ==="
echo "Core binaries:"
for bin in gog blu himalaya sonoscli ordercli goplaces blogwatcher; do
    if docker run --rm "$SLIM_IMAGE" which "$bin" 2>/dev/null; then
        echo "  ✅ $bin"
    else
        echo "  ⚠️  $bin not found"
    fi
done
echo ""

echo "=== Step 5: Checking Node/Bun in slim image ==="
if docker run --rm "$SLIM_IMAGE" node --version 2>/dev/null; then
    echo "✅ Node.js available"
else
    echo "⚠️  Node.js not found"
fi

if docker run --rm "$SLIM_IMAGE" bun --version 2>/dev/null; then
    echo "✅ Bun available"
else
    echo "⚠️  Bun not found"
fi
echo ""

echo "=== Step 6: Pulling full image ==="
docker pull "$FULL_IMAGE"
echo ""

echo "=== Step 7: Verifying full image ==="
echo "Image ID: $(docker images -q $FULL_IMAGE)"
echo "Size: $(docker images --format '{{.Size}}' $FULL_IMAGE)"
echo ""

echo "=== Step 8: Checking QMD models in full image ==="
if docker run --rm "$FULL_IMAGE" ls -la /home/openclaw/.qmd/models/ 2>/dev/null; then
    echo "✅ QMD models directory exists"
else
    echo "⚠️  QMD models directory empty or not found"
    echo "   (Models require HuggingFace authentication to download)"
fi
echo ""

echo "=============================================="
echo "Verification Complete!"
echo "=============================================="
echo ""
echo "To use the images:"
echo "  Slim: docker run -it --rm ghcr.io/exxmen/openclaw:slim"
echo "  Full: docker run -it --rm ghcr.io/exxmen/openclaw:full"
echo ""
