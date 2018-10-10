module Slicer

struct Vertex
    x::Float32
    y::Float32
    z::Float32
end

const Vector = Vertex

struct Triangle
    normal::Vector
    u::Vertex
    v::Vertex
    w::Vertex
end

function load(stlpath::AbstractString)
    open(stlpath) do stl
        skip(stl, 80)  # skip header
        trianglecount = read(stl, UInt32)
        ref = Ref{Triangle}()
        triangles = map(1:trianglecount) do i
            read!(stl, ref)
            skip(stl, 2)  # skip attribute byte count
            ref[]
        end
        @assert eof(stl)
        return triangles
    end
end

end # module
