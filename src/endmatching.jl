import DataStructures: DefaultDict, OrderedSet
import LinearAlgebra: cross, norm

function match(segments::Vector{LineSegment})::Vector{Polygon}
    cache = DefaultDict{Vertex, Vector{Vertex}}(Vector{Vertex})
    for segment in segments
        push!(cache[segment.a], segment.b)
        push!(cache[segment.b], segment.a)
    end

    polygons = Vector{Polygon}()

    while !isempty(cache)
        polygon = OrderedSet{Vertex}()
        start = first(cache).first
        push!(polygon, start)
        current = pop!(cache[start])
        delete!(cache, start)

        while haskey(cache, current)
            push!(polygon, current)
            a = pop!(cache[current])
            b = pop!(cache[current])
            @assert isempty(cache[current])
            delete!(cache, current)
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
