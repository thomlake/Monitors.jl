module Monitors

export Monitor,
       register,
       run_server,
       kill_server

using HttpServer
using HttpCommon
using JSON

type Monitor
    usestd::Bool
    server_task::Nullable{Task}
    verbose_server::Bool
    registered_ios::Vector{IO}
    data::Dict{Any,Any}
    Monitor(usestd::Bool=true) = new(usestd, Nullable{Task}(), true, IO[], Dict())
end

Base.getindex(monitor::Monitor, key) = monitor.data[key]

Base.setindex!(monitor::Monitor, value, key) = monitor.data[key] = value

function register(monitor::Monitor, io::IO)
    push!(monitor.registered_ios, io)
end

function register(monitor::Monitor, filename::String, mode::String="w")
    push!(monitor.registered_ios, open(filename, mode))
end

function Base.call(monitor::Monitor, str::String, ending::Char='\n')
    msg = "$str$ending"
    for io in monitor.registered_ios
        write(io, msg)
    end
    if monitor.usestd
        write(STDOUT, msg)
    end
end

const colormap = Dict(:erro=>:red, :warn=>:yellow, :info=>:green)

function Base.call(monitor::Monitor, level::Symbol, str::String, ending::Char='\n')
    msg = "$str$ending"
    prefix = uppercase(string(level))
    for io in monitor.registered_ios
        write(io, "[$prefix] $msg")
    end
    if monitor.usestd
        color = get(colormap, level, :normal)
        if level == :erro
            print_with_color(color, STDERR, "$msg")
        else
            print_with_color(color, STDOUT, "$msg")
        end
    end
end

function Base.close(monitor::Monitor)
    for io in monitor.registered_ios
        if typeof(io) <: IOStream
            try
                close(io)
            end
        end
    end
end

function run_server(monitor::Monitor; name::String="data", port::Int=8000)
    const ping = r"^/ping/"
    const raw = Regex("^/$name/")
    const data = Regex("^/$name?.*")
    count = 0

    function handle(req::Request, res::Response)
        if ismatch(ping, req.resource)
            count += 1
            monitor.verbose_server && monitor(:info, "(HTTP) ping: $count")
            Response("reply $count")
        elseif ismatch(raw, req.resource)
            count += 1
            monitor.verbose_server && monitor(:info, "(HTTP) raw: $count")
            Response(json(monitor.data))
        elseif ismatch(data, req.resource)
            count += 1
            monitor.verbose_server && monitor(:info, "(HTTP) data: $count")
            qargs = parsequerystring(split(req.resource, "?")[2])
            content = string(qargs["callback"], "(", json(monitor.data), ")")
            Response(content)
        else
            count += 1
            monitor.verbose_server && monitor(:erro, "error: $count\n$req")
            Response(404)
        end
    end

    http = HttpHandler(handle)
    http.events["error"] = (client, err) -> monitor.verbose_server && monitor(:erro, "(HTTP) error: $err")
    http.events["listen"] = (port) -> monitor.verbose_server && monitor(:info, "(HTTP) listening on $port...")
    server = Server(http)

    function runner(server)
        try
            run(server, host=IPv4(127,0,0,1), port=port)
        catch err
            if isa(err, InterruptException)
                monitor.verbose_server && monitor(:info, "(HTTP) server shutting down")
            else
                throw(err)
            end
        end
    end
    server_task = @async runner(server)
    monitor.server_task = Nullable(server_task)
end

function kill_server(monitor::Monitor)
    if !isnull(monitor.server_task)
        Base.throwto(get(monitor.server_task), InterruptException())
    end
end

end
