using SafeTestsets


@time @safetestset "Model Simulation Tests" begin include("test_model_simulation.jl") end
#@time @safetestset "Ensemble Simulation Tests" begin include("ensemble/simulation_tests.jl") end
#@time @safetestset "Singular Assimilation Tests" begin include("singular/assimilation_tests.jl") end