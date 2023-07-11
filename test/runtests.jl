using SafeTestsets


@time @safetestset "Singular Simulation Tests" begin include("singular/simulation_tests.jl") end
@time @safetestset "Ensemble Simulation Tests" begin include("ensemble/simulation_tests.jl") end
