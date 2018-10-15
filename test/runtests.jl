using Test
import Slicer
import Slicer: Plane, Vertex, Triangle, AABB, LineSegment, Polygon

@testset "Load STL" begin
    stl = joinpath("data", "nist.stl")
    triangles = Slicer.load(stl)

    @test length(triangles) == 7392
end

@testset "Point-plane distance" begin
    plane = Plane((0, 0, 1), (0, 0, 0))

    @test Slicer.distance(Vertex(0, 0, 1), plane) == 1
    @test Slicer.distance(Vertex(1, 1, 1), plane) == 1
    @test Slicer.distance(Vertex(-1, -1, -1), plane) == -1
    @test Slicer.distance(Vertex(0, 0, 0), plane) == 0
end

@testset "Line-plane intersection" begin
    plane = Plane((0, 0, 1), (0, 0, 0))

    @test Slicer.intersect(Vertex(1, 1, 0), Vertex(-1, -1, 0), plane) == [Vertex(1, 1, 0), Vertex(-1, -1, 0)]
    @test Slicer.intersect(Vertex(1, 1, 1), Vertex(-1, -1, -1), plane) == [Vertex(0, 0, 0)]
    @test Slicer.intersect(Vertex(1, 1, 1), Vertex(-1, -1, 1), plane) == []
    @test Slicer.intersect(Vertex(0, 0, 0), Vertex(0, 0, 1), plane) == [Vertex(0, 0, 0)]
end

@testset "Triangle-plane intersection" begin
    plane = Plane((0, 0, 1), (0, 0, 0))
    triangle1 = Triangle((1, 0, 0), (0, 0, 0), (0, 1, 0), (0, 0, 1))
    triangle2 = Triangle((1, 0, 0), (0, 0, -.5), (0, 1, -.5), (0, 0, .5))

    @test Slicer.intersect(triangle1, plane) == LineSegment([0, 0, 0], [0, 1, 0])
    @test Slicer.intersect(triangle2, plane) == LineSegment([0, 0, 0], [0, .5, 0])
    @test Slicer.intersect(triangle1, Plane((0, 0, 1), (0, 0, 5))) == nothing
    @test Slicer.intersect(triangle1, Plane((0, 0, 1), (0, 0, 1))) == nothing
end

@testset "Triangles-plane intersection" begin
    triangle1 = Triangle((1, 0, 0), (0, 0, 0), (0, 1, 0), (0, 0, 1))
    triangle2 = Triangle((1, 0, 0), (0, 0, -.5), (0, 1, -.5), (0, 0, .5))
    triangle3 = Triangle((1, 0, 0), (0, 1, 0), (0, 0, 1), (0, 1, 1))

    @test Slicer.intersect([triangle1, triangle2], Plane((0, 0, 1), (0, 0, 0))) ==
            [LineSegment([0, 0, 0], [0, 1, 0]), LineSegment([0, 0, 0], [0, .5, 0])]
    @test Slicer.intersect([triangle1, triangle3], Plane((0, 0, 1), (0, 0, 0))) ==
            [LineSegment([0, 0, 0], [0, 1, 0])]
    @test Slicer.intersect([triangle1, triangle3], Plane((0, 0, 1), (0, 0, .5))) ==
            [LineSegment([0, .5, .5], [0, 0, .5]), LineSegment([0, .5, .5], [0, 1, .5])]
    @test Slicer.intersect([triangle1, triangle3], Plane((0, 0, 1), (0, 0, 1))) ==
            [LineSegment([0, 1, 1], [0, 0, 1])]
    @test Slicer.intersect([triangle1, triangle3], Plane((1, 0, 0), (0, 0, 0))) == []
end

@testset "Axis-aligned bounding box" begin
    triangle1 = Triangle((1, 0, 0), (0, 0, 0), (0, 1, 0), (0, 0, 1))
    triangle2 = Triangle((1, 0, 0), (0, 0, -.5), (0, 1, -.5), (0, 0, .5))

    @test Slicer.boundingbox(Triangle((1, 0, 0), (0, 0, 0), (0, 1, 0), (0, 0, 1))) == AABB(0, 0, 0, 1, 0, 1)
    @test AABB(0, 0, 0, 1, 0, 42) + AABB(-1, 1, 0, .5, -.5, 1) == AABB(-1, 1, 0, 1, -.5, 42)
    @test Slicer.boundingbox([triangle1, triangle2]) == AABB(0, 0, 0, 1, -.5, 1)
end

@testset "End matching" begin
    @test Slicer.match([
        LineSegment((0, 0, 0), (1, 0, 0)),
        LineSegment((1, 0, 0), (0, 1, 0)),
        LineSegment((0, 1, 0), (0, 0, 0)),
    ]) == [
        Polygon([(0, 0, 0), (0, 1, 0), (1, 0, 0)])
    ]

    @test Slicer.match([
        LineSegment((0, 0, 0), (1, 0, 0)),
        LineSegment((1, 0, 0), (0, 1, 0)),
        LineSegment((0, 1, 0), (0, 0, 0)),
        LineSegment((0, 0, 1), (1, 0, 1)),
        LineSegment((1, 0, 1), (0, 1, 1)),
        LineSegment((0, 1, 1), (0, 0, 1)),
    ]) == [
        Polygon([(0, 0, 0), (0, 1, 0), (1, 0, 0)]),
        Polygon([(1, 0, 1), (0, 1, 1), (0, 0, 1)]),
    ]

    @test Slicer.match([
        LineSegment((0, 0, 0), (1, 0, 0)),
        LineSegment((1, 0, 0), (1, 1, 0)),
        LineSegment((1, 1, 0), (0, 1, 0)),
        LineSegment((0, 1, 0), (0, 0, 0)),
    ]) == [
        Polygon([(1, 1, 0), (0, 1, 0), (0, 0, 0), (1, 0, 0)]),
    ]
end
