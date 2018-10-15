"""
    boundingbox(polygon)

Compute axis-aligned bounding box for polygon.
"""
function boundingbox(polygon)
    sum(map(boundingbox, polygon))
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

function boundingbox(vertex::Vertex)
    AABB(
        vertex[1],  # xmin
        vertex[1],  # xmax
        vertex[2],  # ymin
        vertex[2],  # ymax
        vertex[3],  # zmin
        vertex[3],  # zmax
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

function Base.issubset(a::AABB, b::AABB)
    a.xmin >= b.xmin &&
    a.xmax <= b.xmax &&
    a.ymin >= b.ymin &&
    a.ymax <= b.ymax &&
    a.zmin >= b.zmin &&
    a.zmax <= b.zmax
end
