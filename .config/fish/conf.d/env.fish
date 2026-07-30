# .config/fish/conf.d/env.fish
# PATH + editor + pager

set -gx EDITOR (command -v nvim || echo vi)
set -gx VISUAL $EDITOR

# less como pager padrão (cat/less do coreutils — sem bat)
if command -q less
    set -gx PAGER less
    set -gx LESS "-R"   # preserva cores ANSI
end

# PATH — local bin, cargo, opencode
fish_add_path -g $HOME/.local/bin $HOME/.cargo/bin $HOME/.opencode/bin
