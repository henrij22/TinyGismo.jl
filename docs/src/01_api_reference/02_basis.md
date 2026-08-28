# Basis Functions

Basis functions are the building blocks of spline spaces. This module provides both B-spline and NURBS basis functions in univariate and tensor product forms.

## Base Types

```@docs
TinyGismo.gsBasis
```

## Generic Basis Operations

These methods work on all basis types (B-spline and NURBS).

### Element and Activity Queries

```@docs
knotSpans
elementIndex
elementInSupportOf
active!
isActive
boundary
```

### Degree and Continuity Operations

```@docs
degreeElevate!
degreeReduce!
degreeIncrease!
degreeDecrease!
elevateContinuity!
reduceContinuity!
setDegree!
setDegreePreservingMultiplicity!
```

### Geometric Operations

```@docs
TinyGismo.reverse!
```

### Evaluation

```@docs
eval!
_eval
evalSingle!
evalSingle
evalFunc!
evalFunc
```

### Derivatives

```@docs
TinyGismo.deriv!
TinyGismo.deriv
TinyGismo.derivSingle!
TinyGismo.derivSingle
TinyGismo.derivFunc
TinyGismo.deriv2!
TinyGismo.deriv2
TinyGismo.deriv2Single!
TinyGismo.deriv2Single
TinyGismo.deriv2Func
```

### Refinement

```@docs
uniformRefine!
uniformCoarsen!
uniformRefine_withCoefs!
```

## B-Spline Bases

### Constructors

```@docs
BSplineBasis
TensorBSplineBasis
```

### Query Functions

```@docs
TinyGismo.knots
TinyGismo.knot
size(::BSplineBasis)
size(::TensorBSplineBasis)
size(::NurbsBasis)
size(::TensorNurbsBasis)
numElements
numTotalElements
TinyGismo.degree
TinyGismo.order
TinyGismo.component
```

### Active Basis Functions

```@docs
numActive
```

### Refinement Operations

```@docs
insertKnot!
removeKnot!
insertKnots!
```

## NURBS Bases

### Constructors

```@docs
NurbsBasis
TensorNurbsBasis
```

### Query Functions

```@docs
TinyGismo.weights
```

## Hierarchical Bases

Hierarchical bases add *local* refinement: a tensor basis is taken as the coarsest level, and
finer levels are introduced only over the regions that need them. Two flavours are available and
differ only in truncation.

| | Partition of unity after refinement | Use |
|---|---|---|
| [`THBSplineBasis`](@ref) | yes | the usual choice |
| [`HBSplineBasis`](@ref) | no | when the untruncated functions are wanted |

In G+Smo these are one class template with truncation switched on or off, so everything below
applies equally to both.

### Constructors

```@docs
THBSplineBasis
HBSplineBasis
```

### Level Queries

```@docs
numLevels
levelOf
tensorLevel
getLevelAtPoint
levelAtCorner
treeSize
```

### Elements

```@docs
elementBoxes
```

### Local Refinement

Refinement is addressed either by parametric coordinates ([`refine!`](@ref)) or by naming exact
elements ([`refineElements!`](@ref)). The latter goes through [`RefinementBox`](@ref), which is
also where the level and index conventions are spelled out.

```@docs
RefinementBox
refine!
unrefine!
refineElements!
unrefineElements!
refineElements_withCoefs!
unrefineElements_withCoefs!
refine_withCoefs!
refineSide!
refineBasisFunction!
increaseMultiplicity!
```

Evaluation, derivatives and the degree operations are inherited unchanged from
[`gsBasis`](@ref TinyGismo.gsBasis) — see [Generic Basis Operations](02_basis.md#Generic-Basis-Operations).
[`knotSpans`](@ref) is the one exception: it is not available for hierarchical bases, and
[`elementBoxes`](@ref) replaces it.
