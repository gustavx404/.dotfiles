#!/bin/bash
# Dotfiles Installer — multi-distro
# Usage: ./scripts/install.sh [install|status|backup|uninstall]
# One-liner (cache-bust ?t= ignorance para contornar CDN do GitHub raw):
#   curl -fsSL "https://raw.githubusercontent.com/gustavx404/.dotfiles/main/scripts/install.sh?t=$(date +%s)" | bash

# Sem 'set -e': erros sao tratados manualmente e o script NUNCA aborta no meio —
# falhas sao coletadas em FAILED_STEPS e resumidas no final.
FAILED_STEPS=()

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

# Detecta o gerenciador de pacotes pela distro.
# IDs exatos primeiro; fallback DINAMICO via ID_LIKE (qualquer derivado
# futuro — CachyOS, Archcraft, etc — cai na familia certa automaticamente).
# OS_RELEASE_FILE=<path> sobrescreve /etc/os-release (usado em testes).
detect_distro() {
    local osr="${OS_RELEASE_FILE:-/etc/os-release}"
    local id="" id_like=""
    if [ -f "$osr" ]; then
        id=$(grep -E '^ID=' "$osr" | head -1 | cut -d= -f2 | tr -d '"' | tr -d "'")
        id_like=$(grep -E '^ID_LIKE=' "$osr" | head -1 | cut -d= -f2 | tr -d '"' | tr -d "'")
    fi
    case "$id" in
        fedora|rhel|centos|rocky|alma)            echo dnf;    return 0 ;;
        ubuntu|debian|pop|linuxmint|kali)         echo apt;    return 0 ;;
        arch|manjaro|garuda|endeavouros|cachyos)  echo pacman; return 0 ;;
    esac
    case " $id_like " in
        *" fedora "*|*" rhel "*)   echo dnf;    return 0 ;;
        *" debian "*|*" ubuntu "*) echo apt;    return 0 ;;
        *" arch "*)                echo pacman; return 0 ;;
    esac
    echo unknown
}

# Atualiza db/sistema ANTES de instalar (evita 404 de mirror stale).
# Em Arch rolling, -Syu evita partial-upgrade e ja atualiza o sistema.
pkg_refresh() {
    local pm=$1
    case "$pm" in
        pacman)
            log "Atualizando sistema (pacman -Syu)..."
            sudo pacman -Syu --noconfirm || warn "pacman -Syu falhou — tentando instalar mesmo assim"
            ;;
        apt)
            log "Atualizando indice (apt update)..."
            sudo apt update || warn "apt update falhou — tentando instalar mesmo assim"
            ;;
        dnf)
            sudo dnf makecache --refresh >/dev/null 2>&1 || true
            ;;
    esac
}

# Instala UM pacote; retorna !=0 se falhar (caller decide — nunca aborta)
install_pkg() {
    local pm=$1; shift
    case "$pm" in
        dnf)    sudo dnf install -y "$@" ;;
        apt)    sudo apt install -y "$@" ;;
        pacman)
            sudo pacman -S --needed --noconfirm "$@" && return 0
            # retry unico apos refresh de db (mirror stale/404)
            warn "pacman falhou em '$*' — refresh de db e retry..."
            sudo pacman -Sy --noconfirm >/dev/null 2>&1
            sudo pacman -S --needed --noconfirm "$@"
            ;;
        *) error "PM desconhecido: $pm (pacote: $*)"; return 1 ;;
    esac
}

# Instala starship via script oficial do projeto (não existe em dnf no FC44)
# Único fallback que não é via gerenciador de pacotes.
install_starship_official() {
    command -v starship >/dev/null 2>&1 && { info "starship já instalado"; return; }
    local tmp
    tmp=$(mktemp -d)
    # -b instala em user space; o script oficial exige que o dir ja exista
    mkdir -p "$HOME/.local/bin"
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

# Instala JetBrainsMono Nerd Font.
# Arch/CachyOS: pacote oficial ttf-jetbrains-mono-nerd (preferido).
# Demais: zip direto do GitHub (apt/dnf nao tem a variante Nerd).
install_nerd_font() {
    local pm=${1:-unknown}
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
        info "JetBrainsMono Nerd Font já instalada"
        return
    fi
    if [ "$pm" = pacman ] && pacman -Si ttf-jetbrains-mono-nerd >/dev/null 2>&1; then
        log "Instalando JetBrainsMono Nerd Font via pacman..."
        if install_pkg pacman ttf-jetbrains-mono-nerd; then
            fc-cache -f >/dev/null 2>&1 || true
            return
        fi
        warn "pacote da fonte falhou — tentando zip do GitHub"
    fi
    log "Instalando JetBrainsMono Nerd Font (zip do GitHub)..."
    local font_dir="$HOME/.local/share/fonts/jetbrainsmono-nerd"
    mkdir -p "$font_dir"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    local tmp=$(mktemp -d)
    if command -v curl >/dev/null; then
        curl -fsSL "$url" -o "$tmp/jb.zip" || { warn "download da fonte falhou"; FAILED_STEPS+=("nerd font (download)"); rm -rf "$tmp"; return; }
    elif command -v wget >/dev/null; then
        wget -qO "$tmp/jb.zip" "$url" || { warn "download da fonte falhou"; FAILED_STEPS+=("nerd font (download)"); rm -rf "$tmp"; return; }
    else
        warn "sem curl/wget — pulei a fonte"
        FAILED_STEPS+=("nerd font (sem curl/wget)")
        rm -rf "$tmp"; return
    fi
    unzip -qo "$tmp/jb.zip" -d "$font_dir" 2>/dev/null || { warn "unzip falhou"; FAILED_STEPS+=("nerd font (unzip)"); }
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
    local pm=$(detect_distro)
    log "Gerenciador de pacotes: $pm"

    if [ "$pm" = unknown ]; then
        warn "Distro nao reconhecida — pacotes serao PULADOS (symlinks continuam)."
        warn "Instale manualmente: fish kitty git unzip curl btop fastfetch starship"
    else
        # Cacheia a credencial sudo uma unica vez (evita prompts repetidos)
        sudo -v || warn "sudo sem credencial — etapas de pacote vao avisar e seguir"
        pkg_refresh "$pm"
    fi

    # Dependências — só via gerenciador de pacotes, sem cargo/pip/etc
    # Exceções (fallback): starship em dnf antigo e a Nerd Font fora do Arch
    # Mapeia nome do binario -> nome do pacote por distro
    pkg_for() {  # <binary> <pm>
        case "$1" in
            gh)  [ "$2" = pacman ] && echo github-cli || echo gh ;;
            *)   echo "$1" ;;
        esac
    }

    local need=()
    for c in fish kitty git unzip curl gh btop fastfetch; do
        if ! command -v "$c" >/dev/null 2>&1; then
            need+=("$c")
        fi
    done
    if [ "$pm" != unknown ] && [ ${#need[@]} -gt 0 ]; then
        info "Pacotes via ${pm}: ${need[*]}"
        # instala um-a-um para não derrubar a transação inteira
        local failed=()
        for bin in "${need[@]}"; do
            local pkg
            pkg=$(pkg_for "$bin" "$pm")
            if install_pkg "$pm" "$pkg"; then
                log "instalado: $bin"
            else
                warn "falhou: $bin"
                failed+=("$bin")
            fi
        done
        if [ ${#failed[@]} -gt 0 ]; then
            warn "Não instalados via ${pm}: ${failed[*]}"
            FAILED_STEPS+=("pacotes ${pm}: ${failed[*]}")
        fi
    elif [ "$pm" != unknown ]; then
        info "Todos os pacotes via ${pm} já estão instalados"
    fi

    # starship — pacote de sistema onde existe (Arch/CachyOS, Debian/Ubuntu
    # recentes); script oficial como fallback (dnf do Fedora nao empacota)
    if ! command -v starship >/dev/null 2>&1; then
        local starship_missing=1
        if [ "$pm" = pacman ] || [ "$pm" = apt ]; then
            info "instalando starship via ${pm}"
            install_pkg "$pm" starship && starship_missing=0
        fi
        if [ "$starship_missing" -eq 1 ]; then
            info "instalando starship via script oficial (ssl-only, sem cargo)"
            install_starship_official && starship_missing=0
        fi
        if [ "$starship_missing" -eq 1 ]; then
            warn "instalação do starship falhou"
            FAILED_STEPS+=("starship")
        fi
    fi

    install_nerd_font "$pm"

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
            # Fallback comum em distro pen-test (Kali, Parrot): PAM bloqueia chsh
            # para usuarios sem aquela linha em /etc/pam.d/chsh. usermod -s edita
            # /etc/passwd direto via root e contorna isso.
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
        info "starship: $(command -v starship 2>/dev/null || echo 'NÃO instalado')"
        info "btop:     $(command -v btop   2>/dev/null || echo 'NÃO instalado')"
        info "fastfetch:$(command -v fastfetch 2>/dev/null || echo 'NÃO instalado')"
        info "gh:       $(command -v gh     2>/dev/null || echo 'NÃO instalado')"
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
