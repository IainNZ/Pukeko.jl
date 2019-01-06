# This file is a part of Pukeko.jl.
# License is MIT. https://github.com/IainNZ/Pukeko.jl

import Pukeko

module PukekoTests

    using Pukeko

    parametric_by_function_called = 0
    function parametric_by_function(value)
        global parametric_by_function_called += 1
        @test value in ["foo", "bar"]
        @test parametric_by_function_called >= 1
    end
    Pukeko.parametric(PukekoTests, parametric_by_function, ["foo", "bar"])

    parametric_by_macro_called = 0
    function parametric_by_macro(value)
        global parametric_by_macro_called += 1
        @test value in ["foo", "bar"]
        @test parametric_by_macro_called >= 1
    end
    Pukeko.@parametric parametric_by_macro ["foo", "bar"]

    parametric_many_called = 0
    function parametric_many(value1, value2)
        global parametric_many_called += 1
        @test value1 + 1 == value2
        @test parametric_many_called >= 1
    end
    Pukeko.@parametric parametric_many ((1, 2), (3, 4), (5, 6))

    function __test_equal()
        @test 1 == 1
    end
end

Pukeko.run_tests(PukekoTests)
@assert PukekoTests.parametric_by_function_called == 2
@assert PukekoTests.parametric_by_macro_called == 2
@assert PukekoTests.parametric_many_called == 3

module FailFastTests
    using Pukeko
    function test_fail()
        @test 1 == 2
    end
    should_be_zero = 0
    function test_not_run()
        global should_be_zero += 1
    end
end

println("Message about failing test should appear next")
should_not_run = true
try
    Pukeko.run_tests(FailFastTests, fail_fast=true)
    global should_not_run = false
catch
    @assert should_not_run
end
@assert should_not_run
@assert FailFastTests.should_be_zero == 0

module FailSlowTests
    using Pukeko
    function test_fail()
        @test 1 == 2
    end
    should_be_one = 0
    function test_run()
        global should_be_one += 1
    end
end

should_not_run = true
try
    Pukeko.run_tests(FailSlowTests)
    global should_not_run = false
catch
    @assert should_not_run
end
@assert should_not_run
@assert FailSlowTests.should_be_one == 1

module Empty
end
Pukeko.run_tests(Empty)

module OnlyCallFunctions
    test_variable = 2
    module test_stuff
    end
end
Pukeko.run_tests(OnlyCallFunctions)

include("base_int.jl")
