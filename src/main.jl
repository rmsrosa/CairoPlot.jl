# https://github.com/JuliaGraphics/Cairo.jl
# https://www.cairographics.org
# https://www.cairographics.org/tutorial/
# 
"""
    get_paddings(u::Tuple)

Return the top, right, bottom, and left padding in this order from the given value or tuple.

It follows the CSS standards:
    * If a single value is given, it is used in all paddings;
    * If two values are given, the first value gives the top and bottom paddings,
    and the second value gives the right and left values;
    * If three values are given, the first value gives the top paddings, the second
    value gives the right and left paddings, and the third value gives the bottom padding.
    * If four values are given, they yield, in the order, the top, right, bottom, and left
    paddings.
"""
function get_paddings(u::Tuple)
    if any(x -> (x < 0 || x > 1), u)
        throw(ArgumentError("padding is relative to the dimensions and should be between 0.0 and 1.0"))
    end
    if length(u) == 1
        return u[1], u[1], u[1], u[1]
    elseif length(u) == 2
        return u[1], u[2], u[1], u[2]
    elseif length(u) == 2
        return u[1], u[2], u[3], u[1]
    elseif length(u) == 4
        return u[1], u[2], u[3], u[4]
    else
        throw(ArgumentError("padding should either be a Real or a tuple with length between 1 and 4"))
    end
    return nothing
end

function get_paddings(u::Real)
    return get_paddings(Tuple(u))
end

function get_limits(v::AbstractVector{<:Number})
    vmin, vmax = minimum(v), maximum(v)
    if vmin ≈ vmax
        let vunit = oneunit(v)
            vmin -= vunit
            vmax += vunit
        end
    end
    return vmin, vmax
end

function get_limits(v::AbstractVector{<:Date})
    vmin, vmax = minimum(v), maximum(v)
    if vmin == vmax
        let vunit = oneunit(vmax - vmin)
            vmin -= vunit
            vmax += vunit
        end
    end
    return vmin, vmax
end

"""
    npos(v, beginoffset, endoffset, vmin, vmax)

Proportional transformation to map the coordinate to the pixel position.

    * `beginoffset` and `endoffset` are the offsets defining the pixel window
    to draw onto.
    * `vmin` and `vmax` are the values to be taken to `beginoffset` and
    `endoffset`, respectively.
    * `v` is the coordinate value we want to map from.
"""
function npos(v, beginoffset, endoffset, vmin, vmax)
    return  beginoffset .+ (endoffset - beginoffset) * (v - vmin)/(vmax - vmin)
end

function npos(v::Date, beginoffset, endoffset, vmin::Date, vmax::Date)
    return  beginoffset .+ (endoffset - beginoffset) * (v - vmin).value/(vmax - vmin).value
end

function get_tickvalues(vmin::Number, vmax::Number, nticks::Int)
    tstep = round(( vmax - vmin ) / nticks, sigdigits = 1)
    tickvalues = floor(vmin, sigdigits=1) : tstep : ceil(vmax, sigdigits=1)
    return tickvalues
end

function get_tickvalues(vmin::Date, vmax::Date, nticks::Int)
    tstep = div( ( vmax - vmin ), nticks)
    tickvalues = vmin : tstep : vmax
    return tickvalues
end

function crplot(
    x, y; Nx=512, Ny=384, title="", xticks=6, yticks=4,
    padding=(0.01, 0.04, 0.02, 0.01), plotstyle = :lineplot, marker_width = 4,
    titlefontsize = 12, tickfontsize = 10, fontface = "JuliaMono"
    )

    c = CairoRGBSurface(Nx,Ny)
    ctx = CairoContext(c)

    # Set font face
    select_font_face(ctx, fontface, Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)

    # colors
    background_frame_color = (0.25,0.25,0.25)
    background_plot_color = (0.15,0.15,0.15)
    title_color = (1.0, 1.0, 1.0)
    axes_color = (0.8, 0.8, 0.8)
    tickvalues_color = (1.0, 1.0, 1.0)
    series_color = (1.0, 0.25, 0.25)

    # line widths
    guide_lines_width = 1.0
    bar_width = 0.1
    series_width = 2.0

    # paddings and tick length
    toppadding, rightpadding, bottompadding, leftpadding = get_paddings(padding)
    titlepadding = 0.02
    titlespacing = 0.01
    ticklength = 0.02*min(Nx,Ny)
    innerpadding = 0.03
    tickvaluepadding = 0.01

    # background for frame around plot
    rectangle(ctx,0.0,0.0,Nx,Ny)
    set_source_rgb(ctx, background_frame_color...)
    fill(ctx)

    # inner offset
    xinneroffset = innerpadding * Nx
    yinneroffset = innerpadding * Ny

    # show title and calculate top offset (top offset from frame to canvas)
    set_font_size(ctx, titlefontsize)
    titlelines = strip.(split(title, '\n'))
    set_source_rgb(ctx, title_color...)
    Nw = 0.0
    topoffset = (toppadding+titlepadding)*Ny
    for i in 1:length(titlelines)
        width, height = text_extents(ctx, titlelines[i])[3:4]
        Nw = max(Nw, width)
        topoffset += height + titlespacing*Ny
        move_to(ctx, (Nx-width)/2, topoffset)
        show_text(ctx,titlelines[i])
    end
    topoffset += (toppadding+titlepadding)*Ny

    # calculate plot size
    xmin, xmax = get_limits(x)
    ymin, ymax = get_limits(y)

    # Set tick values offsets
    xvalueoffset = tickvaluepadding*Nx
    yvalueoffset = tickvaluepadding*Ny

    # calculate tick values
    if xticks !== nothing
        if xticks isa AbstractVector
            xtickvalues = xticks
        elseif xticks isa Int
            xtickvalues = get_tickvalues(xmin, xmax, xticks)
        else
            throw(Argument(
                "`xticks` should be one of the following:\n" *
                "  `nothing`,\n  an `AbstractVector`,\n  an `Int`.")
            )
        end
    end
    if yticks !== nothing
        if yticks isa AbstractVector
            ytickvalues = yticks
        elseif yticks isa Int
            ytickvalues = get_tickvalues(ymin, ymax, yticks)
        else
            throw(Argument(
                "`yticks` should be one of the following:\n" *
                "  `nothing`,\n  an `AbstractVector`,\n  an `Int`.")
            )
        end
    end

    set_font_size(ctx, tickfontsize)

    # calculate left offset
    leftoffset = 0.0 
    if yticks !== nothing
        for yt in ytickvalues
            leftoffset = max(leftoffset, text_extents(ctx, string(yt))[3])
        end
    end
    leftoffset += xvalueoffset + leftpadding*Nx

    # calculate bottom offset
    bottomoffset = 0.0
    if xticks !== nothing
        for xt in xtickvalues
            bottomoffset = max(bottomoffset, text_extents(ctx, string(xt))[4])
        end
    end
    bottomoffset += yvalueoffset + bottompadding*Ny

    # set right offset
    rightoffset = rightpadding*Nx

    # background for plot
    rectangle(ctx,leftoffset,topoffset,Nx-rightoffset-leftoffset,Ny-bottomoffset-topoffset)
    set_source_rgb(ctx,background_plot_color...)
    fill(ctx)

    # draw axes
    move_to(ctx, leftoffset, topoffset)
    line_to(ctx, leftoffset, Ny - bottomoffset)
    line_to(ctx, Nx-rightoffset, Ny - bottomoffset)
    line_to(ctx, Nx-rightoffset, topoffset)
    line_to(ctx, leftoffset, topoffset)

    set_line_width(ctx, guide_lines_width)
    set_source_rgb(ctx, axes_color...)
    stroke(ctx)

    # draw ticks and grid
    if xticks !== nothing
        for xt in xtickvalues
            nt = npos(xt, leftoffset + xinneroffset,
                Nx - rightoffset - xinneroffset, xmin, xmax)
            if leftoffset ≤ nt ≤ Nx - rightoffset
                # draw bottom tick
                move_to(ctx, nt, Ny - bottomoffset)
                line_to(ctx, nt, Ny - bottomoffset - ticklength)
                set_line_width(ctx, guide_lines_width)
                set_source_rgb(ctx, axes_color...)
                stroke(ctx)
                # draw vertical bar
                move_to(ctx, nt, Ny - bottomoffset - ticklength)
                line_to(ctx, nt, topoffset + ticklength)
                set_line_width(ctx, bar_width)
                set_source_rgb(ctx, axes_color...)
                stroke(ctx)
                # draw top tick
                move_to(ctx, nt, topoffset + ticklength)
                line_to(ctx, nt, topoffset)
                set_line_width(ctx, guide_lines_width)
                set_source_rgb(ctx, axes_color...)
                stroke(ctx)

                # show tick value
                width, height = text_extents(ctx, string(xt))[3:4]
                move_to(ctx, nt-width/2, Ny-bottomoffset+yvalueoffset+height)
                set_source_rgb(ctx, tickvalues_color...)
                show_text(ctx,string(xt))
            end
        end
    end

    if yticks !== nothing
        for yt in ytickvalues
            nt = Ny - npos(yt, bottomoffset - yinneroffset,
                Ny - topoffset - yinneroffset, ymin, ymax)
            if topoffset ≤ nt ≤ Ny - bottomoffset
                # draw left tick
                move_to(ctx, leftoffset, nt)
                line_to(ctx, leftoffset + ticklength, nt)
                set_line_width(ctx, guide_lines_width)
                set_source_rgb(ctx, axes_color...)
                stroke(ctx)

                # draw horizontal bar
                move_to(ctx, leftoffset + ticklength, nt)
                line_to(ctx, Nx - rightoffset - ticklength, nt)
                set_line_width(ctx, bar_width)
                set_source_rgb(ctx, axes_color...)
                stroke(ctx)

                # draw right tick
                move_to(ctx, Nx - rightoffset - ticklength, nt)
                line_to(ctx, Nx - rightoffset, nt)
                set_line_width(ctx, guide_lines_width)
                set_source_rgb(ctx, axes_color...)
                stroke(ctx)

                # show tick value
                width, height = text_extents(ctx, string(yt))[3:4]
                move_to(ctx, leftoffset-xvalueoffset-width, nt+height/2)
                set_source_rgb(ctx, tickvalues_color...)
                show_text(ctx, string(yt))
            end
        end
    end

    # draw series
    nx = npos.(x, leftoffset + xinneroffset,
        Nx - rightoffset - xinneroffset, xmin, xmax)
    ny = Ny .- npos.(y, bottomoffset + yinneroffset,
        Ny - topoffset - yinneroffset, ymin, ymax)
    
    set_source_rgb(ctx, series_color...)

    if plotstyle == :lineplot
        move_to(ctx, nx[1], ny[1])
        for i in 2:length(nx)
            line_to(ctx, nx[i], ny[i])
        end
        set_line_width(ctx, series_width)
        stroke(ctx)
    elseif plotstyle == :scatterplot
        for i in 1:length(nx)
            circle(ctx, nx[i], ny[i], marker_width)
            fill(ctx)
        end
    end

    # Cairo.save(ctx) # not sure if needed, but I saw it in examples; it saves the state internally

    return c
end

nothing
