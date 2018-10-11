import StaticArrays: SVector

const Vertex = SVector{3, Float32}
const Normal = SVector{3, Float32}

struct Triangle
    normal::Normal
    a::Vertex
    b::Vertex
    c::Vertex
end

struct Plane
    normal::Normal
    point::Vertex
end

struct AABB
    xmin::Float32
    xmax::Float32
    ymin::Float32
    ymax::Float32
    zmin::Float32
    zmax::Float32
end
