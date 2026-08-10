# TinyGismo.jl

Welcome to the documentation of TinyGismo.jl, a Julia interface to the G+Smo (Geometry +
Simulation Modules) library.

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

```@example quickstart
using TinyGismo

# A knot vector defines the parametric domain and the continuity of the spline
kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])

# The basis fixes the spline space; the control points place it in physical space
basis = BSplineBasis(kv)
curve = BSpline(basis, [0.0 0.0
                        1.0 1.5
                        2.0 -0.5
                        3.0 1.0])

# Evaluate the geometry at a parameter
x = gsMatrix()
eval!(curve, [0.5], x)
toMatrix(x)
```

Standard shapes come ready-made, and refining one leaves its geometry untouched while
enlarging the underlying spline space:

```@example quickstart
rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
uniformRefine!(rect)
Int(coefsSize(rect)), toMatrix(coefs(rect))
```

## Documentation Structure

- **[Examples](@ref "Examples overview")**: task-oriented, runnable walkthroughs
  - [Creating geometries](02_examples/01_geometries.md)
  - [Tensor product B-splines and NURBS](02_examples/02_tensor_bsplines.md)
  - [Refinement](02_examples/03_refinement.md)
  - [Evaluation](02_examples/04_evaluation.md)
- **[API Reference](@ref)**: detailed documentation of all types and functions
  - [Knot Vectors](01_api_reference/01_knotvector.md)
  - [Basis Functions](01_api_reference/02_basis.md)
  - [Geometries](01_api_reference/03_geometries.md)
  - [Geometry Factories](01_api_reference/04_factories.md)
  - [Utilities](01_api_reference/05_utilities.md)
  - [Input/Output](01_api_reference/06_io.md)
