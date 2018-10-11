"""
    load(path::AbstractString)

Load STL file to list of triangles.
"""
function load(path::AbstractString)
    open(path) do stl
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
