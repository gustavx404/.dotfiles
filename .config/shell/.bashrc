# Bash Configuration
# Cross-distro compatible

# History
HISTFILE=~/.bash_history
HISTSIZE=10000
SAVEHIST=10000
export HISTCONTROL=ignoreboth:erasedups

# Prompt
PS1='\[\e[36m\]\u\e[0m@\[\e[32m\]\h\e[0m:\[\e[34m\]\w\e[0m\$ '

# Source aliases
[ -f ~/.config/shell/aliases.bash ] && source ~/.config/shell/aliases.bash

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
