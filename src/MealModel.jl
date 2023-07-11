



module MealModel
using OrdinaryDiffEq, SciMLBase

include("model/Model.jl")
include("simulaton/Simulation.jl")

# model function
export MixedMealModel

# simulation functions
export predict, output

# Write your package code here.

end

