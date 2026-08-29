#!/bin/bash
# Dotfiles Installer — CachyOS / Arch (pacman)
# Usage: ./scripts/install.sh [install|status|backup|uninstall]
#
# One-liner (clona sozinho em ~/.dotfiles se rodar via curl | bash):
#   curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/refs/tags/latest/scripts/install.sh | bash

# Sem 'set -e': erros sao tratados manualmente e o script NUNCA aborta no meio —
# falhas sao coletadas em FAILED_STEPS e resumidas no final.
FAILED_STEPS=()

DOTFILES_DIR=""   # filled by resolve_dotfiles_dir; the default value used to short-circuit detection
BACKUP_DIR="$HOME/.config/backup/$(date +%Y%m%d_%H%M%S)"

# Pacotes instalados via pacman (todos nos repos oficiais do CachyOS/Arch).
PACKAGES=(fish kitty neovim git unzip curl github-cli btop fastfetch starship ttf-jetbrains-mono-nerd)

# ---- Cores ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()   { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }
info()  { echo -e "${BLUE}[i]${NC} $1"; }

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------

# Confirma que a maquina e pacman-based (CachyOS/Arch e derivados).
# OS_RELEASE_FILE=<path> sobrescreve /etc/os-release (usado em testes).
is_pacman_system() {
    command -v pacman >/dev/null 2>&1 || return 1
    local osr="${OS_RELEASE_FILE:-/etc/os-release}"
    [ -f "$osr" ] || return 0   # tem pacman e sem os-release: assume Arch
    local id id_like
    id=$(grep -E '^ID='      "$osr" | head -1 | cut -d= -f2 | tr -d '"' | tr -d "'")
    id_like=$(grep -E '^ID_LIKE=' "$osr" | head -1 | cut -d= -f2 | tr -d '"' | tr -d "'")
    case "$id" in
        arch|cachyos|manjaro|garuda|endeavouros|archcraft|artix) return 0 ;;
    esac
    case " $id_like " in
        *" arch "*) return 0 ;;
    esac
    # pacman presente mas distro nao reconhecida — deixa seguir mesmo assim
    return 0
}

# Sincroniza o sistema e instala TUDO numa transacao unica do pacman.
# -Syu evita partial-upgrade; --needed torna o re-run idempotente.
# Retorna !=0 se falhar (caller decide — nunca aborta o script).
pkg_install_all() {
    log "pacman -Syu + instalando: ${PACKAGES[*]}"
    sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}" && return 0
    # retry unico: forca refresh de db (mirror stale / 404) e tenta de novo
    warn "pacman falhou — forçando refresh de db (-Syy) e novo retry..."
    sudo pacman -Syy --noconfirm >/dev/null 2>&1
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
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
    if [ -n "$DOTFILES_DIR" ] && [ -d "$DOTFILES_DIR/.config" ]; then
        return
    fi

    # Rodando via `curl | bash`? Nao ha arquivo em disco (BASH_SOURCE vazio
    # ou "bash") — pula direto pro clone em ~/.dotfiles.
    local script_dir=""
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != bash ]; then
        script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd) || script_dir=""
    fi

    # Rodando de dentro de um clone local?
    # Detecta por arquivos-testemunha (o caminho do config mudou entre versoes)
    if [ -n "$script_dir" ] && { [ -f "$script_dir/.config/fish/config.fish" ] \
        || [ -f "$script_dir/.config/kitty/kitty.conf" ] \
        || [ -f "$script_dir/scripts/install.sh" ]; }; then
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
        # --ff-only eh suficiente na maioria dos casos; se falhar (divergencia,
        # mudancas locais nao-committed, branch em estado sujo), faz reset hard
        # pra garantir que o clone local reflete o remote main.
        if ! git -C "$HOME/.dotfiles" fetch origin main \
            || ! git -C "$HOME/.dotfiles" reset --hard origin/main >/dev/null; then
            warn "git update de ~/.dotfiles falhou — usando estado atual"
        fi
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
    if ! is_pacman_system; then
        warn "pacman não encontrado — este dotfiles é só para CachyOS/Arch."
        warn "Pacotes serão PULADOS (os symlinks continuam sendo aplicados)."
        warn "Instale manualmente: ${PACKAGES[*]}"
    else
        # Cacheia a credencial sudo uma unica vez (evita prompts repetidos)
        sudo -v || warn "sudo sem credencial — etapas de pacote vao avisar e seguir"

        if pkg_install_all; then
            fc-cache -f >/dev/null 2>&1 || true
        else
            warn "instalação de pacotes falhou — rode o installer de novo (mirror stale / senha do sudo)"
            FAILED_STEPS+=("pacman: ${PACKAGES[*]}")
        fi
    fi

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
    link_config "$DOTFILES_DIR/.config/environment.d"      "$HOME/.config/environment.d"
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
            warn "chsh falhou ($(head -1 /tmp/chsh.err 2>/dev/null))"
            # Fallback: se PAM bloquear chsh, usermod -s edita /etc/passwd via root.
            info "Tentando fallback 'sudo usermod -s $fish_bin $USER'..."
            if sudo usermod -s "$fish_bin" "$USER" 2>/tmp/usermod.err; then
                log "usermod OK — login shell atualizado em /etc/passwd"
                warn "REINICIE o computador para a proxima sessao gráfica carregar o fish."
            else
                warn "usermod também falhou: $(head -1 /tmp/usermod.err 2>/dev/null)"
                FAILED_STEPS+=("login shell (chsh/usermod)")
                warn "Aplique manualmente (qualquer um):"
                warn "    chsh -s $fish_bin"
                warn "    sudo usermod -s $fish_bin $USER"
            fi
        fi
    fi

    echo
    if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
        warn "Concluido com ${#FAILED_STEPS[@]} pendencia(s):"
        for s in "${FAILED_STEPS[@]}"; do
            warn "  - $s"
        done
        warn "Re-rodar o installer resolve a maioria (mirror stale, senha do sudo)."
        echo
    fi
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
        info "fish:     $(command -v fish   2>/dev/null || echo 'NÃO instalado')"
        info "kitty:    $(command -v kitty  2>/dev/null || echo 'NÃO instalado')"
        info "nvim:     $(command -v nvim   2>/dev/null || echo 'NÃO instalado')"
        info "starship: $(command -v starship 2>/dev/null || echo 'NÃO instalado')"
        info "btop:     $(command -v btop   2>/dev/null || echo 'NÃO instalado')"
        info "fastfetch:$(command -v fastfetch 2>/dev/null || echo 'NÃO instalado')"
        info "gh:       $(command -v gh     2>/dev/null || echo 'NÃO instalado')"
        info "JetBrainsMono Nerd Font: $(fc-list 2>/dev/null | grep -qi 'jetbrainsmono nerd' && echo 'instalada' || echo 'NÃO instalada')"
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
