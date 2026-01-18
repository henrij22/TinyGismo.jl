@testitem "Knot Vector Test" begin
    vec = [0, 0, 0, 0.5, 1, 1, 1]
    kv = KnotVector(vec)

    @test size(kv) == length(vec)
    @test uSize(kv) == length(unique(vec))
    @test numElements(kv) == length(unique(vec)) - 1
end

@testitem "BSpline Basis Test" begin
    vec = [0, 0, 0, 0.5, 1, 1, 1]
    kv = KnotVector(vec)
    basis = BSplineBasis(kv)
    p = 2

    @test size(basis) == size(kv) - p - 1
    @test knotContainer(knots(basis)) ≈ vec
    @test degree(basis) == p
    @test numElements(basis) == numElements(kv)
    @test numActive(basis) == 3

    uniformRefine(basis)
    @test numElements(basis) == 2numElements(kv)
    @test degree(basis) == p

    uniformCoarsen(basis)
    @test numElements(basis) == numElements(kv)
    @test degree(basis) == p

    # Degree Elevation (each unique knot gets repeated)
    degreeElevate(basis)
    @test numElements(basis) == numElements(kv)
    @test degree(basis) == p + 1
    @test length(knotContainer(knots(basis))) == size(kv) + uSize(kv)

    # Degree Reduce keeps continuity in [0, 0, 0, 0.5, 0.5, 1, 1, 1]
    degreeDecrease(basis)
    @test numElements(basis) == numElements(kv)
    @test degree(basis) == p
    @test length(knotContainer(knots(basis))) == size(kv) + 1

    # Degree Increase (only outer knots are repeated?)
    basis = BSplineBasis(kv)
    degreeIncrease(basis)
    @test degree(basis) == p + 1
    @test length(knotContainer(knots(basis))) == size(kv) + 2

    # Degree Reduce (elevates continuity (?))
    basis = BSplineBasis(kv)
    degreeElevate(basis)
    degreeReduce(basis)
    @test knotContainer(knots(basis)) ≈ vec

    # continuity, effectivly gets rid of one knot in the middle (?)
    basis = BSplineBasis(kv)
    elevateContinuity(basis)
    @test degree(basis) == p
    @test numElements(basis) == 1
    @test length(knotContainer(knots(basis))) == size(kv) - 1

    # Test eval! evalSingle and evalFunc
    basis = BSplineBasis(kv)
    coefs = randn(size(basis))
    ξ = [0.4]

    # Test equivalency bang and non-bang methods
    # Note directly calling toMatrix might invalidate the results, in general use bang-mathods
    _result = TinyGismo._eval(basis, ξ)
    result = toMatrix(_result)

    result2 = gsMatrix()
    TinyGismo.eval!(basis, ξ, result2)
    @test result ≈ toMatrix(result2)

    # Partition of unity
    sum(result) ≈ 1.0

    # actives 
    out = gsMatrix{Int32}()
    active!(basis, ξ, out)
    length(toVector(out)) == numActive(basis)


    # Eval Func, evaluating directly in a Float is fine 
    resultFunc = toMatrix(TinyGismo.evalFunc(basis, ξ, coefs))[1]

    funcVal = 0.0 
    for i in 1:numActive(basis)
        Ni = toMatrix(TinyGismo.evalSingle(basis, i, [0.4]))[1]
        @test Ni ≈ result[i]
        global funcVal += Ni * coefs[toVector(out)[i]] 
    end

end

@testitem "BSpline Test" begin
    vec = [0, 0, 0, 0.5, 1, 1, 1]
    kv = KnotVector(vec)
    basis = BSplineBasis(kv)

    coefs = randn(4)
    spline = BSpline(basis, coefs)

    @test TinyGismo.targetDim(spline) == 1
    @test TinyGismo.coefDim(spline) == 1
    @test TinyGismo.parDim(spline) == 1
    @test TinyGismo.geoDim(spline) == 1

    result = gsMatrix()
    TinyGismo.eval!(basis, [0.4], result)
    @test size(toMatrix(result)) == (3, 1)

    result2 = gsMatrix()
    TinyGismo.eval!(basis, [0.4], result)

    coefs = randn(4, 2)
    spline = BSpline(basis, coefs)

    @test TinyGismo.targetDim(spline) == 2
    @test TinyGismo.coefDim(spline) == 2
    @test TinyGismo.parDim(spline) == 1
    @test TinyGismo.geoDim(spline) == 2

end
