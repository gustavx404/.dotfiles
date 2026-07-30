# .config/fish/conf.d/05-fastfetch.fish
# Roda fastfetch no início de cada sessão fish interativa.
# Sem flags/variáveis — toda janela nova do Kitty executa de novo
# (fastfetch é barato e rápido).

if status is-interactive; and command -q fastfetch; and test -f ~/.config/fastfetch/config.jsonc
    fastfetch
end
