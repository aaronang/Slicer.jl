import DataStructures: DefaultDict, OrderedSet

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

function correct!(polygons::Vector{Polygon})
    boxes = map(boundingbox, polygons)
    for (index, box) in enumerate(boxes)
        num_enclosing = sum(map(other -> issubset(box, other) ? 1 : 0, boxes))
        if iseven(num_enclosing)
            isclockwise(polygons[index]) && reverse!(polygons[index])
        else
            !isclockwise(polygons[index]) && reverse!(polygons[index])
        end
    end
    nothing
end
