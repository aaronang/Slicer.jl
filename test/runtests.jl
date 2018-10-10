using Test
import Slicer

const STL = joinpath("data", "nist.stl")
triangles = Slicer.load(STL)

@test length(triangles) == 7392
