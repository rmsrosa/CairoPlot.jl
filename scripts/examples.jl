#= include(joinpath("..", "src", "CairoPlot.jl"))

using .CairoPlot =#

using Cairo
using Dates

include(joinpath("..", "src", "main.jl"))

Nx = 640
Ny = 384
title = "Perturbation\n of a sine wave"
x = range(0, 10π, length=30)
y = sin.(x/5) .+ 0.3randn(length(x))
xticks = 0:5:30
yticks = -1.5:0.5:1.5
c = crplot(x, y; xticks, yticks, Nx, Ny, title)
write_to_png(c,"cairoplot_perturbedsineexample.png")

title = "Plot of a sine wave"
x = range(0, 10π, length=200)
y = sin.(x)
xticks = 0:5:30
yticks = -1.0:0.25:1.0
c = crplot(x, y; xticks, yticks, Nx, Ny, title)
write_to_png(c,"cairoplot_sineexample.png")

xd = today():Year(1):today()+Year(20)
yd = rand(length(xd))

xdticks = today():Year(5):today()+Year(20)
ydticks = 0.0:0.2:1.0

c = crplot(xd, yd; xticks=xdticks, yticks=ydticks, title="Date evolution")
write_to_png(c,"cairoplot_dateexample.png")

nothing
