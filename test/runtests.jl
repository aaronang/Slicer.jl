using Test
import Slicer

const STL = joinpath("data", "nist.stl")

@test length(Slicer.load(STL)) == 7392
