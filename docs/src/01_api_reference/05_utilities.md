# Utilities

Utility types and functions for working with Gismo objects.

## Knot Span

```@docs
TinyGismo.KnotSpan
centerPoint
lowerCorner
upperCorner
```

## Matrix and Vector Types

Gismo uses its own matrix and vector types for efficient computation and interfacing with C++.

### Constructors

```@docs
gsMatrix
gsVector
```

### Size and Dimension Queries

```@docs
Base.size(::TinyGismo.gsMatrix)
Base.size(::TinyGismo.gsMatrix, ::Integer)
Base.size(::TinyGismo.gsVector)
Base.size(::TinyGismo.gsVector, ::Integer)
Base.length(::TinyGismo.gsMatrix)
TinyGismo.rows
TinyGismo.cols
TinyGismo.size
```

### Conversion Functions

```@docs
toMatrix
toVector
TinyGismo.toValue
```

### Element Access

```@docs
TinyGismo.value
TinyGismo._value
TinyGismo.setValue!
```
