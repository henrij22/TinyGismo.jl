# TinyGismo

TinyGismo.jl provides an alternative Julia interface to the G+Smo (Geometry + Simulation Modules) library, focusing on:

- **Knot Vectors**: Management of knot vectors
- **Basis Functions**: B-spline and NURBS basis functions in univariate and tensor product forms
- **Geometries**: Spline curves, surfaces, and volumes for geometric modeling
- **Factories**: Convenient constructors for standard geometric shapes
- **Utilities**: Matrix types, file I/O, and helper functions

The official Julia bindings can be found at [Gismo.jl](https://github.com/gismo/Gismo.jl).

## Deployment

The C++ component of this library can be found at [libjltinygismo](https://github.com/henrij22/libjltinygismo), with binaries being deployed to [TinyGismo_jll.jl](https://github.com/henrij22/TinyGismo_jll.jl). Binaries are currently deployed for all major platforms.
