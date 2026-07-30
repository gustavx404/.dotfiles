#!/bin/bash
# Dotfiles Installer — multi-distro
# Usage: ./scripts/install.sh [install|status|backup|uninstall]
# One-liner: curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/main/scripts/install.sh | bash

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="$HOME/.config/backup/$(date +%Y%m%d_%H%M%S)"

# ---- Cores ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()   { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }
info()  { echo -e "${BLUE}[i]${NC} $1"; }

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            fedora|rhel|centos|rocky|alma) echo dnf ;;
            ubuntu|debian|pop|linuxmint)   echo apt ;;
            arch|manjaro|garuda|endeavouros) echo pacman ;;
            *) error "Distro não suportada: $ID"; echo unknown ;;
        esac
    else
        echo unknown
    fi
}

install_pkg() {
    local pm=$1; shift
    case "$pm" in
        dnf)   sudo dnf install -y "$@" ;;
        apt)   sudo apt update && sudo apt install -y "$@" ;;
        pacman) sudo pacman -Sy --noconfirm "$@" ;;
        *) error "Não foi possível instalar: $*"; return 1 ;;
    esac
}

# Instala JetBrainsMono Nerd Font (não disponível em todos distros via apt/dnf)
install_nerd_font() {
    local font_dir="$HOME/.local/share/fonts/jetbrainsmono-nerd"
    if fc-list | grep -qi "JetBrainsMono Nerd"; then
        info "JetBrainsMono Nerd Font já instalada"
        return
    fi
    log "Instalando JetBrainsMono Nerd Font..."
    mkdir -p "$font_dir"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    local tmp=$(mktemp -d)
    if command -v curl >/dev/null; then
        curl -fsSL "$url" -o "$tmp/jb.zip"
    elif command -v wget >/dev/null; then
        wget -qO "$tmp/jb.zip" "$url"
    else
        warn "sem curl/wget — pule a fonte"; return
    fi
    unzip -qo "$tmp/jb.zip" -d "$font_dir" 2>/dev/null || warn "unzip não disponível"
    fc-cache -f >/dev/null 2>&1 || true
    rm -rf "$tmp"
}

backup_config() {
    local p=$1
    if [ -e "$p" ]; then
        warn "Backup de $p"
        mkdir -p "$BACKUP_DIR"
        cp -ar "$p" "$BACKUP_DIR/"
    fi
}

link_config() {
    local src=$1 dest=$2
    backup_config "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
    log "Link: $dest → $src"
}

# ------------------------------------------------------------------
# Setup repo
# ------------------------------------------------------------------

setup_repo() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        log "Atualizando dotfiles..."
        git -C "$DOTFILES_DIR" pull --ff-only || warn "git pull falhou"
    else
        log "Clonando dotfiles..."
        git clone https://github.com/gustavx404/.dotfiles.git "$DOTFILES_DIR"
    fi
    cd "$DOTFILES_DIR"
}

# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------

main() {
    local pm=$(detect_distro)
    log "Gerenciador de pacotes: $pm"

    # Dependências
    local need=()
    local check=(zsh starship zoxide fzf eza bat fastfetch git unzip curl)
    if [ "$pm" = pacman ]; then check+=(ttf-jetbrainsmono-nerd); fi
    for c in "${check[@]}"; do
        command -v "$c" >/dev/null 2>&1 || need+=("$c")
    done
    if [ ${#need[@]} -gt 0 ]; then
        info "Instalando: ${need[*]}"
        case "$pm" in
            dnf)
                # eza não está em repo padrão no Fedora < 41 → transfere via cargo as needed
                local pkgs=()
                for p in "${need[@]}"; do
                    case "$p" in
                        eza) info "eza: tente dnf, depois cargo"; pkgs+=("eza") ;;
                        *) pkgs+=("$p") ;;
                    esac
                done
                sudo dnf install -y "${pkgs[@]}" || warn "alguns pacotes falharam"
                command -v eza >/dev/null 2>&1 || {
                    info "Instalando eza via cargo"
                    command -v cargo >/dev/null 2>&1 || install_pkg dnf cargo
                    cargo install --locked eza || warn "cargo eza falhou"
                }
                ;;
            apt)   install_pkg apt "${need[@]}" ;;
            pacman) install_pkg pacman "${need[@]}" ;;
            *) error "Não foi possível instalar pacotes automaticamente" ;;
        esac
    fi

    install_nerd_font

    # Links
    log "Aplicando symlinks..."
    link_config "$DOTFILES_DIR/.config/shell/.zshrc"    "$HOME/.zshrc"
    link_config "$DOTFILES_DIR/.config/shell/.bashrc"   "$HOME/.bashrc"
    link_config "$DOTFILES_DIR/.config/shell/aliases.sh" "$HOME/.config/shell/aliases.sh"
    link_config "$DOTFILES_DIR/.config/kitty"           "$HOME/.config/kitty"
    link_config "$DOTFILES_DIR/.config/starship"        "$HOME/.config/starship"
    link_config "$DOTFILES_DIR/.config/fastfetch"       "$HOME/.config/fastfetch"
    link_config "$DOTFILES_DIR/.config/git/.gitconfig"  "$HOME/.gitconfig"

    # Troca shell para zsh
    local zsh_bin
    zsh_bin=$(command -v zsh 2>/dev/null || true)
    if [ -n "$zsh_bin" ] && [ "$SHELL" != "$zsh_bin" ]; then
        info "Trocando shell padrão para zsh..."
        chsh -s "$zsh_bin" || warn "chsh falhou — troque manualmente: chsh -s $zsh_bin"
    fi

    echo
    log "Pronto! Restart do terminal para ativar as mudancas."
    log "Backup em: $BACKUP_DIR"
}

# ------------------------------------------------------------------
# CLI
# ------------------------------------------------------------------

case "${1:-install}" in
    install)
        setup_repo
        main
        ;;
    status)
        log "Status das configs:"
        for f in ~/.zshrc ~/.bashrc ~/.gitconfig; do
            [ -L "$f" ] && log "$f → $(readlink "$f")" || warn "$f não linkado"
        done
        for d in kitty starship fastfetch; do
            [ -L "$HOME/.config/$d" ] && log "~/.config/$d → $(readlink "$HOME/.config/$d")" || warn "~/.config/$d não linkado"
        done
        echo
        info "Shell atual: $SHELL"
        info "zsh:    $(command -v zsh   2>/dev/null || echo 'NÃO instalado')"
        info "starship: $(command -v starship 2>/dev/null || echo 'NÃO instalado')"
        info "zoxide: $(command -v zoxide  2>/dev/null || echo 'NÃO instalado')"
        info "fzf:    $(command -v fzf    2>/dev/null || echo 'NÃO instalado')"
        info "eza:    $(command -v eza    2>/dev/null || echo 'NÃO instalado')"
        ;;
    backup)
        log "Backup manual..."
        for p in ~/.zshrc ~/.bashrc ~/.gitconfig ~/.config/kitty ~/.config/starship ~/.config/fastfetch; do
            backup_config "$p"
        done
        log "Backup em: $BACKUP_DIR"
        ;;
    uninstall)
        warn "Removendo symlinks..."
        rm -f ~/.zshrc ~/.bashrc ~/.gitconfig ~/.config/shell/aliases.sh
        rm -f ~/.config/kitty ~/.config/starship ~/.config/fastfetch 2>/dev/null || true
        rmdir ~/.config/shell 2>/dev/null || true
        log "Symlinks removidos. Pacotes NÃO foram desinstalados."
        ;;
    *)
        echo "Usage: $0 {install|status|backup|uninstall}"
        exit 1
        ;;
esac
