using Test
import Slicer
import Slicer: Plane, Vertex, Triangle, AABB

const STL = joinpath("data", "nist.stl")
triangles = Slicer.load(STL)

@test length(triangles) == 7392

plane = Plane((0, 0, 1), (0, 0, 0))

@test Slicer.distance(Vertex(0, 0, 1), plane) == 1
@test Slicer.distance(Vertex(1, 1, 1), plane) == 1
@test Slicer.distance(Vertex(-1, -1, -1), plane) == -1
@test Slicer.distance(Vertex(0, 0, 0), plane) == 0

@test Slicer.intersect(Vertex(1, 1, 0), Vertex(-1, -1, 0), plane) == Set([Vertex(1, 1, 0), Vertex(-1, -1, 0)])
@test Slicer.intersect(Vertex(1, 1, 1), Vertex(-1, -1, -1), plane) == Set([Vertex(0, 0, 0)])
@test Slicer.intersect(Vertex(1, 1, 1), Vertex(-1, -1, 1), plane) == Set()

triangle1 = Triangle((1, 0, 0), (0, 0, 0), (0, 1, 0), (0, 0, 1))
triangle2 = Triangle((1, 0, 0), (0, 0, -.5), (0, 1, -.5), (0, 0, .5))

@test Slicer.intersect(triangle1, plane) == Set([Vertex(0, 0, 0), Vertex(0, 1, 0)])
@test Slicer.intersect(triangle2, plane) == Set([Vertex(0, 0, 0), Vertex(0, .5, 0)])
@test Slicer.intersect([triangle1, triangle2], plane) == Set([Vertex(0, 0, 0), Vertex(0, 1, 0), Vertex(0, .5, 0)])

@test Slicer.boundingbox(Triangle((1, 0, 0), (0, 0, 0), (0, 1, 0), (0, 0, 1))) == AABB(0, 0, 0, 1, 0, 1)
@test AABB(0, 0, 0, 1, 0, 42) + AABB(-1, 1, 0, .5, -.5, 1) == AABB(-1, 1, 0, 1, -.5, 42)
@test Slicer.boundingbox([triangle1, triangle2]) == AABB(0, 0, 0, 1, -.5, 1)
