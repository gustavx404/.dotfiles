# ~/.bashrc — dotfiles repo
# Tema: Ayu Dark | Prompt: Starship | Fuzzy: fzf | Cd: zoxide | Ls: eza

# ---- Histórico ----
HISTFILE=~/.bash_history
HISTSIZE=50000
HISTFILESIZE=50000
export HISTCONTROL=ignoreboth:erasedups:ignorespace
shopt -s histappend

# ---- Opções ----
shopt -s checkwinsize cdspell dirspell globstar
export PROMPT_COMMAND='history -a'

# ---- PATH ----
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.opencode/bin:$PATH"

# ---- Editor / Pager ----
export EDITOR=${EDITOR:-nvim}
export VISUAL="$EDITOR"

# ---- Aliases ----
[ -f ~/.config/shell/aliases.sh ] && source ~/.config/shell/aliases.sh
[ -f ~/.config/shell/aliases.bash ] && source ~/.config/shell/aliases.bash

# ---- eza / exa ----
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons'
  alias ll='eza -la --group-directories-first --git --icons'
  alias la='eza -a --group-directories-first --git --icons'
  alias lt='eza -lT --icons --git-ignore'
fi

# ---- fzf ----
[ -f /usr/share/fzf/shell/key-bindings.bash ] && source /usr/share/fzf/shell/key-bindings.bash
[ -f /usr/share/fzf/shell/completion.bash ] && source /usr/share/fzf/shell/completion.bash
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
  --color=fg:#B3B1AD,bg:#0A0E14,hl:#FFD173,fg+:#D9D7CE,bg+:#1C2128,hl+:#FFB454
  --color=info:-1,prompt:#73D0FF,pointer:#73D0FF,marker:#AAD84C,spinner:#F29E74,header:#686868'

# ---- Starship ----
command -v starship >/dev/null && eval "$(starship init bash)"

# ---- fastfetch no início ----
if command -v fastfetch >/dev/null && [[ -z $LOADED_FF ]]; then
  fastfetch
  export LOADED_FF=1
fi

# ---- Zoxide (deve ficar por último — recomendação oficial) ----
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"

export PATH="$HOME/.opencode/bin:$PATH"
