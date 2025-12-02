#!/usr/bin/env bash
set -euo pipefail

# Installer for acli binary using curl on Linux
# This script downloads and installs the acli binary directly from Atlassian
# Usage: sudo ./install_acli_curl.sh

ACLI_REPO="https://github.com/atlassian/aclip/releases/latest/download"
BINARY_NAME="aclip-linux-amd64"
INSTALL_PATH="/usr/local/bin/acli"

# Check if running as root
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

# Ensure curl is installed
if ! command -v curl >/dev/null 2>&1; then
  echo "curl not found. Installing..."
  apt-get update
  apt-get install -y curl
fi

echo "Installing acli binary..."

# Create temporary file for download
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Get the latest release download URL
echo "Fetching latest acli release..."
DOWNLOAD_URL="https://acli.atlassian.com/linux/latest/acli_linux_arm64/acli"

echo "Downloading from: $DOWNLOAD_URL"
if ! curl -fsSL -o "$TEMP_FILE" "$DOWNLOAD_URL"; then
  echo "Error: Failed to download acli binary"
  echo "Make sure you have internet access and the release exists at:"
  echo "$DOWNLOAD_URL"
  exit 1
fi

if [ ! -f "$TEMP_FILE" ] || [ ! -s "$TEMP_FILE" ]; then
  echo "Error: Downloaded file is empty or missing"
  exit 1
fi

echo "Installing to: $INSTALL_PATH"
mkdir -p "$(dirname "$INSTALL_PATH")"
mv "$TEMP_FILE" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

echo "acli installation complete!"
echo "Verifying installation..."
if "$INSTALL_PATH" --version 2>/dev/null; then
  echo "acli is ready to use!"
else
  echo "Installation complete. Run 'acli --version' to verify."
fi
