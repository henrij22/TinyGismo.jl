## File to hold docstrings

@doc """
    gsBasis

Abstract base type for all basis function types in TinyGismo.

# Details
`gsBasis` is the parent type for all spline basis functions, including:
- `BSplineBasis`: Univariate B-spline bases
- `TensorBSplineBasis`: Tensor product B-spline bases
- `NurbsBasis`: Univariate NURBS bases
- `TensorNurbsBasis`: Tensor product NURBS bases

All basis types support common operations such as evaluation, differentiation, 
degree elevation, and refinement.

# See Also
- [`BSplineBasis`](@ref)
- [`TensorBSplineBasis`](@ref)
- [`NurbsBasis`](@ref)
- [`TensorNurbsBasis`](@ref)
"""
gsBasis

@doc """
    gsGeometry

Abstract base type for all geometry types in TinyGismo.

# Details
`gsGeometry` is the parent type for all geometric objects, including:
- `BSpline`: Univariate and multivariate B-spline curves/surfaces
- `TensorBSpline`: Tensor product B-spline surfaces and volumes
- `Nurbs`: Univariate and multivariate NURBS curves/surfaces
- `TensorNurbs`: Tensor product NURBS surfaces and volumes

All geometry types support common operations such as evaluation, derivatives,
closest point queries, and geometric refinement.

# See Also
- [`BSpline`](@ref)
- [`TensorBSpline`](@ref)
- [`Nurbs`](@ref)
- [`TensorNurbs`](@ref)
"""
gsGeometry

@doc """
    BSplineBasis(knotVector::KnotVector)

Construct a univariate B-spline basis from a knot vector.

# Arguments
- `knotVector`: The knot vector defining the basis

# Returns
A B-spline basis object

# Examples
```julia
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
basis = BSplineBasis(kv)
```
"""
function BSplineBasis end

@doc """
    TensorBSplineBasis{2}(knotVector1::KnotVector, knotVector2::KnotVector)

Construct a bivariate tensor product B-spline basis from two knot vectors.

The parametric dimension must be given explicitly as a type parameter; there is no
unparameterized `TensorBSplineBasis(kv1, kv2)` convenience constructor.

# Arguments
- `knotVector1`, `knotVector2`: Knot vectors for each parametric direction

# Returns
A `TensorBSplineBasis{2}`

# Examples
```julia
kv1 = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
kv2 = KnotVector([0.0, 0.0, 1.0, 1.0])
basis = TensorBSplineBasis{2}(kv1, kv2)
```
"""
function TensorBSplineBasis end

@doc """
    knots(basis::BSplineBasis, i::Int=1)

Get the knot vector for a given parametric direction.

# Arguments
- `basis`: The B-spline basis
- `i`: The parametric direction (default: 1)

# Returns
The knot vector for direction `i`
"""
function knots end

@doc """
    knot(basis::BSplineBasis, i::Int)

Get the `i`-th knot value.

# Arguments
- `basis`: The B-spline basis
- `i`: The knot index

# Returns
The knot value at index `i`
"""
function knot end

@doc """
    TinyGismo.size(obj)

The raw C++ `size()` method: the number of basis functions of a basis, the number of knots
of a knot vector, or the total number of entries of a matrix or vector.

# Arguments
- `obj`: A basis, [`KnotVector`](@ref), [`gsMatrix`](@ref) or [`gsVector`](@ref)

# Returns
The count, as an unsigned integer

# Note
Prefer the `Base` methods, which need no `TinyGismo.` prefix:

- `size(basis)` and `size(kv)` forward here and return the same count.
- `size(m)` on a matrix or vector returns a **dimension tuple** instead, following the usual
  `Base.size` contract, with `length(m)` giving the total entry count that this method
  returns.
"""
function size end

@doc """
    numElements(basis::gsBasis)
    numElements(basis::gsBasis, side::Int)
    numElements(kv::KnotVector)

Get the number of elements (knot spans).

Without a second argument this is the total element count of the whole domain — the product
over all parametric directions for a tensor product basis.

# Arguments
- `basis`: The basis
- `side`: A **boxSide** (`1`/`2` west and east, `3`/`4` south and north), *not* a parametric
  direction. The result is the number of elements lying along that boundary side. Passing `0`
  (or `-1`) gives the total, as in the one-argument form.

# Returns
The number of elements

# Note
To count elements **per parametric direction** on a tensor product basis, use
[`TinyGismo.component`](@ref): `numElements(component(basis, i))`.
"""
function numElements end

@doc """
    numTotalElements(basis::TensorBSplineBasis)

Get the total number of elements in a tensor product basis.

# Arguments
- `basis`: The tensor product B-spline basis

# Returns
The total number of elements across all parametric directions
"""
function numTotalElements end

@doc """
    degree(obj::Union{KnotVector, BSplineBasis, NurbsBasis, BSpline, Nurbs})
    degree(obj::Union{TensorBSplineBasis, TensorNurbsBasis, TensorBSpline, TensorNurbs}, i::Int)

Get the polynomial degree of a knot vector, basis or geometry.

Knot vectors and univariate objects take no further argument. Tensor product objects
**require** the parametric direction `i` (1-based), since the degree may differ per
direction.

# Arguments
- `obj`: The knot vector, basis or geometry object
- `i`: The parametric direction, 1-based (tensor product objects only)

# Returns
The polynomial degree

# Examples
```julia
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
degree(kv)                            # 2, deduced from the end multiplicities
degree(BSplineBasis(kv))              # 2
degree(TensorBSplineBasis{2}(kv, kv), 1)
```
"""
function degree end

@doc """
    order(basis::BSplineBasis)

Get the order of the B-spline basis.

The order equals the polynomial degree plus one.

# Arguments
- `basis`: The B-spline basis

# Returns
The order of the basis (degree + 1)
"""
function order end

@doc """
    insertKnot!(basis::BSplineBasis, knot::Float64, mult::Int=1)

Insert a knot into the basis.

This operation refines the basis by inserting a knot value. The multiplicity determines how many times the knot is inserted.

# Arguments
- `basis`: The B-spline basis (modified in-place)
- `knot`: The knot value to insert
- `mult`: The multiplicity of insertion (default: 1)

# Note
This operation modifies the basis in-place.
"""
function insertKnot! end

@doc """
    removeKnot!(basis::BSplineBasis, knot::Float64, mult::Int=1)

Remove a knot from the basis.

# Arguments
- `basis`: The B-spline basis (modified in-place)
- `knot`: The knot value to remove
- `mult`: The multiplicity of removal (default: 1)

# Note
This operation modifies the basis in-place.
"""
function removeKnot! end

@doc """
    insertKnots!(basis::BSplineBasis, knots::Vector{Float64})

Insert multiple knots into the basis.

# Arguments
- `basis`: The B-spline basis (modified in-place)
- `knots`: A vector of knot values to insert

# Note
This operation modifies the basis in-place.
"""
function insertKnots! end

@doc """
    numActive(basis::gsBasis)

Get the number of basis functions that are nonzero on any single element.

This does not depend on the evaluation point: it is `p + 1` for a univariate basis of degree
`p`, and the product of `pᵢ + 1` over the parametric directions of a tensor product basis.

# Arguments
- `basis`: Any B-spline or NURBS basis, univariate or tensor product

# Returns
The number of active basis functions per element

# Examples
```julia
numActive(BSplineBasis(kv))               # p + 1
numActive(TensorBSplineBasis{2}(k1, k2))  # (p1 + 1) * (p2 + 1)
```

# See Also
- [`active!`](@ref) for the indices of those functions at a given point
"""
function numActive end

@doc """
    component(basis::TensorBSplineBasis, i::Int)

Get the univariate B-spline basis component for a parametric direction.

# Arguments
- `basis`: The tensor product B-spline basis
- `i`: The parametric direction (1-indexed)

# Returns
The univariate B-spline basis for direction `i`
"""
function component end

# deriv! is documented below for gsBasis/gsGeometry (more general)
function deriv! end

# deriv2! is documented below for gsBasis/gsGeometry (more general)
function deriv2! end

@doc """
    NurbsBasis(knotVector::KnotVector)
    NurbsBasis(knotVector::KnotVector, weights::Vector{Float64})
    NurbsBasis(basis::BSplineBasis, weights::Vector{Float64})

Construct a univariate NURBS (Non-Uniform Rational B-Spline) basis from a knot vector and optional weights.

# Arguments
- `knotVector`: The knot vector defining the basis
- `weights`: Control point weights (optional, defaults to uniform weights)
- `basis`: Existing B-spline basis to convert to NURBS

# Returns
A NURBS basis object

# Details
NURBS bases generalize B-spline bases by associating weights with control points, allowing for more flexible shape control and exact representation of conic sections.

# Examples
```julia
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
basis = NurbsBasis(kv)

# With weights
w = [1.0, 1.0, sqrt(2)/2, 1.0, 1.0]
basis = NurbsBasis(kv, w)
```
"""
function NurbsBasis end

@doc """
    TensorNurbsBasis{2}(knotVector1::KnotVector, knotVector2::KnotVector, weights::Matrix{Float64})

Construct a bivariate tensor product NURBS basis from two knot vectors and weights.

The parametric dimension must be given explicitly as a type parameter.

# Arguments
- `knotVector1`, `knotVector2`: Knot vectors for each parametric direction
- `weights`: One weight per basis function as a single-column matrix, ordered
  lexicographically with the first parametric direction running fastest

# Returns
A `TensorNurbsBasis{2}`

# Details
Tensor product NURBS surfaces are formed by taking the tensor product of univariate NURBS bases, with weights controlling the influence of each control point.

# Examples
```julia
kv1 = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])   # 3 functions
kv2 = KnotVector([0.0, 0.0, 1.0, 1.0])             # 2 functions
w = reshape([1.0, sqrt(2)/2, 1.0, 1.0, sqrt(2)/2, 1.0], 6, 1)
basis = TensorNurbsBasis{2}(kv1, kv2, w)
```
"""
function TensorNurbsBasis end

@doc """
    KnotVector(knots::Vector{Float64})

Construct a knot vector from a vector of knot values.

# Arguments
- `knots`: A vector of knot values (non-decreasing)

# Returns
A knot vector object

# Details
A knot vector is a non-decreasing sequence of real numbers that define the parametric domain and behavior of B-spline and NURBS bases.

# Examples
```julia
knots = [0.0, 0.0, 0.0, 0.25, 0.5, 0.75, 1.0, 1.0, 1.0]
kv = KnotVector(knots)
```
"""
function KnotVector end


# size already documented above
function size end

@doc """
    uSize(knotVector::KnotVector)

Get the number of unique knot values.

# Arguments
- `knotVector`: The knot vector

# Returns
The number of unique knots
"""
function uSize end

# numElements already documented above
function numElements end

@doc """
    unique(knotVector::KnotVector)

Get the unique knot values from the knot vector.

# Arguments
- `knotVector`: The knot vector

# Returns
A vector of unique knot values in ascending order
"""
function unique end

@doc """
    multiplicities(knotVector::KnotVector)

Get the multiplicity of each unique knot value.

# Arguments
- `knotVector`: The knot vector

# Returns
A vector of multiplicities corresponding to each unique knot

# Details
The multiplicity of a knot indicates how many times that knot value appears in the knot vector. Higher multiplicity reduces continuity at that knot.
"""
function multiplicities end

@doc """
    knotContainer(knotVector::KnotVector)

Get the underlying knot values as an array.

# Arguments
- `knotVector`: The knot vector

# Returns
A const array view of the knot values
"""
function knotContainer end

@doc """
    multiplicity(knotVector::KnotVector, u::Real)

Get the multiplicity of a single knot value.

# Arguments
- `knotVector`: The knot vector
- `u`: The knot value to look up

# Returns
How many times `u` occurs in the knot vector, or `0` if it is not a knot at all

# Details
This is the per-value counterpart of [`multiplicities`](@ref), which returns the multiplicity
of every unique knot at once. A knot of multiplicity `m` in a degree-`p` basis leaves the
spline `C^(p-m)` continuous there.

# Examples
```julia
kv = KnotVector([0.0, 0.0, 0.0, 0.25, 0.5, 0.5, 1.0, 1.0, 1.0])
multiplicity(kv, 0.5)   # 2
multiplicity(kv, 0.3)   # 0 -- not a knot
```
"""
function multiplicity end

@doc """
    greville!(knotVector::KnotVector, out::gsMatrix{Float64})

Compute all Greville abscissae of the knot vector (in-place).

# Arguments
- `knotVector`: The knot vector
- `out`: Output `gsMatrix{Float64}`, filled with a `1 × n` row of abscissae, one per basis
  function (modified in-place)

# Details
The `i`-th Greville abscissa is the average of the `p` knots following knot `i`, for degree
`p`. They are the canonical interpolation sites of a spline space: a control point placed at
its Greville abscissa gives a curve that stays close to the control polygon, which makes them
the usual choice for control-point-based interpolation and for plotting a control net against
the parameter axis.

# Examples
```julia
kv = KnotVector([0.0, 0.0, 0.0, 0.25, 0.5, 0.5, 1.0, 1.0, 1.0])
out = gsMatrix()
greville!(kv, out)
toVector(out)   # [0.0, 0.125, 0.375, 0.5, 0.75, 1.0]
```

# See Also
- [`greville`](@ref)
"""
function greville! end

@doc """
    greville(knotVector::KnotVector)
    greville(knotVector::KnotVector, i::Int)

Get the Greville abscissae of the knot vector.

Without an index, returns all of them as a `1 × n` [`gsMatrix`](@ref) — read it with
[`toVector`](@ref). With an index, returns that single abscissa as a `Float64`, 1-based.

# Arguments
- `knotVector`: The knot vector
- `i`: The index of a single abscissa (1-based)

# Returns
A `gsMatrix` of all abscissae, or a single `Float64`

# Examples
```julia
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
toVector(greville(kv))   # [0.0, 0.25, 0.75, 1.0]
greville(kv, 2)          # 0.25
```

# See Also
- [`greville!`](@ref) for the in-place variant
"""
function greville end


# degree already documented above
function degree end

# degreeIncrease! is documented below for gsBasis/gsGeometry (more general)
function degreeIncrease! end

# degreeDecrease! is documented below for gsBasis/gsGeometry (more general)
function degreeDecrease! end

# degreeElevate! is documented below for gsBasis/gsGeometry (more general)
function degreeElevate! end

# uniformRefine! is documented below for gsBasis (more general)
function uniformRefine! end
# gsBasis methods (applicable to all basis types)

@doc """
    elementIndex(basis::gsBasis, u::Union{Vector{Float64}, Matrix{Float64}})

Get the index of the knot span element containing a parametric point.

# Arguments
- `basis`: The basis
- `u`: A parametric point (vector) or multiple points (matrix, one per column)

# Returns
The element index (1-indexed)

# Details
Returns the index of the knot span containing the given parameter value(s).
"""
function elementIndex end

@doc """
    elementInSupportOf(basis::gsBasis, j::Int)

Get the knot spans in the support of the `j`-th basis function.

# Arguments
- `basis`: The basis
- `j`: The basis function index (1-indexed)

# Returns
A `gsMatrix{Float64}` holding the lower and upper corner of *one* element contained in the
support of basis function `j` — the coordinates of an element, not a list of element indices,
and not the whole support.

# See Also
- [`knotSpans`](@ref) to iterate over every element of the mesh
- [`isActive`](@ref) to test a single function at a single point
"""
function elementInSupportOf end

@doc """
    active!(basis::gsBasis, u::Union{Vector{Float64}, Matrix{Float64}}, out::gsMatrix{Int32})

Get the indices of active basis functions at parametric point(s) (in-place).

# Arguments
- `basis`: The basis
- `u`: A parametric point (vector) or multiple points (matrix)
- `out`: Output gsMatrix{Int32} to store active basis indices (modified in-place, 1-indexed)

# Details
Returns the indices of all basis functions that are nonzero at the given parametric point(s).
"""
function active! end

@doc """
    isActive(basis::gsBasis, i::Int, u::Vector{Float64})

Check if the `i`-th basis function is active (nonzero) at a parametric point.

# Arguments
- `basis`: The basis
- `i`: The basis function index (1-indexed)
- `u`: The parametric point

# Returns
Boolean indicating whether the basis function is active at the point
"""
function isActive end

@doc """
    degreeElevate!(obj::Union{gsBasis, gsGeometry}, i::Int=1, dir::Int=0)

Elevate the polynomial degree of a basis or geometry.

# Arguments
- `obj`: A basis or geometry object (modified in-place)
- `i`: The amount to elevate degree by (default: 1)
- `dir`: The parametric direction, 1-based, or `0` for all directions (default: `0`)

Directions outside `0:parDim(obj)` are rejected with an error.

# Note
This operation modifies the object in-place.
"""
function degreeElevate! end

@doc """
    degreeReduce!(obj::Union{gsBasis, gsGeometry}, i::Int=1, dir::Int=0)

Reduce the polynomial degree of a basis or geometry.

# Arguments
- `obj`: A basis or geometry object (modified in-place)
- `i`: The amount to reduce degree by (default: 1)
- `dir`: The parametric direction, 1-based, or `0` for all directions (default: `0`)

Directions outside `0:parDim(obj)` are rejected with an error.

# Note
This operation modifies the object in-place.
"""
function degreeReduce! end

@doc """
    degreeIncrease!(obj::Union{gsBasis, gsGeometry}, i::Int=1, dir::Int=0)

Increase the polynomial degree of a basis or geometry.

# Arguments
- `obj`: A basis or geometry object (modified in-place)
- `i`: The amount to increase degree by (default: 1)
- `dir`: The parametric direction, 1-based, or `0` for all directions (default: `0`)

Directions outside `0:parDim(obj)` are rejected with an error.

# Note
This operation modifies the object in-place.
"""
function degreeIncrease! end

@doc """
    degreeDecrease!(obj::Union{gsBasis, gsGeometry}, i::Int=1, dir::Int=0)

Decrease the polynomial degree of a basis or geometry.

# Arguments
- `obj`: A basis or geometry object (modified in-place)
- `i`: The amount to decrease degree by (default: 1)
- `dir`: The parametric direction, 1-based, or `0` for all directions (default: `0`)

Directions outside `0:parDim(obj)` are rejected with an error.

# Note
This operation modifies the object in-place.
"""
function degreeDecrease! end

@doc """
    elevateContinuity!(basis::gsBasis, i::Int=1, dir::Int=0)

Elevate the continuity of the basis.

# Arguments
- `basis`: The basis (modified in-place)
- `i`: The number of continuity levels to increase (default: 1)
- `dir`: The parametric direction, 1-based, or `0` (equivalently `-1`) for all directions (default: `0`)

# Details
Elevates continuity by increasing the polynomial degree and adjusting knot multiplicities.

# Note
This operation modifies the basis in-place.
"""
function elevateContinuity! end

@doc """
    reduceContinuity!(basis::gsBasis, i::Int=1, dir::Int=0)

Reduce the continuity of the basis.

# Arguments
- `basis`: The basis (modified in-place)
- `i`: The number of continuity levels to decrease (default: 1)
- `dir`: The parametric direction, 1-based, or `0` (equivalently `-1`) for all directions (default: `0`)

# Note
This operation modifies the basis in-place.
"""
function reduceContinuity! end

@doc """
    setDegree!(basis::gsBasis, i::Int)

Set the polynomial degree of the basis to a specific value.

# Arguments
- `basis`: The basis (modified in-place)
- `i`: The target polynomial degree

# Note
This operation modifies the basis in-place.
"""
function setDegree! end

@doc """
    setDegreePreservingMultiplicity!(basis::gsBasis, i::Int)

Set the polynomial degree while preserving knot multiplicities.

# Arguments
- `basis`: The basis (modified in-place)
- `i`: The target polynomial degree

# Note
This operation modifies the basis in-place.
"""
function setDegreePreservingMultiplicity! end

@doc """
    boundary(basis::gsBasis, s::Int)
    boundary(geo::gsGeometry, s::Int)

Extract a side of the domain.

For a **basis**, returns the indices of the basis functions that are nonzero on that side, as
a single-column matrix (read it with [`toVector`](@ref)).

For a **geometry**, returns that side as a geometry of one lower parametric dimension,
wrapped in a C++ `unique_ptr` to the abstract base class — dereference it with `[]` before
use, e.g. `west = boundary(geo, 1)[]`.

# Arguments
- `basis` / `geo`: The basis or geometry
- `s`: The boxSide describing the side: `1`/`2` are west and east (``u = 0`` and ``u = 1``),
  `3`/`4` are south and north.
"""
function boundary end

@doc """
    reverse!(basis::gsBasis)

Reverse the basis (flip the parametric direction).

# Arguments
- `basis`: The basis (modified in-place)

# Note
This operation modifies the basis in-place.
"""
function reverse! end

@doc """
    eval!(obj::Union{gsBasis, gsGeometry}, u::Vector{Float64}, out::gsMatrix{Float64})

Evaluate basis functions or geometry at parametric point(s) (in-place).

# Arguments
- `obj`: A basis or geometry object
- `u`: Parametric point(s) (vector or matrix where columns are points)
- `out`: Output gsMatrix{Float64} to store values (modified in-place)

# Details
For basis objects, evaluates all basis functions that are nonzero at the given point(s).
For geometry objects, evaluates the geometry at the given parametric point(s).
"""
function eval! end

@doc """
    _eval(obj::Union{gsBasis, gsGeometry}, u::Vector{Float64})

Evaluate basis functions or geometry at parametric point(s).

# Arguments
- `obj`: A basis or geometry object
- `u`: Parametric point(s)

# Returns
For basis objects, returns a matrix of basis function values.
For geometry objects, returns a matrix of evaluated points.
"""
function _eval end

@doc """
    evalSingle!(basis::gsBasis, i::Int, u::Vector{Float64}, out::gsMatrix{Float64})

Evaluate a single basis function at parametric point(s) (in-place).

# Arguments
- `basis`: The basis
- `i`: The basis function index (1-indexed)
- `u`: Parametric point(s)
- `out`: Output gsMatrix{Float64} (modified in-place)
"""
function evalSingle! end

@doc """
    evalSingle(basis::gsBasis, i::Int, u::Vector{Float64})

Evaluate a single basis function at parametric point(s).

# Arguments
- `basis`: The basis
- `i`: The basis function index (1-indexed)
- `u`: Parametric point(s)

# Returns
The basis function values
"""
function evalSingle end

@doc """
    evalFunc!(basis::gsBasis, u::Vector{Float64}, coefs::Union{Vector{Float64}, Matrix{Float64}}, out::gsMatrix{Float64})

Evaluate a function represented in the basis (in-place).

# Arguments
- `basis`: The basis
- `u`: Parametric evaluation points
- `coefs`: Control point coefficients (vector or matrix)
- `out`: Output gsMatrix{Float64} to store function values (modified in-place)

# Details
Evaluates the function defined by ∑(coefs_i × basis_i) at the given points.
"""
function evalFunc! end

@doc """
    evalFunc(basis::gsBasis, u::Vector{Float64}, coefs::Union{Vector{Float64}, Matrix{Float64}})

Evaluate a function represented in the basis.

# Arguments
- `basis`: The basis
- `u`: Parametric evaluation points
- `coefs`: Control point coefficients (vector or matrix)

# Returns
A matrix of function values
"""
function evalFunc end

@doc """
    deriv!(obj::Union{gsBasis, gsGeometry}, u::Vector{Float64}, out::gsMatrix{Float64})

Evaluate the first derivative (in-place).

# Arguments
- `obj`: A basis or geometry object
- `u`: Parametric evaluation points
- `out`: Output gsMatrix{Float64} to store derivatives (modified in-place)

# Details
For basis objects, evaluates the derivatives of basis functions.
For geometry objects, evaluates the derivative (tangent) of the geometry.
"""
function deriv! end

@doc """
    derivSingle!(basis::gsBasis, i::Int, u::Vector{Float64}, out::gsMatrix{Float64})

Evaluate the first derivative of a single basis function (in-place).

# Arguments
- `basis`: The basis
- `i`: The basis function index (1-indexed)
- `u`: Parametric evaluation points
- `out`: Output gsMatrix{Float64} (modified in-place)
"""
function derivSingle! end

@doc """
    derivSingle(basis::gsBasis, i::Int, u::Vector{Float64})

Evaluate the first derivative of a single basis function.

# Arguments
- `basis`: The basis
- `i`: The basis function index (1-indexed)
- `u`: Parametric evaluation points

# Returns
The derivative values
"""
function derivSingle end

@doc """
    derivFunc(basis::gsBasis, u::Vector{Float64}, coefs::Union{Vector{Float64}, Matrix{Float64}})

Evaluate the first derivative of a function represented in the basis.

# Arguments
- `basis`: The basis
- `u`: Parametric evaluation points
- `coefs`: Control point coefficients (vector or matrix)

# Returns
A matrix of derivative values
"""
function derivFunc end

@doc """
    deriv2!(obj::Union{gsBasis, gsGeometry}, u::Vector{Float64}, out::gsMatrix{Float64})

Evaluate the second derivative (in-place).

# Arguments
- `obj`: A basis or geometry object
- `u`: Parametric evaluation points
- `out`: Output gsMatrix{Float64} to store second derivatives (modified in-place)

# Details
For basis objects, evaluates the second derivatives of basis functions.
For geometry objects, evaluates the second derivative (curvature information) of the geometry.
"""
function deriv2! end

@doc """
    deriv2Single!(basis::gsBasis, i::Int, u::Vector{Float64}, out::gsMatrix{Float64})

Evaluate the second derivative of a single basis function (in-place).

# Arguments
- `basis`: The basis
- `i`: The basis function index (1-indexed)
- `u`: Parametric evaluation points
- `out`: Output gsMatrix{Float64} (modified in-place)
"""
function deriv2Single! end

@doc """
    deriv2Single(basis::gsBasis, i::Int, u::Vector{Float64})

Evaluate the second derivative of a single basis function.

# Arguments
- `basis`: The basis
- `i`: The basis function index (1-indexed)
- `u`: Parametric evaluation points

# Returns
The second derivative values
"""
function deriv2Single end

@doc """
    deriv2Func(basis::gsBasis, u::Vector{Float64}, coefs::Union{Vector{Float64}, Matrix{Float64}})

Evaluate the second derivative of a function represented in the basis.

# Arguments
- `basis`: The basis
- `u`: Parametric evaluation points
- `coefs`: Control point coefficients (vector or matrix)

# Returns
A matrix of second derivative values
"""
function deriv2Func end

@doc """
    uniformRefine!(basis::gsBasis, numKnots::Int=1, mul::Int=1)

Uniformly refine the basis by inserting knots.

# Arguments
- `basis`: The basis (modified in-place)
- `numKnots`: Number of knots to insert in each span (default: 1)
- `mul`: Multiplicity of each inserted knot (default: 1)

# Note
This operation modifies the basis in-place.
"""
function uniformRefine! end

@doc """
    uniformCoarsen!(basis::gsBasis, numKnots::Int=1)

Uniformly coarsen the basis by removing knots.

# Arguments
- `basis`: The basis (modified in-place)
- `numKnots`: Number of knots to remove from each span (default: 1)

# Note
This operation modifies the basis in-place.
"""
function uniformCoarsen! end

@doc """
    uniformRefine_withCoefs!(basis::gsBasis, coefs::Matrix{Float64}, numKnots::Int=1, mul::Int=1)

Uniformly refine the basis and compute the matching refined control points.

# Arguments
- `basis`: The basis (modified in-place)
- `coefs`: Control point coefficients, one row per basis function
- `numKnots`: Number of knots to insert in each span (default: 1)
- `mul`: Multiplicity of each inserted knot (default: 1)

# Returns
A `gsMatrix` of refined coefficients, with one row per function of the refined basis

# Details
The refined basis together with the returned coefficients represents exactly the same
function as the original pair did.

The coefficients are **not** updated in place: refinement adds control points, so the result
has more rows than `coefs`. Only the basis is modified in place, hence the `!`.

`coefs` must have exactly `size(basis)` rows, otherwise an error is raised.

# Examples
```julia
basis = BSplineBasis(kv)
newcoefs = toMatrix(uniformRefine_withCoefs!(basis, coefs))
refined = BSpline(basis, newcoefs)   # the same curve in a richer space
```
"""
function uniformRefine_withCoefs! end


@doc raw"""
    knotSpans(basis::gsBasis)

Returns a list of the Knot Spans, i.e. elements in reference space.

For a tensor product basis the spans tile the parameter domain, ordered with the first
parametric direction running fastest.

# Common Methods
- [`centerPoint`](@ref)
- [`lowerCorner`](@ref)
- [`upperCorner`](@ref)

Each of these returns a [`gsVector`](@ref) with one entry per parametric direction.
"""
function knotSpans end


# BSpline methods

@doc """
    BSpline(basis::BSplineBasis, coefs::Union{Vector{Float64}, Matrix{Float64}})

Construct a B-spline curve or surface from a basis and control points.

# Arguments
- `basis`: The B-spline basis
- `coefs`: Control point coefficients (vector for curves, matrix for surfaces)

# Returns
A BSpline object

# Details
A B-spline is defined by a basis and control points. The basis determines the spline space, and the control points define the actual geometry.

# Examples
```julia
basis = BSplineBasis(kv)
coefs = [1.0, 2.0, 3.0, 4.0]
spline = BSpline(basis, coefs)
```
"""
function BSpline end

@doc """
    numCoefs(spline::BSpline)

Get the number of control points.

# Arguments
- `spline`: The B-spline

# Returns
The number of control points
"""
function numCoefs end

# knots already documented above

# insertKnot! already documented above
function insertKnot! end

# degree already documented above
function degree end

@doc """
    basis(spline::BSpline)

Get the underlying B-spline basis.

# Arguments
- `spline`: The B-spline

# Returns
The BSplineBasis used by the spline
"""
function basis end

# boundary already documented above
function boundary end

# coefAtCorner already documented above
function coefAtCorner end

# gsGeometry methods (applicable to all geometries including BSpline, Nurbs, etc.)

@doc """
    coefsSize(geometry::gsGeometry)

Get the size (number of control points).

# Arguments
- `geometry`: The geometry

# Returns
The number of control points
"""
function coefsSize end

@doc """
    coefs(geometry::gsGeometry)

Get the control points (coefficients) of the geometry.

# Arguments
- `geometry`: The geometry

# Returns
A matrix of control point coordinates
"""
function coefs end

@doc """
    coefAtCorner(geometry::gsGeometry, c::Int)

Get the control point at a specific corner.

# Arguments
- `geometry`: The geometry
- `c`: The corner index

# Returns
The control point coordinates at that corner
"""
function coefAtCorner end

# eval! already documented above for gsBasis
function eval! end

# _eval already documented above
function _eval end

# deriv! already documented above for gsBasis
function deriv! end

@doc """
    deriv(obj::Union{gsBasis, gsGeometry}, u::Union{Vector{Float64}, Matrix{Float64}})

Evaluate the first derivative.

# Arguments
- `obj`: A basis or geometry object
- `u`: Parametric evaluation points

# Returns
For basis objects, returns a matrix of basis function derivatives.
For geometry objects, returns a matrix of derivative (tangent) vectors.
"""
function deriv end

# deriv2! already documented above
function deriv2! end

@doc """
    deriv2(obj::Union{gsBasis, gsGeometry}, u::Union{Vector{Float64}, Matrix{Float64}})

Evaluate the second derivative.

# Arguments
- `obj`: A basis or geometry object
- `u`: Parametric evaluation points

# Returns
A matrix of second derivative vectors
"""
function deriv2 end

@doc """
    closestPointTo(geometry::gsGeometry, pt::Vector{Float64}, result::gsVector{Float64})

Find the closest point on the geometry to a given point.

# Arguments
- `geometry`: The geometry
- `pt`: The query point
- `result`: Output gsVector{Float64} to store the closest parametric point (modified in-place)

# Details
Computes the closest point on the geometry to the given point and returns its parametric coordinates in `result`.
"""
function closestPointTo end

@doc """
    jacobian!(geometry::gsGeometry, u::Union{Vector{Float64}, Matrix{Float64}}, out::gsMatrix{Float64})

Evaluate the Jacobian matrix of the geometry (in-place).

# Arguments
- `geometry`: The geometry
- `u`: Parametric evaluation points
- `out`: Output gsMatrix{Float64} to store Jacobian (modified in-place)

# Details
The Jacobian is the matrix of all first-order partial derivatives of the geometry mapping.
"""
function jacobian! end

@doc """
    jacobian(geometry::gsGeometry, u::Union{Vector{Float64}, Matrix{Float64}})

Evaluate the Jacobian matrix of the geometry.

# Arguments
- `geometry`: The geometry
- `u`: Parametric evaluation points

# Returns
The Jacobian matrix
"""
function jacobian end

@doc """
    hessian!(geometry::gsGeometry, u::Union{Vector{Float64}, Matrix{Float64}}, out::gsMatrix{Float64}, coord::Int)

Evaluate the Hessian matrix of a coordinate function (in-place).

# Arguments
- `geometry`: The geometry
- `u`: Parametric evaluation points
- `out`: Output gsMatrix{Float64} to store Hessian (modified in-place)
- `coord`: The coordinate component (1-indexed)

# Details
The Hessian is the matrix of second-order partial derivatives for the specified coordinate.
"""
function hessian! end

@doc """
    hessian(geometry::gsGeometry, u::Union{Vector{Float64}, Matrix{Float64}}, coord::Int)

Evaluate the Hessian matrix of a coordinate function.

# Arguments
- `geometry`: The geometry
- `u`: Parametric evaluation points
- `coord`: The coordinate component (1-indexed)

# Returns
The Hessian matrix
"""
function hessian end

@doc """
    targetDim(geometry::gsGeometry)

Get the dimension of the ambient space (target dimension).

# Arguments
- `geometry`: The geometry

# Returns
The target dimension (physical space dimension)
"""
function targetDim end

@doc """
    coefDim(geometry::gsGeometry)

Get the dimension of the coefficient space.

# Arguments
- `geometry`: The geometry

# Returns
The coefficient dimension
"""
function coefDim end

@doc """
    geoDim(geometry::gsGeometry)

Get the geometric dimension (same as target dimension).

# Arguments
- `geometry`: The geometry

# Returns
The geometric dimension
"""
function geoDim end

@doc """
    parDim(geometry::gsGeometry)

Get the parametric dimension (number of parameters).

# Arguments
- `geometry`: The geometry

# Returns
The parametric dimension (1 for curves, 2 for surfaces, etc.)
"""
function parDim end

# TensorBSpline methods

@doc """
    TensorBSpline{1}(basis::BSplineBasis{1}, coefs::Union{Vector{Float64}, Matrix{Float64}})
    TensorBSpline{2}(basis::TensorBSplineBasis{2}, coefs::Matrix{Float64})
    TensorBSpline{3}(basis::TensorBSplineBasis{3}, coefs::Matrix{Float64})
    TensorBSpline{N}(corner::Matrix{Float64}, kv1::KnotVector, kv2::KnotVector)

Construct a tensor product B-spline surface or volume.

# Arguments
- `basis`: The tensor product B-spline basis
- `coefs`: Control point coefficients — one row per control point, one column per physical
  coordinate, ordered lexicographically with the first parametric direction running fastest
- `corner`: A `4 × 3` matrix of three-dimensional corner points listed **counterclockwise**
  around the patch; the result is a surface with `targetDim == 3`
- `kv1`, `kv2`: Knot vectors for each parametric direction

# Returns
A TensorBSpline object (surface or volume)

# Details
Tensor product B-splines are formed by taking the tensor product of univariate B-spline bases. They are parameterized by 2 or more parameters and are commonly used for representing surfaces and volumes.

All methods from `gsGeometry` are available for TensorBSpline objects.

# Examples
```julia
kv1 = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])   # 3 functions
kv2 = KnotVector([0.0, 0.0, 1.0, 1.0])             # 2 functions
coefs = [0.0 0.0; 0.5 0.4; 1.0 0.0; 0.0 1.0; 0.5 1.4; 1.0 1.0]
basis = TensorBSplineBasis{2}(kv1, kv2)
surface = TensorBSpline{2}(basis, coefs)
```

# Note
There are further overloads taking the knot vectors directly, such as
`TensorBSpline{2}(kv1, kv2, coefs)`; those expect `coefs` as a [`gsMatrix`](@ref), which you
fill with [`TinyGismo.setValue!`](@ref). The `(basis, coefs)` form is usually easier, since
it accepts a plain Julia matrix.
"""
function TensorBSpline end

# knots already documented above

# uniformRefine! already documented above
function uniformRefine! end

# uniformCoarsen! already documented above
function uniformCoarsen! end

# degree already documented above
function degree end

# basis already documented above
function basis end

# boundary already documented above
function boundary end

# Nurbs methods

@doc """
    Nurbs(basis::NurbsBasis, coefs::Union{Vector{Float64}, Matrix{Float64}})

Construct a NURBS curve from a NURBS basis and control points.

# Arguments
- `basis`: The NURBS basis
- `coefs`: Control point coefficients (vector for curves, matrix for surfaces)

# Returns
A Nurbs object

# Details
A NURBS (Non-Uniform Rational B-Spline) curve or surface is defined by a NURBS basis (which includes weights) and control points. The rational nature allows exact representation of conic sections and provides local control through weights.

# Examples
```julia
kv = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
weights = [1.0, sqrt(2)/2, 1.0]
basis = NurbsBasis(kv, weights)
coefs = [1.0 0.0; 1.0 1.0; 0.0 1.0]
curve = Nurbs(basis, coefs)
```

All methods from `gsGeometry` are available for Nurbs objects.
"""
function Nurbs end

# knots already documented above

@doc """
    weight(nurbs::Nurbs, i::Int)

Get the weight of a specific control point.

# Arguments
- `nurbs`: The NURBS curve
- `i`: The control point index (1-indexed)

# Returns
The weight value at control point `i`
"""
function weight end

@doc """
    weights(nurbs::Nurbs)

Get all control point weights.

# Arguments
- `nurbs`: The NURBS curve

# Returns
A vector of all weights
"""
function weights end

# insertKnot! already documented above
function insertKnot! end

# uniformRefine! already documented above
function uniformRefine! end

# degree already documented above
function degree end

# basis already documented above
function basis end

# boundary already documented above
function boundary end

# coefAtCorner already documented above
function coefAtCorner end

# TensorNurbs methods

@doc """
    TensorNurbs{2}(basis::TensorNurbsBasis{2}, coefs::Matrix{Float64})
    TensorNurbs{3}(basis::TensorNurbsBasis{3}, coefs::Matrix{Float64})

Construct a tensor product NURBS surface or volume from a basis and control points.

# Arguments
- `basis`: The tensor product NURBS basis
- `coefs`: Control point coefficients — one row per control point, one column per physical
  coordinate, ordered lexicographically with the first parametric direction running fastest

# Returns
A TensorNurbs object (surface or volume)

# Details
Tensor product NURBS surfaces and volumes are formed by taking the tensor product of univariate NURBS bases. They combine the flexibility of tensor products with the rational properties of NURBS, enabling exact representation of complex shapes including quadric surfaces.

All methods from `gsGeometry` are available for TensorNurbs objects — unlike the univariate
[`Nurbs`](@ref).

# Examples
```julia
kv1 = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])   # 3 functions
kv2 = KnotVector([0.0, 0.0, 1.0, 1.0])             # 2 functions
weights = reshape([1.0, sqrt(2)/2, 1.0, 1.0, sqrt(2)/2, 1.0], 6, 1)
basis = TensorNurbsBasis{2}(kv1, kv2, weights)
coefs = [1.0 0.0; 2.0 0.0; 1.0 1.0; 2.0 2.0; 0.0 1.0; 0.0 2.0]
surface = TensorNurbs{2}(basis, coefs)
```

# Note
As for [`TensorBSpline`](@ref), the overloads taking knot vectors directly expect `coefs` as
a [`gsMatrix`](@ref); the `(basis, coefs)` form accepts a plain Julia matrix.
"""
function TensorNurbs end

# knots already documented above

# weights already documented above
function weights end

# uniformCoarsen! already documented above
function uniformCoarsen! end

# degree already documented above
function degree end

# basis already documented above
function basis end

# gsMatrix and gsVector utility types

@doc """
    gsMatrix{T}()
    gsMatrix{T}(rows::Int, cols::Int)

Construct a Gismo matrix with specified dimensions. If you don't specify a type, type constructions defaults to `Float64`.

# Arguments
- `rows`: Number of rows
- `cols`: Number of columns

# Type Parameters
- `T`: Element type (typically `Float64`, `Int32`, or `Int64`)

# Returns
A gsMatrix object

# Details
gsMatrix is a parametric type used throughout Gismo for matrix operations. It's commonly used as output parameters in bang methods (methods ending with `!`).

Elements are read with [`TinyGismo.value`](@ref) or `m[i, j]` and written with
[`TinyGismo.setValue!`](@ref), so a `gsMatrix` can be filled directly as well as by being
passed to a bang method.

# Examples
```julia
# Create a matrix for output
out = gsMatrix{Float64}()
eval!(geometry, u, out)

# Create an integer matrix for active basis indices
active_out = gsMatrix{Int32}()
active!(basis, u, active_out)
```
"""
function gsMatrix end

@doc """
    gsVector{T}()
    gsVector{T}(rows::Int)

Construct a Gismo vector with specified length. If you don't specify a type, type constructions defaults to `Float64`.

# Arguments
- `rows`: Number of elements

# Type Parameters
- `T`: Element type (typically `Float64`, `Int32`, or `Int64`)

# Returns
A gsVector object

# Details
gsVector is a parametric type used throughout Gismo for vector operations.

# Examples
```julia
result = gsVector{Float64}(3)
closestPointTo(geometry, pt, result)
```
"""
function gsVector end

@doc """
    toMatrix(matrix::gsMatrix)

Convert a gsMatrix to a Julia array.

# Arguments
- `matrix`: The gsMatrix

# Returns
A Julia Matrix with the same dimensions and values
"""
function toMatrix end

@doc """
    toVector(matrix::gsMatrix)

Convert a single-column gsMatrix to a Julia vector.

# Arguments
- `matrix`: The gsMatrix (must have exactly one column)

# Returns
A Julia Vector

# Throws
RuntimeError if the matrix has more than one column
"""
function toVector end

@doc """
    toValue(matrix::gsMatrix)

Extract the single value from a 1×1 gsMatrix.

# Arguments
- `matrix`: The gsMatrix (must be 1×1)

# Returns
The scalar value

# Throws
RuntimeError if the matrix has more than one element
"""
function toValue end

@doc """
    _value(matrix::gsMatrix, i::Int, j::Int)

Get a matrix element without bounds checking (unsafe).

# Arguments
- `matrix`: The gsMatrix
- `i`: Row index (1-indexed)
- `j`: Column index (1-indexed)

# Returns
The value at position (i, j)

# Warning
This method does not perform bounds checking. Use `value()` for safe access.
"""
function _value end

@doc """
    value(matrix::gsMatrix, i::Int, j::Int)
    value(vector::gsVector, i::Int)

Get a matrix or vector element with bounds checking.

# Arguments
- `matrix`/`vector`: The gsMatrix or gsVector
- `i`: Row/element index (1-indexed)
- `j`: Column index (for matrices only, 1-indexed)

# Returns
The value at the specified position

# Throws
RuntimeError if indices are out of bounds
"""
function value end

@doc """
    setValue!(matrix::gsMatrix, i::Int, j::Int, value)
    setValue!(vector::gsVector, i::Int, value)

Write a single element of a gsMatrix or gsVector, with bounds checking.

# Arguments
- `matrix`/`vector`: The gsMatrix or gsVector (modified in-place)
- `i`: Row/element index (1-indexed)
- `j`: Column index (for matrices only, 1-indexed)
- `value`: The value to store

# Details
Together with the sized constructor this lets you build a `gsMatrix` yourself, which is what
the constructors taking a `gsMatrix` of coefficients need:

```julia
cm = gsMatrix(6, 2)
for j in 1:2, i in 1:6
    setValue!(cm, i, j, coefs[i, j])
end
surface = TensorBSpline{2}(kv1, kv2, cm)
```

# Throws
RuntimeError if indices are out of bounds
"""
function setValue! end

# Knot Spans

@doc """
    KnotSpan

A single element of the parametric mesh — one knot span of a basis, i.e. one box in the
parameter domain on which the basis is a polynomial.

`KnotSpan` objects are not constructed directly; they are obtained from
[`knotSpans`](@ref), which returns one per element of a basis.

# Common Methods
- [`lowerCorner`](@ref)
- [`upperCorner`](@ref)
- [`centerPoint`](@ref)

Each returns a [`gsVector`](@ref) with one entry per parametric direction, so a knot span of
a univariate basis is described by one-element vectors and a knot span of a surface basis by
two-element vectors.

# Examples
```julia
basis = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))
for span in knotSpans(basis)
    lo, up = toVector(lowerCorner(span)), toVector(upperCorner(span))
end
```
"""
KnotSpan

@doc """
    centerPoint(knotSpan::KnotSpan)

returns the center point of a knot span in parametric coordinates, as a [`gsVector`](@ref)
with one entry per parametric direction.
"""
function centerPoint end

@doc """
    lowerCorner(knotSpan::KnotSpan)

returns the lower corner point of a knot span in parametric coordinates, as a
[`gsVector`](@ref) with one entry per parametric direction.
"""
function lowerCorner end

@doc """
    upperCorner(knotSpan::KnotSpan)

returns the upper corner point of a knot span in parametric coordinates, as a
[`gsVector`](@ref) with one entry per parametric direction.
"""
function upperCorner end


# Geometry Constructor Functions

@doc """
    createBSplineUnitInterval(deg::Int)

Create a B-spline basis on the unit interval [0, 1].

# Arguments
- `deg`: Polynomial degree of the basis

# Returns
A [`BSpline`](@ref) geometry of degree `deg` mapping the parametric domain [0, 1] onto the
interval [0, 1] — that is, the identity curve, with `parDim == targetDim == 1`

# Details
This is a convenience function for the standard univariate spline space on the unit interval
with a clamped knot vector. Use [`TinyGismo.basis`](@ref) on the result to get the
corresponding [`BSplineBasis`](@ref).

# Examples
```julia
# Quadratic identity curve on [0, 1]
curve = createBSplineUnitInterval(2)

# ... and its basis
b = TinyGismo.basis(curve)
```
"""
function createBSplineUnitInterval end

@doc """
    createBSplineRectangle(low_x=0, low_y=0, upp_x=1, upp_y=1, turndeg=0)

Create a B-spline rectangular patch.

# Arguments
- `low_x`: Lower x-coordinate (default: 0)
- `low_y`: Lower y-coordinate (default: 0)
- `upp_x`: Upper x-coordinate (default: 1)
- `upp_y`: Upper y-coordinate (default: 1)
- `turndeg`: Rotation angle in degrees (default: 0)

# Returns
A TensorBSpline{2} representing a rectangular patch

# Examples
```julia
# Unit square
rect = createBSplineRectangle()

# Custom rectangle -- arguments are positional; keyword arguments are not supported
rect = createBSplineRectangle(-1, -1, 2, 3)
```
"""
function createBSplineRectangle end

@doc """
    createBSplineTrapezium(Lbot=1, Ltop=0.5, H=1, d=0, turndeg=0)
    createBSplineTrapezium(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy, turndeg=0)

Create a B-spline trapezoidal patch.

# Arguments

**Parameter version:**
- `Lbot`: Length of bottom edge (default: 1)
- `Ltop`: Length of top edge (default: 0.5)
- `H`: Height (default: 1)
- `d`: Horizontal offset of top edge (default: 0)
- `turndeg`: Rotation angle in degrees (default: 0)

**Corner points version:**
- `Ax`, `Ay`: First corner coordinates
- `Bx`, `By`: Second corner coordinates
- `Cx`, `Cy`: Third corner coordinates
- `Dx`, `Dy`: Fourth corner coordinates
- `turndeg`: Rotation angle in degrees (default: 0)

# Returns
A TensorBSpline{2} representing a trapezoidal patch

# Examples
```julia
# Parameter version -- arguments are positional; keyword arguments are not supported
trap = createBSplineTrapezium(2, 1, 1.5)

# Corner points version
trap = createBSplineTrapezium(0, 0, 2, 0, 1.5, 1, 0.5, 1)
```
"""
function createBSplineTrapezium end

@doc """
    createNurbsArcTrapezium(Lbot=1, Ltop=0.5, H=1, d=0, turndeg=0)
    createNurbsArcTrapezium(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy, turndeg=0)

Create a NURBS trapezoidal patch with curved sides.

# Arguments

**Parameter version:**
- `Lbot`: Length of bottom edge (default: 1)
- `Ltop`: Length of top edge (default: 0.5)
- `H`: Height (default: 1)
- `d`: Horizontal offset of top edge (default: 0)
- `turndeg`: Rotation angle in degrees (default: 0)

**Corner points version:**
- `Ax`, `Ay`: First corner coordinates
- `Bx`, `By`: Second corner coordinates
- `Cx`, `Cy`: Third corner coordinates
- `Dx`, `Dy`: Fourth corner coordinates
- `turndeg`: Rotation angle in degrees (default: 0)

# Returns
A TensorNurbs{2} representing a trapezoidal patch with curved edges

# Details
Unlike the B-spline version, this creates a trapezium with smoothly curved sides using NURBS.
"""
function createNurbsArcTrapezium end

@doc """
    createBSplineAmoeba(r=1, x=0, y=0)

Create an amoeba-shaped B-spline patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing an amoeba shape

# Details
Creates an organic, blob-like shape useful for testing and demonstrations.
"""
function createBSplineAmoeba end

@doc """
    createBSplineAmoebaBig(r=1, x=0, y=0)

Create a larger amoeba-shaped B-spline patch with more detail.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing a larger amoeba shape
"""
function createBSplineAmoebaBig end

@doc """
    createBSplineAustria(r=1, x=0, y=0)

Create an Austria-shaped B-spline patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing the outline of Austria
"""
function createBSplineAustria end

@doc """
    createBSplineFish(r=1, x=0, y=0)

Create a fish-shaped B-spline patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing a fish shape
"""
function createBSplineFish end

@doc """
    createBSplineAmoeba3degree(r=1, x=0, y=0)

Create a cubic (degree 3) amoeba-shaped B-spline patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing an amoeba shape with cubic basis functions
"""
function createBSplineAmoeba3degree end

@doc """
    createNurbsQrtPlateWHoleC0()

Create a quarter plate with a hole (C0 continuity).

# Returns
A TensorNurbs{2} representing a quarter of a plate with a circular hole

# Details
This benchmark geometry is commonly used for testing structural mechanics problems, particularly for plates with stress concentrations.
"""
function createNurbsQrtPlateWHoleC0 end

@doc """
    createBSplineTriangle(H=1, W=1)

Create a triangular B-spline patch.

# Arguments
- `H`: Height of the triangle (default: 1)
- `W`: Width of the triangle base (default: 1)

# Returns
A TensorBSpline{2} representing a triangular patch
"""
function createBSplineTriangle end

@doc """
    createBSplineSquare(r=1, x=0, y=0)

Create a square B-spline patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing a square patch
"""
function createBSplineSquare end

@doc """
    createBSplineCube(r=1, x=0, y=0, z=0)

Create a cube B-spline volume.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)
- `z`: Center z-coordinate (default: 0)

# Returns
A TensorBSpline{3} representing a cubic volume
"""
function createBSplineCube end

@doc """
    createBSplineHalfCube(r=1, x=0, y=0, z=0)

Create a half-cube B-spline volume.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)
- `z`: Center z-coordinate (default: 0)

# Returns
A TensorBSpline{3} representing a half-cubic volume
"""
function createBSplineHalfCube end

@doc """
    createNurbsCube(r=1, x=0, y=0, z=0)

Create a cube NURBS volume.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)
- `z`: Center z-coordinate (default: 0)

# Returns
A TensorNurbs{3} representing a cubic volume
"""
function createNurbsCube end

@doc """
    createNurbsQuarterAnnulus(r0=1, r1=2)

Create a quarter annulus (ring) NURBS patch.

# Arguments
- `r0`: Inner radius (default: 1)
- `r1`: Outer radius (default: 2)

# Returns
A TensorNurbs{2} representing a quarter annulus
"""
function createNurbsQuarterAnnulus end

@doc """
    createNurbsAnnulus(r0=1, r1=2)

Create a full annulus (ring) NURBS patch.

# Arguments
- `r0`: Inner radius (default: 1)
- `r1`: Outer radius (default: 2)

# Returns
A TensorNurbs{2} representing a complete annulus
"""
function createNurbsAnnulus end

@doc """
    createNurbsSphere(r=1, x=0, y=0, z=0)

Create a NURBS sphere.

# Arguments
- `r`: Radius (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)
- `z`: Center z-coordinate (default: 0)

# Returns
A `TensorNurbs{2}` representing a sphere — a *surface*, so `parDim == 2` and
`targetDim == 3`
"""
function createNurbsSphere end

@doc """
    createNurbsCircle(r=1, x=0, y=0)

Create a NURBS circle curve.

# Arguments
- `r`: Radius (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A Nurbs curve representing a circle
"""
function createNurbsCircle end

@doc """
    createBSplineFatCircle(r=1, x=0, y=0)

Create a B-spline circle patch (disk).

# Arguments
- `r`: Radius (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A [`BSpline`](@ref) *curve* in the plane (`parDim == 1`, `targetDim == 2`) approximating a
circle. For the filled disk as a surface, see [`createBSplineFatDisk`](@ref).
"""
function createBSplineFatCircle end

@doc """
    createBSplineFatDisk(r=1, x=0, y=0)

Create a B-spline disk patch.

# Arguments
- `r`: Radius (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing a disk patch
"""
function createBSplineFatDisk end

@doc """
    createNurbsCurve1(r=1, x=0, y=0)

Create a NURBS curve (variant 1).

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A Nurbs curve
"""
function createNurbsCurve1 end

@doc """
    createNurbsCurve2(r=1, x=0, y=0)

Create a NURBS curve (variant 2).

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A Nurbs curve
"""
function createNurbsCurve2 end

@doc """
    createNurbsBean(r=1, x=0, y=0)

Create a bean-shaped NURBS patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorNurbs{2} representing a bean shape
"""
function createNurbsBean end

@doc """
    createBSplineE(r=1, x=0, y=0)

Create a capital E-shaped B-spline patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorBSpline{2} representing the letter E
"""
function createBSplineE end

@doc """
    createNurbsAmoebaFull(r=1, x=0, y=0)

Create a full amoeba-shaped NURBS patch.

# Arguments
- `r`: Radius/scale factor (default: 1)
- `x`: Center x-coordinate (default: 0)
- `y`: Center y-coordinate (default: 0)

# Returns
A TensorNurbs{2} representing a full amoeba shape
"""
function createNurbsAmoebaFull end

@doc """
    createBSplineSegment(u0=0, u1=1)

Create a B-spline line segment.

# Arguments
- `u0`: Start parameter (default: 0)
- `u1`: End parameter (default: 1)

# Returns
A [`BSpline`](@ref) curve representing a line segment, with `parDim == targetDim == 1`

# Details
Creates a simple parametric line segment that can be used as a basis for other constructions.
"""
function createBSplineSegment end

# Geometry Transformation Functions

@doc """
    rotate2D(geo::TensorBSpline{2}, turndeg::Float64=0, Tx::Float64=0, Ty::Float64=0)

Rotate a 2D geometry around the origin.

# Arguments
- `geo`: A 2D B-spline or NURBS geometry
- `turndeg`: Rotation angle in degrees (default: 0)
- `Tx`: Translation in x-direction (default: 0)
- `Ty`: Translation in y-direction (default: 0)

# Returns
A new rotated geometry

# Details
Applies a 2D rotation transformation to the geometry around the origin, with optional translation.
"""
function rotate2D end

@doc """
    rotate2D!(geo::gsGeometry, turndeg::Float64=0, Tx::Float64=0, Ty::Float64=0)

In-place 2D rotation of a geometry.

# Arguments
- `geo`: A 2D geometry (modified in-place)
- `turndeg`: Rotation angle in degrees (default: 0)
- `Tx`: Translation in x-direction (default: 0)
- `Ty`: Translation in y-direction (default: 0)

# Note
This operation modifies the geometry in-place.
"""
function rotate2D! end

@doc """
    rotate3D!(geo::gsGeometry, phi_z::Float64=0, phi_y::Float64=0, phi_x::Float64=0)

In-place 3D rotation of a geometry.

# Arguments
- `geo`: A 3D geometry (modified in-place)
- `phi_z`: Rotation angle around z-axis in degrees (default: 0)
- `phi_y`: Rotation angle around y-axis in degrees (default: 0)
- `phi_x`: Rotation angle around x-axis in degrees (default: 0)

# Details
Applies 3D Euler angle rotations (Z-Y-X convention) to the geometry.

# Note
This operation modifies the geometry in-place.
"""
function rotate3D! end

@doc """
    shift2D(geo::TensorBSpline{2}, dx::Float64=0, dy::Float64=0, dz::Float64=0)

Translate a 2D geometry.

# Arguments
- `geo`: A 2D B-spline or NURBS geometry
- `dx`: Translation in x-direction (default: 0)
- `dy`: Translation in y-direction (default: 0)
- `dz`: Translation in z-direction (default: 0)

# Returns
A new translated geometry
"""
function shift2D end

@doc """
    shift2D!(geo::gsGeometry, dx::Float64=0, dy::Float64=0, dz::Float64=0)

In-place translation of a 2D geometry.

# Arguments
- `geo`: A 2D geometry (modified in-place)
- `dx`: Translation in x-direction (default: 0)
- `dy`: Translation in y-direction (default: 0)
- `dz`: Translation in z-direction (default: 0)

# Note
This operation modifies the geometry in-place.
"""
function shift2D! end

@doc """
    mirror2D(geo::TensorBSpline{2}, axis::Bool)

Mirror a 2D geometry across an axis.

# Arguments
- `geo`: A 2D B-spline or NURBS geometry
- `axis`: Axis to mirror across (false for x-axis, true for y-axis)

# Returns
A new mirrored geometry
"""
function mirror2D end

@doc """
    mirror2D!(geo::gsGeometry, axis::Bool)

In-place mirroring of a 2D geometry.

# Arguments
- `geo`: A 2D geometry (modified in-place)
- `axis`: Axis to mirror across (false for x-axis, true for y-axis)

# Note
This operation modifies the geometry in-place.
"""
function mirror2D! end

@doc """
    scale2D(geo::TensorBSpline{2}, factor::Float64=1.0)

Scale a 2D geometry uniformly.

# Arguments
- `geo`: A 2D B-spline or NURBS geometry
- `factor`: Scaling factor (default: 1.0)

# Returns
A new scaled geometry
"""
function scale2D end

@doc """
    scale2DVec(geo::TensorBSpline{2}, factors::Vector{Float64})

Scale a 2D geometry non-uniformly.

# Arguments
- `geo`: A 2D B-spline or NURBS geometry
- `factors`: Scaling factors for each axis [scale_x, scale_y]

# Returns
A new scaled geometry
"""
function scale2DVec end

@doc """
    scale2D!(geo::gsGeometry, factor::Float64=1.0)

In-place uniform scaling of a 2D geometry.

# Arguments
- `geo`: A 2D geometry (modified in-place)
- `factor`: Scaling factor (default: 1.0)

# Note
This operation modifies the geometry in-place.
"""
function scale2D! end

@doc """
    scale2DVec!(geo::gsGeometry, factors::Vector{Float64})

In-place non-uniform scaling of a 2D geometry.

# Arguments
- `geo`: A 2D geometry (modified in-place)
- `factors`: Scaling factors for each axis [scale_x, scale_y]

# Note
This operation modifies the geometry in-place.
"""
function scale2DVec! end

# Paraview Export Functions

@doc """
    writeParaview(geo::gsGeometry, fn::String; npts=1000, mesh=false, ctrlNet=false)
    writeParaview(basis::gsBasis, fn::String; npts=1000, mesh=false)
    writeParaview(basis::gsBasis, indices::Vector{Int}, fn::String; npts=1000, mesh=false)

Export TinyGismo geometries and bases to Paraview VTK files.

# Arguments
- `geo`: Geometry to export (B-spline or NURBS)
- `basis`: Basis to export (B-spline or NURBS)
- `indices`: Basis function indices to export (1-indexed)
- `fn`: Output filename
- `npts`: Number of sampling points (default: 1000)
- `mesh`: Plot parameter mesh (default: false)
- `ctrlNet`: Plot control net (geometry export only, default: false)

# Details
- Geometry export writes the shape with optional mesh and control net.
- Basis export writes all basis functions, or only the specified indices.
"""
function writeParaview end

@doc """
    writeParaviewBasisFnct(i::Int, basis::gsBasis, fn::String; npts=1000)

Export a single basis function to a Paraview file.

# Arguments
- `i`: Index of the basis function (1-indexed)
- `basis`: The B-spline or NURBS basis
- `fn`: Output filename
- `npts`: Number of sampling points (default: 1000)

# Details
Exports a single basis function as a curve/surface in VTK format.
"""
function writeParaviewBasisFnct end

@doc """
    writeParaviewPoints(points::Matrix{Float64}, fn::String)
    writeParaviewPoints(X::Matrix{Float64}, Y::Matrix{Float64}, fn::String)
    writeParaviewPoints(X::Matrix{Float64}, Y::Matrix{Float64}, Z::Matrix{Float64}, fn::String)
    writeParaviewPoints(X::Matrix{Float64}, Y::Matrix{Float64}, Z::Matrix{Float64}, V::Matrix{Float64}, fn::String)

Export 2D/3D point sets and tensor-structured grids to Paraview.

# Arguments
- `points`: Matrix with points as columns (2 or 3 rows)
- `X`, `Y`, `Z`: 1×n coordinate arrays for structured point sets
- `V`: 1×n scalar values for each point (optional)
- `fn`: Output filename

# Details
- Supports simple point clouds and structured grids with optional scalar data.
"""
function writeParaviewPoints end

# File I/O Functions

@doc """
    readFile(Type, filename::String)

Read a Gismo object from a file.

# Arguments
- `Type`: The type of object to read (e.g., `BSplineBasis`, `TensorBSpline{2}`, `Nurbs`, etc.)
- `filename`: Path to the file to read

# Returns
An object of the specified type read from the file

# Supported Types
- Basis types: `BSplineBasis`, `TensorBSplineBasis{1/2/3}`, `NurbsBasis`, `TensorNurbsBasis{1/2/3}`
- Geometry types: `BSpline`, `TensorBSpline{1/2/3}`, `Nurbs`, `TensorNurbs{2/3}`

# Examples
```julia
# Read a B-spline surface
surface = readFile(TensorBSpline{2}, "surface.xml")

# Read a NURBS curve
curve = readFile(Nurbs, "curve.xml")

# Read a basis
basis = readFile(TensorBSplineBasis{2}, "basis.xml")
```

# Details
Reads Gismo XML format files containing geometric or basis function data.
"""
function readFile end
# Matrix and Vector Methods

# @doc """
#     size(obj::Union{gsMatrix, gsVector})

# Get the total number of elements in a matrix or vector.

# # Arguments
# - `obj`: A gsMatrix or gsVector object

# # Returns
# The total number of elements (rows × columns for matrices, or length for vectors)
# """
# function size end

@doc """
    rows(obj::Union{gsMatrix, gsVector})

Get the number of rows in a matrix or vector.

# Arguments
- `obj`: A gsMatrix or gsVector object

# Returns
The number of rows
"""
function rows end

@doc """
    cols(obj::Union{gsMatrix, gsVector})

Get the number of columns in a matrix or vector.

# Arguments
- `obj`: A gsMatrix or gsVector object

# Returns
The number of columns (1 for vectors)
"""
function cols end
