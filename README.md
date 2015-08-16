# Monitors.jl
Monitors.jl is a Julia package for making program status information available through multiple sources.
It was designed for use in conjunction with long running processes such as optimization, inference, or simulation.

## Monitoring
Monitors.jl provides a Monitor type to handle program monitoring.
A Monitor instance has two distinct pieces of functionality.

The first is standard logging functionality. The primary advantage of
using a Monitor to log is when logging to multiple IOs. A Monitor will
handle the multiple sources behind the scenes without requiring the user
repeat the same code for each IO.

The second piece of functionality is a simple HttpServer for serving JSON data.
This data can then be used in your browser, with something like D3.js for example,
to display visualizations of program status. This has the advantage of separating
visualization code and program code as well as making results available as soon as they
are produced.

## Installation
Monitors.jl is unregistered, to install use
```julia
julia> Pkg.clone("https://github.com/thomlake/Monitors.jl.git")
```

# Logging
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

By default Monitor instances always log to STDOUT for levels `:info` and `:warn` and STDERR for `:erro`.
To suppress this behavior simply pass `false` when instantiating the Monitor, `monitor = Monitor(false)`.
When logging to files, logging levels `:info`, `:warn`, and `:erro` are denoted by [INFO], [WARN], or [ERRO].
When logging to STDOUT or STDERR, the colors green, yellow, and red are used. To have colors work outside of the
REPL, Julia needs to be started with `$ julia --color=yes myscript.jl`.
