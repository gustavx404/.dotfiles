# Alias adicionais específicos do ZSH (carregado após aliases.sh)

# Histórico melhorado de expansão
alias history-sum='history | awk "{print \$2}" | sort | uniq -c | sort -rn | head -20'

# zsh-specific atalhos
alias reload='exec zsh'
alias path='echo -e ${PATH//:/\\n}'
