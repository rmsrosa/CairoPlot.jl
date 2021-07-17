# Time to first plot

using BenchmarkTools

@time include(joinpath("..", "src", "CairoPlot.jl"))
@time using Plots; gr()
@time using GR
@time using .CairoPlot

Nx = 640
Ny = 384
title = "Perturbation\n of a sine wave\nwhat else?"
x = range(0, 10π, length=30)
y = sin.(x/5) .+ 0.3randn(length(x))
xticks = 1:5:30
yticks = -1.5:0.5:1.5

@time p = Plots.plot(x, y, title=title)
@time display(p)
@time g = GR.plot(x, y, title=title)
@time display(g)
@time c = CairoPlot.crplot(x, y; xticks, yticks, Nx, Ny, title, padding=(0.00, 0.02, 0.08, 0.02))
@time display(c)

#write_to_png(c,"cairoplotsineexample.png")

#= 
```julia
  0.124250 seconds (52.25 k allocations: 3.099 MiB)
  0.000274 seconds (181 allocations: 14.000 KiB, 1280.88% compilation time)
  0.000290 seconds (156 allocations: 11.984 KiB)
  0.000007 seconds (6 allocations: 192 bytes)
  0.333511 seconds (558.74 k allocations: 34.445 MiB, 21.95% gc time, 98.93% compilation time)
  0.943304 seconds (213.19 k allocations: 4.561 MiB, 1.31% compilation time)
  0.229121 seconds (458.57 k allocations: 25.959 MiB, 10.56% gc time, 97.96% compilation time)
nothing
  0.009630 seconds (2.24 k allocations: 136.368 KiB, 94.21% compilation time)
  1.094656 seconds (817.51 k allocations: 46.853 MiB, 2.47% gc time, 55.03% compilation time)
Cairo.CairoSurfaceBase{UInt32}(Ptr{Nothing} @0x00007fdbef089e20, 640.0, 384.0)
  0.206945 seconds (317.54 k allocations: 19.051 MiB, 95.52% compilation time)
```
=#
