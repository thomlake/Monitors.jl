using Monitors

function getcpu()
    topout = readall(pipe(`top -l3`, `grep '^CPU'`))
    lastrow = split(strip(topout), "\n")[end]
    idle = parse(Float64, split(lastrow, " ")[end-1][1:end-1])
    return 100 - idle
end

function main()
    ccall(:jl_exit_on_sigint, Void, (Cint,), 0)
    monitor = Monitor()
    register(monitor, "cpu.log")
    run_server(monitor)

    monitor[:cpu] = Any[]
    cpu = getcpu()
    monitor("CPU: $cpu")
    push!(monitor[:cpu], cpu)
    i = 1
    try
        while true
            cpu = getcpu()
            monitor("CPU: $cpu")
            push!(monitor[:cpu], cpu)
            sleep(1)
        end
    end
    kill_server(monitor)
end

main()
