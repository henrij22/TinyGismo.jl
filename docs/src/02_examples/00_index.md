# Examples overview

These pages are runnable: every code block is executed when the documentation is built, and
the printed results are the values TinyGismo actually returns.

- [Creating geometries](01_geometries.md) — knot vector → basis → geometry, and the
  `create*` convenience functions.
- [Tensor product B-splines and NURBS](02_tensor_bsplines.md) — bases and geometries in two
  and three parametric directions, weights, and per-direction queries.
- [Refinement](03_refinement.md) — knot insertion, uniform refinement, degree elevation, and
  what each of them does to the control net.
- [Evaluation](04_evaluation.md) — coefficients, basis function values, active functions,
  geometry positions, derivatives and Jacobians.
- [Hierarchical splines](05_hierarchical.md) — local refinement with HB- and THB-splines,
  refinement boxes, hierarchical geometries, and what truncation buys you.

## Conventions used throughout

A few things are worth knowing before reading the examples.

**Names that are not exported.** The core queries `knots`, `degree`, `basis`, `order`,
`component`, `weight`, `weights`, `jacobian`, `hessian` and `unique` live in the `TinyGismo`
namespace but are not exported, because their names are common enough to collide with other
packages. Bring in the ones you need explicitly:

```@example conventions
using TinyGismo
using TinyGismo: knots, degree, basis, order
nothing # hide
```

**Sizes come back as unsigned integers.** Anything mapping to a C++ `size()` or `index_t`
returns an unsigned type, which the REPL prints in hexadecimal:

```@example conventions
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
size(kv)
```

Wrap it in `Int` when you want to read it, or compare it — comparisons work either way:

```@example conventions
Int(size(kv)), size(kv) == 7
```

**Bang methods write into a `gsMatrix`.** Where G+Smo has an `_into()` method, TinyGismo has
a `!` method taking a preallocated [`gsMatrix`](@ref) or [`gsVector`](@ref) as the last
argument. The non-bang variants allocate and return a `gsMatrix`, which you convert with
[`toMatrix`](@ref) or [`toVector`](@ref):

```@example conventions
basis1d = BSplineBasis(kv)
values = gsMatrix()
eval!(basis1d, [0.4], values)
toMatrix(values)
```

Prefer the bang methods in hot loops: the non-bang ones allocate a fresh matrix on every
call.

**Indexing is 1-based.** Basis function indices, control point indices and knot span indices
are all 1-based, unlike the underlying C++ library.
