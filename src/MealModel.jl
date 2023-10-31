module MealModel
using OrdinaryDiffEq, SciMLBase, SciMLSensitivity, Optimization
using ComponentArrays
using Trapz
using LatinHypercubeSampling
using Random

include("model/Model.jl")
include("simulation/Simulation.jl")
include("assimilation/Assimilation.jl")

# model constructor
export MixedMealModel

# model components
export meal_appearance, glucose_meal_appearance, plasma_glucose_flux, plasma_insulin_flux, interstitial_insulin_flux, plasma_nefa_flux, plasma_tg_flux

# simulation functions
export predict, output

# assimilation related functions
export make_predictor, make_loss, make_error, perform_preselection, create_full_parameter_vector, set_estimated_parameters

end

