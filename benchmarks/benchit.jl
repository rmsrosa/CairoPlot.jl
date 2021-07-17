# Time to first plot

using BenchmarkTools

display("""include(joinpath("..", "src", "CairoPlot.jl")""")
@time include(joinpath("..", "src", "CairoPlot.jl"))
display("")

display("using Plots; gr()")
@time using Plots; gr()
display("using GR")
@time using GR
display("using Winston")
@time using Winston
display("using .CairoPlot")
@time using .CairoPlot

title = "Perturbation\n of a sine wave"
x = range(0, 10π, length=30)
y = sin.(x/5) .+ 0.3randn(length(x))
xticks = 1:5:30
yticks = -1.5:0.5:1.5

display("")
display("p = Plots.plot(x, y, title=title)")
@time p = Plots.plot(x, y, title=title)
display("g = GR.plot(x, y, title=title)")
@time g = GR.plot(x, y, title=title)
display("w = Winston.plot(x, y, title=title)")
@time w = Winston.plot(x, y, title=title)
display("c = CairoPlot.crplot(x, y; xticks, yticks, title)")
@time c = CairoPlot.crplot(x, y; xticks, yticks, title)

display("")
display("display(g)")
@time display(g)
display("display(p)")
@time display(p)
display("display(w)")
@time display(w)
display("display(c)")
@time display(c)
