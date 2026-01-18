# Basis Functions

Basis functions are the building blocks of spline spaces. This module provides both B-spline and NURBS basis functions in univariate and tensor product forms.

## Base Types

```@docs
TinyGismo.gsBasis
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
```

### Active Basis Functions

```@docs
numActive
numActive!
TinyGismo.component
```

### Refinement Operations

```@docs
insertKnot
removeKnot
insertKnots
```

## NURBS Bases

### Constructors

```@docs
NurbsBasis
TensorNurbsBasis
```

## Generic Basis Operations

These methods work on all basis types (B-spline and NURBS).

### Element and Activity Queries

```@docs
elementIndex
elementInSupportOf
active!
isActive
```

### Degree and Continuity Operations

These operations work on all basis types and are shared with geometry types. For detailed documentation, see the docstrings:

- [`degreeElevate`](@ref) - Elevate the polynomial degree
- [`degreeReduce`](@ref) - Reduce the polynomial degree  
- [`degreeIncrease`](@ref) - Increase the polynomial degree
- [`degreeDecrease`](@ref) - Decrease the polynomial degree
- [`elevateContinuity`](@ref) - Elevate the continuity
- [`reduceContinuity`](@ref) - Reduce the continuity
- [`setDegree`](@ref) - Set the polynomial degree
- [`setDegreePreservingMultiplicity`](@ref) - Set degree while preserving knot multiplicities

### Geometric Operations

```@docs
TinyGismo.reverse
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
TinyGismo.derivSingle!
TinyGismo.derivSingle
TinyGismo.derivFunc
TinyGismo.deriv2!
TinyGismo.deriv2Single!
TinyGismo.deriv2Single
TinyGismo.deriv2Func
```

### Refinement

```@docs
uniformRefine
uniformCoarsen
uniformRefine_withCoefs
```
