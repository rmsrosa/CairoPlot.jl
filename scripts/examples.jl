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
# c = crplot(x, y; xticks, yticks, Nx, Ny, title)
c = crplot(x, y; title)
write_to_png(c,"perturbedsineplot.png")

title = "Plot of a sine wave"
x = range(0, 10π, length=200)
y = sin.(x)
xticks = 0:5:30
yticks = -1.0:0.25:1.0
# c = crplot(x, y; xticks, yticks, Nx, Ny, title)
c = crplot(x, y; title)
write_to_png(c,"sineplot.png")

xd = today():Year(1):today()+Year(20)
yd = rand(length(xd))

xdticks = today():Year(5):today()+Year(20)
ydticks = 0.0:0.2:1.0

#c = crplot(xd, yd; xticks=xdticks, yticks=ydticks, title="Date evolution")
c = crplot(xd, yd; title="Prediction for the next 20 years")
write_to_png(c,"20years_future.png")

xd = today()-Year(1):Month(1):today()
yd = 100.0 * rand(length(xd))

c = crplot(xd, yd; title="One month evolution")
write_to_png(c,"onemonth_past.png")



nothing
