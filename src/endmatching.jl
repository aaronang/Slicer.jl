import DataStructures: DefaultDict, OrderedSet
import LinearAlgebra: cross, norm

function match(linesegments::Vector{LineSegment})::Vector{Polygon}
    polygons = Vector{Polygon}()
    segments = Set(linesegments)

    while !isempty(segments)
        polygon = Vector{Vertex}()
        current = pop!(segments)
        push!(polygon, current.a)
        push!(polygon, current.b)
        current = findnearest(current.b, segments)

        while current !== nothing
            delete!(segments, current)
            tail = last(polygon)
            adist = distance(tail, current.a)
            bdist = distance(tail, current.b)
            if adist < bdist
                push!(polygon, current.b)
                current = findnearest(current.b, segments)
            else
                push!(polygon, current.a)
                current = findnearest(current.a, segments)
            end
        end

        pop!(polygon)
        push!(polygons, polygon)
    end

    return polygons
end

function distance(a::Vertex, b::Vertex)
    norm(a - b)
end

function findnearest(vertex::Vertex, segments::Set{LineSegment}, tolerance::Real=1e-3)
    dist = Inf
    nearest = nothing
    for segment in segments
        d = distance(vertex, segment.a)
        if d < dist && d < tolerance
            nearest = segment
            dist = d
        end
        d = distance(vertex, segment.b)
        if d < dist && d < tolerance
            nearest = segment
            dist = d
        end
    end
    nearest
end

function simplify(polygons::Vector{Polygon})
    map(simplify, polygons)
end

function simplify(polygon::Polygon)
    [b for ((a, b), (c, d)) in edges(collect(edges(polygon))) if !iscollinear(b - a, d - c)]
end

function iscollinear(a::Vertex, b::Vertex)
    isapprox(norm(cross(a, b)), 0, atol=1e-3)
end

"""
    correct(polygons::Vector{Polygon})

Correct rotation of polygons. The outer polygon should be counter-clockwise.
"""
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
