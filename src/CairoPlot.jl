module CairoPlot

using Cairo
using Dates

export crplot

include("main.jl")

#precompile(crplot(0:10, 0:2:20))

end