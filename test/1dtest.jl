@testitem "Knot Vector Test" begin
    vec = [0, 0, 0, 0.5, 1, 1, 1]
    kv = KnotVector(vec)

    @test size(kv) == length(vec)
    @test uSize(kv) == length(unique(vec))
    @test numElements(kv) == length(unique(vec)) - 1
end
