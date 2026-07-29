# Bash Aliases

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
alias bashrc='$EDITOR ~/.config/shell/.bashrc'
alias reload='source ~/.config/shell/.bashrc'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
