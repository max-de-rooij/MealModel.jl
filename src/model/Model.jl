include("Equations.jl")
include("Parameters.jl")
using Random

struct MixedMealModel
  prob::ODEProblem
  estimated_parameters::AbstractVector{Int}
end

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

function set_estimated_parameters(model::MixedMealModel, estimated_parameter_indices::AbstractVector{Int})
  MixedMealModel(
    model.prob, estimated_parameter_indices
  )
end