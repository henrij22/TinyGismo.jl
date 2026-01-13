module TinyGismo

using CxxWrap
using TinyGismo_jll

@wrapmodule(() -> libjltinygismo)

function __init__()
    return @initcxx
end

export BSplineBasis, BSpline, TensorBSplineBasis, TensorBSpline, KnotVector

export degreeElevate, degreeReduce, degreeIncrease, degreeDecrease, elevateContinuity, reduceContinuity
export insertKnot, removeKnot, uniformRefine, uniformCoarsen, uniformRefine_withCoefs

export numElements, multiplicities, uSize, knotContainer
export closestPointTo

export gsGeometry, gsMatrix, gsVector
export toMatrix, toVector

export createBSplineRectangle, createBSplineTrapezium


# Mapping Base.size
Base.size(basis::KnotVector) = size(basis)
Base.size(basis::BSplineBasis) = size(basis)
Base.size(basis::TensorBSplineBasis) = size(basis)


# Default Constructors
BSplineBasis(args...) = BSplineBasis{1}(args...)
gsMatrix(args...) = gsMatrix{Float64}(args...)
gsVector(args...) = gsVector{Float64}(args...)

end # module TinyGismo

