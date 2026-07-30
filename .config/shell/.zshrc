# ~/.zshrc — dotfiles repo
# Tema: Ayu Dark | Prompt: Starship | Fuzzy: fzf | Cd: zoxide | Ls: eza

# ---- Histórico ----
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history

# ---- Opções ----
bindkey -e
setopt auto_cd
setopt interactive_comments
setopt no_beep

# ---- Conclusão ----
autoload -Uz compinit && compinit -d ~/.zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
autoload -Uz colors && colors

# ---- PATH ----
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# ---- Editor ----
export EDITOR=${EDITOR:-nvim}
export VISUAL="$EDITOR"
export PAGER="bat --style=plain" 2>/dev/null || command -v less >/dev/null && export PAGER=less

# ---- Aliases (comuns) ----
[ -f ~/.config/shell/aliases.sh ] && source ~/.config/shell/aliases.sh
# Aliases específicos do ZSH
[ -f ~/.config/shell/aliases.zsh ] && source ~/.config/shell/aliases.zsh

# ---- Starship ----
command -v starship >/dev/null && eval "$(starship init zsh)"

# ---- Zoxide (cd inteligente) ----
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# ---- fzf ----
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
[ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
  --color=fg:#B3B1AD,bg:#0A0E14,hl:#FFD173,fg+:#D9D7CE,bg+:#1C2128,hl+:#FFB454
  --color=info:-1,prompt:#73D0FF,pointer:#73D0FF,marker:#AAD84C,spinner:#F29E74,header:#686868'
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

# ---- eza (substitui ls) ----
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons'
  alias ll='eza -l --group-directories-first --icons --git'
  alias la='eza -la --group-directories-first --icons --git'
  alias lt='eza -lT --icons --git-ignore'
elif command -v exa >/dev/null; then
  alias ls='exa --group-directories-first --icons'
  alias ll='exa -l --group-directories-first --icons --git'
  alias la='exa -la --group-directories-first --icons --git'
fi

# ---- fastfetch no início ----
if command -v fastfetch >/dev/null && [[ -f ~/.config/fastfetch/config.jsonc ]] && [[ -z $LOADED_FF ]]; then
  fastfetch
  export LOADED_FF=1
fi
