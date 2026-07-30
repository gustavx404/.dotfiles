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
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.opencode/bin:$PATH"

# ---- Editor / Pager / bat ----
export EDITOR=${EDITOR:-nvim}
export VISUAL="$EDITOR"
export PAGER="bat --style=plain" 2>/dev/null || command -v less >/dev/null && export PAGER=less
export BAT_THEME="ayu"      # bat com tema Ayu Dark (instalado nativamente em bat >= 0.18)

# ---- Aliases (comuns) ----
[ -f ~/.config/shell/aliases.sh ] && source ~/.config/shell/aliases.sh
# Aliases específicos do ZSH
[ -f ~/.config/shell/aliases.zsh ] && source ~/.config/shell/aliases.zsh

# ---- Aliases específicos do ZSH
[ -f ~/.config/shell/aliases.zsh ] && source ~/.config/shell/aliases.zsh

# ============================================================
# zsh plugins (autosuggestions + syntax-highlighting)
# Source seguro — silencioso se não instalado
# ============================================================
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#686868'   # cinza Ayu Dark
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
bindkey '^I'  _zsh_autosuggest_accept         # Tab aceita sugestão
bindkey '^E'  _zsh_autosuggest_accept_line    # End aceita tudo

[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Cores Ayu Dark via $ZSH_HIGHLIGHT_STYLES (defaults já combinam, override se quiser)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF6767'         # vermelho: comando inválido
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#73D0FF'               # azul: builtin
ZSH_HIGHLIGHT_STYLES[command]='fg=#AAD84C'              # verde: comando válido
ZSH_HIGHLIGHT_STYLES[alias]='fg=#73D0FF'                # azul: alias
ZSH_HIGHLIGHT_STYLES[path]='fg=#FFD173,underline'       # amarelo underline: path
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#FFD173'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#FFD173'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#F29E74'               # laranja: atribuição

# ---- Starship ----
command -v starship >/dev/null && eval "$(starship init zsh)"

# ---- fzf ----
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
# completion.zsh só existe em algumas distros; se houver, usa
[ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh

# FZF com paleta Ayu Dark + preview bat/--color=always
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || rg --files --hidden --glob "!.git/*" 2>/dev/null'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
  --color=fg:#B3B1AD,bg:#0A0E14,hl:#FFD173,fg+:#D9D7CE,bg+:#1C2128,hl+:#FFB454
  --color=info:-1,prompt:#73D0FF,pointer:#73D0FF,marker:#AAD84C,spinner:#F29E74,header:#686868'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}' --preview-window=right:60%:wrap"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null'
export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --preview 'eza --tree --level=1 --icons --color=always {} 2>/dev/null || ls -la {}' --preview-window=right:50%:wrap"
export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window=down:3:wrap --header='Ctrl+R history'"

# zi: zoxide interativo com preview fzf (anda com cd inteligente)
if command -v zoxide >/dev/null && command -v fzf >/dev/null; then
  zi() {
    local result
    result=$(zoxide query --list --score 2>/dev/null \
      | fzf --tac --nth 2.. \
          --preview 'eza --tree --level=2 --icons --color=always {2} 2>/dev/null || ls -la {2}' \
          --preview-window=right:50%:wrap \
          --header='zoxide directories') || return
    cd "${result##* }" || return
  }
fi

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

# ---- Zoxide (deve ficar por último — recomendação oficial) ----
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
