# mkcd — cria diretório e faz cd nele
# Ex.: `mkcd projetos/novo`

function mkcd --description "mkdir -p + cd"
    if test (count $argv) -eq 0
        echo "uso: mkcd <dir>"
        return 1
    end
    mkdir -p $argv[1]; and cd $argv[1]
end
