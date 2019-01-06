![Pukeko.jl](https://github.com/IainNZ/Pukeko.jl/raw/master/pukeko.jpg)

# Pukeko.jl

Testing for Julia, simplified.
Supports Julia versions `0.7`, and `1.x`.

[![Build Status](https://travis-ci.org/IainNZ/Pukeko.jl.svg?branch=master)](https://travis-ci.org/IainNZ/Pukeko.jl)

### Features, Differences

* **Minimal macros**: [Macros](https://docs.julialang.org/en/stable/manual/metaprogramming/) are neat, but can be hard to understand. The `Base.Test` macros do many things in the name of generality, but as a result generate a lot of code and stress the compiler. Pukeko aims for minimal complexity in its test macros, which essentially just call functions. Pukeko has familiar `@test` and `@test_throws` macros to make moving from `Base.Test` as easy as possible. As little work as possible is done for the usual case (tests passing).

* **Functions**: `Base.Test` has testsets that are defined by `@testset begin end` blocks. These blocks do not introduce proper scopes and tend to lead to very large functions with a high level of nesting. Pukeko uses plain-old-functions as a testset and uses modules to collect all the tests to be executed together. Minimal magic, maximum clarity, less danger of reusing variables accidentally, and less compiler strain (large functions are hard on the Julia compiler).

* **Parallel testing**: Larger projects inevitably end up with a large number of tests. There are typically many tests per file, spread across many files. Normally this involves having one central `test/runtests.jl` file that includes other `test/*.jl` files. This is good for automated CI services like Travis, but often developer testing machines can run more than one test at a time. Pukeko's module-and-functions pattern naturally makes each of these `test/*.jl` files runnable individually or as part of a larger test run: `ls test/ | xargs -I % julia --project=. %`

* **Use command line for...**: Pukeko makes use of commandline flags for customization. Highlights include selectively running tests, printing out run times for tests to identify slow tests, and changing behaviour on test failures.

Pukeko follows the [JuMP Style Guide](http://www.juliaopt.org/JuMP.jl/latest/style.html).

### Minimal example

```julia
# test/runtests.jl

module MyTests
    using Pukeko  # @test, @test_throws

    function test_arithmetic()
        @test 2 + 2 == 4
        @test 2 * 3 == 6
    end

    function _test_parametric(value, value_exp)
        @test value * value == value_exp
    end
    Pukeko.@parametric _test_parametric [(1, 1), (2, 4), (3, 9)]
end

import Pukeko
Pukeko.run_tests(MyTests)
# 4 test function(s) ran successfully in module MyTests
```

### Credits

Package by [Iain Dunning](https://iaindunning.com).

Pukeko photo from [Wikipedia](https://en.wikipedia.org/wiki/Australasian_swamphen#/media/File:Porphyrio_porphyrio_-Waikawa,_Marlborough,_New_Zealand-8.jpg).
