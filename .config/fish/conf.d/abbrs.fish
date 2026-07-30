# .config/fish/conf.d/abbrs.fish
# Abreviações fish (expande ao apertar espaço — sem quebrar igual a alias)

if status is-interactive
    # ---- Navegação ----
    abbr -a ..      '..'
    abbr -a ...     '../..'
    abbr -a ....    '../../..'

    # ---- ls (GNU ls padrão, com cores) ----
    abbr -a ls  'ls --color=auto'
    abbr -a ll  'ls -la --color=auto'
    abbr -a la  'ls -A --color=auto'
    abbr -a l   'ls -CF --color=auto'

    # ---- Git ----
    abbr -a g  git
    abbr -a gs 'git s'
    abbr -a ga 'git a'
    abbr -a gc 'git c'
    abbr -a gp 'git p'
    abbr -a gl 'git l'
    abbr -a gd 'git d'

    # ---- Editor ----
    abbr -a fishrc "$EDITOR ~/.config/fish/config.fish"
    abbr -a reload 'exec fish'

    # ---- Docker ----
    abbr -a dk docker
    abbr -a dc 'docker compose'

    # ---- Util ----
    abbr -a top  'btop 2>/dev/null; or command top'
    abbr -a htop 'btop 2>/dev/null; or command htop'
    abbr -a df   'df -h'
    abbr -a du   'du -h'
    abbr -a free 'free -h'
    abbr -a weather 'curl -s wttr.in | head -20'
end
