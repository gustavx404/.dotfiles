# .config/fish/conf.d/fzf.fish
# fzf + integração (key bindings + colors Ayu Dark)

if command -q fzf
    # Carrega key bindings default do fzf (Alt+C, Ctrl+T, Ctrl+R) — são fishing do /usr/share
    for f in /usr/share/fzf/shell/key-bindings.fish /usr/share/fzf/key-bindings.fish
        test -f $f; and source $f
    end
    fzf_key_bindings 2>/dev/null

    # Cores Ayu Dark
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git 2>/dev/null; or rg --files --hidden --glob "!.git/*" 2>/dev/null'
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git 2>/dev/null'
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --color=fg:#B3B1AD,bg:#0A0E14,hl:#FFD173,fg+:#D9D7CE,bg+:#1C2128,hl+:#FFB454 --color=info:-1,prompt:#73D0FF,pointer:#73D0FF,marker:#AAD84C,spinner:#F29E74,header:#686868'
    set -gx FZF_CTRL_T_OPTS $FZF_DEFAULT_OPTS" --preview 'bat --color=always --style=numbers {} 2>/dev/null; or cat {}' --preview-window=right:60%:wrap"
    set -gx FZF_ALT_C_OPTS $FZF_DEFAULT_OPTS" --preview 'eza --tree --level=1 --icons --color=always {} 2>/dev/null; or ls -la {}' --preview-window=right:50%:wrap"
    set -gx FZF_CTRL_R_OPTS $FZF_DEFAULT_OPTS" --preview 'echo {}' --preview-window=down:3:wrap --header='Ctrl+R history'"
end
