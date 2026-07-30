# Aliases comuns (sourced por .zshrc e .bashrc)

# ----- Navegação -----
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ----- Listagem (vai ser sobrescrita por eza/exa se disponível) -----
alias ls='ls --color=auto'
alias ll='ls -la --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# ----- Sistema (auto-detecta distro) -----
. /etc/os-release 2>/dev/null
case "$ID" in
    fedora|rhel|centos|Rocky)
        alias update='sudo dnf upgrade --refresh'
        alias install='sudo dnf install'
        alias search='dnf search'
        alias remove='sudo dnf remove'
        alias upgrade='sudo dnf distro-sync' ;;
    ubuntu|debian|pop)
        alias update='sudo apt update && sudo apt upgrade'
        alias install='sudo apt install'
        alias search='apt-cache search'
        alias remove='sudo apt remove'
        alias upgrade='sudo apt full-upgrade' ;;
    arch|garuda|manjaro)
        alias update='sudo pacman -Syu'
        alias install='sudo pacman -S'
        alias search='pacman -Ss'
        alias remove='sudo pacman -Rns'
        alias upgrade='sudo pacman -Syu' ;;
esac

# ----- Git -----
alias g='git'
alias gs='git s'
alias ga='git a'
alias gc='git c'
alias gp='git p'
alias gl='git l'
alias gd='git d'

# ----- Containers -----
alias dk='docker'
alias dc='docker compose'

# ----- Utilitários comuns -----
alias cat='bat --style=plain 2>/dev/null || cat'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tulanp | grep LISTEN'
alias psg='ps aux | grep -i'
alias top='btop 2>/dev/null || top'   # btop substitui top quando disponível
alias htop='btop 2>/dev/null || htop'

# mkcd: cria dir e faz cd em um comando
mkcd() { mkdir -p "$1" && cd "$1" }

# killporta: mata processo que escuta na PORTA informada
killporta() {
    local port=$1 pid
    [ -z "$port" ] && { echo "uso: killporta <porta>"; return 1; }
    pid=$(ss -tlnp 2>/dev/null | grep ":$port " | grep -oP 'pid=\K[0-9]+' | head -1)
    if [ -z "$pid" ]; then
        echo "nada escutando na porta $port"
        return 1
    fi
    echo "matando PID $pid (porta $port)"
    kill "${@:2}" "$pid"
}

# extract: descompacta qualquer formato conhecido
extract() {
    local f=$1
    [ -z "$f" ] && { echo "uso: extract <arquivo>"; return 1; }
    [ ! -f "$f" ] && { echo "arquivo não existe: $f"; return 1; }
    case "$f" in
        *.tar.bz2|*.tbz2)  tar xjf "$f" ;;
        *.tar.gz|*.tgz)    tar xzf "$f" ;;
        *.tar.xz|*.txz)    tar xJf "$f" ;;
        *.tar.zst)         tar --zstd -xf "$f" ;;
        *.tar)             tar xf "$f" ;;
        *.bz2)             bunzip2 "$f" ;;
        *.gz)              gunzip "$f" ;;
        *.xz)              unxz "$f" ;;
        *.zip)             unzip "$f" ;;
        *.7z)              7z x "$f" ;;
        *.rar)             unrar x "$f" ;;
        *.Z)               uncompress "$f" ;;
        *) echo "extensão não suportada: $f"; return 1 ;;
    esac
}

# ----- Edição rápida -----
alias zshrc='$EDITOR ~/.zshrc'
alias bashrc='$EDITOR ~/.bashrc'
alias reloadzsh='source ~/.zshrc'

# ----- Senurança -----
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ----- Misc -----
alias weather='curl -s wttr.in | head -20'
alias ip='curl -s ifconfig.me; echo'
