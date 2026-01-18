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

export BSplineBasis, BSpline, TensorBSplineBasis, TensorBSpline, KnotVector
export NurbsBasis, TensorNurbsBasis, Nurbs, TensorNurbs

export degreeElevate, degreeReduce, degreeIncrease, degreeDecrease, elevateContinuity, reduceContinuity, setDegree, setDegreePreservingMultiplicity
export insertKnot,insertKnots, removeKnot, uniformRefine, uniformCoarsen, uniformRefine_withCoefs, boundary

export eval!, deriv!, deriv2!, evalSingle!, evalFunc!
export _eval, deriv, deriv2, evalSingle, evalFunc

export numElements, multiplicities, uSize, knotContainer
export numActive, numTotalElements, numActive!, numCoefs
export coefs, coefsSize, coefAtCorner
export closestPointTo, elementIndex, elementInSupportOf, active!, isActive
export targetDim, coefDim, geoDim, parDim
export gsGeometry, gsMatrix, gsVector
export toMatrix, toVector

export readFile

export createBSplineRectangle, createBSplineTrapezium, createNurbsArcTrapezium, createBSplineTriangle

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

# Documentation 
include("stubs.jl")

end # module TinyGismo

