# ZSH Aliases

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'

# System
alias update='sudo dnf update'
alias install='sudo dnf install'
alias search='dnf search'

# Quick edit
alias zshrc='$EDITOR ~/.config/shell/.zshrc'
alias reload='source ~/.config/shell/.zshrc'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
