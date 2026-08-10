# Refinement

```@example refine
using TinyGismo
using TinyGismo: knots, degree, basis, component
nothing # hide
```

Refinement enlarges a spline space without changing what it currently represents. That is the
property isogeometric analysis relies on: refine the geometry, and the geometry is unchanged
while the discretization gets richer.

There are three independent ways to enlarge the space, and they are worth keeping apart:

| operation | knots | degree | continuity |
| :-- | :-- | :-- | :-- |
| knot insertion / uniform refinement | more | unchanged | unchanged at old knots |
| degree elevation | multiplicities raised | higher | unchanged |
| degree increase | ends only | higher | raised in the interior |

All of them are in-place — the `!` suffix is not decoration.

## Knot insertion

[`insertKnot!`](@ref) adds a single knot, optionally with a multiplicity. Start from a
quadratic basis with one interior knot:

```@example refine
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
b = BSplineBasis(kv)
knotContainer(knots(b))
```

```@example refine
insertKnot!(b, 0.25)
knotContainer(knots(b))
```

A multiplicity greater than one lowers the continuity at that knot. Inserting `0.75` twice
into a quadratic basis leaves only ``C^0`` there:

```@example refine
insertKnot!(b, 0.75, 2)
knotContainer(knots(b))
```

[`insertKnots!`](@ref) does a batch, and [`removeKnot!`](@ref) undoes an insertion:

```@example refine
insertKnots!(b, [0.1, 0.9])
knotContainer(knots(b))
```

```@example refine
removeKnot!(b, 0.1)
knotContainer(knots(b))
```

Each inserted knot adds exactly one basis function and one element:

```@example refine
Int(size(b)), Int(numElements(b)), Int(uSize(knots(b)))
```

## Uniform refinement

[`uniformRefine!`](@ref) splits *every* element, which is the usual way to build a
convergence study. The default inserts one knot per span, so the element count doubles:

```@example refine
b = BSplineBasis(kv)
before = (Int(numElements(b)), Int(size(b)))
uniformRefine!(b)
before, (Int(numElements(b)), Int(size(b))), knotContainer(knots(b))
```

The first argument after the basis is the number of knots inserted per span, so a value of
`3` quadruples the element count in one step:

```@example refine
uniformRefine!(b, 3)
Int(numElements(b))
```

[`uniformCoarsen!`](@ref) reverses it:

```@example refine
uniformCoarsen!(b)
Int(numElements(b))
```

## Refining a geometry keeps its shape

This is the point of the whole exercise. Refining a *geometry* — rather than a bare basis —
recomputes the control points so that the mapping is preserved exactly.

```@example refine
controlpoints = [0.0  0.0
                 1.0  1.5
                 2.0 -0.5
                 3.0  1.0]
curve = BSpline(BSplineBasis(kv), controlpoints)

x = gsMatrix()
eval!(curve, [0.3], x)
before = toMatrix(x)
```

```@example refine
uniformRefine!(curve)
eval!(curve, [0.3], x)
after = toMatrix(x)

before ≈ after
```

The control net, however, is completely different — there are now six control points instead
of four, and none of the interior ones sit where they used to:

```@example refine
Int(coefsSize(curve)), toMatrix(coefs(curve))
```

### Refining a bare basis and its coefficients

If you are carrying coefficients separately rather than in a geometry object,
[`uniformRefine_withCoefs!`](@ref) does the same job: it refines the basis in place and
**returns** the matching refined coefficients. They cannot be updated in place, because
refinement adds control points.

```@example refine
b = BSplineBasis(kv)
newcoefs = toMatrix(uniformRefine_withCoefs!(b, controlpoints))
Int(size(b)), size(newcoefs)
```

The refined pair represents exactly the same curve:

```@example refine
eval!(BSpline(b, newcoefs), [0.3], x)
toMatrix(x) ≈ before
```

## Degree elevation and degree increase

Both raise the polynomial degree, but they differ in what happens to the interior knots, and
therefore to the continuity of the space.

[`degreeElevate!`](@ref) raises the multiplicity of every interior knot along with the
degree, so the continuity at each knot is preserved:

```@example refine
b = BSplineBasis(kv)
degreeElevate!(b)
degree(b), knotContainer(knots(b)), Int(numElements(b))
```

The interior knot `0.5` is now doubled: at degree 3 with multiplicity 2 the space is still
``C^1`` there, as it was at degree 2 with multiplicity 1.

[`degreeIncrease!`](@ref) touches only the end knots, so the interior continuity goes *up*
along with the degree:

```@example refine
b = BSplineBasis(kv)
degreeIncrease!(b)
degree(b), knotContainer(knots(b)), Int(numElements(b))
```

[`degreeReduce!`](@ref) and [`degreeDecrease!`](@ref) are the corresponding inverses.
Elevating and then reducing returns the original knot vector:

```@example refine
b = BSplineBasis(kv)
degreeElevate!(b)
degreeReduce!(b)
knotContainer(knots(b)) ≈ knotContainer(kv)
```

Degree elevation on a geometry preserves the shape in the same way knot insertion does, at
the cost of more control points:

```@example refine
rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
beforedeg = (degree(rect, 1), degree(rect, 2), Int(coefsSize(rect)))
degreeElevate!(rect)
beforedeg, (degree(rect, 1), degree(rect, 2), Int(coefsSize(rect)))
```

## Continuity without changing the degree

[`elevateContinuity!`](@ref) and [`reduceContinuity!`](@ref) move continuity at fixed degree,
by removing or repeating interior knots. Elevating continuity on the quadratic basis above
removes the single interior knot altogether, collapsing the two elements into one Bézier
segment:

```@example refine
b = BSplineBasis(kv)
elevateContinuity!(b)
degree(b), Int(numElements(b)), knotContainer(knots(b))
```

## Refining tensor product geometries

On a tensor product geometry the same calls apply to all directions at once:

```@example refine
rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
rb = basis(rect)
(ncoefs = Int(coefsSize(rect)), nelements = Int(numElements(rb)))
```

```@example refine
uniformRefine!(rect, 2)
rb = basis(rect)
(ncoefs = Int(coefsSize(rect)), nelements = Int(numElements(rb)))
```

Both directions went from one element to three, giving nine elements in total.

### Working one direction at a time

Directional calls take a **1-based direction index, with `0` meaning "all directions"**. For
[`insertKnot!`](@ref) on a geometry the third argument is the direction and the fourth the
multiplicity:

```@example refine
insertKnot!(rect, 0.5, 1)   # value 0.5, direction 1
knotContainer(knots(rect, 1))
```

The second direction is untouched:

```@example refine
knotContainer(knots(rect, 2))
```

Anything outside `0:parDim` is rejected:

```@example refine
try
    degreeElevate!(rect, 1, -1)
catch err
    err
end
```

To read the per-direction element counts, go through [`TinyGismo.component`](@ref), which
returns the univariate basis for one direction:

```@example refine
rb = basis(rect)
(
    dir1 = Int(numElements(component(rb, 1))),
    dir2 = Int(numElements(component(rb, 2))),
    total = Int(numElements(rb)),
)
```

The mesh is now anisotropic — four elements across, three up, twelve in total.

Do **not** reach for the two-argument [`numElements`](@ref) here. Its second argument is a
**box side** in the G+Smo numbering (`1`/`2` west and east, `3`/`4` south and north), so it
returns the number of elements *along that boundary edge*. Sides 1 and 2 run up the ``v``
direction and give `3`, while sides 3 and 4 run along ``u`` and give `4`:

```@example refine
[Int(numElements(rb, s)) for s in 1:4]
```

Directional degree operations follow the same convention: the second argument of
[`degreeElevate!`](@ref) is the number of levels and the third is the direction.

```@example refine
degreeElevate!(rect, 1, 1)   # elevate once, direction 1 only
degree(rect, 1), degree(rect, 2)
```

[`uniformRefine!`](@ref) on a geometry accepts the same trailing direction argument, after
the knot count and the multiplicity:

```@example refine
square = createBSplineRectangle()
uniformRefine!(square, 1, 1, 2)   # one knot per span, multiplicity 1, direction 2
sb = basis(square)
Int(numElements(component(sb, 1))), Int(numElements(component(sb, 2)))
```
