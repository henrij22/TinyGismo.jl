@testitem "Nurbs: the full geometry interface is available" begin
    using TinyGismo: weights, weight, basis, knots, jacobian

    circle = createNurbsCircle(1.0)

    # gsNurbs was missing its upcast to gsGeometry, so all of these used to fail.
    @test parDim(circle) == 1
    @test targetDim(circle) == 2
    @test geoDim(circle) == 2
    @test coefsSize(circle) == 9
    @test size(toMatrix(coefs(circle))) == (9, 2)
    @test size(toMatrix(jacobian(circle, [0.3]))) == (2, 1)

    out = gsMatrix()
    @test (eval!(circle, [0.25], out); true)
end

@testitem "Nurbs: a NURBS circle is exactly round" begin
    for r in (1.0, 2.5)
        circle = createNurbsCircle(r)
        for u in 0.0:0.02:1.0
            out = gsMatrix()
            eval!(circle, [u], out)
            @test sqrt(sum(abs2, toMatrix(out))) ≈ r
        end
    end

    @testset "a polynomial B-spline cannot manage it" begin
        # createBSplineFatCircle is the polynomial approximation of the same shape
        approx = createBSplineFatCircle(1.0)
        radii = map(0.0:0.02:1.0) do u
            out = gsMatrix()
            eval!(approx, [u], out)
            sqrt(sum(abs2, toMatrix(out)))
        end
        @test !all(≈(1.0), radii)
    end
end

@testitem "Nurbs: weights" begin
    using TinyGismo: weights, weight

    circle = createNurbsCircle(1.0)
    w = toVector(weights(circle))

    @test length(w) == coefsSize(circle)
    @test all(w .> 0)
    # the quadratic rational arcs of a circle carry sqrt(2)/2 at the corner points
    @test w[2] ≈ sqrt(2) / 2
    @test all(weight(circle, i) ≈ w[i] for i in eachindex(w))
end

@testitem "Nurbs: unit weights reduce to the B-spline case" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]

    bspline = BSpline(BSplineBasis(kv), cp)
    nurbs = Nurbs(NurbsBasis(kv, ones(4)), cp)

    for u in 0.0:0.1:1.0
        a, b = gsMatrix(), gsMatrix()
        eval!(bspline, [u], a)
        eval!(nurbs, [u], b)
        @test toMatrix(a) ≈ toMatrix(b)
    end
end

@testitem "TensorNurbs: the quarter annulus is an exact ring" begin
    using TinyGismo: weights

    inner, outer = 1.0, 2.0
    annulus = createNurbsQuarterAnnulus(inner, outer)

    @test parDim(annulus) == 2
    @test targetDim(annulus) == 2

    ev(uv) = (out = gsMatrix(); eval!(annulus, uv, out); vec(toMatrix(out)))

    # u is the radial direction, v the angular one
    for v in 0.0:0.05:1.0
        @test sqrt(sum(abs2, ev([0.0, v]))) ≈ inner
        @test sqrt(sum(abs2, ev([1.0, v]))) ≈ outer
    end

    # the corner weights of a quarter turn
    w = toVector(weights(annulus))
    @test count(≈(sqrt(2) / 2), w) == 2

    @testset "sweeps exactly a quarter turn" begin
        start, stop = ev([0.0, 0.0]), ev([0.0, 1.0])
        @test atan(start[2], start[1]) ≈ 0.0 atol = 1.0e-12
        @test atan(stop[2], stop[1]) ≈ pi / 2
    end
end

@testitem "TensorNurbs: sphere is a surface in three dimensions" begin
    sphere = createNurbsSphere(1.5)

    @test parDim(sphere) == 2      # a surface, despite the name
    @test targetDim(sphere) == 3

    for u in 0.0:0.2:1.0, v in 0.0:0.2:1.0
        out = gsMatrix()
        eval!(sphere, [u, v], out)
        @test sqrt(sum(abs2, toMatrix(out))) ≈ 1.5
    end
end
