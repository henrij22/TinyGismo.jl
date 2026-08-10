@testitem "KnotVector: construction and queries" begin
    using TinyGismo: degree, unique, multiplicity

    knots = [0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]
    kv = KnotVector(knots)

    @test size(kv) == length(knots)
    @test uSize(kv) == length(Base.unique(knots))
    @test numElements(kv) == length(Base.unique(knots)) - 1
    @test knotContainer(kv) ≈ knots
    @test unique(kv) ≈ [0.0, 0.5, 1.0]
    @test multiplicities(kv) == [3, 1, 3]

    # The degree is implied by the end multiplicities, not stored separately.
    @test degree(kv) == 2
    @test degree(KnotVector([0.0, 0.0, 1.0, 1.0])) == 1
    @test degree(KnotVector([0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0])) == 3
end

@testitem "KnotVector: multiplicity of a single value" begin
    using TinyGismo: multiplicity

    kv = KnotVector([0.0, 0.0, 0.0, 0.25, 0.5, 0.5, 1.0, 1.0, 1.0])

    @test multiplicity(kv, 0.0) == 3
    @test multiplicity(kv, 0.25) == 1
    @test multiplicity(kv, 0.5) == 2
    @test multiplicity(kv, 1.0) == 3
    @test multiplicity(kv, 0.3) == 0   # not a knot at all

    # multiplicity and multiplicities agree
    @test [multiplicity(kv, u) for u in unique(knotContainer(kv))] == multiplicities(kv)
end

@testitem "KnotVector: Greville abscissae" begin
    using TinyGismo: greville, greville!, degree

    kv = KnotVector([0.0, 0.0, 0.0, 0.25, 0.5, 0.5, 1.0, 1.0, 1.0])
    expected = [0.0, 0.125, 0.375, 0.5, 0.75, 1.0]

    @test toVector(greville(kv)) ≈ expected

    out = gsMatrix()
    greville!(kv, out)
    @test toVector(out) ≈ expected

    # The indexed overload is 1-based and range-checked.
    @test greville(kv, 1) ≈ expected[1]
    @test greville(kv, 3) ≈ expected[3]
    @test_throws Exception greville(kv, 0)
    @test_throws Exception greville(kv, 99)

    # There is one abscissa per basis function.
    @test length(toVector(greville(kv))) == size(BSplineBasis(kv))

    @testset "definition: average of the p following knots" begin
        kv2 = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])  # degree 2
        raw = knotContainer(kv2)
        p = degree(kv2)
        manual = [sum(raw[(i + 1):(i + p)]) / p for i in 1:(length(raw) - p - 1)]
        @test toVector(greville(kv2)) ≈ manual
    end
end

@testitem "KnotVector: refinement and degree operations" begin
    using TinyGismo: degree

    base = [0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]

    @testset "uniformRefine! halves every span" begin
        kv = KnotVector(base)
        uniformRefine!(kv)
        @test numElements(kv) == 4
        uniformRefine!(kv, 3)
        @test numElements(kv) == 16
    end

    @testset "degreeElevate! preserves continuity" begin
        kv = KnotVector(base)
        degreeElevate!(kv)
        @test degree(kv) == 3
        # every unique knot gains one multiplicity
        @test size(kv) == length(base) + 3
        @test numElements(kv) == 2
    end

    @testset "degreeIncrease! only repeats the end knots" begin
        kv = KnotVector(base)
        degreeIncrease!(kv)
        @test degree(kv) == 3
        @test size(kv) == length(base) + 2
        @test numElements(kv) == 2
    end

    @testset "degreeDecrease! inverts degreeIncrease!" begin
        kv = KnotVector(base)
        degreeIncrease!(kv)
        degreeDecrease!(kv)
        @test degree(kv) == 2
        @test knotContainer(kv) ≈ base
    end
end
