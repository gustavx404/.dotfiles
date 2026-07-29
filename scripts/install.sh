#!/bin/bash
# Dotfiles Installer
# Cross-distro compatible (Fedora, Ubuntu, Arch)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

# Get package manager command
get_pkg_cmd() {
    local distro=$1
    case $distro in
        fedora) echo "dnf" ;;
        ubuntu) echo "apt" ;;
        arch) echo "pacman" ;;
        *) echo "unknown" ;;
    esac
}

# Install package
install_pkg() {
    local pkg=$1
    local distro=$2
    local pkg_cmd=$(get_pkg_cmd "$distro")
    
    case $distro in
        fedora)
            sudo dnf install -y "$pkg"
            ;;
        ubuntu)
            sudo apt install -y "$pkg"
            ;;
        arch)
            sudo pacman -S --noconfirm "$pkg"
            ;;
        *)
            error "Unknown distro: $distro"
            return 1
            ;;
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
    log "Linked: $dest -> $src"
}

# Main installation
main() {
    local distro=$(detect_distro)
    log "Detected distro: $distro"
    
    # Check for required tools
    for cmd in git curl; do
        if ! command -v $cmd &> /dev/null; then
            warn "Installing $cmd..."
            install_pkg "$cmd" "$distro"
        fi
    done
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Link shell configs
    log "Installing shell configs..."
    link_config "$DOTFILES_DIR/.config/shell/.zshrc" "$HOME/.zshrc"
    link_config "$DOTFILES_DIR/.config/shell/.bashrc" "$HOME/.bashrc"
    link_config "$DOTFILES_DIR/.config/shell/aliases.zsh" "$HOME/.config/shell/aliases.zsh"
    link_config "$DOTFILES_DIR/.config/shell/aliases.bash" "$HOME/.config/shell/aliases.bash"
    
    # Link kitty config
    log "Installing kitty config..."
    link_config "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty"
    
    # Link fastfetch config
    log "Installing fastfetch config..."
    link_config "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
    
    # Link git config
    log "Installing git config..."
    link_config "$DOTFILES_DIR/.config/git/.gitconfig" "$HOME/.gitconfig"
    
    log "Installation complete!"
    log "Backup saved to: $BACKUP_DIR"
    log "Restart your terminal for changes to take effect."
}

# Parse arguments
case "${1:-install}" in
    install)
        main
        ;;
    status)
        log "Checking dotfiles status..."
        echo ""
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
    *)
        echo "Usage: $0 {install|status|backup}"
        exit 1
        ;;
esac
