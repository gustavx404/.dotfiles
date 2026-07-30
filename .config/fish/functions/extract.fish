# extract — descompacta qualquer formato conhecido
# Ex.: `extract arquivo.tar.gz`

function extract --description "Descompacta baseado na extensão"
    if test (count $argv) -eq 0
        echo "uso: extract <arquivo>"
        return 1
    end

    set -l f $argv[1]
    if not test -f "$f"
        echo "arquivo não existe: $f"
        return 1
    end

    switch $f
        case '*.tar.bz2' '*.tbz2'
            tar xjf $f
        case '*.tar.gz' '*.tgz'
            tar xzf $f
        case '*.tar.xz' '*.txz'
            tar xJf $f
        case '*.tar.zst'
            tar --zstd -xf $f
        case '*.tar'
            tar xf $f
        case '*.bz2'
            bunzip2 $f
        case '*.gz'
            gunzip $f
        case '*.xz'
            unxz $f
        case '*.zip'
            unzip $f
        case '*.7z'
            7z x $f
        case '*.rar'
            unrar x $f
        case '*.Z'
            uncompress $f
        case '*'
            echo "extensão não suportada: $f"
            return 1
    end
end
