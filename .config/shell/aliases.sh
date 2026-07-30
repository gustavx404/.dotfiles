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
