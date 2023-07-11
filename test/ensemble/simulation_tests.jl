using MealModel
using Test

# Ensemble simulation (multiple subjects in parallel)
@testset "Ensemble model definition" begin
  function define_ensemble()

    MixedMealModel(100)
    true
  end
  
  @test define_ensemble()
end

@testset "Ensemble model simulation" begin
  function run_ensemble_simulation()
    model = MixedMealModel(10)
    output(model)
    true
  end
  
  @test run_ensemble_simulation()
end