module MealModel
using OrdinaryDiffEq, SciMLBase, SciMLSensitivity, Optimization
using ComponentArrays

include("model/Model.jl")
include("simulation/Simulation.jl")
include("assimilation/Assimilation.jl")

# model constructor
export MixedMealModel

# model components
export meal_appearance, glucose_meal_appearance, plasma_glucose_flux, plasma_insulin_flux, interstitial_insulin_flux, plasma_nefa_flux, plasma_tg_flux

# simulation functions
export predict, output

# data types
export TimedVector, MealResponseData, CompleteMealResponse, PartialMealResponse

# options
export AssimilationOptions, ParsimoniousModelOptions, DefaultModelOptions

# model setup
export setup

end

