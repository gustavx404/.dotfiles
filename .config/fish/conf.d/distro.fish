# .config/fish/conf.d/distro.fish
# Aliases que mudam conforme a distro (update/install/search/etc)
# /etc/os-release é sintaxe sh, não source em fish — parsear manualmente

set -l ID unknown
if test -f /etc/os-release
    while read -l line
        if string match -q 'ID=*' -- $line
            set ID (string replace -r '^ID=|"' '' -- $line)
            break
        end
    end < /etc/os-release
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
