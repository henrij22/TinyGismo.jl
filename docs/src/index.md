# TinyGismo.jl

Welcome to the documentation of TinyGismo.jl, a Julia interface to the G+Smo (Geometry + Simulation Modules) library.

## Overview

TinyGismo.jl provides comprehensive tools for:

- **Spline-based geometric modeling** using B-splines and NURBS
- **Isogeometric analysis** with basis function evaluation and refinement
- **Parametric curves, surfaces, and volumes** for CAD and scientific computing

## Key Features

- Univariate and tensor product B-spline bases
- NURBS (Non-Uniform Rational B-Spline) support with weights
- Knot vector manipulation and refinement
- Geometric evaluation, derivatives, Jacobians, and Hessians
- Factory functions for creating standard shapes
- File I/O for reading and writing geometric data

## Quick Start

```@example
using TinyGismo

# Create a knot vector
knots = [0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]
kv = KnotVector(knots)

# Create a B-spline basis
basis = BSplineBasis(kv)

# Create a simple rectangle
rect = createBSplineRectangle(0.0, 0.0, 1.0, 1.0)

# Evaluate the geometry at a point
u = [0.5, 0.5]
out = gsMatrix{Float64}(2, 1)
eval!(rect, u, out)
```

## Documentation Structure

- **[API Reference](@ref)**: Detailed documentation of all types and functions
  - [Knot Vectors](01_api_reference/01_knotvector.md)
  - [Basis Functions](01_api_reference/02_basis.md)
  - [Geometries](01_api_reference/03_geometries.md)
  - [Geometry Factories](01_api_reference/04_factories.md)
  - [Utilities](01_api_reference/05_utilities.md)
