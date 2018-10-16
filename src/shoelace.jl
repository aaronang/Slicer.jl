"""
    isclockwise(polygon::Polygon)

The shoelace formula, also known as Gauss's area formula, is used to determine
whether polygon traversal is clockwise or counter-clockwise. If the sum over the
edges is greater than 0, the curve is clockwise. If the sum over the edges is
lesser than 0, the curve is counter-clockwise. When the sum over the edges
equals 0, the polygon traverses like a figure eight.

Note: The right-handed coordinate system is used.
"""
function isclockwise(polygon::Polygon)
    sum([(b[1] - a[1]) * (b[2] + a[2]) for (a, b) in edges(polygon)]) > 0
end
