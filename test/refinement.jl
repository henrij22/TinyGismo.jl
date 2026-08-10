@testitem "Knot insertion adds one function and one element per knot" begin
    using TinyGismo: knots, degree, multiplicity

    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    b = BSplineBasis(kv)
    n0, e0 = size(b), numElements(b)

    insertKnot!(b, 0.25)
    @test size(b) == n0 + 1
    @test numElements(b) == e0 + 1
    @test degree(b) == 2                       # insertion never changes the degree
    @test multiplicity(knots(b), 0.25) == 1

    insertKnot!(b, 0.75, 2)
    @test multiplicity(knots(b), 0.75) == 2
    @test size(b) == n0 + 3
    @test numElements(b) == e0 + 2             # a double knot still adds one span

    insertKnots!(b, [0.1, 0.9])
    @test multiplicity(knots(b), 0.1) == 1
    @test multiplicity(knots(b), 0.9) == 1

    removeKnot!(b, 0.1)
    @test multiplicity(knots(b), 0.1) == 0
end

@testitem "uniformRefine! splits every element" begin
    using TinyGismo: knots

    b = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))

    uniformRefine!(b)
    @test numElements(b) == 4
    @test size(b) == 6
    @test knotContainer(knots(b)) ≈ [0, 0, 0, 0.25, 0.5, 0.75, 1, 1, 1]

    uniformRefine!(b, 3)                       # three knots per span
    @test numElements(b) == 16

    uniformCoarsen!(b)
    @test numElements(b) == 8
end

@testitem "Refining a geometry leaves it unchanged" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]

    sample(geo) = [
        (out = gsMatrix(); eval!(geo, [u], out); vec(toMatrix(out)))
            for u in 0.0:0.05:1.0
    ]

    curve = BSpline(BSplineBasis(kv), cp)
    before = sample(curve)

    uniformRefine!(curve)
    @test coefsSize(curve) == 6
    @test all(sample(curve) .≈ before)
    @test !(toMatrix(coefs(curve))[2, :] ≈ cp[2, :])   # the control net did move

    insertKnot!(curve, 0.3)
    @test all(sample(curve) .≈ before)

    degreeElevate!(curve)
    @test TinyGismo.degree(curve) == 3
    @test all(sample(curve) .≈ before)
end

@testitem "uniformRefine_withCoefs! returns the refined coefficients" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]

    sample(geo) = [
        (out = gsMatrix(); eval!(geo, [u], out); vec(toMatrix(out)))
            for u in 0.0:0.05:1.0
    ]
    before = sample(BSpline(BSplineBasis(kv), cp))

    b = BSplineBasis(kv)
    newcoefs = toMatrix(uniformRefine_withCoefs!(b, copy(cp)))

    # The coefficients cannot be updated in place -- refinement adds control points.
    @test size(newcoefs) == (6, 2)
    @test size(b) == 6
    @test all(sample(BSpline(b, newcoefs)) .≈ before)

    @test_throws Exception uniformRefine_withCoefs!(BSplineBasis(kv), zeros(3, 2))
end

@testitem "Degree elevation versus degree increase" begin
    using TinyGismo: knots, degree, multiplicity

    base = [0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]

    @testset "elevate raises interior multiplicities, keeping continuity" begin
        b = BSplineBasis(KnotVector(base))
        degreeElevate!(b)
        @test degree(b) == 3
        @test multiplicity(knots(b), 0.5) == 2       # C^1 at degree 3, as before
        @test numElements(b) == 2
    end

    @testset "increase leaves the interior alone, raising continuity" begin
        b = BSplineBasis(KnotVector(base))
        degreeIncrease!(b)
        @test degree(b) == 3
        @test multiplicity(knots(b), 0.5) == 1       # now C^2
        @test numElements(b) == 2
    end

    @testset "reduce inverts elevate" begin
        b = BSplineBasis(KnotVector(base))
        degreeElevate!(b)
        degreeReduce!(b)
        @test degree(b) == 2
        @test knotContainer(knots(b)) ≈ base
    end

    @testset "decrease inverts increase" begin
        b = BSplineBasis(KnotVector(base))
        degreeIncrease!(b)
        degreeDecrease!(b)
        @test degree(b) == 2
    end
end

@testitem "Continuity operations at fixed degree" begin
    using TinyGismo: knots, degree

    b = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))
    elevateContinuity!(b)
    @test degree(b) == 2                     # unchanged
    @test numElements(b) == 1                # the interior knot is gone
    @test knotContainer(knots(b)) ≈ [0, 0, 0, 1, 1, 1]

    # These take no direction argument.
    @test_throws MethodError elevateContinuity!(b, 1, 0)
end

@testitem "Refining a tensor geometry, all directions at once" begin
    using TinyGismo: basis, component, degree

    rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
    @test numElements(basis(rect)) == 1

    uniformRefine!(rect, 2)
    b = basis(rect)
    @test numElements(component(b, 1)) == 3
    @test numElements(component(b, 2)) == 3
    @test numElements(b) == 9
    @test coefsSize(rect) == 25

    beforedeg = (degree(rect, 1), degree(rect, 2))
    degreeElevate!(rect)
    @test (degree(rect, 1), degree(rect, 2)) == beforedeg .+ 1
end

@testitem "Refining a single direction" begin
    using TinyGismo: basis, component, knots, degree

    rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
    uniformRefine!(rect, 1, 1, 1)              # direction 1 only
    b = basis(rect)
    @test numElements(component(b, 1)) == 2
    @test numElements(component(b, 2)) == 1

    insertKnot!(rect, 0.25, 2)                 # value, direction 2
    b = basis(rect)
    @test numElements(component(b, 1)) == 2
    @test numElements(component(b, 2)) == 2

    degreeElevate!(rect, 1, 1)                 # elevate once, direction 1
    @test (degree(rect, 1), degree(rect, 2)) == (3, 2)
    degreeElevate!(rect, 1, 2)
    @test (degree(rect, 1), degree(rect, 2)) == (3, 3)
end

@testitem "Direction 0 means all directions" begin
    using TinyGismo: degree

    r = createBSplineRectangle()
    degreeElevate!(r, 1, 0)
    @test (degree(r, 1), degree(r, 2)) == (3, 3)

    r2 = createBSplineRectangle()
    degreeElevate!(r2)                          # the default is 0
    @test (degree(r2, 1), degree(r2, 2)) == (3, 3)
end

@testitem "Out-of-range directions raise rather than corrupting memory" begin
    # -1 used to be forwarded to G+Smo, which indexes without bounds checks and
    # segfaulted the process.
    for f in (degreeElevate!, degreeIncrease!, degreeDecrease!, degreeReduce!)
        @test_throws Exception f(createBSplineRectangle(), 1, -1)
        @test_throws Exception f(createBSplineRectangle(), 1, 3)
    end

    @test_throws Exception uniformRefine!(createBSplineRectangle(), 1, 1, -1)
    @test_throws Exception uniformRefine!(createBSplineRectangle(), 1, 1, 3)
    @test_throws Exception insertKnot!(createBSplineRectangle(), 0.5, 0)
    @test_throws Exception insertKnot!(createBSplineRectangle(), 0.5, 3)

    # a univariate geometry only has direction 1
    @test_throws Exception uniformRefine!(createBSplineUnitInterval(2), 1, 1, 2)
end
