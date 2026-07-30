# ~/.config/fish/config.fish — dotfiles repo
# Tema: Ayu Dark | Prompt: Starship | Shell: fish (autosuggestions + syntax highlight nativos)

# ---- Histórico ----
set -g fish_history_size 50000
set -g fish_history_max 50000

# ---- Opções + bindmode ----
fish_default_key_bindings     # emacs-style (Ctrl+A/E/K/etc) — você usa bindkey -e no zsh
set -g fish_key_bindings fish_default_key_bindings

# ---- Ui ----
# Sem greeting ao iniciar o fish (a mensagem default "Bem-vindo ao fish..." é silenciada)
set -g fish_greeting
set -g fish_color_autosuggestion 686868     # cinza Ayu Dark
set -g fish_color_command      green
set -g fish_color_command_valid green        # sugestão de comando válido
set -g fish_color_quote        yellow        # strings amarelas
set -g fish_color_redirection  F29E74        # laranja-magenta
set -g fish_color_end          B3B1AD
set -g fish_color_error        FF6767        # vermelho: erro
set -g fish_color_param        B3B1AD
set -g fish_color_comment      686868
set -g fish_color_operator     73D0FF        # azul Ayu
set -g fish_color_escape       F29E74
set -g fish_color_cwd         73D0FF        # cwd azul
set -g fish_color_user         F29E74
set -g fish_color_host         cyan
set -g fish_color_history_current --bold
set -g fish_color_match        --background=brblue
set -g fish_color_selection    "white" --bold --background=1C2128
set -g fish_color_search_match "white" --bold --background=1C2128
set -g fish_pager_color_prefix 73D0FF       # azul nos completions
set -g fish_pager_color_progress F29E74
set -g fish_pager_color_description 686868

# ---- Sources automagicos ----
# fish auto-sourceia tudo em ~/.config/fish/conf.d/*.fish
# (env.fish, 00-fastfetch.fish, starship.fish, etc — adicionados lá)
