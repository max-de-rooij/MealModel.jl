include("Equations.jl")
include("Parameters.jl")
using Random

"""
MixedMealModel object containing the ODEProblem for simulation and the estimated parameters for creating A
loss function.
"""
struct MixedMealModel
  prob::ODEProblem
  estimated_parameters::AbstractVector{Int}
end

# single meal
"""
Create a single-meal variant of the Mixed Meal Model. The meal is set at t=0.

Arguments:
* meal_glucose_mass: glucose mass found in the meal in mg (default 75000)
* meal_tg_mass: tg mass found in the meal in mg (default 60000)
* subject_body_mass: body mass of the simulated subject in kg (default 84.2)
* fasting_glucose: fasting glucose values of the simulated subject in mM (default 5.)
* fasting_insulin: fasting insulin values of the simulated subject in μIU/mL (default 18.)
* fasting_TG: fasting TG values of the simulated subject in mM (default 1.3)
* fasting_NEFA: fasting NEFA values of the simulated subject in mM (default 0.33)
* timespan: 2-tuple containing (start time, end time). Defaults to (0., 480.)
* params: vector of the model parameters. Defaults by a call to the parameters function (see Parameters.jl)
* equations: meal model equations. Defaults to the system() function call (see Equations.jl)
* estimated_parameter_indices: indices of the parameters estimated. Defaults to the parameters estimated in O'Donovan et al. (2022)

Outputs:
* MixedMealModel: A MixedMealModel object containing the ODEProblem for simulating and the estimated parameter indices, used when
  creating a loss function.
"""
function MixedMealModel(; 
  meal_glucose_mass::Real = 75_000.,
  meal_tg_mass::Real = 60_000.,
  subject_body_mass::Real = 84.2,
  fasting_glucose::Real = 5.,
  fasting_insulin::Real = 18.,
  fasting_TG::Real = 1.3,
  fasting_NEFA::Real = 0.33,
  timespan::Tuple{<:Real, <:Real} = (0., 480.),
  params::AbstractVector{<:Real} = parameters(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass),
  equations = system(),
  estimated_parameter_indices::AbstractVector{Int} = [1,5,6,17,20,21,23,25])

  u0 = [0., fasting_glucose, 0., fasting_insulin, 0., fasting_insulin, fasting_insulin, fasting_insulin, fasting_NEFA, 0., 0.,0.,fasting_TG]

  MixedMealModel(ODEProblem{true, SciMLBase.FullSpecialize}(
    equations, u0, timespan, params, sensealg=ForwardDiffSensitivity()
  ), estimated_parameter_indices)
end

"""
Create a multi-meal variant of the Mixed Meal Model.

Arguments:
* meal_times: time values of the meals as a vector.
* meals_glucose_mass: glucose mass found in the meals in mg as a vector (default [75000, 75000])
* meals_tg_mass: tg mass found in the meals in mg as a vector (default [60000, 60000])
* subject_body_mass: body mass of the simulated subject in kg (default 84.2)
* fasting_glucose: fasting glucose values of the simulated subject in mM (default 5.)
* fasting_insulin: fasting insulin values of the simulated subject in μIU/mL (default 18.)
* fasting_TG: fasting TG values of the simulated subject in mM (default 1.3)
* fasting_NEFA: fasting NEFA values of the simulated subject in mM (default 0.33)
* timespan: 2-tuple containing (start time, end time). Defaults to (0., 480.)
* params: vector of the model parameters. Defaults by a call to the parameters function (see Parameters.jl)
* equations: meal model equations. Defaults to the system() function call (see Equations.jl)
* estimated_parameter_indices: indices of the parameters estimated. Defaults to the parameters estimated in O'Donovan et al. (2022)

Outputs:
* MixedMealModel: A MixedMealModel object containing the ODEProblem for simulating and the estimated parameter indices, used when
  creating a loss function.
"""
function MixedMealModel(meal_times::AbstractVector{<:Real}; 
  meals_glucose_mass::AbstractVector{<:Real} = [75_000., 75_000],
  meals_tg_mass::AbstractVector{<:Real} = [60_000., 60_000.],
  subject_body_mass::Real = 84.2,
  fasting_glucose::Real = 5.,
  fasting_insulin::Real = 18.,
  fasting_TG::Real = 1.3,
  fasting_NEFA::Real = 0.33,
  timespan::Tuple{<:Real, <:Real} = (0., 480.),
  params::AbstractVector{<:Real} = parameters(fasting_glucose, fasting_insulin, meals_glucose_mass, meals_tg_mass, subject_body_mass),
  equations = system(meal_times),
  estimated_parameter_indices::AbstractVector{Int} = [1,5,6,17,20,21,23,25])

  u0 = [0., fasting_glucose, 0., fasting_insulin, 0., fasting_insulin, fasting_insulin, fasting_insulin, fasting_NEFA, 0., 0.,0.,fasting_TG]

  MixedMealModel(ODEProblem{true, SciMLBase.FullSpecialize}(
    equations, u0, timespan, params, sensealg=ForwardDiffSensitivity()
  ), estimated_parameter_indices)
end

function set_estimated_parameters(model::MixedMealModel, estimated_parameter_indices::AbstractVector{Int})
  MixedMealModel(
    model.prob, estimated_parameter_indices
  )
end