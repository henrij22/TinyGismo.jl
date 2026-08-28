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
export THBSplineBasis, HBSplineBasis, THBSpline, HBSpline
export RefinementBox

# Basis/Geometry Modification
# Degree and continuity operations (in-place)
export degreeElevate!, degreeReduce!, degreeIncrease!, degreeDecrease!
export elevateContinuity!, reduceContinuity!
export setDegree!, setDegreePreservingMultiplicity!
export reverse!

# Refinement operations (in-place)
export insertKnot!, insertKnots!, removeKnot!
export uniformRefine!, uniformCoarsen!, uniformRefine_withCoefs!

# Local (hierarchical) refinement
export refine!, unrefine!, refineElements!, unrefineElements!
export refineElements_withCoefs!, unrefineElements_withCoefs!, refine_withCoefs!
export refineSide!, refineBasisFunction!, increaseMultiplicity!

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
export numLevels, treeSize, levelOf, tensorLevel, getLevelAtPoint, levelAtCorner
export elementBoxes
export multiplicities, uSize, knotContainer
export elementIndex, elementInSupportOf, active!, isActive
export numActive, numActive!

## Geometry queries
export numCoefs, coefs, coefsSize, coefAtCorner
export closestPointTo
export convertToBSpline
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

@doc """
    Base.size(basis::THBSplineBasis)

Get the number of basis functions in the truncated hierarchical B-spline basis.

Alias for the C++ `size()` method.
"""
Base.size(basis::THBSplineBasis) = size(basis)

@doc """
    Base.size(basis::HBSplineBasis)

Get the number of basis functions in the hierarchical B-spline basis.

Alias for the C++ `size()` method.
"""
Base.size(basis::HBSplineBasis) = size(basis)

@doc """
    Base.size(matrix::gsMatrix)

Get the dimensions of the matrix as a `(rows, cols)` tuple.

Unlike the counts above this follows the usual `Base.size` contract for array-like objects,
so `size(m, 1)` and generic code that walks the axes behave as expected. `gsMatrix` supports
`m[i, j]`, which makes a dimension tuple the far less surprising choice here.

Use `length` for the total number of entries, which is what the C++ `size()` method returns.
"""
Base.size(matrix::gsMatrix) = (Int(rows(matrix)), Int(cols(matrix)))

@doc """
    Base.size(matrix::gsMatrix, d::Integer)

Get the extent of the matrix along dimension `d`.

Returns `1` for `d > 2`, as `Base` does for any array: `size(A, d)` is not an error beyond
`ndims(A)`, and generic code relies on that.
"""
Base.size(matrix::gsMatrix, d::Integer) = d <= 2 ? Base.size(matrix)[d] : 1

@doc """
    Base.size(vector::gsVector)

Get the dimensions of the vector as the one-element tuple `(length,)`.
"""
Base.size(vector::gsVector) = (Int(rows(vector)),)

@doc """
    Base.size(vector::gsVector, d::Integer)

Get the extent of the vector along dimension `d`, which is its length for `d == 1` and `1`
beyond, matching `Base`.
"""
Base.size(vector::gsVector, d::Integer) = d <= 1 ? Base.size(vector)[d] : 1

@doc """
    Base.length(obj::Union{gsMatrix, gsVector})

Get the total number of entries — `rows * cols` for a matrix.

This is the value the underlying C++ `size()` method returns.
"""
Base.length(matrix::gsMatrix) = Int(TinyGismo.size(matrix))
Base.length(vector::gsVector) = Int(TinyGismo.size(vector))

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

# Hierarchical refinement boxes
include("hbox.jl")

# Documentation
include("stubs.jl")

end # module TinyGismo
