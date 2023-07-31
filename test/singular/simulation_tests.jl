using MealModel
using Test

# single subject simulation
@testset "Singular model definition" begin
  function define_model()
    
    MixedMealModel()
    true
  end

  @test define_model()
end

@testset "Singular model simulation" begin
  function run_model_simulation()

    model = MixedMealModel()
    output(model)
    true
  end

  @test run_model_simulation()
end


