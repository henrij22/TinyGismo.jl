module TinyGismo

using CxxWrap

# Helper
using EnumX

# Binary Dependency
using TinyGismo_jll

@wrapmodule(() -> libjltinygismo)

function __init__()
    return @initcxx
end

# Core Types
# Basis types and geometry types exposed by the module
export BSplineBasis, BSpline, TensorBSplineBasis, TensorBSpline, KnotVector
export NurbsBasis, TensorNurbsBasis, Nurbs, TensorNurbs

# Basis/Geometry Modification
# Degree and continuity operations (in-place)
export degreeElevate!, degreeReduce!, degreeIncrease!, degreeDecrease!
export elevateContinuity!, reduceContinuity!
export setDegree!, setDegreePreservingMultiplicity!
export reverse!

# Refinement operations (in-place)
export insertKnot!, insertKnots!, removeKnot!
export uniformRefine!, uniformCoarsen!, uniformRefine_withCoefs!

# Boundary extraction
export boundary

# Knot span helpers
export centerPoint, lowerCorner, upperCorner, knotSpans

# Evaluation and derivatives
export eval!, _eval
export evalSingle!, evalSingle
export evalFunc!, evalFunc
export deriv!, deriv, deriv2!, deriv2
export derivSingle!, derivSingle
export deriv2Single!, deriv2Single
export derivFunc, deriv2Func

# Queries
## Basis/knot vector queries
export numElements, numTotalElements
export multiplicities, uSize, knotContainer
export elementIndex, elementInSupportOf, active!, isActive
export numActive, numActive!

## Geometry queries
export numCoefs, coefs, coefsSize, coefAtCorner
export closestPointTo
export targetDim, coefDim, geoDim, parDim

# Matrix/Vector utilities
export gsGeometry, gsMatrix, gsVector
export toMatrix, toVector

# I/O
export readFile
export writeParaview, writeParaviewBasisFnct, writeParaviewPoints

# Factory functions (geometry constructors)
export createBSplineRectangle, createBSplineTrapezium, createNurbsArcTrapezium, createBSplineTriangle
export createBSplineSquare, createBSplineSegment, createBSplineUnitInterval
export createBSplineCube, createBSplineHalfCube, createNurbsCube, createNurbsSphere
export createNurbsCircle, createBSplineFatCircle, createBSplineFatDisk
export createNurbsQuarterAnnulus, createNurbsAnnulus
export createNurbsCurve1, createNurbsCurve2

# Mapping Base.size
@doc """
    Base.size(kv::KnotVector)

Get the total number of knots in the knot vector (including multiplicities).

Alias for the C++ `size()` method.
"""
Base.size(kv::KnotVector) = size(kv)

@doc """
    Base.size(basis::BSplineBasis)

Get the number of basis functions in the B-spline basis.

Alias for the C++ `size()` method.
"""
Base.size(basis::BSplineBasis) = size(basis)

@doc """
    Base.size(basis::TensorBSplineBasis)

Get the number of basis functions in the tensor product B-spline basis.

Alias for the C++ `size()` method.
"""
Base.size(basis::TensorBSplineBasis) = size(basis)

@doc """
    Base.size(basis::NurbsBasis)

Get the number of basis functions in the NURBS basis.

Alias for the C++ `size()` method.
"""
Base.size(basis::NurbsBasis) = size(basis)

@doc """
    Base.size(basis::TensorNurbsBasis)

Get the number of basis functions in the tensor product NURBS basis.

Alias for the C++ `size()` method.
"""
Base.size(basis::TensorNurbsBasis) = size(basis)

# Default Constructors
@doc """
    BSplineBasis(args...)

Default constructor for univariate B-spline basis (dimension = 1).

This is a convenience constructor that defaults to `BSplineBasis{1}(args...)`.
"""
BSplineBasis(args...) = BSplineBasis{1}(args...)

@doc """
    NurbsBasis(args...)

Default constructor for univariate NURBS basis (dimension = 1).

This is a convenience constructor that defaults to `NurbsBasis{1}(args...)`.
"""
NurbsBasis(args...) = NurbsBasis{1}(args...)

@doc """
    gsMatrix(args...)

Default constructor for gsMatrix with Float64 element type.

This is a convenience constructor that defaults to `gsMatrix{Float64}(args...)`.
"""
gsMatrix(args...) = gsMatrix{Float64}(args...)

@doc """
    gsVector(args...)

Default constructor for gsVector with Float64 element type.

This is a convenience constructor that defaults to `gsVector{Float64}(args...)`.
"""
gsVector(args...) = gsVector{Float64}(args...)


Base.IndexStyle(::gsMatrix) = IndexLinear()
Base.getindex(v::gsMatrix, i::Int, j::Int) = TinyGismo.value(v, i, j)

# Documentation
include("stubs.jl")

end # module TinyGismo
