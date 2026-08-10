# Evaluation

```@example eval
using TinyGismo
using TinyGismo: knots, degree, basis, jacobian, hessian
nothing # hide
```

Everything on this page follows the same pattern: pick a parametric point, ask a basis or a
geometry for something at that point, and read the answer out of a [`gsMatrix`](@ref).

Two objects are used throughout — a quadratic univariate basis and a plane curve built on it:

```@example eval
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
b = BSplineBasis(kv)

controlpoints = [0.0  0.0
                 1.0  1.5
                 2.0 -0.5
                 3.0  1.0]
curve = BSpline(b, controlpoints)

ξ = [0.4]
nothing # hide
```

## Control points

[`coefs`](@ref) returns the control net as a `gsMatrix` — one row per control point, one
column per physical coordinate — and [`coefsSize`](@ref) its row count:

```@example eval
Int(coefsSize(curve)), toMatrix(coefs(curve))
```

For a univariate [`BSpline`](@ref) there is also [`numCoefs`](@ref), which is the same
number:

```@example eval
Int(numCoefs(curve))
```

[`coefAtCorner`](@ref) picks out a corner of the control net, which for a curve is simply the
first or last control point:

```@example eval
toVector(coefAtCorner(curve, 1)), toVector(coefAtCorner(curve, 2))
```

The dimension queries describe the mapping itself rather than its control net:

```@example eval
(
    parDim    = parDim(curve),      # number of parameters
    targetDim = targetDim(curve),   # dimension of the physical space
    geoDim    = geoDim(curve),
    coefDim   = coefDim(curve),
)
```

## Basis function values

[`eval!`](@ref) on a *basis* returns only the functions that are **nonzero** at the point —
`p + 1` of them for a univariate degree-`p` basis, not all `size(basis)`:

```@example eval
N = gsMatrix()
eval!(b, ξ, N)
toMatrix(N)
```

Which functions those are is answered by [`active!`](@ref), which fills a `gsMatrix{Int32}`
with 1-based indices in the same order as the values above:

```@example eval
A = gsMatrix{Int32}()
active!(b, ξ, A)
toVector(A)
```

Together the two give the standard local assembly loop. Note the partition of unity:

```@example eval
values = toVector(N)
indices = toVector(A)
collect(zip(indices, values)), sum(values)
```

[`isActive`](@ref) answers the same question for one function at a time, and
[`numActive`](@ref) gives the count:

```@example eval
(
    first = isActive(b, 1, ξ),
    last  = isActive(b, 4, ξ),
    count = Int(numActive(b)),
)
```

[`numActive`](@ref) works the same way on a tensor product basis, where it is the product
over the directions — it never needs an evaluation point, because the count is the same on
every element:

```@example eval
tb = basis(createBSplineRectangle())
Int(numActive(tb)), (degree(tb, 1) + 1) * (degree(tb, 2) + 1)
```

A single basis function can be evaluated on its own with [`evalSingle`](@ref), using a global
1-based index rather than a position in the active list:

```@example eval
toMatrix(evalSingle(b, 2, ξ))
```

## Derivatives of basis functions

[`deriv!`](@ref) and [`deriv2!`](@ref) give first and second derivatives of the active
functions, in the same layout as `eval!`:

```@example eval
dN = gsMatrix()
deriv!(b, ξ, dN)
toMatrix(dN)
```

The derivatives sum to zero, which is the differentiated partition of unity:

```@example eval
sum(toMatrix(dN))
```

```@example eval
ddN = gsMatrix()
deriv2!(b, ξ, ddN)
toMatrix(ddN)
```

The per-function variants [`derivSingle`](@ref) and [`deriv2Single`](@ref) mirror
`evalSingle`. Note that `deriv2Single` returns a bare `Float64` rather than a `gsMatrix`:

```@example eval
toMatrix(derivSingle(b, 2, ξ)), deriv2Single(b, 2, ξ)
```

## Functions expressed in the basis

[`evalFunc`](@ref) evaluates ``\sum_i c_i N_i(u)`` for a coefficient vector, without building
a geometry object. [`derivFunc`](@ref) and [`deriv2Func`](@ref) do the same for derivatives:

```@example eval
c = [1.0, 2.0, 0.0, -1.0]
toMatrix(evalFunc(b, ξ, c)), toMatrix(derivFunc(b, ξ, c))
```

This agrees with assembling the sum by hand from the active functions:

```@example eval
sum(values[k] * c[indices[k]] for k in eachindex(indices))
```

## Geometry positions

On a *geometry*, [`eval!`](@ref) maps parameters to physical points. The result is
`targetDim × npoints`:

```@example eval
x = gsMatrix()
eval!(curve, ξ, x)
toMatrix(x)
```

Sampling the whole curve is a matter of passing a `1 × n` matrix — one column per point:

```@example eval
u = Matrix(collect(range(0.0, 1.0; length = 6))')
X = gsMatrix()
eval!(curve, u, X)
toMatrix(X)
```

The same works in higher parametric dimensions, with one row per parametric coordinate:

```@example eval
rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
uv = [0.0 0.5 1.0
      0.0 0.5 1.0]
P = gsMatrix()
eval!(rect, uv, P)
toMatrix(P)
```

### Derivatives and the Jacobian

[`deriv`](@ref) on a geometry gives the tangent, and [`TinyGismo.jacobian`](@ref) the full
derivative matrix of the mapping:

```@example eval
toMatrix(deriv(curve, ξ)), toMatrix(jacobian(curve, ξ))
```

For a surface the Jacobian is `targetDim × parDim` — the two columns are the tangent vectors
along ``u`` and ``v``:

```@example eval
toMatrix(jacobian(rect, [0.5, 0.5]))
```

[`TinyGismo.hessian`](@ref) takes the index of the physical coordinate whose second
derivatives you want. The rectangle is an affine map, so its Hessians vanish:

```@example eval
toMatrix(hessian(rect, [0.5, 0.5], 1))
```

### Inverting the mapping

[`closestPointTo`](@ref) goes the other way: given a physical point, it finds the parameter
that comes closest to it, writing the answer into a [`gsVector`](@ref).

The query point need not lie on the curve. Here it sits well above it:

```@example eval
par = gsVector()
closestPointTo(curve, [1.5, 1.5], par)
toVector(par)
```

Evaluating the curve at that parameter gives the actual nearest point, which is what you
compare against:

```@example eval
foot = gsMatrix()
eval!(curve, toVector(par), foot)
toMatrix(foot)
```

For a point that *is* on the curve, the round trip returns it exactly:

```@example eval
onpar = gsVector()
closestPointTo(curve, [1.5, 0.5], onpar)
back = gsMatrix()
eval!(curve, toVector(onpar), back)
toVector(onpar), toMatrix(back)
```

## Walking the mesh

[`knotSpans`](@ref) returns the elements of the parametric mesh as a vector, one entry per
element. Each is described by [`lowerCorner`](@ref), [`upperCorner`](@ref) and
[`centerPoint`](@ref), all of which return a `gsVector` with one entry per parametric
direction.

```@example eval
b2 = BSplineBasis(kv)
uniformRefine!(b2)

map(knotSpans(b2)) do span
    (lower = toVector(lowerCorner(span)), center = toVector(centerPoint(span)),
     upper = toVector(upperCorner(span)))
end
```

In two dimensions the spans tile the parameter domain, ordered with the first direction
running fastest:

```@example eval
tb = basis(createBSplineRectangle(0.0, 0.0, 2.0, 1.0))
uniformRefine!(tb)

map(knotSpans(tb)) do span
    toVector(lowerCorner(span)) => toVector(upperCorner(span))
end
```

This is the natural loop for numerical quadrature: for each span, map quadrature points from
the reference element into the span, then evaluate the basis and the geometry there. As a
sanity check, a one-point midpoint rule over the spans recovers the area of the rectangle
exactly, because the mapping is affine:

```@example eval
refined = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
uniformRefine!(refined, 3)

area = sum(knotSpans(basis(refined))) do span
    lo, up = toVector(lowerCorner(span)), toVector(upperCorner(span))
    J = toMatrix(jacobian(refined, toVector(centerPoint(span))))
    detJ = J[1, 1] * J[2, 2] - J[1, 2] * J[2, 1]
    abs(detJ) * prod(up .- lo)
end
```

[`elementIndex`](@ref) is the inverse lookup — which span contains a given parameter:

```@example eval
[Int(elementIndex(b2, [u])) for u in (0.1, 0.3, 0.6, 0.9)]
```
