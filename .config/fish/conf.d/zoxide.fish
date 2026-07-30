# .config/fish/conf.d/zoxide.fish
# Zoxide para 'cd' inteligente
# (deixa o `cd` do fish como fallback; `zi` em functions abre o interativo)

if command -q zoxide
    zoxide init fish --cmd cd | source
end
