#!/bin/bash
# Dotfiles Installer - One-liner install
# Usage: curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/main/scripts/install.sh | bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.config/backup/$(date +%Y%m%d_%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Install package
install_pkg() {
    local pkg=$1
    local distro=$2
    case $distro in
        fedora) sudo dnf install -y "$pkg" ;;
        ubuntu) sudo apt install -y "$pkg" ;;
        arch) sudo pacman -S --noconfirm "$pkg" ;;
        *) error "Unknown distro: $distro"; return 1 ;;
    esac
}

# Backup existing config
backup_config() {
    local config_path=$1
    if [ -e "$config_path" ]; then
        warn "Backing up $config_path"
        mkdir -p "$BACKUP_DIR"
        cp -r "$config_path" "$BACKUP_DIR/"
    fi
}

# Create symlink
link_config() {
    local src=$1
    local dest=$2
    backup_config "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    log "Linked: $dest"
}

# Clone or update repo
setup_repo() {
    if [ -d "$DOTFILES_DIR" ]; then
        log "Updating existing dotfiles..."
        cd "$DOTFILES_DIR" && git pull
    else
        log "Cloning dotfiles..."
        git clone https://github.com/gustavx404/.dotfiles.git "$DOTFILES_DIR"
        cd "$DOTFILES_DIR"
    fi
}

# Main installation
main() {
    local distro=$(detect_distro)
    log "Detected distro: $distro"
    
    # Check for git
    if ! command -v git &> /dev/null; then
        warn "Installing git..."
        install_pkg git "$distro"
    fi
    
    # Setup repo
    setup_repo
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Link configs
    log "Installing configs..."
    link_config "$DOTFILES_DIR/.config/shell/.zshrc" "$HOME/.zshrc"
    link_config "$DOTFILES_DIR/.config/shell/.bashrc" "$HOME/.bashrc"
    link_config "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty"
    link_config "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
    link_config "$DOTFILES_DIR/.config/git/.gitconfig" "$HOME/.gitconfig"
    
    log "Installation complete!"
    log "Backup saved to: $BACKUP_DIR"
    log "Restart your terminal for changes to take effect."
}

# Parse arguments
case "${1:-install}" in
    install) main ;;
    status)
        log "Checking dotfiles status..."
        echo "Shell:     $(ls -la ~/.zshrc 2>/dev/null || echo 'NOT INSTALLED')"
        echo "Kitty:     $(ls -la ~/.config/kitty 2>/dev/null || echo 'NOT INSTALLED')"
        echo "Fastfetch: $(ls -la ~/.config/fastfetch 2>/dev/null || echo 'NOT INSTALLED')"
        echo "Git:       $(ls -la ~/.gitconfig 2>/dev/null || echo 'NOT INSTALLED')"
        ;;
    backup)
        log "Creating backup..."
        backup_config "$HOME/.zshrc"
        backup_config "$HOME/.bashrc"
        backup_config "$HOME/.config/kitty"
        backup_config "$HOME/.config/fastfetch"
        backup_config "$HOME/.gitconfig"
        log "Backup complete: $BACKUP_DIR"
        ;;
    *) echo "Usage: $0 {install|status|backup}"; exit 1 ;;
esac
