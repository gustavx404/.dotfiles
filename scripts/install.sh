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

# Instala starship via script oficial do projeto (não existe em dnf no FC44)
# Único fallback que não é via gerenciador de pacotes.
install_starship_official() {
    command -v starship >/dev/null 2>&1 && { info "starship já instalado"; return; }
    local tmp
    tmp=$(mktemp -d)
    log "Baixando starship.rs (script oficial)..."
    if command -v curl >/dev/null; then
        curl -fsSL https://starship.rs/install.sh -o "$tmp/starship-install.sh"
    elif command -v wget >/dev/null; then
        wget -qO "$tmp/starship-install.sh" https://starship.rs/install.sh
    else
        warn "sem curl/wget — pulei starship"; return 1
    fi
    # -y auto-confirma, -b <dir> instala em user space (sem sudo)
    sh "$tmp/starship-install.sh" -y -b "$HOME/.local/bin" || { warn "install starship falhou"; return 1; }
    rm -rf "$tmp"
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
    log "starship instalado em ~/.local/bin"
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
# Resolve dotfiles dir
#   - DOTFILES_DIR env var (preferido)
#   - repo local atual (se já rodando de um clone)
#   - ~/\.dotfiles (clone oficial)
# ------------------------------------------------------------------

resolve_dotfiles_dir() {
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

    if [ -n "$DOTFILES_DIR" ] && [ -d "$DOTFILES_DIR/.config" ]; then
        return
    fi

    # Rodando de dentro do repo local?
    if [ -f "$script_dir/.config/shell/.zshrc" ]; then
        DOTFILES_DIR="$script_dir"
        return
    fi

    # Senão, clona/atualiza em ~/.dotfiles
    if [ -d "$HOME/.dotfiles/.git" ]; then
        log "Atualizando ~/.dotfiles..."
        git -C "$HOME/.dotfiles" pull --ff-only || warn "git pull falhou"
    else
        log "Clonando dotfiles em ~/.dotfiles..."
        git clone https://github.com/gustavx404/.dotfiles.git "$HOME/.dotfiles"
    fi
    DOTFILES_DIR="$HOME/.dotfiles"
}

# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------

main() {
    local pm=$(detect_distro)
    log "Gerenciador de pacotes: $pm"

    # Dependências — só via gerenciador de pacotes, sem cargo/pip/etc
    # Exceção: starship não está empacotado no dnf do Fedora → instalaVia script oficial
    local need=()
    local starship_missing=0
    for c in zsh starship zoxide fzf eza bat fastfetch git unzip curl; do
        if ! command -v "$c" >/dev/null 2>&1; then
            if [ "$c" = starship ]; then
                starship_missing=1
            else
                need+=("$c")
            fi
        fi
    done
    if [ ${#need[@]} -gt 0 ]; then
        info "Pacotes via ${pm}: ${need[*]}"
        # instala um-a-um para não derrubar a transação inteira
        local failed=()
        for p in "${need[@]}"; do
            if install_pkg "$pm" "$p"; then
                log "instalado: $p"
            else
                warn "falhou: $p"
                failed+=("$p")
            fi
        done
        [ ${#failed[@]} -gt 0 ] && warn "Não instalados via ${pm}: ${failed[*]}"
    else
        info "Todos os pacotes via ${pm} já estão instalados"
    fi

    # starship — único fallback (não empacotado no dnf em FC44)
    if [ "$starship_missing" -eq 1 ]; then
        if [ "$pm" = pacman ]; then
            info "instalando starship via pacman"
            install_pkg pacman starship || warn "starship pacman falhou"
        elif [ "$pm" = apt ]; then
            info "instalando starship via apt"
            install_pkg apt starship || warn "starship apt falhou"
        else
            info "instalando starship via script oficial (ssl-only, sem cargo)"
            install_starship_official || warn "instalação do starship falhou"
        fi
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
    local zsh_bin current_shell
    zsh_bin=$(command -v zsh 2>/dev/null || true)
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    if [ -z "$zsh_bin" ]; then
        warn "zsh não instalado — skip chsh"
    elif [ "$current_shell" = "$zsh_bin" ]; then
        info "zsh já é o shell de login"
    else
        info "Trocando shell de login: $current_shell → $zsh_bin"
        chsh -s "$zsh_bin" || warn "chsh falhou — rode manualmente: chsh -s $zsh_bin"
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
        resolve_dotfiles_dir
        log "Usando: $DOTFILES_DIR"
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
