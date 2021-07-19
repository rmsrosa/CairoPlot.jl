using Dates

include(joinpath("..", "src", "CairoPlot.jl"))
using .CairoPlot

# using Cairo
# include(joinpath("..", "src", "main.jl"))

x = today():Year(1):today()+Year(20)
y = rand(length(x))

xticks = today():Year(5):today()+Year(20)
yticks = 0.0:0.2:1.0

c = CairoPlot.crplot(x, y; xticks, yticks)
write_to_png(c,"cairoplot_dateexample.png")

nothing