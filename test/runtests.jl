# This file is a part of Pukeko.jl.
# License is MIT. https://github.com/IainNZ/Pukeko.jl

import Pukeko

module PukekoTests

    import Pukeko
    import Pukeko: @test

    parametric_by_function_called = 0
    function parametric_by_function(value)
        global parametric_by_function_called += 1
        @test value in ["foo", "bar"]
        @test parametric_by_function_called >= 1
    end
    Pukeko.parametric(PukekoTests, parametric_by_function, ["foo", "bar"])

    @static if VERSION >= v"0.7"
        # Macro version uses __module__, not available on 0.6.
        parametric_by_macro_called = 0
        function parametric_by_macro(value)
            global parametric_by_macro_called += 1
            @test value in ["foo", "bar"]
            @test parametric_by_macro_called >= 1
        end
        Pukeko.@parametric parametric_by_macro ["foo", "bar"]
    end

    function __test_equal()
        @test 1 == 1
    end
end

Pukeko.run_tests(PukekoTests)
@assert PukekoTests.parametric_by_function_called == 2
@static if VERSION >= v"0.7"
    @assert PukekoTests.parametric_by_macro_called == 2
end

module FailFastTests
    import Pukeko: @test
    function __test_fail()
        @test 1 == 2
    end
    should_be_zero = 0
    function __test_not_run()
        global should_be_zero += 1
    end
end

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
    import Pukeko: @test
    function __test_fail()
        @test 1 == 2
    end
    should_be_one = 0
    function __test_not_run()
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
