# This file is a part of Pukeko.jl.
# License is MIT. https://github.com/IainNZ/Pukeko.jl

module Pukeko
    """
        MAGIC_FUNCTION_PREFIX
    
    Functions with this at the the start of their name will be treated as
    self-contained sets of tests.
    """
    const MAGIC_FUNCTION_PREFIX = "__test"

    """
        TestException
    
    The Exception thrown when a Pukeko test fails.
    """
    struct TestException <: Exception
        message::String
    end

    """
        test_true(value)

    Test that `value` is `true`. Corresponds to macro `@test`.
    """
    function test_true(value)
        if value != true
            throw(TestException("Expression did not evaluate to `true`: " *
                                string(value)))
        end
        return nothing
    end

    """
        test_equal(value_left, value_right)

    Test that `value_left` is equal to `value_right`. Corresponds to macro
    `@test` for the special case of `@test expr_left == expr_right`.
    """
    function test_equal(value_left, value_right)
        if value_left != value_right
            throw(TestException(string("L != R | ", value_left, " | ", value_right)))
        end
        return nothing
    end

    """
        @test expression
    
    If `expression` is of form `expr_left == expr_right`, uses `test_equal`.
    Otherwise, uses `test_true`.
    """
    macro test(expression)
        if (expression.head == :call && expression.args[1] == :(==) &&
            length(expression.args) == 3)
            return quote
                test_equal($(esc(expression.args[2])),
                           $(esc(expression.args[3])))
            end
        end
        return quote
            test_true($(esc(expression)))
        end
    end

    if VERSION >= v"0.7"
        compat_name(mod) = names(mod, all=true)
    else
        compat_name(mod) = names(mod, true)
    end

    """
        run_tests(module_to_test; fail_fast=false)
    
    Runs all the tests in module `module_to_test`. Looks for all functions in
    the module that begin with `MAGIC_FUNCTION_PREFIX`, and runs them. If any
    one function fails, the others will still run unless `fail_fast`` is `true`.
    At the end of testing, if any have failed then a summary is printed an
    exception is thrown.
    """
    function run_tests(module_to_test; fail_fast=false)
        test_failures = Dict{Symbol, TestException}()
        test_functions = 0
        for maybe_function in compat_name(module_to_test)
            maybe_function_name = string(maybe_function)
            if startswith(maybe_function_name, MAGIC_FUNCTION_PREFIX)
                test_functions += 1
                if fail_fast
                    @eval module_to_test ($maybe_function)()
                else
                    try
                        @eval module_to_test ($maybe_function)()
                    catch test_exception
                        if isa(test_exception, TestException)
                            test_failures[maybe_function] = test_exception
                        else
                            println("Unexpected exception occurred in test",
                                    "function " * maybe_function_name)
                            throw(test_exception)
                        end
                    end
                end
            end
        end
        if length(test_failures) > 0
            println("Test failures occurred in module $(module_to_test)")
            println("Functions with failed tests:")
            for (sym, test_exception) in test_failures
                println("    $(sym): ", test_exception)
            end
            error("Some tests failed")
        end
        println("$test_functions test function(s) ran successfully.")
    end

    """
        parametric(module_to_test, func, iterable)
    
    Create a version of `func` that is prefixed with `MAGIC_FUNCTION_PREFIX` in
    `module_to_test` for each value in `iterable`.
    """
    function parametric(module_to_test, func, iterable)
        for value in iterable
            func_name = Symbol(string(MAGIC_FUNCTION_PREFIX, func, value))
            @eval module_to_test $func_name() = $func($value)
        end
    end

    """
        @parametric func iterable
    
    
    """
    macro parametric(func, iterable)
        return quote
            parametric($(__module__), $(esc(func)), $(esc(iterable)))
        end
    end
end