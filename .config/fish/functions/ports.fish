# ports — lista portas TCP/UDP em LISTEN (formato curto)

function ports --description "Lista portas em LISTEN"
    ss -tulanp 2>/dev/null | grep LISTEN
end
