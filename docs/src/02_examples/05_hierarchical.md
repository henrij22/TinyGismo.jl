# Hierarchical and truncated hierarchical splines

```@example hier
using TinyGismo
using TinyGismo: basis, degree
nothing # hide
```

Uniform refinement enlarges the space everywhere. That is wasteful when only a small part of the
domain needs resolving: halving the mesh of a bivariate basis quadruples the number of functions
no matter how local the feature is. Hierarchical splines refine *locally* — a coarse tensor basis
is the first level, and finer levels are introduced only over the regions that need them.

TinyGismo exposes two flavours, [`THBSplineBasis`](@ref) (truncated) and
[`HBSplineBasis`](@ref) (not). They are constructed and refined identically; the difference shows
up in the basis functions themselves, and is the subject of the last section.

## Building a hierarchical basis

A hierarchical basis starts as a tensor basis, which becomes its coarsest level. Here is a
quadratic basis on a 4×4 element grid:

```@example hier
kv = KnotVector([0.0, 0.0, 0.0, 0.25, 0.5, 0.75, 1.0, 1.0, 1.0])
tensor = TensorBSplineBasis{2}(kv, kv)
thb = THBSplineBasis{2}(tensor)
(size(thb), numLevels(thb), Int(numElements(thb)))
```

With a single level it is exactly the tensor basis it was built from — same functions, same
elements. [`numLevels`](@ref) counts levels 1-based, so level `1` is the coarsest.

## Refining elements

[`refineElements!`](@ref) refines an exactly named set of elements, written as a
[`RefinementBox`](@ref). One convention does all the work here and is worth stating plainly:

> A box names the level the region is set **to**, and its corners are indexed on **that same
> level's** grid.

Each level halves the cells of the one before it, so a single cell `k` on level `l` is the pair of
cells `2k-1:2k` on level `l+1`. To take the first coarse cell — the square ``[0, 0.25]^2`` — down
one level, name level 2 and give its corners on level 2's grid:

```@example hier
refineElements!(thb, RefinementBox(2, 1:2, 1:2))
(size(thb), numLevels(thb), Int(numElements(thb)))
```

One element became four, and the basis grew by three functions rather than by the 45 that a
uniform refinement would have added. [`getLevelAtPoint`](@ref) confirms the refinement landed
where it was asked to and nowhere else:

```@example hier
[getLevelAtPoint(thb, p) for p in ([0.125, 0.125], [0.375, 0.125], [0.125, 0.375], [0.875, 0.875])]
```

Refinement composes — refining again inside the refined region adds a third level:

```@example hier
refineElements!(thb, RefinementBox(3, 1:2, 1:2))
(size(thb), numLevels(thb), getLevelAtPoint(thb, [0.0625, 0.0625]))
```

### Refining by coordinates instead

When the region of interest is known as a parametric box rather than as element indices,
[`refine!`](@ref) takes corner coordinates directly — a `d × 2k` matrix, each consecutive pair of
columns one box. It refines each box one level deeper than the level it currently sits at:

```@example hier
byCoords = THBSplineBasis{2}(tensor)
refine!(byCoords, [0.0 0.25; 0.0 0.25])
(size(byCoords), getLevelAtPoint(byCoords, [0.125, 0.125]))
```

This matches the element-box refinement above. The optional third argument `refExt` widens every
box by that many cells first, which keeps a refinement from hugging a feature too tightly.

[`unrefine!`](@ref) and [`unrefineElements!`](@ref) go the other way. The level in a box means the
same thing there — the level the region is set *to* — so undoing the refinement above names
level 1:

```@example hier
unrefineElements!(byCoords, RefinementBox(1, 1:1, 1:1))
(size(byCoords), getLevelAtPoint(byCoords, [0.125, 0.125]))
```

## Inspecting the elements

`knotSpans` is not available for hierarchical bases; [`elementBoxes`](@ref) replaces it, returning
a `2d × numElements` matrix whose columns hold each element's lower and upper corner:

```@example hier
boxes = toMatrix(elementBoxes(thb))
size(boxes)
```

The elements partition the parameter domain, so their areas sum to one:

```@example hier
lower, upper = boxes[1:2, :], boxes[3:4, :]
sum(prod(upper .- lower; dims = 1))
```

This is the loop an adaptive scheme hangs off: evaluate an error indicator per element, then feed
the worst ones back into `refineElements!`.

## Hierarchical geometries

A [`THBSpline`](@ref) pairs a hierarchical basis with control points. Any tensor B-spline geometry
can be lifted into the hierarchical setting unchanged, which is the usual starting point:

```@example hier
rect = createBSplineRectangle()
geo = THBSpline{2}(rect)
(numCoefs(geo), toVector(_eval(geo, [0.4, 0.4])))
```

Refining a geometry carries its control points along, so it gains resolution without moving:

```@example hier
before = toVector(_eval(geo, [0.4, 0.4]))
refineElements!(geo, RefinementBox(2, 1:1, 1:1))
after = toVector(_eval(geo, [0.4, 0.4]))
(numCoefs(geo), before ≈ after)
```

Refining a *basis* on its own leaves any coefficients you hold beside it stale, since the number
of functions changed. [`refineElements_withCoefs!`](@ref) updates both together and returns the
new coefficients:

```@example hier
b = THBSplineBasis{2}(tensor)
coefs = [Float64(i + j) for i in 1:size(b), j in 1:3]
newCoefs = toMatrix(refineElements_withCoefs!(b, coefs, RefinementBox(2, 1:2, 1:2)))
(Base.size(coefs, 1), Base.size(newCoefs, 1))
```

[`convertToBSpline`](@ref) goes back to a tensor B-spline by refining the whole domain to the
finest level present. The result is the same map, and usually far larger — that size difference is
exactly what hierarchical refinement buys. `thb` from earlier carries three levels over a domain
that is coarse almost everywhere:

```@example hier
deep = THBSpline{2}(thb, [Float64(i + j) for i in 1:size(thb), j in 1:3])
flattened = convertToBSpline(deep)
(numCoefs(deep), coefsSize(flattened))
```

Nearly an eightfold difference, for a geometry refined in one corner. `deep` itself is untouched —
`convertToBSpline` carries no `!`.

Both describe the same surface:

```@example hier
toVector(_eval(deep, [0.6, 0.6])) ≈ toVector(_eval(flattened, [0.6, 0.6]))
```

## Truncation

This is the one place the two flavours part company. Refine the same region in both:

```@example hier
truncated = THBSplineBasis{2}(tensor)
plain = HBSplineBasis{2}(tensor)
refineElements!(truncated, RefinementBox(2, 1:2, 1:2))
refineElements!(plain, RefinementBox(2, 1:2, 1:2))
(size(truncated), size(plain))
```

The two spaces have the same dimension and span the same functions. But over the refined region
the coarse functions overlap the fine ones, and only the truncated basis subtracts that overlap
back out. The consequence is visible in the simplest possible test — whether the basis functions
sum to one:

```@example hier
u = [0.125, 0.125]   # inside the refined region
(sum(toMatrix(_eval(truncated, u))), sum(toMatrix(_eval(plain, u))))
```

The truncated basis is a partition of unity; the untruncated one over-counts. Away from the
refinement both agree, since there is no overlap to correct:

```@example hier
v = [0.875, 0.875]
(sum(toMatrix(_eval(truncated, v))), sum(toMatrix(_eval(plain, v))))
```

Partition of unity is what makes coefficients behave like control points and keeps the basis
well-conditioned, so [`THBSplineBasis`](@ref) is the default choice unless you specifically want
the untruncated functions.

## Reading and writing

Hierarchical bases and geometries round-trip through the G+Smo XML format and export to Paraview
like any other type:

```@example hier
writeParaview(thb, joinpath(tempdir(), "thb_basis"), 100)
writeParaview(geo, joinpath(tempdir(), "thb_geometry"), 100)
nothing # hide
```

[`readFile`](@ref) takes the type to read as its first argument:

```julia
basis = readFile(THBSplineBasis{2}, "thbs_basis_02.xml")
geometry = readFile(THBSpline{2}, "thbs_face_3levels.xml")
```
