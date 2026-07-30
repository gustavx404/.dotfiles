# zi — zoxide interativo com fzf (anda com cd inteligente)
# Ex.: `zi` → lista todos dirs; `zi proj` → filtra por "proj"

function zi --description "cd inteligente interativo (zoxide + fzf + preview eza)"
    if not command -q zoxide; or not command -q fzf
        echo "zi precisa de zoxide e fzf instalados"
        return 1
    end
    set -l result (zoxide query --list --score 2>/dev/null \
        | fzf --tac --nth 2.. \
              --preview 'eza --tree --level=2 --icons --color=always {2} 2>/dev/null; or ls -la {2}' \
              --preview-window=right:50%:wrap \
              --header='zoxide directories' \
              --query "$argv[1]")
    if test -n "$result"
        cd (string replace -r '^\S+\s+' '' -- $result)
    end
end
