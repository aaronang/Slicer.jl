import LinearAlgebra: dot

function intersect(triangles::Vector{Triangle}, plane::Plane)
    filter(l -> l !== nothing, map(t -> intersect(t, plane), triangles))
end

function intersect(triangle::Triangle, plane::Plane)::Union{LineSegment, Nothing}
    intersections = Set(union(intersect(triangle.a, triangle.b, plane),
                              intersect(triangle.b, triangle.c, plane),
                              intersect(triangle.c, triangle.a, plane)))

    length(intersections) == 2 ? LineSegment(intersections...) : nothing
end

"""
    intersect(a::Vertex, b::Vertex, plane::Plane)

Intersect line segment and plane. Two intersections are returned when line
segment is contained in plane.
"""
function intersect(a::Vertex, b::Vertex, plane::Plane)
    intersections = []
    
    adistance = distance(a, plane)
    bdistance = distance(b, plane)

    if adistance * bdistance > eps(Float32)
        return intersections
    end

    ainplane = isapprox(adistance, 0)
    binplane = isapprox(bdistance, 0)

    if ainplane push!(intersections, a) end
    if binplane push!(intersections, b) end

    if ainplane || binplane
        return intersections
    end
    
    t = adistance / (adistance - bdistance)
    push!(intersections, a + t * (b - a))
end

function distance(point::Vertex, plane::Plane)
    dot(point - plane.point, plane.normal)
end
