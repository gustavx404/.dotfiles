# .config/fish/conf.d/distro.fish
# Aliases que mudam conforme a distro (update/install/search/etc)
# /etc/os-release é sintaxe sh, não source em fish — parsear manualmente
# DOTFILES_OS_RELEASE=<path> sobrescreve /etc/os-release (usado em testes)

set -l osr /etc/os-release
if set -q DOTFILES_OS_RELEASE
    set osr $DOTFILES_OS_RELEASE
end

set -l ID unknown
set -l ID_LIKE ""
if test -f $osr
    while read -l line
        if string match -q 'ID=*' -- $line
            set ID (string replace -r '^ID=|"' '' -- $line)
        else if string match -q 'ID_LIKE=*' -- $line
            set ID_LIKE (string replace -r '^ID_LIKE=|"' '' -- $line)
        end
    end < $osr
end

# IDs exatos primeiro; fallback DINÂMICO via ID_LIKE — qualquer derivado
# futuro (CachyOS, Archcraft, etc.) cai na família certa automaticamente.
switch $ID
    case fedora rhel centos rocky alma
        abbr -a update 'sudo dnf upgrade --refresh'
        abbr -a install 'sudo dnf install'
        abbr -a search 'dnf search'
        abbr -a remove 'sudo dnf remove'
    case ubuntu debian pop linuxmint kali
        abbr -a update 'sudo apt update; and sudo apt upgrade'
        abbr -a install 'sudo apt install'
        abbr -a search 'apt-cache search'
        abbr -a remove 'sudo apt remove'
    case arch manjaro garuda endeavouros cachyos
        abbr -a update 'sudo pacman -Syu'
        abbr -a install 'sudo pacman -S'
        abbr -a search 'pacman -Ss'
        abbr -a remove 'sudo pacman -Rns'
    case '*'
        switch "$ID_LIKE"
            case '*arch*'
                abbr -a update 'sudo pacman -Syu'
                abbr -a install 'sudo pacman -S'
                abbr -a search 'pacman -Ss'
                abbr -a remove 'sudo pacman -Rns'
            case '*debian*' '*ubuntu*'
                abbr -a update 'sudo apt update; and sudo apt upgrade'
                abbr -a install 'sudo apt install'
                abbr -a search 'apt-cache search'
                abbr -a remove 'sudo apt remove'
            case '*fedora*' '*rhel*'
                abbr -a update 'sudo dnf upgrade --refresh'
                abbr -a install 'sudo dnf install'
                abbr -a search 'dnf search'
                abbr -a remove 'sudo dnf remove'
        end
end

abbr -a ports 'ss -tulanp | grep LISTEN'
abbr -a psg   'ps aux | grep -i'
