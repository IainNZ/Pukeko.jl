# This file is a part of Pukeko.jl.
# License is MIT. https://github.com/IainNZ/Pukeko.jl
# This file is adapted from the Julia `test/int.jl` file.
# It serves as an example.
# License is MIT: https://julialang.org/license

module BaseInt
    using Pukeko

    function test_flipsign_copysign()
        for y in (-4, Float32(-4), -4.0, big(-4.0))
            @test flipsign(3, y)  == -3
            @test flipsign(-3, y) == 3
            @test copysign(3, y)  == -3
            @test copysign(-3, y) == -3
        end

        for y in (4, Float32(4), 4.0, big(4.0))
            @test flipsign(3, y)  == 3
            @test flipsign(-3, y) == -3
            @test copysign(3, y)  == 3
            @test copysign(-3, y) == 3
        end
    end

    function _flipsign_copysign_type(U)
        for T in (Base.BitInteger_types..., BigInt,
                  Rational{Int}, Rational{BigInt},
                  Float16, Float32, Float64)
            @test typeof(copysign(T(3), U(4))) === T
            @test typeof(flipsign(T(3), U(4))) === T
        end
        # Bool promotes to Int
        U <: Unsigned && return
        for x in [true, false]
            @test flipsign(x, U(4)) === Int(x)
            @test flipsign(x, U(-1)) === -Int(x)
            @test copysign(x, U(4)) === Int(x)
            @test copysign(x, U(-1)) === -Int(x)
        end
    end
    @parametric _flipsign_copysign_type (Base.BitInteger_types..., BigInt,
                                         Rational{Int}, Rational{BigInt},
                                         Float16, Float32, Float64)
    
    function _flipsign_copysign_typemin(T)
        for U in (Base.BitSigned_types..., BigInt, Float16, Float32, Float64)
            @test flipsign(typemin(T), U(-1)) == typemin(T)
            @test copysign(typemin(T), U(-1)) == typemin(T)
        end
    end
    @parametric _flipsign_copysign_typemin Base.BitInteger_types

    function test_flipsign_with_floats()
        for s1 in (-1,+1), s2 in (-1,+1)
            @test flipsign(Int16(3s1), Float16(3s2)) === Int16(3s1*s2)
            @test flipsign(Int32(3s1), Float32(3s2)) === Int32(3s1*s2)
            @test flipsign(Int64(3s1), Float64(3s2)) === Int64(3s1*s2)
        end
    end
end

@static if VERSION >= v"0.7"
    # The expected results of tests are different in Julia 0.6!
    import Pukeko
    Pukeko.run_tests(BaseInt)
end