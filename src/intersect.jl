import LinearAlgebra: dot

function intersect(triangles::Vector{Triangle}, plane::Plane)
    union(map(t -> intersect(t, plane), triangles)...)
end

function intersect(triangle::Triangle, plane::Plane)
    union(intersect(triangle.a, triangle.b, plane),
          intersect(triangle.b, triangle.c, plane),
          intersect(triangle.c, triangle.a, plane))
end

"""
    intersect(a::Vertex, b::Vertex, plane::Plane)

Intersect line segment and plane. Two intersections are returned when line
segment is contained in plane.
"""
function intersect(a::Vertex, b::Vertex, plane::Plane)
    intersections = Set{Vertex}()

    adistance = distance(a, plane)
    bdistance = distance(b, plane)

    ainplane = isapprox(adistance, 0)
    binplane = isapprox(bdistance, 0)

    if ainplane push!(intersections, a) end
    if binplane push!(intersections, b) end

    if ainplane || binplane || adistance * bdistance > eps(Float32)
        return intersections
    end

    t = adistance / (adistance - bdistance)
    push!(intersections, a + t * (b - a))
end

function distance(point::Vertex, plane::Plane)
    dot(point - plane.point, plane.normal)
end
