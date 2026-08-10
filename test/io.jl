@testitem "readFile: reading a NURBS surface" begin
    using TinyGismo: degree, basis, weights

    filename = joinpath(@__DIR__, "data", "scordelis_lo.xml")
    @assert isfile(filename) "test data missing: $filename"

    geo = readFile(TensorNurbs{2}, filename)
    @test parDim(geo) == 2
    @test targetDim(geo) == 3
    @test coefsSize(geo) > 0
    @test size(toMatrix(coefs(geo)), 2) == 3
    @test length(toVector(weights(geo))) == coefsSize(geo)

    out = gsMatrix()
    eval!(geo, [0.5, 0.5], out)
    @test length(toMatrix(out)) == 3
end

@testitem "readFile: reading the basis of the same file" begin
    using TinyGismo: degree

    filename = joinpath(@__DIR__, "data", "scordelis_lo.xml")

    basis = readFile(TensorNurbsBasis{2}, filename)
    @test size(basis) > 0
    @test degree(basis, 1) == 2

    geo = readFile(TensorNurbs{2}, filename)
    @test size(basis) == coefsSize(geo)

    values = gsMatrix()
    eval!(basis, [0.5, 0.5], values)
    @test sum(toMatrix(values)) ≈ 1.0
end

@testitem "readFile: failure modes" begin
    filename = joinpath(@__DIR__, "data", "scordelis_lo.xml")

    @test_throws Exception readFile(TensorNurbs{2}, "no_such_file_here.xml")
    # the file holds a TensorNurbs2, not a B-spline curve
    @test_throws Exception readFile(BSpline, filename)
end

@testitem "writeParaview round-trips to disk" begin
    mktempdir() do dir
        geo = createBSplineRectangle(0.0, 0.0, 2.0, 1.0)

        base = joinpath(dir, "rect")
        writeParaview(geo, base)
        @test !isempty(filter(f -> startswith(f, "rect"), readdir(dir)))

        basisbase = joinpath(dir, "basis")
        writeParaviewBasisFnct(1, TinyGismo.basis(geo), basisbase)
        @test !isempty(filter(f -> startswith(f, "basis"), readdir(dir)))

        pointsbase = joinpath(dir, "points")
        writeParaviewPoints([0.0 1.0 2.0; 0.0 0.5 1.0], pointsbase)
        @test !isempty(filter(f -> startswith(f, "points"), readdir(dir)))
    end
end
