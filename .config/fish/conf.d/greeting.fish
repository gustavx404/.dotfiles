# .config/fish/conf.d/greeting.fish
# Mensagem de boas-vindas breve e estética com ícones Nerd Font + cores Ayu

if status is-interactive; and test -z "$LOADED_GREETING"
    set -gx LOADED_GREETING 1

    function fish_greeting
        set -l host (hostname)
        set -l kernel (uname -r)
        # Cores Ayu Dark
        set -l blue   (set_color 73D0FF)
        set -l cyan   (set_color 36A3D9)
        set -l green  (set_color AAD84C)
        set -l yellow (set_color FFD173)
        set -l red    (set_color FF6767)
        set -l magenta (set_color F29E74)
        set -l gray   (set_color 686868)
        set -l reset  (set_color normal)

        echo ""
        echo "$blue ~  $red $reset$gray greeting $reset $blue ~$reset"
        echo "  $magenta ($reset$blue $USER $reset$magenta at$reset $cyan $host $reset$magenta)$reset"
        echo "  $magenta ($reset$yellow  kernel $reset$gray $kernel $reset$magenta)$reset"
        echo "  $magenta ($reset$yellow  fish $reset$gray $FISH_VERSION $reset$magenta)$reset"
        echo ""
    end
end
