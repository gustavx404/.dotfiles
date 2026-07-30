# killport — kill the process listening on a given port
# Usage:
#   killport 8000
#   killport 8000 -9      # passes extra flags to kill

function killport --description "Kill process listening on the given port"
    if test (count $argv) -eq 0
        echo "usage: killport <port> [flags for kill]"
        return 1
    end

    set -l port $argv[1]
    set -l pid (ss -tlnp 2>/dev/null \
                | string match -r '.*:'$port' .*pid=(\d+).*' \
                | tail -1)

    if test -z "$pid"  # fallback: try lsof if available
        if command -q lsof
            set pid (sudo lsof -ti tcp:$port 2>/dev/null | head -1)
        end
    end

    if test -z "$pid"
        echo "nothing listening on port $port"
        return 1
    end

    echo "killing PID $pid (port $port)"
    kill $argv[2..] $pid
end
