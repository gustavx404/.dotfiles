# .config/fish/conf.d/distro.fish
# Aliases que mudam conforme a distro (update/install/search/etc)

if test -f /etc/os-release
    source /etc/os-release 2>/dev/null
else
    set ID unknown
end

switch $ID
    case fedora rhel centos rocky alma
        abbr -a update 'sudo dnf upgrade --refresh'
        abbr -a install 'sudo dnf install'
        abbr -a search 'dnf search'
        abbr -a remove 'sudo dnf remove'
    case ubuntu debian pop linuxmint
        abbr -a update 'sudo apt update; and sudo apt upgrade'
        abbr -a install 'sudo apt install'
        abbr -a search 'apt-cache search'
        abbr -a remove 'sudo apt remove'
    case arch manjaro garuda endeavouros
        abbr -a update 'sudo pacman -Syu'
        abbr -a install 'sudo pacman -S'
        abbr -a search 'pacman -Ss'
        abbr -a remove 'sudo pacman -Rns'
end

abbr -a ports 'ss -tulanp | grep LISTEN'
abbr -a psg   'ps aux | grep -i'
