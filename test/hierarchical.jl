# A quadratic knot vector over [0,1] with four elements, giving a 4x4 grid in 2D.
@testsnippet HierarchicalSetup begin
    HIER_KV = [0.0, 0.0, 0.0, 0.25, 0.5, 0.75, 1.0, 1.0, 1.0]
end

@testitem "RefinementBox: construction and validation" begin
    box = RefinementBox(2, 1:2, 3:4)
    @test box.level == 2
    @test box.lower == (1, 3)
    @test box.upper == (2, 4)
    @test ndims(box) == 2
    @test box == RefinementBox(2, (1, 3), (2, 4))
    @test occursin("RefinementBox(2, 1:2, 3:4)", sprint(show, box))

    @test ndims(RefinementBox(1, 1:1)) == 1
    @test ndims(RefinementBox(1, 1:1, 1:1, 1:1)) == 3

    @test_throws ArgumentError RefinementBox(0, 1:2, 1:2)      # level below 1
    @test_throws ArgumentError RefinementBox(1, 0:2, 1:2)      # lower corner below 1
    @test_throws ArgumentError RefinementBox(1, (2, 1), (1, 1)) # upper below lower
end

@testitem "RefinementBox: flattening to the wire format" begin
    using TinyGismo: _flatten

    # Julia-side values go over as they are; the 1-based -> G+Smo conversion happens in C++.
    @test _flatten(RefinementBox(2, 1:3, 4:5)) == Int64[2, 1, 4, 3, 5]
    @test _flatten([RefinementBox(1, 1:1, 1:1), RefinementBox(2, 2:3, 2:3)]) ==
        Int64[1, 1, 1, 1, 1, 2, 2, 2, 3, 3]

    @test_throws ArgumentError _flatten(RefinementBox[])
    @test_throws ArgumentError _flatten([RefinementBox(1, 1:1), RefinementBox(1, 1:1, 1:1)])
end

@testitem "Hierarchical bases: a single level reproduces the tensor basis" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)

    for b in (THBSplineBasis{2}(tb), HBSplineBasis{2}(tb))
        @test numLevels(b) == 1
        @test size(b) == size(tb)
        @test numElements(b) == numElements(tb)
        @test TinyGismo.degree(b, 1) == 2
        @test TinyGismo.degree(b, 2) == 2
        @test size(tensorLevel(b, 1)) == size(tb)
        @test getLevelAtPoint(b, [0.3, 0.7]) == 1
        # unrefined, a hierarchical basis is just the tensor basis
        @test toMatrix(_eval(b, [0.3, 0.7])) ≈ toMatrix(_eval(tb, [0.3, 0.7]))
    end
end

@testitem "refineElements!: a box refines exactly the cells it names" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)
    b = THBSplineBasis{2}(tb)

    # The level in a box is the level refined *to*, and the corners are indexed on that level's
    # own grid. Level 2 halves the coarse cells, so the first coarse cell [0,0.25]^2 is cells
    # 1:2 on level 2. This is the assertion that pins the whole index convention down.
    refineElements!(b, RefinementBox(2, 1:2, 1:2))

    @test numLevels(b) == 2
    @test getLevelAtPoint(b, [0.125, 0.125]) == 2   # inside the refined cell
    @test getLevelAtPoint(b, [0.375, 0.125]) == 1   # its neighbour in x
    @test getLevelAtPoint(b, [0.125, 0.375]) == 1   # its neighbour in y
    @test getLevelAtPoint(b, [0.375, 0.375]) == 1
    @test getLevelAtPoint(b, [0.875, 0.875]) == 1   # the opposite corner

    # one cell split into four
    @test numElements(b) == numElements(tb) + 3

    # and again at the far corner, which would catch an off-by-one that happened to be
    # symmetric at the origin
    far = THBSplineBasis{2}(tb)
    refineElements!(far, RefinementBox(2, 7:8, 7:8))
    @test getLevelAtPoint(far, [0.875, 0.875]) == 2
    @test getLevelAtPoint(far, [0.625, 0.875]) == 1
    @test getLevelAtPoint(far, [0.875, 0.625]) == 1
end

@testitem "refine!: parametric boxes agree with element boxes" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)

    byCoords = THBSplineBasis{2}(tb)
    refine!(byCoords, [0.0 0.25; 0.0 0.25])

    byElements = THBSplineBasis{2}(tb)
    refineElements!(byElements, RefinementBox(2, 1:2, 1:2))

    @test size(byCoords) == size(byElements)
    @test numElements(byCoords) == numElements(byElements)
    @test numLevels(byCoords) == numLevels(byElements)
    for p in ([0.125, 0.125], [0.375, 0.125], [0.625, 0.625])
        @test getLevelAtPoint(byCoords, p) == getLevelAtPoint(byElements, p)
    end
end

@testitem "unrefine!/unrefineElements!: refinement is undone" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)

    b = THBSplineBasis{2}(tb)
    refineElements!(b, RefinementBox(2, 1:2, 1:2))
    @test numLevels(b) == 2
    # The level in a box is the level the region is set *to*, for unrefinement as much as for
    # refinement. Undoing the refinement above therefore names level 1, on level 1's own grid --
    # naming level 2 again would ask for the state the basis is already in, and do nothing.
    unrefineElements!(b, RefinementBox(1, 1:1, 1:1))
    @test getLevelAtPoint(b, [0.125, 0.125]) == 1
    @test size(b) == size(tb)

    noop = THBSplineBasis{2}(tb)
    refineElements!(noop, RefinementBox(2, 1:2, 1:2))
    unrefineElements!(noop, RefinementBox(2, 1:2, 1:2))
    @test getLevelAtPoint(noop, [0.125, 0.125]) == 2

    b2 = THBSplineBasis{2}(tb)
    refine!(b2, [0.0 0.25; 0.0 0.25])
    unrefine!(b2, [0.0 0.25; 0.0 0.25])
    @test getLevelAtPoint(b2, [0.125, 0.125]) == 1
end

@testitem "Truncation: THB is a partition of unity where HB is not" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)

    thb = THBSplineBasis{2}(tb)
    hb = HBSplineBasis{2}(tb)
    refineElements!(thb, RefinementBox(2, 1:2, 1:2))
    refineElements!(hb, RefinementBox(2, 1:2, 1:2))

    # Both spans are the same size and refine the same region ...
    @test size(thb) == size(hb)
    @test numElements(thb) == numElements(hb)

    # ... but only the truncated basis still sums to one over the refined region, which is what
    # truncation buys. This is what distinguishes the two `Trunc` instantiations.
    inRefined = [0.125, 0.125]
    @test sum(toMatrix(_eval(thb, inRefined))) ≈ 1.0
    @test !(sum(toMatrix(_eval(hb, inRefined))) ≈ 1.0)
    @test !(toMatrix(_eval(thb, inRefined)) ≈ toMatrix(_eval(hb, inRefined)))

    # Away from the refinement both agree with the unrefined tensor basis.
    @test sum(toMatrix(_eval(thb, [0.875, 0.875]))) ≈ 1.0
    @test sum(toMatrix(_eval(hb, [0.875, 0.875]))) ≈ 1.0
end

@testitem "Hierarchical bases inherit the generic gsBasis operations" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)
    b = THBSplineBasis{2}(tb)
    refineElements!(b, RefinementBox(2, 1:2, 1:2))

    u = [0.3, 0.4]

    values = gsMatrix()
    eval!(b, u, values)
    @test toMatrix(values) ≈ toMatrix(_eval(b, u))

    derivs = gsMatrix()
    deriv!(b, u, derivs)
    @test length(derivs) > 0

    act = gsMatrix{Int32}()
    active!(b, u, act)
    @test all(>=(1), toMatrix(act))          # 1-based, like everywhere else
    @test all(<=(size(b)), toMatrix(act))
    # gsBasis::isActive has no implementation for hierarchical bases upstream; it raises rather
    # than returning a wrong answer. Read the actives out of active! instead.
    @test_throws Exception isActive(b, first(toMatrix(act)), u)

    # knotSpans cannot work here (see elementBoxes) and says so rather than handing back
    # element handles that read freed memory.
    @test_throws Exception knotSpans(b)

    @test 1 <= levelOf(b, 1) <= numLevels(b)
    @test 1 <= levelAtCorner(b, 1) <= numLevels(b)
    @test treeSize(b) >= 1
end

@testitem "elementBoxes: the elements tile the parameter domain" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)
    b = THBSplineBasis{2}(tb)
    refineElements!(b, RefinementBox(2, 1:2, 1:2))

    boxes = toMatrix(elementBoxes(b))
    @test Base.size(boxes) == (4, numElements(b))
    @test all(0.0 .<= boxes .<= 1.0)

    lower, upper = boxes[1:2, :], boxes[3:4, :]
    @test all(upper .> lower)

    # The elements partition [0,1]^2 exactly, so their areas sum to one ...
    areas = vec(prod(upper .- lower; dims = 1))
    @test sum(areas) ≈ 1.0
    # ... and the refined coarse cell contributes four cells of a quarter its area.
    @test count(a -> isapprox(a, 0.125^2), areas) == 4
    @test count(a -> isapprox(a, 0.25^2), areas) == 15

    # An unrefined basis reproduces the tensor grid.
    @test Base.size(toMatrix(elementBoxes(THBSplineBasis{2}(tb))), 2) == numElements(tb)
end

@testitem "refineElements_withCoefs!: coefficients follow the refinement" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)
    b = THBSplineBasis{2}(tb)

    coefs = [Float64(i + j) for i in 1:size(b), j in 1:3]
    box = RefinementBox(2, 1:2, 1:2)

    before = toMatrix(evalFunc(b, [0.6, 0.6], coefs))
    refined = toMatrix(refineElements_withCoefs!(b, coefs, box))

    @test Base.size(refined, 1) == size(b) > Base.size(coefs, 1)
    @test Base.size(refined, 2) == 3
    # refinement is exact: the function the coefficients describe is unchanged
    @test toMatrix(evalFunc(b, [0.6, 0.6], refined)) ≈ before

    # a coefficient array that does not belong to this basis is rejected rather than read past
    @test_throws Exception refineElements_withCoefs!(b, coefs, box)
end

@testitem "Hierarchical bases: constructors that pre-refine" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)

    byElements = THBSplineBasis{2}(tb, [2, 1, 1, 2, 2])
    @test numLevels(byElements) == 2
    @test getLevelAtPoint(byElements, [0.125, 0.125]) == 2

    # The parametric-coordinate constructor rounds outward: its upper corner is inclusive of the
    # cell containing it, so a corner sitting on a cell boundary pulls in the next cell too.
    byCoords = THBSplineBasis{2}(tb, [0.0 0.25; 0.0 0.25])
    @test numLevels(byCoords) == 2
    @test getLevelAtPoint(byCoords, [0.125, 0.125]) == 2
    @test size(byCoords) >= size(byElements)
end

@testitem "Hierarchical bases: other refinement entry points" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)

    side = THBSplineBasis{2}(tb)
    refineSide!(side, 1, 2)                      # west side, up to level 2
    @test getLevelAtPoint(side, [0.01, 0.5]) == 2
    @test getLevelAtPoint(side, [0.99, 0.5]) == 1

    fn = THBSplineBasis{2}(tb)
    refineBasisFunction!(fn, 1)
    @test numLevels(fn) == 2

    mult = THBSplineBasis{2}(tb)
    increaseMultiplicity!(mult, 1, 1, 0.5)       # level 1, direction 1, at the knot 0.5
    @test size(mult) > size(tb)
    @test_throws Exception increaseMultiplicity!(mult, 1, 0, 0.5)   # direction 0 is not valid
end

@testitem "Hierarchical bases: univariate and trivariate" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)

    b1 = THBSplineBasis{1}(BSplineBasis(kv))
    refineElements!(b1, RefinementBox(2, 1:2))
    @test numLevels(b1) == 2
    @test getLevelAtPoint(b1, [0.125]) == 2
    @test getLevelAtPoint(b1, [0.875]) == 1
    @test sum(toMatrix(_eval(b1, [0.125]))) ≈ 1.0

    b3 = THBSplineBasis{3}(TensorBSplineBasis{3}(kv, kv, kv))
    refineElements!(b3, RefinementBox(2, 1:2, 1:2, 1:2))
    @test numLevels(b3) == 2
    @test getLevelAtPoint(b3, [0.125, 0.125, 0.125]) == 2
    @test sum(toMatrix(_eval(b3, [0.125, 0.125, 0.125]))) ≈ 1.0
end

@testitem "Hierarchical bases: invalid boxes are rejected" setup = [HierarchicalSetup] begin
    kv = KnotVector(HIER_KV)
    b = THBSplineBasis{2}(TensorBSplineBasis{2}(kv, kv))

    @test_throws Exception refineElements!(b, Int64[2, 1, 1, 2])       # not a multiple of 2d+1
    @test_throws Exception refineElements!(b, Int64[0, 1, 1, 2, 2])    # level below 1
    @test_throws Exception refineElements!(b, Int64[2, 0, 1, 2, 2])    # lower corner below 1
    @test_throws Exception refineElements!(b, Int64[2, 3, 3, 2, 2])    # upper below lower
    @test_throws Exception tensorLevel(b, 0)
    @test_throws Exception tensorLevel(b, numLevels(b) + 1)
end

@testitem "THBSpline: local refinement leaves the geometry unchanged" setup = [HierarchicalSetup] begin
    using TinyGismo: basis

    kv = KnotVector(HIER_KV)
    tb = TensorBSplineBasis{2}(kv, kv)
    b = THBSplineBasis{2}(tb)

    coefs = [Float64(i + 2j) for i in 1:size(b), j in 1:3]
    geo = THBSpline{2}(b, coefs)

    @test numCoefs(geo) == size(b)
    @test parDim(geo) == 2
    @test geoDim(geo) == 3
    @test size(basis(geo)) == size(b)
    @test TinyGismo.degree(geo, 1) == 2

    before = toMatrix(_eval(geo, [0.6, 0.6]))
    refineElements!(geo, RefinementBox(2, 1:2, 1:2))

    @test numCoefs(geo) > size(b)
    @test numCoefs(geo) == size(basis(geo))
    @test numLevels(basis(geo)) == 2
    # refinement changes the representation, not the map
    @test toMatrix(_eval(geo, [0.6, 0.6])) ≈ before
    @test toMatrix(_eval(geo, [0.1, 0.1])) ≈ toMatrix(_eval(THBSpline{2}(b, coefs), [0.1, 0.1]))
end

@testitem "THBSpline: lifting from and lowering to tensor B-splines" begin
    using TinyGismo: basis

    rect = createBSplineRectangle()
    lifted = THBSpline{2}(rect)
    @test numCoefs(lifted) == coefsSize(rect)
    @test toMatrix(_eval(lifted, [0.4, 0.4])) ≈ toMatrix(_eval(rect, [0.4, 0.4]))

    refineElements!(lifted, RefinementBox(2, 1:1, 1:1))
    before = numCoefs(lifted)
    flattened = convertToBSpline(lifted)
    @test flattened isa TensorBSpline
    @test toMatrix(_eval(flattened, [0.4, 0.4])) ≈ toMatrix(_eval(lifted, [0.4, 0.4]))
    # convertToBSpline carries no bang, so it must leave its argument alone -- upstream
    # gsTHBSpline::convertToBSpline refines *this, which the binding works around.
    @test numCoefs(lifted) == before
end

@testitem "Hierarchical I/O: reading XML and writing Paraview" begin
    using TinyGismo: basis

    b = readFile(THBSplineBasis{2}, joinpath(@__DIR__, "data", "thbs_basis_02.xml"))
    @test numLevels(b) > 1
    @test size(b) > 0
    @test sum(toMatrix(_eval(b, [0.5, 0.5]))) ≈ 1.0

    geo = readFile(THBSpline{2}, joinpath(@__DIR__, "data", "thbs_face_3levels.xml"))
    @test numLevels(basis(geo)) > 1
    @test numCoefs(geo) == size(basis(geo))

    mktempdir() do dir
        writeParaview(geo, joinpath(dir, "geo"), 100)
        writeParaview(b, joinpath(dir, "basis"), 100)
        @test !isempty(readdir(dir))
    end
end
