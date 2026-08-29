# ssh-terminfo — instala o terminfo `xterm-kitty` num host remoto (uma vez).
# Use quando não dá pra usar `kitten ssh`: jump host, conexão de dentro do
# tmux, Ansible/scripts, etc.
#
#   ssh-terminfo usuario@host
#
# Depois disso, ncurses (nano, htop, vim...) funciona sem exportar TERM.

function ssh-terminfo --description "copia o terminfo xterm-kitty pro host remoto"
    if test (count $argv) -eq 0
        echo "uso: ssh-terminfo <destino ssh>"
        return 1
    end
    infocmp -x xterm-kitty \
        | command ssh $argv[1] 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo /dev/stdin' \
        && echo "terminfo xterm-kitty instalado em "$argv[1]":~/.terminfo"
end
