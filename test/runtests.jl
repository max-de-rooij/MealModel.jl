using SafeTestsets


@time @safetestset "Model Simulation Tests" begin include("test_model_simulation.jl") end
@time @safetestset "Parameter Esimtation Tests" begin include("test_parameter_estimation.jl") end