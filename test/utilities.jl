@testitem "gsMatrix: construction, access and conversion" begin
    using TinyGismo: rows, cols, value, _value, setValue!, toValue

    m = gsMatrix(3, 2)
    @test rows(m) == 3
    @test cols(m) == 2

    # Base.size gives dimensions, length the total entry count.
    @test size(m) == (3, 2)
    @test size(m, 1) == 3
    @test size(m, 2) == 2
    @test length(m) == 6
    @test TinyGismo.size(m) == 6      # the raw C++ size() is still the total

    for j in 1:2, i in 1:3
        setValue!(m, i, j, 10i + j)
    end

    @test toMatrix(m) == [11.0 12.0; 21.0 22.0; 31.0 32.0]
    @test value(m, 2, 1) == 21.0
    @test _value(m, 2, 1) == 21.0
    @test m[2, 1] == 21.0                       # Base.getindex

    @testset "bounds are checked" begin
        @test_throws Exception value(m, 4, 1)
        @test_throws Exception value(m, 1, 3)
        @test_throws Exception value(m, 0, 1)
        @test_throws Exception setValue!(m, 4, 1, 0.0)
        @test_throws Exception setValue!(m, 1, 0, 0.0)
    end

    @testset "toValue needs a 1x1 matrix" begin
        one = gsMatrix(1, 1)
        setValue!(one, 1, 1, 42.0)
        @test toValue(one) == 42.0
        @test_throws Exception toValue(m)
    end
end

@testitem "gsVector: construction, access and conversion" begin
    using TinyGismo: rows, value, setValue!

    v = gsVector(3)
    @test rows(v) == 3
    @test size(v) == (3,)
    @test size(v, 1) == 3
    @test length(v) == 3
    @test TinyGismo.size(v) == 3

    for i in 1:3
        setValue!(v, i, float(i^2))
    end

    @test toVector(v) == [1.0, 4.0, 9.0]
    @test value(v, 3) == 9.0
    @test_throws Exception value(v, 4)
    @test_throws Exception setValue!(v, 0, 1.0)
end

@testitem "toVector accepts a single row or a single column" begin
    using TinyGismo: greville, setValue!

    col = gsMatrix(3, 1)
    for i in 1:3
        setValue!(col, i, 1, float(i))
    end
    @test toVector(col) == [1.0, 2.0, 3.0]

    # greville hands back a 1 x n row
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    @test length(toVector(greville(kv))) == 4

    @test_throws Exception toVector(gsMatrix(2, 2))
end

@testitem "Integer matrix types" begin
    using TinyGismo: setValue!

    m = gsMatrix{Int32}(2, 2)
    for j in 1:2, i in 1:2
        setValue!(m, i, j, Int32(i * j))
    end
    @test toMatrix(m) == Int32[1 2; 2 4]

    v = gsVector{Int32}(2)
    setValue!(v, 1, Int32(7))
    setValue!(v, 2, Int32(8))
    @test toVector(v) == Int32[7, 8]
end

@testitem "Returned arrays own their memory" begin
    using TinyGismo: knots, weights, jacobian, greville

    # toMatrix/toVector/knotContainer used to return a view into a C++ buffer. In every
    # expression below the source is a temporary, so a collection between the call and the
    # read would silently hand back freed memory.
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    basis = BSplineBasis(kv)
    rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)
    annulus = createNurbsQuarterAnnulus(1.0, 2.0)

    cases = [
        ("knotContainer(knots(basis))", () -> knotContainer(knots(basis)), [0, 0, 0, 0.5, 1, 1, 1]),
        ("knotContainer(kv)", () -> knotContainer(kv), [0, 0, 0, 0.5, 1, 1, 1]),
        ("toMatrix(coefs(rect))", () -> toMatrix(coefs(rect))[1:3, :], [0.0 0.0; 1.0 0.0; 2.0 0.0]),
        (
            "toVector(weights(annulus))", () -> toVector(weights(annulus)),
            [1, 1, sqrt(2) / 2, sqrt(2) / 2, 1, 1],
        ),
        ("toMatrix(_eval(basis, u))", () -> toMatrix(_eval(basis, [0.4])), [0.04, 0.64, 0.32]),
        ("toMatrix(jacobian(rect, u))", () -> toMatrix(jacobian(rect, [0.5, 0.5])), [2.0 0.0; 0.0 1.0]),
        ("toVector(greville(kv))", () -> toVector(greville(kv)), [0.0, 0.25, 0.75, 1.0]),
        ("toVector(coefAtCorner(rect, 1))", () -> toVector(coefAtCorner(rect, 1)), [0.0, 0.0]),
    ]

    for (name, f, expected) in cases
        @testset "$name" begin
            got = f()
            GC.gc()
            GC.gc()
            @test vec(got) ≈ vec(expected)
        end
    end

    @testset "the copy is independent of the source" begin
        m = gsMatrix()
        eval!(basis, [0.4], m)
        a = toMatrix(m)
        b = toMatrix(m)
        a[1] = -999.0
        @test b[1] != -999.0            # separate arrays
        @test toMatrix(m)[1] != -999.0  # and the gsMatrix is untouched
    end
end

@testitem "Base.size mappings" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])

    @testset "knot vectors and bases report a count" begin
        @test size(kv) == 7
        @test size(BSplineBasis(kv)) == 4
        @test size(TensorBSplineBasis{2}(kv, kv)) == 16
        @test size(NurbsBasis(kv)) == 4
        @test size(TensorNurbsBasis{2}(kv, kv, ones(16, 1))) == 16
    end

    @testset "size(obj, d) follows Base's contract for trailing dimensions" begin
        # Base returns 1 for d > ndims rather than raising, and generic array code relies
        # on it: size(A, d) must never be a BoundsError for a valid positive d.
        m = gsMatrix(4, 3)
        @test size(m, 1) == 4
        @test size(m, 2) == 3
        @test size(m, 3) == 1
        @test size(m, 7) == 1

        v = gsVector(5)
        @test size(v, 1) == 5
        @test size(v, 2) == 1
        @test size(v, 7) == 1

        @testset "matching what Base does for ordinary arrays" begin
            @test size(m, 3) == size(zeros(4, 3), 3)
            @test size(v, 2) == size(zeros(5), 2)
        end
    end

    @testset "matrices and vectors report dimensions" begin
        # These are array-like -- gsMatrix supports m[i, j] -- so they follow the usual
        # Base.size contract instead, with the total on length.
        m = gsMatrix(4, 3)
        @test size(m) == (4, 3)
        @test size(m, 1) == 4
        @test size(m, 2) == 3
        @test length(m) == 12

        v = gsVector(5)
        @test size(v) == (5,)
        @test length(v) == 5

        @test size(gsMatrix{Int32}(2, 7)) == (2, 7)
        @test length(gsVector{Int32}(6)) == 6
    end

    @testset "size works unqualified on every wrapped type" begin
        # Nothing here needs a TinyGismo. prefix.
        for obj in (kv, BSplineBasis(kv), NurbsBasis(kv), gsMatrix(2, 2), gsVector(2))
            @test size(obj) !== nothing
        end
    end
end
