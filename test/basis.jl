@testitem "BSplineBasis: structure" begin
    using TinyGismo: knots, degree, order

    knotvals = [0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]
    kv = KnotVector(knotvals)
    basis = BSplineBasis(kv)

    # n = m - p - 1
    @test size(basis) == length(knotvals) - degree(basis) - 1
    @test degree(basis) == 2
    @test order(basis) == degree(basis) + 1
    @test numElements(basis) == numElements(kv)
    @test numActive(basis) == degree(basis) + 1
    @test knotContainer(knots(basis)) ≈ knotvals
end

@testitem "BSplineBasis: evaluation is a partition of unity" begin
    basis = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.25, 0.5, 0.75, 1.0, 1.0, 1.0]))

    for u in 0.0:0.05:1.0
        values = gsMatrix()
        eval!(basis, [u], values)
        N = toMatrix(values)

        @test size(N, 1) == numActive(basis)
        @test sum(N) ≈ 1.0
        @test all(N .>= -1.0e-14)          # B-splines are non-negative
    end
end

@testitem "BSplineBasis: actives are 1-based and match evalSingle" begin
    using TinyGismo: evalSingle

    basis = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))
    u = [0.4]

    values = gsMatrix()
    eval!(basis, u, values)
    N = toVector(values)

    actives = gsMatrix{Int32}()
    active!(basis, u, actives)
    idx = toVector(actives)

    @test length(idx) == numActive(basis)
    @test idx == Int32[1, 2, 3]                       # 1-based, contiguous
    @test all(1 .<= idx .<= size(basis))

    # eval! lists exactly the active functions, in order
    for (k, i) in enumerate(idx)
        @test toMatrix(evalSingle(basis, i, u))[1] ≈ N[k]
    end

    # and every other function really is zero there
    for i in setdiff(1:Int(size(basis)), idx)
        @test toMatrix(evalSingle(basis, i, u))[1] ≈ 0.0 atol = 1.0e-14
        @test !isActive(basis, i, u)
    end
    @test all(isActive(basis, i, u) for i in idx)
end

@testitem "BSplineBasis: element lookup" begin
    basis = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.25, 0.5, 0.75, 1.0, 1.0, 1.0]))

    @test numElements(basis) == 4
    @test elementIndex(basis, [0.1]) == 1
    @test elementIndex(basis, [0.3]) == 2
    @test elementIndex(basis, [0.6]) == 3
    @test elementIndex(basis, [0.9]) == 4

    # elementInSupportOf hands back the corners of one element of the support
    for i in 1:Int(size(basis))
        span = toMatrix(elementInSupportOf(basis, i))
        @test length(span) == 2
        @test span[1] < span[2]
        @test isActive(basis, i, [(span[1] + span[2]) / 2])
    end
end

@testitem "BSplineBasis: derivatives" begin
    using TinyGismo: derivSingle, deriv2Single, evalSingle

    basis = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))
    u = [0.4]

    dN = gsMatrix()
    deriv!(basis, u, dN)
    # The partition of unity differentiates to zero.
    @test sum(toMatrix(dN)) ≈ 0.0 atol = 1.0e-12

    ddN = gsMatrix()
    deriv2!(basis, u, ddN)
    @test sum(toMatrix(ddN)) ≈ 0.0 atol = 1.0e-12

    actives = gsMatrix{Int32}()
    active!(basis, u, actives)
    idx = toVector(actives)

    for (k, i) in enumerate(idx)
        @test toMatrix(derivSingle(basis, i, u))[1] ≈ toMatrix(dN)[k]
        @test deriv2Single(basis, i, u) isa Float64
    end

    @testset "first derivative against finite differences" begin
        h = 1.0e-6
        for (k, i) in enumerate(idx)
            fd = (
                toMatrix(evalSingle(basis, i, [0.4 + h]))[1] -
                    toMatrix(evalSingle(basis, i, [0.4 - h]))[1]
            ) / (2h)
            @test toMatrix(derivSingle(basis, i, u))[1] ≈ fd atol = 1.0e-6
        end
    end
end

@testitem "BSplineBasis: evalFunc equals manual assembly" begin
    using TinyGismo: derivFunc

    basis = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))
    coefs = [1.0, 2.0, 0.0, -1.0]

    for u in (0.1, 0.4, 0.5, 0.9)
        values = gsMatrix()
        eval!(basis, [u], values)
        N = toVector(values)

        actives = gsMatrix{Int32}()
        active!(basis, [u], actives)
        idx = toVector(actives)

        manual = sum(N[k] * coefs[idx[k]] for k in eachindex(idx))
        @test toMatrix(evalFunc(basis, [u], coefs))[1] ≈ manual

        # The same function built as a geometry agrees.
        spline = BSpline(basis, coefs)
        out = gsMatrix()
        eval!(spline, [u], out)
        @test toMatrix(out)[1] ≈ manual
    end

    @testset "derivFunc agrees with finite differences" begin
        h, u = 1.0e-6, 0.4
        fd = (
            toMatrix(evalFunc(basis, [u + h], coefs))[1] -
                toMatrix(evalFunc(basis, [u - h], coefs))[1]
        ) / (2h)
        @test toMatrix(derivFunc(basis, [u], coefs))[1] ≈ fd atol = 1.0e-6
    end
end

@testitem "BSplineBasis: boundary functions" begin
    basis = BSplineBasis(KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]))

    # A clamped knot vector makes exactly one function nonzero at each end.
    @test toVector(boundary(basis, 1)) == Int32[1]
    @test toVector(boundary(basis, 2)) == Int32[size(basis)]
end

@testitem "NurbsBasis: construction" begin
    using TinyGismo: degree, knots

    kv = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
    w = [1.0, sqrt(2) / 2, 1.0]

    plain = NurbsBasis(kv)
    weighted = NurbsBasis(kv, w)
    fromBSpline = NurbsBasis(BSplineBasis(kv), w)

    for b in (plain, weighted, fromBSpline)
        @test size(b) == 3
        @test degree(b) == 2
        @test numActive(b) == 3
        @test knotContainer(knots(b)) ≈ knotContainer(kv)
    end

    @testset "rational basis is still a partition of unity" begin
        values = gsMatrix()
        eval!(weighted, [0.3], values)
        @test sum(toMatrix(values)) ≈ 1.0
    end
end
