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

"""
    npos(v, beginoffset, endoffset, relmin, relmax)

Proportional transformation to map the coordinate to the pixel position.

    * `beginoffset` and `endoffset` are the paddings defining the pixel window
    to draw onto.
    * `relmin` and `relmax` are the values to be taken to `beginoffset` and
    `endoffset`, respectively.
    * `v` is the coordinate value we want to map from.
"""
function npos(v, beginoffset, endoffset, relmin, relmax)
    return  beginoffset .+ (endoffset - beginoffset) * (v - relmin)/(relmax - relmin)
end

function crplot(
    x, y; Nx=512, Ny=384, title="", xticks=nothing, yticks=nothing,
    padding = 0.06
    )

    c = CairoRGBSurface(Nx,Ny)
    ctx = CairoContext(c)

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
    titlesize = 12

    # paddings and tick length
    toppadding, rightpadding, bottompadding, leftpadding = get_paddings(padding)
    titlepadding = 0.02
    titlespacing = 0.01
    ticklength = 0.02*min(Nx,Ny)
    innerpadding = 0.03
    thickpadding = 0.02

    # background for frame around plot
    rectangle(ctx,0.0,0.0,Nx,Ny)
    set_source_rgb(ctx, background_frame_color...)
    fill(ctx)

    # show title and calculate topoffset (top offset from frame to canvas)
    titlelines = strip.(split(title, '\n'))
    set_font_size(ctx, titlesize)
    select_font_face(ctx, "JuliaMono", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)
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

    # calculate chart dimensions
    xmin, xmax = minimum(x), maximum(x)
    ymin, ymax = minimum(y), maximum(y)
    let xspan = xmax - xmin, yspan = ymax - ymin
        xmax += innerpadding*xspan
        xmin -= innerpadding*xspan
        ymax += innerpadding*yspan
        ymin -= innerpadding*yspan
    end

    # calculate remaining offsets
    leftoffset = 0.0 
    if yticks !== nothing
        for yt in yticks
            if ymin ≤ yt ≤ ymax
                leftoffset = max(leftoffset, text_extents(ctx, string(yt))[3])
            end
        end
    end
    leftoffset += 2leftpadding*Nx
    rightoffset = rightpadding*Nx
    bottomoffset = bottompadding*Ny
    thickoffset = thickpadding*Ny

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
        for xt in xticks
            if xmin ≤ xt ≤ xmax
                nt = npos(xt, leftoffset, Nx - rightoffset, xmin, xmax)
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
                height = text_extents(ctx, string(xt))[4]
                move_to(ctx, nt, Ny-bottomoffset+thickoffset+height)
                set_source_rgb(ctx, tickvalues_color...)
                show_text(ctx,string(xt))
            end
        end
    end

    if yticks !== nothing
        for yt in yticks
            if ymin ≤ yt ≤ ymax
                nt = Ny - npos(yt, bottomoffset, Ny-topoffset, ymin, ymax)

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
                width = text_extents(ctx, string(yt))[3]
                move_to(ctx, leftoffset-thickoffset-width, nt)
                set_source_rgb(ctx, tickvalues_color...)
                show_text(ctx, string(yt))
            end
        end
    end

    # draw series
    nx = npos.(x, leftoffset, Nx - rightoffset, xmin, xmax)
    ny = Ny .- npos.(y, bottomoffset, Ny - topoffset, ymin, ymax)

    move_to(ctx, nx[1], ny[1])
    for i in 2:length(nx)-1
        line_to(ctx, nx[i+1], ny[i+1])
    end

    set_line_width(ctx, series_width)
    set_source_rgb(ctx, series_color...)
    stroke(ctx)
    # Cairo.save(ctx) # not sure if needed, but I saw it in examples; it saves the state internally

    return c
end

nothing
