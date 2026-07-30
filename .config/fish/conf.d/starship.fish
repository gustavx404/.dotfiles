# .config/fish/conf.d/starship.fish
# Starship prompt (mesmo starship.toml já configurado)

if command -q starship
    starship init fish | source
end
