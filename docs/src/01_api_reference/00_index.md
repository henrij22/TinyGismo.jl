# API Reference

This section provides detailed documentation for all types and functions in TinyGismo.jl.

## Contents

```@contents
Pages = [
    "01_knotvector.md",
    "02_basis.md",
    "03_geometries.md",
    "04_factories.md",
    "05_utilities.md",
    "06_io.md",
]
Depth = 2
```

## Overview

TinyGismo.jl provides an alternative Julia interface to the G+Smo (Geometry + Simulation Modules) library, focusing on:

- **Knot Vectors**: Management of knot vectors
- **Basis Functions**: B-spline and NURBS basis functions in univariate and tensor product forms
- **Geometries**: Spline curves, surfaces, and volumes for geometric modeling
- **Factories**: Convenient constructors for standard geometric shapes
- **Utilities**: Matrix types, file I/O, and helper functions
- **Input/Output**: File I/O and visualization with Paraview

The official Julia bindings can be found at [Gismo.jl](https://github.com/gismo/Gismo.jl).
