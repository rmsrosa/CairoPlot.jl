module CairoPlot

using Cairo
using Dates

export crplot
export write_to_png

include("main.jl")

#precompile(crplot(0:10, 0:2:20))

end
