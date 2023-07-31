module MealModel
using OrdinaryDiffEq, SciMLBase, SciMLSensitivity, Optimization

include("model/Model.jl")
include("simulation/Simulation.jl")
include("assimilation/Assimilation.jl")

# model function
export MixedMealModel

# simulation functions
export predict, output

# data types
export TimedVector, MealResponseData, CompleteMealResponse, PartialMealResponse

# options
export AssimilationOptions, ParsimoniousModelOptions, DefaultModelOptions

# model setup
export setup

end

