# ZSH Configuration
# Cross-distro compatible

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory

# Key bindings
bindkey -e

# Completion
autoload -Uz compinit
compinit

# Prompt
PS1='%F{cyan}%n%f@%F{green}%m%f:%F{blue}%~%f%# '

# Source aliases
[ -f ~/.config/shell/aliases.zsh ] && source ~/.config/shell/aliases.zsh

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
