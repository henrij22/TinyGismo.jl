# Creating geometries

```@example geometries
using TinyGismo
using TinyGismo: knots, degree, basis, order, unique
nothing # hide
```

A spline geometry in TinyGismo is always built from two ingredients: a **basis**, which fixes
the spline space, and a matrix of **control points** (coefficients), which places that space
in physical space. The basis in turn is built from one **knot vector** per parametric
direction.

This page walks that chain from the bottom up, and then shows the `create*` functions that
skip it when you only need a standard shape.

## Knot vectors

A [`KnotVector`](@ref) is a non-decreasing sequence of parameter values. Repeating a value
raises its multiplicity, which lowers the continuity of the spline there; repeating the end
values ``p+1`` times gives the usual *clamped* (open) knot vector that interpolates the first
and last control point.

```@example geometries
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
knotContainer(kv)
```

The degree is implied rather than stored: with `3` repetitions at each end, this is a
quadratic knot vector. The queries below describe it:

```@example geometries
(
    nknots       = Int(size(kv)),        # counting multiplicities
    nunique      = Int(uSize(kv)),       # distinct values
    nelements    = Int(numElements(kv)), # non-empty knot spans
)
```

[`TinyGismo.unique`](@ref) gives the distinct breakpoints and [`multiplicities`](@ref) how
often each occurs:

```@example geometries
unique(kv), multiplicities(kv)
```

## From knot vector to basis

[`BSplineBasis`](@ref) turns a knot vector into a univariate spline basis. The degree is
deduced from the end multiplicities, and the number of basis functions follows as
``n = m - p - 1`` for ``m`` knots and degree ``p``:

```@example geometries
b = BSplineBasis(kv)
(
    degree    = degree(b),
    order     = order(b),          # degree + 1
    nfunctions = Int(size(b)),
    nelements = Int(numElements(b)),
)
```

The basis keeps a reference to its knot vector, which you can read back:

```@example geometries
knotContainer(knots(b))
```

## From basis to geometry

[`BSpline`](@ref) combines the basis with a control point matrix. The matrix has one **row
per control point** and one **column per physical coordinate**, so the number of rows must
equal the number of basis functions:

```@example geometries
controlpoints = [0.0  0.0
                 1.0  1.5
                 2.0 -0.5
                 3.0  1.0]

curve = BSpline(b, controlpoints)
(
    parDim    = parDim(curve),      # number of parameters
    targetDim = targetDim(curve),   # dimension of the physical space
    ncoefs    = Int(coefsSize(curve)),
)
```

The column count is what decides the target dimension — the same basis with a single column
of coefficients gives a scalar function of one parameter rather than a plane curve:

```@example geometries
scalar = BSpline(b, [0.0, 1.0, -1.0, 0.5])
parDim(scalar), targetDim(scalar)
```

Evaluating the curve at a parameter gives a `targetDim × npoints` matrix:

```@example geometries
x = gsMatrix()
eval!(curve, [0.5], x)
toMatrix(x)
```

Several parameters at once are passed as a `1 × n` matrix — one **column per point**, which
is the same layout the result uses:

```@example geometries
u = collect(range(0.0, 1.0; length = 5))'  # 1 × 5
X = gsMatrix()
eval!(curve, Matrix(u), X)
toMatrix(X)
```

## NURBS curves

[`NurbsBasis`](@ref) adds one weight per basis function. Weights let a spline reproduce conic
sections exactly, which a polynomial B-spline cannot do:

```@example geometries
w = 0.5 * sqrt(2)
quarterarc = NurbsBasis(KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0]), [1.0, w, 1.0])
Int(size(quarterarc)), degree(quarterarc)
```

Attaching control points gives a [`Nurbs`](@ref) curve, which supports the full geometry
interface. A NURBS circle is the standard demonstration — it is *exactly* round, which a
polynomial B-spline cannot manage:

```@example geometries
circle = createNurbsCircle(1.0)
p = gsMatrix()
eval!(circle, [0.3], p)
point = toMatrix(p)
point, sqrt(sum(abs2, point))
```

The weights are what make that possible:

```@example geometries
toVector(TinyGismo.weights(circle))
```

## The convenience functions

For standard shapes the `create*` factories skip the whole chain. They take **positional
arguments only** — keyword arguments are not supported, because these functions come
straight from the C++ layer.

```@example geometries
rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)   # low_x, low_y, upp_x, upp_y
(parDim = parDim(rect), targetDim = targetDim(rect), ncoefs = Int(coefsSize(rect)))
```

Every argument has a default, so the bare call gives the unit shape:

```@example geometries
toMatrix(coefs(createBSplineSquare()))
```

The factories cover a range of parametric and physical dimensions. A quarter annulus is a
rational surface in the plane:

```@example geometries
annulus = createNurbsQuarterAnnulus(1.0, 2.0)   # inner radius, outer radius
(typeof = nameof(typeof(annulus)), parDim = parDim(annulus), targetDim = targetDim(annulus))
```

a cube is a trivariate volume:

```@example geometries
cube = createBSplineCube(1.0)
(parDim = parDim(cube), targetDim = targetDim(cube), ncoefs = Int(coefsSize(cube)))
```

and a sphere is a *surface* — two parameters embedded in three-dimensional space:

```@example geometries
sphere = createNurbsSphere(1.0)
(parDim = parDim(sphere), targetDim = targetDim(sphere), ncoefs = Int(coefsSize(sphere)))
```

Note that "B-spline" in a factory name refers to the shape being polynomial, not to the
parametric dimension: `createBSplineFatCircle` returns a *curve* in the plane, while
`createBSplineFatDisk` returns a *surface*.

```@example geometries
circleboundary = createBSplineFatCircle(1.0)
disk = createBSplineFatDisk(1.0)
(circle = parDim(circleboundary), disk = parDim(disk))
```

See [Geometry Factories](../01_api_reference/04_factories.md) for the full list, including
the test shapes (`createBSplineAmoeba`, `createBSplineFish`, `createNurbsQrtPlateWHoleC0`,
…) that are not exported but reachable as `TinyGismo.createBSplineFish()`.

## Extracting boundaries

[`boundary`](@ref) pulls a side out of a geometry as a geometry of one lower parametric
dimension. Sides are numbered in the G+Smo convention: `1` and `2` are the west and east
edges (``u = 0`` and ``u = 1``), `3` and `4` the south and north edges.

The result is a C++ `unique_ptr` to the abstract geometry base class, so dereference it with
`[]` before using it:

```@example geometries
west = boundary(rect, 1)[]
(parDim = parDim(west), targetDim = targetDim(west))
```

The west edge of the ``[0,2] \times [0,1]`` rectangle is the segment ``x = 0``:

```@example geometries
toMatrix(coefs(west))
```

Applied to a basis instead, `boundary` returns the **indices** of the basis functions that
are nonzero on that side:

```@example geometries
toVector(boundary(basis(rect), 1))
```
