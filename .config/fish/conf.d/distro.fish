# .config/fish/conf.d/distro.fish
# Aliases de pacote — CachyOS / Arch (pacman). Dotfiles é single-distro.

abbr -a update  'sudo pacman -Syu'
abbr -a install 'sudo pacman -S'
abbr -a search  'pacman -Ss'
abbr -a remove  'sudo pacman -Rns'
abbr -a orphans 'pacman -Qtdq'
abbr -a pacclean 'sudo pacman -Sc'

abbr -a ports 'ss -tulanp | grep LISTEN'
abbr -a psg   'ps aux | grep -i'
