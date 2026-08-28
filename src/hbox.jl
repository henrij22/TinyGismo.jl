# Element boxes for local refinement of hierarchical bases.
#
# The C++ side takes a flat `Vector{Int64}` of `2d+1` entries per box,
# `[level, lower..., upper...]`, and shifts it to the G+Smo convention at the boundary, as it
# does every other index. `RefinementBox` is the typed form of one entry, so a box is validated
# once and cannot be silently transposed into the wrong layout.

"""
    RefinementBox(level, lower::NTuple{d,Integer}, upper::NTuple{d,Integer})
    RefinementBox(level, ranges::AbstractUnitRange{<:Integer}...)

A box of elements on one level of a hierarchical basis, used to refine or unrefine locally.

`level` is the level the region is refined **to**, 1-based, with level `1` the coarsest. `lower`
and `upper` are 1-based, **inclusive** cell indices *in the index space of that same level*: the
box covers cells `lower[i]:upper[i]` in direction `i`.

The indices being given on the *target* level is the part that catches people out. Each level
halves the cells of the one before it, so cell `k` of level `l` is cells `2k-1:2k` on level
`l+1`. To refine the first cell of a coarse basis one level deeper:

```julia
refineElements!(basis, RefinementBox(2, 1:2, 1:2))   # coarse cell (1,1), addressed on level 2
RefinementBox(2, (1, 1), (2, 2))                     # the same box, corners instead of ranges
```

See [`refineElements!`](@ref) and [`unrefineElements!`](@ref).
"""
struct RefinementBox{d}
    level::Int
    lower::NTuple{d, Int}
    upper::NTuple{d, Int}

    function RefinementBox{d}(level::Integer, lower::NTuple{d, Integer}, upper::NTuple{d, Integer}) where {d}
        level >= 1 || throw(ArgumentError("RefinementBox: level must be >= 1, got $level"))
        all(>=(1), lower) || throw(ArgumentError("RefinementBox: lower corner must be >= 1, got $lower"))
        all(upper .>= lower) ||
            throw(ArgumentError("RefinementBox: upper corner $upper must not be below the lower corner $lower"))
        return new{d}(Int(level), Int.(lower), Int.(upper))
    end
end

function RefinementBox(level::Integer, lower::NTuple{d, Integer}, upper::NTuple{d, Integer}) where {d}
    return RefinementBox{d}(level, lower, upper)
end

function RefinementBox(level::Integer, ranges::AbstractUnitRange{<:Integer}...)
    return RefinementBox(level, map(first, ranges), map(last, ranges))
end

Base.ndims(::RefinementBox{d}) where {d} = d

function Base.show(io::IO, box::RefinementBox{d}) where {d}
    ranges = join(("$(l):$(u)" for (l, u) in zip(box.lower, box.upper)), ", ")
    return print(io, "RefinementBox($(box.level), $ranges)")
end

# Flatten to the layout the C++ methods expect. Mixed dimensions would produce an array the C++
# side cannot segment, so they are rejected here.
_flatten(box::RefinementBox) = Int64[box.level, box.lower..., box.upper...]

function _flatten(boxes)
    isempty(boxes) && throw(ArgumentError("refinement box list is empty"))
    d = ndims(first(boxes))
    all(b -> ndims(b) == d, boxes) ||
        throw(ArgumentError("all refinement boxes must have the same dimension, got $(Base.unique(ndims.(boxes)))"))

    flat = Vector{Int64}(undef, (2d + 1) * length(boxes))
    at = 1
    for box in boxes
        flat[at] = box.level
        flat[(at + 1):(at + d)] .= box.lower
        flat[(at + d + 1):(at + 2d)] .= box.upper
        at += 2d + 1
    end
    return flat
end

# The refinement entry points below are identical for truncated and untruncated, and for bases
# and geometries alike.
const HierarchicalBasis = Union{THBSplineBasis, HBSplineBasis}
const HierarchicalSpline = Union{THBSpline, HBSpline}
const Hierarchical = Union{HierarchicalBasis, HierarchicalSpline}

for f in (:refineElements!, :unrefineElements!)
    @eval begin
        $f(obj::Hierarchical, boxes::AbstractVector{<:RefinementBox}) = $f(obj, _flatten(boxes))
        $f(obj::Hierarchical, box::RefinementBox) = $f(obj, _flatten(box))
    end
end

for f in (:refineElements_withCoefs!, :unrefineElements_withCoefs!)
    @eval begin
        function $f(
                basis::HierarchicalBasis, coefs::AbstractMatrix{Float64},
                boxes::AbstractVector{<:RefinementBox}
            )
            return $f(basis, coefs, _flatten(boxes))
        end
        $f(basis::HierarchicalBasis, coefs::AbstractMatrix{Float64}, box::RefinementBox) =
            $f(basis, coefs, _flatten(box))
    end
end
