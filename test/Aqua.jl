@testitem "Aqua.jl" begin
    using Aqua

    # The CxxWrap-generated methods (`__delete`, constructors) are reported as piracy, and
    # the ambiguity check does not terminate on the wrapped API.
    Aqua.test_all(TinyGismo; ambiguities = false, piracies = false)
end
