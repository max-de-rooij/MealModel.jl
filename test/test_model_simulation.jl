using MealModel
using Test

# single subject simulation
@testset "Define default model" begin
  function define_model()
    
    MixedMealModel()
    true
  end

  @test define_model()
end

@testset let model=MixedMealModel()
  
  prediction = (m) -> begin predict(m.prob, 1); return true; end
  obtain_output = (m) -> begin output(m); return true; end

  @test prediction(model)
  @test obtain_output(model)

end


