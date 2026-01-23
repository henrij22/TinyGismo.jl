# Geometries

Geometric objects represent spline curves, surfaces, and volumes. All geometry types inherit from `gsGeometry` and support evaluation, derivatives, and various geometric queries.

## Base Types

```@docs
TinyGismo.gsGeometry
```

## B-Spline Geometries

### Univariate B-Splines

```@docs
BSpline
```

#### Properties and Queries

These query functions are also available for basis functions. See the [Basis Functions](02_basis.md) section for detailed documentation.

- [`TinyGismo.knots`](@ref) - Get the knot vector
- [`TinyGismo.degree`](@ref) - Get the polynomial degree
- [`TinyGismo.basis`](@ref) - Get the underlying basis
- [`boundary`](@ref) - Extract a boundary curve/surface

```@docs
TinyGismo.basis
TinyGismo.boundary
numCoefs
coefAtCorner
```

#### Refinement

Refinement operations are shared with basis functions. See the [Basis Functions - Refinement](02_basis.md#Refinement) section for detailed documentation.

- [`insertKnot`](@ref) - Insert a knot into the geometry
- [`uniformRefine`](@ref) - Uniformly refine the mesh
- [`uniformCoarsen`](@ref) - Uniformly coarsen the mesh

#### Degree Operations

These degree operations are shared with basis functions. See the [Basis Functions - Degree and Continuity Operations](02_basis.md#Degree-and-Continuity-Operations) section for detailed documentation.

- [`degreeElevate`](@ref) - Elevate the polynomial degree
- [`degreeReduce`](@ref) - Reduce the polynomial degree
- [`degreeIncrease`](@ref) - Increase the polynomial degree
- [`degreeDecrease`](@ref) - Decrease the polynomial degree

### Tensor Product B-Splines

```@docs
TensorBSpline
```

#### Properties and Queries

These query functions are also available for basis functions. See the [Basis Functions](02_basis.md) section for detailed documentation.

- [`TinyGismo.knots`](@ref) - Get the knot vector
- [`TinyGismo.degree`](@ref) - Get the polynomial degree
- [`TinyGismo.basis`](@ref) - Get the underlying basis
- [`TinyGismo.boundary`](@ref) - Extract a boundary curve/surface

#### Refinement

Refinement operations are shared with basis functions. See the [Basis Functions - Refinement](02_basis.md#Refinement) section for detailed documentation.

- [`insertKnot`](@ref) - Insert a knot into the geometry
- [`uniformRefine`](@ref) - Uniformly refine the mesh
- [`uniformCoarsen`](@ref) - Uniformly coarsen the mesh

#### Degree Operations

These degree operations are shared with basis functions. See the [Basis Functions - Degree and Continuity Operations](02_basis.md#Degree-and-Continuity-Operations) section for detailed documentation.

- [`degreeElevate`](@ref) - Elevate the polynomial degree
- [`degreeReduce`](@ref) - Reduce the polynomial degree
- [`degreeIncrease`](@ref) - Increase the polynomial degree
- [`degreeDecrease`](@ref) - Decrease the polynomial degree

## NURBS Geometries

### Univariate NURBS

```@docs
Nurbs
```

#### Properties and Queries

These query functions are also available for basis functions. See the [Basis Functions](02_basis.md) section for detailed documentation.

- [`TinyGismo.knots`](@ref) - Get the knot vector
- [`TinyGismo.degree`](@ref) - Get the polynomial degree
- [`TinyGismo.basis`](@ref) - Get the underlying basis
- [`TinyGismo.boundary`](@ref) - Extract a boundary curve/surface
- [`TinyGismo.weights`](@ref) - Get the control point weights

```@docs
TinyGismo.weight
```

#### Refinement

Refinement operations are shared with basis functions. See the [Basis Functions - Refinement](02_basis.md#Refinement) section for detailed documentation.

- [`insertKnot`](@ref) - Insert a knot into the geometry
- [`uniformRefine`](@ref) - Uniformly refine the mesh
- [`uniformCoarsen`](@ref) - Uniformly coarsen the mesh

#### Degree Operations

These degree operations are shared with basis functions. See the [Basis Functions - Degree and Continuity Operations](02_basis.md#Degree-and-Continuity-Operations) section for detailed documentation.

- [`degreeElevate`](@ref) - Elevate the polynomial degree
- [`degreeReduce`](@ref) - Reduce the polynomial degree
- [`degreeIncrease`](@ref) - Increase the polynomial degree
- [`degreeDecrease`](@ref) - Decrease the polynomial degree

### Tensor Product NURBS

```@docs
TensorNurbs
```

#### Properties and Queries

These query functions are also available for basis functions. See the [Basis Functions](02_basis.md) section for detailed documentation.

- [`TinyGismo.knots`](@ref) - Get the knot vector
- [`TinyGismo.degree`](@ref) - Get the polynomial degree
- [`TinyGismo.basis`](@ref) - Get the underlying basis
- [`TinyGismo.boundary`](@ref) - Extract a boundary curve/surface
- [`TinyGismo.weights`](@ref) - Get the control point weights

#### Refinement

Refinement operations are shared with basis functions. See the [Basis Functions - Refinement](02_basis.md#Refinement) section for detailed documentation.

- [`insertKnot`](@ref) - Insert a knot into the geometry
- [`uniformRefine`](@ref) - Uniformly refine the mesh
- [`uniformCoarsen`](@ref) - Uniformly coarsen the mesh

#### Degree Operations

These degree operations are shared with basis functions. See the [Basis Functions - Degree and Continuity Operations](02_basis.md#Degree-and-Continuity-Operations) section for detailed documentation.

- [`degreeElevate`](@ref) - Elevate the polynomial degree
- [`degreeReduce`](@ref) - Reduce the polynomial degree
- [`degreeIncrease`](@ref) - Increase the polynomial degree
- [`degreeDecrease`](@ref) - Decrease the polynomial degree

## Generic Geometry Operations

These methods work on all geometry types (B-spline and NURBS).

### Control Points

```@docs
coefsSize
coefs
```

### Evaluation

These evaluation methods are shared with basis functions. See the [Basis Functions - Evaluation](02_basis.md#Evaluation) section for detailed documentation.

- [`eval!`](@ref) - Evaluate at parametric points (in-place)
- [`_eval`](@ref) - Evaluate at parametric points

### Derivatives

These derivative methods are shared with basis functions. See the [Basis Functions - Derivatives](02_basis.md#Derivatives-2) section for detailed documentation.

- [`deriv!`](@ref) - First derivative (in-place)
- [`deriv`](@ref) - First derivative
- [`deriv2!`](@ref) - Second derivative (in-place)
- [`deriv2`](@ref) - Second derivative

### Geometric Queries

```@docs
closestPointTo
TinyGismo.jacobian!
TinyGismo.jacobian
TinyGismo.hessian!
TinyGismo.hessian
```

### Dimension Queries

```@docs
targetDim
coefDim
geoDim
parDim
```
