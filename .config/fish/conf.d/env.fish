# .config/fish/conf.d/env.fish
# PATH, editor, pager, BAT_THEME

set -gx EDITOR (command -v nvim || echo vi)
set -gx VISUAL $EDITOR

# bat como pager (com fallback)
if command -q bat
    set -gx PAGER "bat --style=plain"
    set -gx BAT_THEME "ayu"   # bat com tema Ayu Dark
else
    set -gx PAGER less
end

# PATH — local bin, cargo, opencode
fish_add_path -g $HOME/.local/bin $HOME/.cargo/bin $HOME/.opencode/bin
