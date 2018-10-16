"""
    edges(polygon)

Return iterator over the edges of a polygon.

```jldoctest
julia> collect(edges([1, 2, 3]))
3-element Array{Tuple{Int64,Int64},1}:
 (1, 2)
 (2, 3)
 (3, 1)
```
"""
function edges(polygon)
    zip(polygon, [polygon[2:end]..., polygon[1]])
end
