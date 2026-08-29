# ssh — dentro do kitty usa `kitten ssh`, que copia o terminfo `xterm-kitty`
# pro host remoto no login. Resolve o erro clássico:
#   ncurses: cannot initialize terminal type ($TERM="xterm-kitty"); exiting
#
# Fora do kitty (ou dentro de tmux/screen, ou sem o kitten) cai no ssh normal.
# git/rsync/scp chamam o binário direto, não passam por esta função.

function ssh --wraps ssh --description "kitten ssh no kitty, ssh normal fora dele"
    if set -q KITTY_WINDOW_ID; and not set -q TMUX; and not set -q STY; and command -q kitten
        kitten ssh $argv
    else
        command ssh $argv
    end
end
