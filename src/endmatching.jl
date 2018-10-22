import DataStructures: DefaultDict, OrderedSet
import LinearAlgebra: cross, norm
import RegionTrees: AbstractRefinery, needs_refinement, refine_data, child_boundary, Cell, adaptivesampling!,
                    HyperRectangle, isleaf, children
import StaticArrays: SVector

struct QuadRefinery <: AbstractRefinery
    segments::Int32
    diagonal::Float32
    vertexedges::DefaultDict{Vertex, Vector{LineSegment}}
end

"""
    needs_refinement(r::QuadRefinery, cell::Cell)

Determine whether to divide region into another quad. Stop condition is
identical to RepRap Host Software's stop condition.

Reference: https://reprap.org/wiki/EndMatching
"""
function needs_refinement(r::QuadRefinery, cell::Cell)
    rectangle = cell.boundary
    diagonal = sqrt((rectangle.origin[1] + rectangle.widths[1])^2 +
                    (rectangle.origin[2] + rectangle.widths[2])^2)
    segments = Set(vcat(map(v -> r.vertexedges[v], cell.data)))

    length(segments) > r.segments && diagonal > r.diagonal
end

"""
Check if child cell contains given vertex. The indices indicate where the child
cell is located in its parent as shown below.

```
┌────────┬────────┐
│ (1, 2) │ (2, 2) │
├────────┼────────┤
│ (1, 1) │ (2, 1) │
└────────┴────────┘
```
"""
function contains(cell::Cell, indices, vertex)
    boundary = child_boundary(cell, indices)
    xmin = boundary.origin[1]
    xmax = xmin + boundary.widths[1]
    ymin = boundary.origin[2]
    ymax = ymin + boundary.widths[2]

    xcontains = indices[1] == 1 ? xmin <= vertex[1] <= xmax : xmin < vertex[1] <= xmax
    ycontains = indices[2] == 1 ? ymin <= vertex[2] < ymax : ymin <= vertex[2] <= ymax
    xcontains && ycontains
end

function search(cell::Cell, vertex::Vertex)
    if isleaf(cell)
        return cell
    end

    for indices in [(1, 1), (1, 2), (2, 1), (2, 2)]
        if contains(cell, indices, vertex)
            return search(cell[indices...], vertex)
        end
    end
end

function refine_data(r::QuadRefinery, cell::Cell, indices)
    [vertex for vertex in cell.data if contains(cell, indices, vertex)]
end

function match(segments::Vector{LineSegment})::Vector{Polygon}
    vertexedges = DefaultDict{Vertex, Vector{LineSegment}}(Vector{LineSegment})
    for segment in segments
        push!(vertexedges[segment.a], segment)
        push!(vertexedges[segment.b], segment)
    end

    vertices = collect(keys(cache))
    aabb = boundingbox(vertices)
    quadtree = Cell(SVector(aabb.xmin, aabb.ymin), SVector(aabb.xmax, aabb.ymax))
    refinery = QuadRefinery(2, 1e-5, vertexedges)
    adaptivesampling!(quadtree, refinery)

    while !isempty(vertexedges)
        polygon = OrderedSet{Vertex}()
        start = first(vertexedges).first
        push!(polygon, start)
        current = pop!(vertexedges[start])
        delete!(vertexedges, start)

        while haskey(vertexedges, current)
            push!(polygon, current)
            a = pop!(vertexedges[current])
            b = pop!(vertexedges[current])
            @assert isempty(vertexedges[current])
            delete!(vertexedges, current)
            current = in(a, polygon) ? b : a
            push!(polygon, a)
            push!(polygon, b)
        end

        push!(polygons, collect(polygon))
    end

    return polygons
end

function simplify(polygons::Vector{Polygon})
    map(simplify, polygons)
end

function simplify(polygon::Polygon)
    [b for ((a, b), (c, d)) in edges(collect(edges(polygon))) if !iscollinear(b - a, d - c)]
end

function iscollinear(a::Vertex, b::Vertex)
    isapprox(norm(cross(a, b)), 0, atol=1e-2)
end

function correct(polygons::Vector{Polygon})
    corrected = Vector{Polygon}()
    boxes = map(boundingbox, polygons)
    for (i, box) in enumerate(boxes)
        num_enclosing = sum(map(other -> issubset(box, other) ? 1 : 0, boxes))
        if iseven(num_enclosing)
            push!(corrected, isclockwise(polygons[i]) ? reverse(polygons[i]) : polygons[i])
        else
            push!(corrected, !isclockwise(polygons[i]) ? reverse(polygons[i]) : polygons[i])
        end
    end
    corrected
end
