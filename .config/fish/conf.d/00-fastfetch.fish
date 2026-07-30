# .config/fish/conf.d/00-fastfetch.fish
# fastfetch roda UMA VEZ ao abrir terminal (LOADED_FF evita repetir
# dentro da mesma sessão fish, porém não é exportado — uma nova janela
# tem LOADED_FF vazio e roda de novo)

if command -q fastfetch; and test -f ~/.config/fastfetch/config.jsonc; and test -z "$LOADED_FF"
    fastfetch
    set -g LOADED_FF 1     # -g local (não -gx): não propaga pra subprocessos
end
