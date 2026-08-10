@testitem "TensorBSplineBasis: structure is the product of its directions" begin
    using TinyGismo: knots, degree, component

    kvu = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])   # quadratic, 3 functions
    kvv = KnotVector([0.0, 0.0, 1.0, 1.0])             # linear,    2 functions
    tb = TensorBSplineBasis{2}(kvu, kvv)

    @test size(tb) == size(BSplineBasis(kvu)) * size(BSplineBasis(kvv))
    @test degree(tb, 1) == 2
    @test degree(tb, 2) == 1

    # component gives back the univariate basis of one direction
    @test size(component(tb, 1)) == 3
    @test size(component(tb, 2)) == 2
    @test degree(component(tb, 1)) == 2
    @test knotContainer(knots(tb, 1)) ≈ knotContainer(kvu)
    @test knotContainer(knots(tb, 2)) ≈ knotContainer(kvv)

    # the count of nonzero functions per element is the product over directions
    @test numActive(tb) == (degree(tb, 1) + 1) * (degree(tb, 2) + 1)
end

@testitem "TensorBSplineBasis: trivariate" begin
    using TinyGismo: degree, component

    kvu = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
    kvv = KnotVector([0.0, 0.0, 1.0, 1.0])
    tb3 = TensorBSplineBasis{3}(kvu, kvv, kvv)

    @test size(tb3) == 3 * 2 * 2
    @test (degree(tb3, 1), degree(tb3, 2), degree(tb3, 3)) == (2, 1, 1)
    @test numActive(tb3) == 3 * 2 * 2

    values = gsMatrix()
    eval!(tb3, [0.5, 0.5, 0.5], values)
    @test sum(toMatrix(values)) ≈ 1.0
end

@testitem "TensorBSplineBasis: partition of unity over the parameter square" begin
    tb = TinyGismo.basis(createBSplineRectangle())
    uniformRefine!(tb, 2)

    for u in 0.0:0.25:1.0, v in 0.0:0.25:1.0
        values = gsMatrix()
        eval!(tb, [u, v], values)
        @test sum(toMatrix(values)) ≈ 1.0
        @test size(toMatrix(values), 1) == numActive(tb)
    end
end

@testitem "numElements second argument is a box side, not a direction" begin
    using TinyGismo: basis, component, knots

    # Build an anisotropic mesh: 4 elements along u, 3 along v.
    rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
    uniformRefine!(rect, 2)          # 3 x 3
    insertKnot!(rect, 0.5, 1)        # -> 4 x 3
    b = basis(rect)

    @test numElements(component(b, 1)) == 4
    @test numElements(component(b, 2)) == 3
    @test numElements(b) == 12                     # total, the product

    # Sides 1/2 (west/east) run along v, sides 3/4 (south/north) run along u.
    @test numElements(b, 1) == 3
    @test numElements(b, 2) == 3
    @test numElements(b, 3) == 4
    @test numElements(b, 4) == 4
end

@testitem "TensorNurbsBasis: construction" begin
    using TinyGismo: degree

    kvu = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
    kvv = KnotVector([0.0, 0.0, 1.0, 1.0])
    w = 0.5 * sqrt(2)
    weights = reshape([1.0, w, 1.0, 1.0, w, 1.0], 6, 1)

    tnb = TensorNurbsBasis{2}(kvu, kvv, weights)
    @test size(tnb) == 6
    @test degree(tnb, 1) == 2
    @test degree(tnb, 2) == 1
    @test numActive(tnb) == 6

    values = gsMatrix()
    eval!(tnb, [0.4, 0.6], values)
    @test sum(toMatrix(values)) ≈ 1.0

    @testset "trivariate" begin
        tnb3 = TensorNurbsBasis{3}(kvu, kvv, kvv, ones(12, 1))
        @test size(tnb3) == 12
        @test numActive(tnb3) == 12
    end
end

@testitem "knotSpans tile the parameter domain" begin
    using TinyGismo: basis

    @testset "univariate" begin
        b = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))
        spans = knotSpans(b)
        @test length(spans) == numElements(b)

        for span in spans
            lo = toVector(lowerCorner(span))
            up = toVector(upperCorner(span))
            mid = toVector(centerPoint(span))
            @test length(lo) == 1
            @test lo[1] < up[1]
            @test mid ≈ (lo .+ up) ./ 2
        end

        # the spans cover [0, 1] exactly, without overlap
        @test sum(toVector(upperCorner(s))[1] - toVector(lowerCorner(s))[1] for s in spans) ≈ 1.0
    end

    @testset "bivariate" begin
        tb = basis(createBSplineRectangle())
        uniformRefine!(tb)
        spans = knotSpans(tb)
        @test length(spans) == numElements(tb) == 4

        area = sum(spans) do span
            lo, up = toVector(lowerCorner(span)), toVector(upperCorner(span))
            @test length(lo) == 2
            prod(up .- lo)
        end
        @test area ≈ 1.0

        # every span centre maps back to the span it came from
        for (i, span) in enumerate(spans)
            @test elementIndex(tb, toVector(centerPoint(span))) == i
        end
    end
end
