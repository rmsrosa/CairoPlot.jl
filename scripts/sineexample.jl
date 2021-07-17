include(joinpath("..", "src", "CairoPlot.jl"))

using .CairoPlot

Nx = 640
Ny = 384
title = "Perturbation\n of a sine wave\nwhat else?"
x = range(0, 10π, length=30)
y = sin.(x/5) .+ 0.3randn(length(x))
xticks = 1:5:30
yticks = -1.5:0.5:1.5
c = crplot(x, y; xticks, yticks, Nx, Ny, title, padding=(0.00, 0.02, 0.08, 0.02))
#write_to_png(c,"cairoplotsineexample.png")

nothing
