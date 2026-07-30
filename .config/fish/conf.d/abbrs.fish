# .config/fish/conf.d/abbrs.fish
# Abreviações fish (expande ao apertar espaço — sem quebrar igual a alias)

if status is-interactive
    # ---- Navegação ----
    abbr -a ..      '..'
    abbr -a ...     '../..'
    abbr -a ....    '../../..'

    # ---- eza (substitui ls) ----
    if command -q eza
        abbr -a ls 'eza --group-directories-first --icons'
        abbr -a ll 'eza -l --group-directories-first --icons --git'
        abbr -a la 'eza -la --group-directories-first --icons --git'
        abbr -a lt 'eza -lT --icons --git-ignore'
    end

    # ---- Git ----
    abbr -a g  git
    abbr -a gs 'git s'
    abbr -a ga 'git a'
    abbr -a gc 'git c'
    abbr -a gp 'git p'
    abbr -a gl 'git l'
    abbr -a gd 'git d'

    # ---- Editor ----
    abbr -a zshrc  "$EDITOR ~/.config/fish/config.fish"
    abbr -a reload 'exec fish'

    # ---- Docker ----
    abbr -a dk docker
    abbr -a dc 'docker compose'

    # ---- Util ----
    abbr -a top  'btop 2>/dev/null; or command top'
    abbr -a htop 'btop 2>/dev/null; or command htop'
    abbr -a cat  'bat --style=plain 2>/dev/null; or cat'
    abbr -a df   'df -h'
    abbr -a du   'du -h'
    abbr -a free 'free -h'
    abbr -a weather 'curl -s wttr.in | head -20'
end
