# Knot Vectors

Knot vectors are fundamental data structures that define the parametric domain and behavior of B-spline and NURBS bases.

## Constructor

```@docs
KnotVector
```

## Query Functions

```@docs
size(basis::KnotVector) 
uSize
TinyGismo.unique
multiplicities
knotContainer
```

- [`numElements`](@ref) - Get the number of elements (see [Basis Functions - Query Functions](02_basis.md#Query-Functions))

## Degree Operations

These operations are documented in the [Basis Functions](02_basis.md) section.

- [`TinyGismo.degree`](@ref) - Get the polynomial degree
- [`degreeIncrease`](@ref) - Increase the polynomial degree
- [`degreeDecrease`](@ref) - Decrease the polynomial degree
- [`degreeElevate`](@ref) - Elevate the polynomial degree

## Refinement

Refinement operations for knot vectors are documented in the [Basis Functions - Refinement](02_basis.md#Refinement) section.

- [`uniformRefine`](@ref) - Uniformly refine the knot vector
