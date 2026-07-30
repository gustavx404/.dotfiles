# .config/fish/conf.d/00-fastfetch.fish
# fastfetch roda UMA VEZ ao abrir terminal (LOADED_FF pra não repetir)

if command -q fastfetch; and test -f ~/.config/fastfetch/config.jsonc; and test -z "$LOADED_FF"
    fastfetch
    set -gx LOADED_FF 1
end
