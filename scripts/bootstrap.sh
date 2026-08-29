#!/bin/bash
# Dotfiles Bootstrap — lightweight entry point that fetches and runs the
# full installer from the latest tag. Target: CachyOS / Arch (pacman).
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/refs/tags/latest/scripts/bootstrap.sh | bash
#
# This script downloads install.sh from the same tag and executes it.
# Falls back to 'main' branch if the 'latest' tag does not exist yet.

set -euo pipefail

REPO="gustavx404/.dotfiles"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

download() {
    local url=$1 dest=$2
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url"
    else
        echo "ERROR: neither curl nor wget is available." >&2
        exit 1
    fi
}

INSTALL_SH="$TMP_DIR/install.sh"

# Try latest tag first, fall back to main branch
echo "==> Fetching installer..."
if download "https://raw.githubusercontent.com/$REPO/refs/tags/latest/scripts/install.sh" "$INSTALL_SH" 2>/dev/null; then
    echo "    (from latest tag)"
elif download "https://raw.githubusercontent.com/$REPO/main/scripts/install.sh" "$INSTALL_SH" 2>/dev/null; then
    echo "    (from main branch — no latest tag yet)"
else
    echo "ERROR: failed to download install.sh" >&2
    exit 1
fi

# Forward all arguments to the full installer
exec bash "$INSTALL_SH" "$@"
