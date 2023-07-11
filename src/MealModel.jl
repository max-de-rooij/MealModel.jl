module MealModel
using OrdinaryDiffEq, SciMLBase

include("model/Model.jl")
include("simulation/Simulation.jl")

# model function
export MixedMealModel

# simulation functions
export predict, output

end

