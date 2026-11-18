<h1 align="center">TinyGismo.jl</h1>

<p align="center">
  <strong>A Julian interface to <a href="https://github.com/gismo/gismo">G+Smo</a> for splines, NURBS and Isogeometric Analysis</strong>
</p>

<p align="center">
  <a href="https://henrij22.github.io/TinyGismo.jl/dev"><img src="https://img.shields.io/badge/docs-dev-blue.svg" alt="Docs dev"></a>
  <a href="https://github.com/henrij22/TinyGismo.jl/actions/workflows/CI.yml"><img src="https://github.com/henrij22/TinyGismo.jl/actions/workflows/CI.yml/badge.svg" alt="Build status"></a>
  <a href="https://codecov.io/gh/henrij22/TinyGismo.jl"><img src="https://codecov.io/gh/henrij22/TinyGismo.jl/graph/badge.svg?token=zWCVMmLie1" alt="codecov"></a>
  <a href="https://github.com/JuliaTesting/Aqua.jl"><img src="https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg" alt="Aqua QA"></a>
  <a href="https://github.com/fredrikekre/Runic.jl"><img src="https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black" alt="Code style: Runic"></a>
</p>

<p align="center">
  <a href="#installation--deployment">Installation</a> ·
  <a href="https://henrij22.github.io/TinyGismo.jl/dev/">Documentation</a>
</p>

---

TinyGismo.jl provides an alternative Julia interface to the G+Smo (Geometry + Simulation Modules) library for Splines, NURBS and Isogeometric Anylsis, focusing on:

- **Knot Vectors**: Management of knot vectors
- **Basis Functions**: B-spline and NURBS basis functions in univariate and tensor product forms
- **Geometries**: Spline curves, surfaces, and volumes for geometric modeling
- **Factories**: Convenient constructors for standard geometric shapes
- **Utilities**: Matrix types, file I/O, and helper functions

The official Julia bindings can be found at [Gismo.jl](https://github.com/gismo/Gismo.jl). This alternative wrapper tries to serve a well documented, more native *Julian* experience to the G+Smo library for Isogeometric Analysis.
Notable difference include, but are not limited to

- Native `1`-based indexing into everything that is iterable, for example shape function indices
- Bang-Methods (`!`) instead of  G+Smo's `_into()` methods
- Native parametric types (e.g. `TensorBSplineBasis{2}`), that map to the C++ templates

## Installation & Deployment

The C++ component of this library can be found at [libjltinygismo](https://github.com/henrij22/libjltinygismo), with binaries being deployed to [TinyGismo_jll.jl](https://github.com/henrij22/TinyGismo_jll.jl). Binaries are currently deployed for all major platforms.

If you want to use this package, please add this repo and the binary dependency [TinyGismo_jll.jl](https://github.com/henrij22/TinyGismo_jll.jl) repo to your environment manually:

```julia
(@v1.12) pkg> add https://github.com/henrij22/TinyGismo_jll.jl
(@v1.12) pkg> add https://github.com/henrij22/TinyGismo.jl
```

Ideas, bug-fixes and other contributions are always welcome.
