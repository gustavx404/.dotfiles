# killporta — mata processo que escuta numa porta
# Ex.: `killporta 8000`
#      `killporta 8000 -9` (passa flags pro kill)

function killporta --description "Mata processo ouvindo na porta informada"
    if test (count $argv) -eq 0
        echo "uso: killporta <porta> [flags pro kill]"
        return 1
    end

    set -l port $argv[1]
    set -l pid (ss -tlnp 2>/dev/null \
                | string match -r '.*:'$port' .*pid=(\d+).*' \
                | tail -1)

    if test -z "$pid"  # fallback: usar lsof se lsof estiver instalado
        if command -q lsof
            set pid (sudo lsof -ti tcp:$port 2>/dev/null | head -1)
        end
    end

    if test -z "$pid"
        echo "nada escutando na porta $port"
        return 1
    end

    echo "matando PID $pid (porta $port)"
    kill $argv[2..] $pid
end
