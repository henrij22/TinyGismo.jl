# Utilities

Utility types and functions for working with Gismo objects.

## Knot Span

```@docs
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
TinyGismo.size
TinyGismo.rows
TinyGismo.cols
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
```
