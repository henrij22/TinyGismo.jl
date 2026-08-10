# Tensor product B-splines and NURBS

```@example tensor
using TinyGismo
using TinyGismo: knots, degree, basis, component, weights, weight
nothing # hide
```

A tensor product basis is the outer product of one univariate basis per parametric direction.
Each direction carries its own knot vector, so the degree, the number of elements and the
refinement level can differ from direction to direction. Everything else — evaluation,
refinement, degree elevation — behaves exactly as in the univariate case.

## Building a tensor product basis

[`TensorBSplineBasis`](@ref) takes one [`KnotVector`](@ref) per direction. The parametric
dimension is a type parameter and **must be given explicitly**:

```@example tensor
kv_u = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])  # quadratic
kv_v = KnotVector([0.0, 0.0, 1.0, 1.0])            # linear

tb = TensorBSplineBasis{2}(kv_u, kv_v)
nothing # hide
```

The size of the tensor basis is the product of the univariate sizes, and likewise for the
element count:

```@example tensor
(
    size      = Int(size(tb)),               # 3 × 2
    nelements = Int(numElements(tb)),
    ntotal    = Int(numTotalElements(tb)),
)
```

Direction-dependent queries take a 1-based direction index:

```@example tensor
(degree(tb, 1), degree(tb, 2))
```

Element counts are the exception: the second argument of [`numElements`](@ref) is a **box
side**, not a direction. For per-direction counts go through the univariate component:

```@example tensor
(Int(numElements(component(tb, 1))), Int(numElements(component(tb, 2))))
```

[`TinyGismo.knots`](@ref) and [`TinyGismo.component`](@ref) reach into a single direction —
the former gives the knot vector, the latter the whole univariate basis:

```@example tensor
knotContainer(knots(tb, 1)), knotContainer(knots(tb, 2))
```

```@example tensor
u_basis = component(tb, 1)
Int(size(u_basis)), degree(u_basis)
```

A trivariate basis takes three knot vectors, and behaves the same way:

```@example tensor
tb3 = TensorBSplineBasis{3}(kv_u, kv_v, kv_v)
(
    size      = Int(size(tb3)),
    numActive = Int(numActive(tb3)),
    degrees   = (degree(tb3, 1), degree(tb3, 2), degree(tb3, 3)),
)
```

## Surfaces

[`TensorBSpline`](@ref) attaches control points to the basis. As in the univariate case there
is one row per control point and one column per physical coordinate, but the rows are now
ordered **lexicographically with the first parametric direction running fastest**: all
``u``-indices for ``v_1``, then all ``u``-indices for ``v_2``, and so on.

```@example tensor
controlpoints = [0.0  0.0     # u1, v1
                 0.5  0.4     # u2, v1
                 1.0  0.0     # u3, v1
                 0.0  1.0     # u1, v2
                 0.5  1.4     # u2, v2
                 1.0  1.0]    # u3, v2

surface = TensorBSpline{2}(tb, controlpoints)
(parDim = parDim(surface), targetDim = targetDim(surface), ncoefs = Int(coefsSize(surface)))
```

Evaluation takes one parameter per parametric direction:

```@example tensor
x = gsMatrix()
eval!(surface, [0.5, 0.5], x)
toMatrix(x)
```

The centre of the patch is pulled off the straight line ``y = 0.5`` because the middle
control points in both rows are offset — the surface is a curved sheet, not a bilinear patch.

### Building a patch from its corners

There is also a corner-point form, which fills the given spline space with a quadrilateral
patch. It expects a **4 × 3 matrix of three-dimensional corner points listed
counterclockwise** around the patch, and it produces a surface in 3D space
(`targetDim == 3`) even when all four corners are coplanar:

```@example tensor
kv_lin = KnotVector([0.0, 0.0, 1.0, 1.0])   # linear in both directions
corners = [0.0 0.0 0.0
           4.0 0.0 0.0
           3.0 2.0 0.0
           1.0 2.0 0.0]

trapezoid = TensorBSpline{2}(corners, kv_lin, kv_lin)
targetDim(trapezoid), toMatrix(coefs(trapezoid))
```

The corners come back out at the corners of the parameter domain, and the interior is the
bilinear blend of them:

```@example tensor
map([[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0], [0.5, 0.5]]) do uv
    x = gsMatrix()
    eval!(trapezoid, uv, x)
    uv => vec(toMatrix(x))
end
```

!!! note "The knot-vector constructors take a `gsMatrix`"
    `TensorBSpline{2}(kv_u, kv_v, coefs)` and its trivariate and rational siblings expect the
    coefficients as a [`gsMatrix`](@ref) rather than a Julia matrix. Fill one with
    [`TinyGismo.setValue!`](@ref) if you want that form; the `TensorBSpline{N}(basis, coefs)`
    form used throughout these examples is equivalent and takes a plain Julia matrix.

## Volumes

A trivariate patch has three parametric directions. The row ordering of the control points
extends the same way: ``u`` fastest, then ``v``, then ``w``.

```@example tensor
volume = createBSplineCube(1.0)
(
    parDim    = parDim(volume),
    targetDim = targetDim(volume),
    ncoefs    = Int(coefsSize(volume)),
    degrees   = (degree(volume, 1), degree(volume, 2), degree(volume, 3)),
)
```

```@example tensor
toMatrix(coefs(volume))
```

Its basis is the `TensorBSplineBasis{3}` mentioned above:

```@example tensor
vb = basis(volume)
Int(size(vb)), Int(numElements(vb))
```

## Rational tensor product geometries

[`TensorNurbsBasis`](@ref) is a tensor B-spline basis plus one weight per basis function,
supplied as a single-column matrix in the same lexicographic order as the control points:

```@example tensor
w = 0.5 * sqrt(2)
weightmatrix = reshape([1.0, w, 1.0, 1.0, w, 1.0], 6, 1)
tnb = TensorNurbsBasis{2}(kv_u, kv_v, weightmatrix)
Int(size(tnb))
```

Unlike univariate [`Nurbs`](@ref), tensor product NURBS support the full geometry interface.
The quarter annulus is the standard example — an *exact* circular ring, which no polynomial
B-spline can represent:

```@example tensor
annulus = createNurbsQuarterAnnulus(1.0, 2.0)   # inner radius, outer radius
toMatrix(coefs(annulus))
```

Reading the control points in the lexicographic order above shows how the patch is laid out:
the first direction is **radial** (two control points, inner then outer) and the second is
**angular** (three control points sweeping the quarter turn).

```@example tensor
toVector(weights(annulus))
```

The middle pair of weights is ``\sqrt{2}/2``, the value that makes a quadratic rational
Bézier segment trace a quarter circle exactly. Evaluating halfway along the inner edge —
``u = 0`` is the inner radius, ``v = 0.5`` is 45° — therefore lands exactly on the unit
circle, which is where a polynomial approximation would fall short:

```@example tensor
p = gsMatrix()
eval!(annulus, [0.0, 0.5], p)
point = toMatrix(p)
point, sqrt(sum(abs2, point))
```

For a univariate [`Nurbs`](@ref), [`TinyGismo.weight`](@ref) reads a single weight; on a
tensor product geometry, index into the vector returned by `weights` instead:

```@example tensor
circle = createNurbsCircle(1.0)
weight(circle, 2), toVector(weights(annulus))[2]
```

## Parametric versus physical dimension

The two are independent, and tensor product geometries make that obvious. A NURBS sphere has
**two** parametric directions but lives in **three-dimensional** space — it is a surface, not
a volume, despite the name:

```@example tensor
sphere = createNurbsSphere(1.0)
(
    parDim    = parDim(sphere),
    targetDim = targetDim(sphere),
    degrees   = (degree(sphere, 1), degree(sphere, 2)),
)
```

Its mesh is anisotropic — two elements around one direction, four around the other.
[`TinyGismo.component`](@ref) is only available on B-spline bases, so on a *rational* basis
count the spans in each knot vector instead:

```@example tensor
sb = basis(sphere)
elements(b, i) = length(unique(knotContainer(knots(b, i)))) - 1
(elements(sb, 1), elements(sb, 2)), Int(numElements(sb))
```

A NURBS cube, by contrast, is genuinely trivariate:

```@example tensor
nurbscube = createNurbsCube(1.0)
parDim(nurbscube), targetDim(nurbscube)
```

Because each direction carries its own knot vector, the two need not stay in step. Refining
or elevating a single direction is covered in [Refinement](03_refinement.md).
