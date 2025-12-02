#!/usr/bin/env bash
set -euo pipefail

# Installer for Atlassian CLI (acli)
# Usage: run as root or let the script re-run with sudo:
#   sudo ./install_acli.sh

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

if ! command -v wget >/dev/null 2>&1; then
  apt-get update
  apt-get install -y wget gnupg2
else
  apt-get install -y gnupg2
fi

mkdir -p -m 755 /etc/apt/keyrings
wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc | gpg --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg
chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main" > /etc/apt/sources.list.d/acli.list

apt update
apt install -y acli

echo "acli installation complete."
