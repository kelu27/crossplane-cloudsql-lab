#!/bin/bash

# MiniSky Universal Installer
# Usage: curl -sSL https://minisky.bmics.com.ng/install.sh | bash

set -e

REPO="qamarudeenm/minisky"
BINARY_NAME="minisky"
INSTALL_DIR="${MINISKY_INSTALL_DIR:-/usr/local/bin}"
WORK_DIR=""

cleanup() {
    if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
    fi
}

trap cleanup EXIT

build_from_source() {
    if ! command -v go >/dev/null 2>&1; then
        echo "❌ Error: Go is required to build MiniSky from source."
        exit 1
    fi

    if ! command -v npm >/dev/null 2>&1; then
        echo "❌ Error: npm is required to build MiniSky from source."
        exit 1
    fi

    WORK_DIR=$(mktemp -d)
    SOURCE_ARCHIVE="$WORK_DIR/source.tar.gz"

    echo "🔧 No prebuilt binary for $OS/$ARCH in $VERSION. Building from source..."
    curl -fsSL -o "$SOURCE_ARCHIVE" "https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz"
    tar -xzf "$SOURCE_ARCHIVE" -C "$WORK_DIR"

    SRC_DIR=$(find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    if [ -z "$SRC_DIR" ]; then
        echo "❌ Error: Could not unpack source archive for $VERSION."
        exit 1
    fi

    (cd "$SRC_DIR/ui" && npm ci)
    (cd "$SRC_DIR/ui" && npm run build)
    (cd "$SRC_DIR" && go build -o "$WORK_DIR/$BIN_OUT" ./cmd/minisky)
}

install_binary() {
    target_path="$INSTALL_DIR/$BIN_OUT"

    if mkdir -p "$INSTALL_DIR" 2>/dev/null; then
        mv "$1" "$target_path"
        chmod +x "$target_path"
        return
    fi

    echo "🚀 Installing '$BIN_OUT' to $INSTALL_DIR..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo mv "$1" "$target_path"
    sudo chmod +x "$target_path"
}

# 1. Detect OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [[ "$OS" == mingw* || "$OS" == msys* ]]; then
    OS="windows"
fi

case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo "🛰️  Installing MiniSky for $OS/$ARCH..."

# 2. Get latest version from GitHub
RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(printf '%s' "$RELEASE_JSON" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not detect latest version."
    exit 1
fi

echo "📦 Found version $VERSION"

# 3. Download and Install
EXT="tar.gz"
BIN_OUT="$BINARY_NAME"
if [ "$OS" = "windows" ]; then 
    EXT="zip"
    BIN_OUT="${BINARY_NAME}.exe"
fi

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/minisky_${OS}_${ARCH}.${EXT}"
ASSET_NAME="minisky_${OS}_${ARCH}.${EXT}"
DOWNLOAD_URL=$(printf '%s' "$RELEASE_JSON" | grep -o '"browser_download_url": "[^"]*"' | sed -E 's/.*"([^"]+)"/\1/' | grep "/${ASSET_NAME}$" | head -n 1 || true)

if [ -z "$DOWNLOAD_URL" ]; then
    build_from_source
else
    echo "📥 Downloading from $DOWNLOAD_URL..."
    curl -fsSL -o "minisky.$EXT" "$DOWNLOAD_URL"

    if [ "$EXT" = "tar.gz" ]; then
        tar -xzf "minisky.$EXT" minisky
    else
        # Windows/Zip
        unzip -q "minisky.$EXT" "$BIN_OUT"
    fi
fi

if [ -n "$WORK_DIR" ]; then
    BINARY_PATH="$WORK_DIR/$BIN_OUT"
else
    BINARY_PATH="./$BIN_OUT"
fi

if [ "$OS" = "windows" ]; then
    echo "✅ MiniSky binary ($BIN_OUT) is ready at $BINARY_PATH."
    echo "To use it globally, add this folder to your Windows PATH."
else
    install_binary "$BINARY_PATH"
fi

if [ -f "minisky.$EXT" ]; then
    rm "minisky.$EXT"
fi

# 4. Final check
echo ""
echo "🚀 MiniSky installation process finished!"
if [ "$OS" != "windows" ]; then
    echo "Try running: minisky start"
fi
echo ""
echo "Note: Ensure Docker is running on your machine."
