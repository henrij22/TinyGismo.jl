@testitem "BSpline: dimensions follow the coefficient matrix" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    basis = BSplineBasis(kv)

    @testset "scalar valued" begin
        spline = BSpline(basis, randn(4))
        @test parDim(spline) == 1
        @test targetDim(spline) == 1
        @test geoDim(spline) == 1
        @test coefDim(spline) == 1
        @test coefsSize(spline) == size(basis)
        @test numCoefs(spline) == size(basis)
    end

    @testset "plane curve" begin
        spline = BSpline(basis, randn(4, 2))
        @test parDim(spline) == 1
        @test targetDim(spline) == 2
        @test geoDim(spline) == 2
        @test coefDim(spline) == 2
    end

    @testset "space curve" begin
        spline = BSpline(basis, randn(4, 3))
        @test parDim(spline) == 1
        @test targetDim(spline) == 3
    end
end

@testitem "BSpline: interpolates its end control points" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]
    curve = BSpline(BSplineBasis(kv), cp)

    @test toMatrix(coefs(curve)) ≈ cp

    out = gsMatrix()
    eval!(curve, [0.0], out)
    @test vec(toMatrix(out)) ≈ cp[1, :]         # clamped knot vector
    eval!(curve, [1.0], out)
    @test vec(toMatrix(out)) ≈ cp[end, :]

    @test toVector(coefAtCorner(curve, 1)) ≈ cp[1, :]
    @test toVector(coefAtCorner(curve, 2)) ≈ cp[end, :]
end

@testitem "BSpline: the curve stays inside the convex hull of its control net" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]
    curve = BSpline(BSplineBasis(kv), cp)

    lo = minimum(cp; dims = 1)
    hi = maximum(cp; dims = 1)

    for u in 0.0:0.05:1.0
        out = gsMatrix()
        eval!(curve, [u], out)
        p = toMatrix(out)
        @test all(vec(lo) .- 1.0e-12 .<= vec(p) .<= vec(hi) .+ 1.0e-12)
    end
end

@testitem "Geometry: evaluating many points at once" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]
    curve = BSpline(BSplineBasis(kv), cp)

    us = collect(range(0.0, 1.0; length = 7))
    batch = gsMatrix()
    eval!(curve, Matrix(us'), batch)
    X = toMatrix(batch)

    @test size(X) == (targetDim(curve), length(us))

    # column i of the batch matches evaluating point i on its own
    for (i, u) in enumerate(us)
        single = gsMatrix()
        eval!(curve, [u], single)
        @test X[:, i] ≈ vec(toMatrix(single))
    end
end

@testitem "Geometry: derivatives against finite differences" begin
    using TinyGismo: jacobian, hessian, deriv, deriv2

    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]
    curve = BSpline(BSplineBasis(kv), cp)

    ev(u) = (out = gsMatrix(); eval!(curve, [u], out); vec(toMatrix(out)))

    h = 1.0e-6
    for u in (0.2, 0.4, 0.7)
        fd = (ev(u + h) .- ev(u - h)) ./ (2h)
        @test vec(toMatrix(deriv(curve, [u]))) ≈ fd atol = 1.0e-6
        @test vec(toMatrix(jacobian(curve, [u]))) ≈ fd atol = 1.0e-6

        fd2 = (ev(u + h) .- 2 .* ev(u) .+ ev(u - h)) ./ h^2
        @test vec(toMatrix(deriv2(curve, [u]))) ≈ fd2 atol = 1.0e-3
    end
end

@testitem "Geometry: Jacobian and Hessian of an affine map" begin
    using TinyGismo: jacobian, hessian

    rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)

    # x = 2u, y = v -- so the Jacobian is constant and the Hessians vanish.
    for u in 0.0:0.25:1.0, v in 0.0:0.25:1.0
        @test toMatrix(jacobian(rect, [u, v])) ≈ [2.0 0.0; 0.0 1.0]
        @test toMatrix(hessian(rect, [u, v], 1)) ≈ zeros(2, 2) atol = 1.0e-12
        @test toMatrix(hessian(rect, [u, v], 2)) ≈ zeros(2, 2) atol = 1.0e-12
    end

    @testset "Jacobian is targetDim x parDim" begin
        @test size(toMatrix(jacobian(rect, [0.5, 0.5]))) == (targetDim(rect), parDim(rect))
        cube = createBSplineCube(1.0)
        @test size(toMatrix(jacobian(cube, [0.5, 0.5, 0.5]))) == (3, 3)
    end
end

@testitem "Geometry: closestPointTo inverts the mapping" begin
    kv = KnotVector([0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0])
    cp = [0.0 0.0; 1.0 1.5; 2.0 -0.5; 3.0 1.0]
    curve = BSpline(BSplineBasis(kv), cp)

    ev(u) = (out = gsMatrix(); eval!(curve, u, out); vec(toMatrix(out)))

    @testset "a point on the curve comes back exactly" begin
        for u in (0.2, 0.42, 0.8)
            target = ev([u])
            par = gsVector()
            closestPointTo(curve, target, par)
            @test ev(toVector(par)) ≈ target atol = 1.0e-6
        end
    end

    @testset "a point off the curve gives the nearest foot" begin
        query = [1.5, 1.5]
        par = gsVector()
        closestPointTo(curve, query, par)
        foot = ev(toVector(par))
        best = minimum(sum(abs2, ev([u]) .- query) for u in 0.0:0.001:1.0)
        @test sum(abs2, foot .- query) ≤ best + 1.0e-6
    end
end

@testitem "boundary extracts a side of lower parametric dimension" begin
    using TinyGismo: basis

    rect = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)

    # boundary of a geometry: a unique_ptr to the base class, dereferenced with []
    corners = Dict(1 => [0.0, 0.0], 2 => [2.0, 0.0], 3 => [0.0, 0.0], 4 => [0.0, 1.0])
    for s in 1:4
        side = boundary(rect, s)[]
        @test parDim(side) == parDim(rect) - 1
        @test targetDim(side) == targetDim(rect)
        @test coefsSize(side) == 3
    end

    @test toMatrix(coefs(boundary(rect, 1)[])) ≈ [0.0 0.0; 0.0 0.5; 0.0 1.0]   # west, x = 0
    @test toMatrix(coefs(boundary(rect, 2)[])) ≈ [2.0 0.0; 2.0 0.5; 2.0 1.0]   # east, x = 2
    @test toMatrix(coefs(boundary(rect, 3)[])) ≈ [0.0 0.0; 1.0 0.0; 2.0 0.0]   # south, y = 0
    @test toMatrix(coefs(boundary(rect, 4)[])) ≈ [0.0 1.0; 1.0 1.0; 2.0 1.0]   # north, y = 1

    # boundary of a basis: the indices of the functions living on that side
    @test toVector(boundary(basis(rect), 1)) == Int32[1, 4, 7]
    @test toVector(boundary(basis(rect), 3)) == Int32[1, 2, 3]
end

@testitem "TensorBSpline: control point ordering is u-fastest" begin
    using TinyGismo: basis

    kvu = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
    kvv = KnotVector([0.0, 0.0, 1.0, 1.0])
    tb = TensorBSplineBasis{2}(kvu, kvv)

    cp = [
        0.0 0.0; 0.5 0.0; 1.0 0.0;    # v = 0 row
        0.0 1.0; 0.5 1.0; 1.0 1.0
    ]    # v = 1 row
    surface = TensorBSpline{2}(tb, cp)

    @test coefsSize(surface) == 6
    @test toMatrix(coefs(surface)) ≈ cp

    # corners of the parameter domain hit the corners of the control net
    ev(uv) = (out = gsMatrix(); eval!(surface, uv, out); vec(toMatrix(out)))
    @test ev([0.0, 0.0]) ≈ cp[1, :]
    @test ev([1.0, 0.0]) ≈ cp[3, :]
    @test ev([0.0, 1.0]) ≈ cp[4, :]
    @test ev([1.0, 1.0]) ≈ cp[6, :]
end

@testitem "TensorBSpline: corner constructor" begin
    kv = KnotVector([0.0, 0.0, 1.0, 1.0])
    # 4 x 3 matrix, counterclockwise, giving a surface in 3D
    corners = [
        0.0 0.0 0.0
        4.0 0.0 0.0
        3.0 2.0 0.0
        1.0 2.0 0.0
    ]
    patch = TensorBSpline{2}(corners, kv, kv)

    @test parDim(patch) == 2
    @test targetDim(patch) == 3

    ev(uv) = (out = gsMatrix(); eval!(patch, uv, out); vec(toMatrix(out)))
    @test ev([0.0, 0.0]) ≈ corners[1, :]
    @test ev([1.0, 0.0]) ≈ corners[2, :]
    @test ev([1.0, 1.0]) ≈ corners[3, :]
    @test ev([0.0, 1.0]) ≈ corners[4, :]
    @test ev([0.5, 0.5]) ≈ vec(sum(corners; dims = 1) ./ 4)   # bilinear blend
end

@testitem "TensorBSpline{2} accepts a gsMatrix of coefficients" begin
    using TinyGismo: setValue!

    kvu = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
    kvv = KnotVector([0.0, 0.0, 1.0, 1.0])
    cp = [0.0 0.0; 0.5 0.4; 1.0 0.0; 0.0 1.0; 0.5 1.4; 1.0 1.0]

    cm = gsMatrix(6, 2)
    for j in 1:2, i in 1:6
        setValue!(cm, i, j, cp[i, j])
    end

    fromKnots = TensorBSpline{2}(kvu, kvv, cm)
    fromBasis = TensorBSpline{2}(TensorBSplineBasis{2}(kvu, kvv), cp)

    a, b = gsMatrix(), gsMatrix()
    eval!(fromKnots, [0.5, 0.5], a)
    eval!(fromBasis, [0.5, 0.5], b)
    @test toMatrix(a) ≈ toMatrix(b)
end
