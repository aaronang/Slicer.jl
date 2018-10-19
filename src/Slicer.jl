module Slicer

using Luxor

include("types.jl")
include("util.jl")
include("stl.jl")
include("intersect.jl")
include("aabb.jl")
include("endmatching.jl")
include("shoelace.jl")

function debug(polygons)
    @svg begin
        for polygon in polygons
            foreach(((a, b),) -> arrow(Point(a[1], a[2]), Point(b[1], b[2]), arrowheadlength=.4, linewidth=.1),
            edges(polygon))
        end
    end
end

function slice(path)
    triangles = load(path)
    polylines = intersect(triangles, Plane((0, 0, 1), (0, 0, 1)))
    polygons = polylines |> match |> simplify |> correct
    debug(polygons)
end

end # module
