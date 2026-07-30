#!/bin/bash
# Dotfiles Installer — multi-distro
# Usage: ./scripts/install.sh [install|status|backup|uninstall]
# One-liner: curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/main/scripts/install.sh | bash

set -e

DOTFILES_DIR=""   # filled by resolve_dotfiles_dir; the default value used to short-circuit detection
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
    # Se já existe um symlink apontando para o lugar ERRADO, força remoção
    # (ln -sfn não consegue substituir symlink-to-dir com `rm` implícito em alguns casos)
    if [ -L "$dest" ]; then
        local cur
        cur=$(readlink "$dest")
        if [ "$cur" != "$src" ]; then
            warn "Substituindo symlink: $dest ($cur → $src)"
            rm -f "$dest"
        fi
    elif [ -e "$dest" ] && [ ! -L "$dest" ]; then
        # Arquivo/dir real: faz backup
        backup_config "$dest"
        rm -rf "$dest"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
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

    # Running from inside a local clone?
    # Detect via several tell-tale files (config path changed across versions)
    if [ -f "$script_dir/.config/fish/config.fish" ] \
        || [ -f "$script_dir/.config/kitty/kitty.conf" ] \
        || [ -f "$script_dir/scripts/install.sh" ]; then
        DOTFILES_DIR="$script_dir"
        # Clean up stale symlinks left over from a previous curl-install
        # that pointed to ~/.dotfiles (an older separate clone).
        if [ "$DOTFILES_DIR" != "$HOME/.dotfiles" ]; then
            for stale in ~/.config/fish ~/.config/kitty ~/.config/starship \
                         ~/.config/btop ~/.config/fastfetch ~/.gitconfig; do
                if [ -L "$stale" ]; then
                    local link_target
                    link_target=$(readlink "$stale")
                    case "$link_target" in
                        "$HOME/.dotfiles"*)
                            warn "Substituindo symlink stale: $stale → $link_target"
                            rm -f "$stale"
                            ;;
                    esac
                fi
            done
        fi
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
    local starship_missing=0
    log "Gerenciador de pacotes: $pm"

    # Dependências — só via gerenciador de pacotes, sem cargo/pip/etc
    # Exceção: starship não empacotado no dnf do Fedora → via script oficial
    local need=()
    for c in fish git unzip curl btop fastfetch; do
        if ! command -v "$c" >/dev/null 2>&1; then
            need+=("$c")
        fi
    done
    # starship nao existe em dnf em FC44 — tratado à parte
    command -v starship >/dev/null 2>&1 || starship_missing=1
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

    # Links — tarefas (apagar links antigos de zsh/bash)
    log "Aplicando symlinks..."
    # Limpa leftovers de migrações anteriores (zsh -> fish)
    for stale in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.config/shell"; do
        if [ -L "$stale" ] || [ -e "$stale" ]; then
            warn "Removendo leftover: $stale"
            rm -f "$stale" 2>/dev/null || rm -rf "$stale" 2>/dev/null
        fi
    done

    link_config "$DOTFILES_DIR/.config/fish"             "$HOME/.config/fish"
    link_config "$DOTFILES_DIR/.config/kitty"            "$HOME/.config/kitty"
    link_config "$DOTFILES_DIR/.config/starship"         "$HOME/.config/starship"
    link_config "$DOTFILES_DIR/.config/fastfetch"        "$HOME/.config/fastfetch"
    link_config "$DOTFILES_DIR/.config/btop"             "$HOME/.config/btop"
    link_config "$DOTFILES_DIR/.config/git/.gitconfig"   "$HOME/.gitconfig"

    # Troca shell de login para fish em /etc/passwd
    local fish_bin current_shell
    fish_bin=$(command -v fish 2>/dev/null || true)
    current_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [ -z "$fish_bin" ]; then
        warn "fish não está instalado — impossível trocar de shell"
    elif [ "$current_shell" = "$fish_bin" ]; then
        info "Login shell em /etc/passwd já é fish ($fish_bin) ✓"
        if [ "$SHELL" != "$fish_bin" ]; then
            warn "Atenção: \$SHELL ainda é '$SHELL' nesta sessão ativa."
            warn "Isso é normal — a sessão KDE/Wayland herda o login shell de quando foi iniciada."
            warn "Para ativar o fish definitivamente:"
            warn "   • Feche TODAS as janelas do Kitty e abra de novo, OU"
            warn "   • Faça logout da sessão KDE e entre de novo, OU"
            warn "   • Reinicie o computador (necessário porque plasmalogin cacheia SHELL)"
        fi
    else
        info "Trocando shell de login: $current_shell → $fish_bin"
        if chsh -s "$fish_bin" 2>/tmp/chsh.err; then
            log "chsh OK — login shell atualizado em /etc/passwd"
            warn "REINICIE o computador (ou systemd restart plasmalogin.service) — Plasma 6 plasmalogin cacheia SHELL"
        else
            warn "chsh falhou:"
            cat /tmp/chsh.err >&2
            warn "Aplique manualmente (qualquer um):"
            warn "    chsh -s $fish_bin"
            warn "    sudo usermod -s $fish_bin $USER"
        fi
    fi

    echo
    log "Pronto! Reinicie o terminal (ou computador) para ativar as mudancas."
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
        for f in ~/.gitconfig; do
            [ -L "$f" ] && log "$f → $(readlink "$f")" || warn "$f não linkado"
        done
        for d in fish kitty starship fastfetch btop; do
            [ -L "$HOME/.config/$d" ] && log "~/.config/$d → $(readlink "$HOME/.config/$d")" || warn "~/.config/$d não linkado"
        done
        echo
        info "Shell atual:  $SHELL"
        info "Login shell:  $(getent passwd "$USER" | cut -d: -f7)"
        info "fish:      $(command -v fish   2>/dev/null || echo 'NÃO instalado')"
        info "starship:  $(command -v starship 2>/dev/null || echo 'NÃO instalado')"
        info "zoxide:   $(command -v zoxide  2>/dev/null || echo 'NÃO instalado')"
        info "fzf:      $(command -v fzf    2>/dev/null || echo 'NÃO instalado')"
        info "eza:      $(command -v eza    2>/dev/null || echo 'NÃO instalado')"
        info "bat:      $(command -v bat    2>/dev/null || echo 'NÃO instalado')"
        info "btop:     $(command -v btop   2>/dev/null || echo 'NÃO instalado')"
        info "fastfetch:$(command -v fastfetch 2>/dev/null || echo 'NÃO instalado')"
        ;;
    backup)
        log "Backup manual..."
        for p in ~/.gitconfig ~/.config/fish ~/.config/kitty ~/.config/starship ~/.config/fastfetch ~/.config/btop; do
            backup_config "$p"
        done
        log "Backup em: $BACKUP_DIR"
        ;;
    uninstall)
        warn "Removendo symlinks..."
        rm -f ~/.gitconfig
        rm -f ~/.config/fish ~/.config/kitty ~/.config/starship ~/.config/fastfetch ~/.config/btop 2>/dev/null || true
        # Leftover de versões antigas (zsh/bash)
        rm -f ~/.zshrc ~/.bashrc ~/.config/shell/aliases.sh 2>/dev/null || true
        rmdir ~/.config/shell 2>/dev/null || true
        log "Symlinks removidos. Pacotes NÃO foram desinstalados."
        ;;
    *)
        echo "Usage: $0 {install|status|backup|uninstall}"
        exit 1
        ;;
esac
