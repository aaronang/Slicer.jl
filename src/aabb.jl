"""
    boundingbox(triangles::Vector{Triangle})

Compute axis-aligned bounding box for tesselated model.
"""
function boundingbox(triangles::Vector{Triangle})
    sum(map(boundingbox, triangles))
end

function boundingbox(triangle::Triangle)
    matrix = hcat(triangle.a, triangle.b, triangle.c)
    AABB(
        minimum(matrix[1,:]),
        maximum(matrix[1,:]),
        minimum(matrix[2,:]),
        maximum(matrix[2,:]),
        minimum(matrix[3,:]),
        maximum(matrix[3,:]),
    )
end

function Base.:+(a::AABB, b::AABB)
    AABB(
        min(a.xmin, b.xmin),
        max(a.xmax, b.xmax),
        min(a.ymin, b.ymin),
        max(a.ymax, b.ymax),
        min(a.zmin, b.zmin),
        max(a.zmax, b.zmax),
    )
end
