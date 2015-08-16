# Monitors.jl
Monitors.jl is a Julia package for making program status information available through multiple sources.
It was designed for use in conjunction with long running processes such as optimization, inference, or simulation.

## Monitoring
Monitors.jl provides a `Monitor` type to handle program monitoring.
A `Monitor` instance has two distinct pieces of functionality.

The first is standard logging functionality. The primary advantage of
using a `Monitor` to log is when logging to multiple `IO`s. A `Monitor` will
handle the multiple sources behind the scenes without requiring the user
repeat the same code for each `IO`.

The second piece of functionality is creating a
[HttpServer.jl](https://github.com/JuliaWeb/HttpServer.jl) `Server` for JSON data.
This data can then be used in your browser, with something like D3.js for example,
to display visualizations of program status. This has the advantage of separating
visualization code and program code as well as making results available as soon as they
are produced.

## Installation
Monitors.jl is unregistered, to install use
```julia
julia> Pkg.clone("https://github.com/thomlake/Monitors.jl.git")
```

## Logging
Logging with Monitors.jl is fairly unsophisticated. Essentially it is just a multiple
output `write` statement with a bit of markup for logging levels (`:info`, `:warn`, `:erro`).

```julia
using Monitors
monitor = Monitor()
register(monitor, "myprog.log")
monitor("It is now $(now())")
monitor(:info, "information")
minitor(:warn, "warning")
monitor(:erro, "error")
```

By default a `Monitor` will always log to `STDOUT` for levels `:info` and `:warn` and `STDERR` for `:erro`.
To suppress this behavior simply instantiate the `Monitor` with `monitor = Monitor(false)`.

When logging to `STDOUT` or `STDERR`, the colors green, yellow, and red are used to denote `:info`, `:warn`, and `:erro`.
In all other cases the logging levels `:info`, `:warn`, and `:erro` are prefixed by [INFO], [WARN], or [ERRO].
To have colors work outside of the REPL, Julia needs to be started with `$ julia --color=yes myscript.jl`.

## Serving JSON
To launch a `Monitor` based HttpServer use `run_server(monitor)`.
Data can be added to the monitor using `Dict` like syntax.

```julia
monitor[:sqrt] = [0.0]
for i = 1:100
    push!(monitor[:sqrt], sqrt(i))
end
monitor[:samples] = randn(100)
```

The served JSON object will now have `.sqrt` and `.samples` fields.

By default the server runs at http://127.0.0.1:8000/. To change this simply call `run_server`
with the desired options `run_server(monitor, host=ip"ip.addr.you.want", port=somenumber)`.

The server instance has three endpoints. The first is a simple test endpoint which
displays the number of requests made to the server, http://host:port/ping/.

The second and third endpoints are for serving JSON data. By default these are available at
http://host:port/data and http://host:port/data?callback=callback. The former simply serves raw JSON
data. The later uses the (JSONP)[https://en.wikipedia.org/wiki/JSONP] technique to work around same origin
policy restrictions.

For a full example of using Monitors.jl to visualize data with D3.js see the
(`examples/cpu/`)[https://github.com/thomlake/Monitors.jl/tree/master/examples/cpu] directory.
