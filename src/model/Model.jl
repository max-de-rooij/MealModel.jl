include("Equations.jl")
include("Parameters.jl")
using Random

# single-subject
function MixedMealModel(; 
  meal_glucose_mass::Real = 75_000.,
  meal_tg_mass::Real = 60_000.,
  subject_body_mass::Real = 84.2,
  fasting_glucose::Real = 5.,
  fasting_insulin::Real = 18.,
  fasting_TG::Real = 1.3,
  fasting_NEFA::Real = 0.33,
  timespan::Tuple{<:Real, <:Real} = (0., 480.),
  parameters::AbstractVector{<:Real} = parameters(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass),
  equations = system())

  u0 = [0., fasting_glucose, 0., fasting_insulin, 0., fasting_insulin, fasting_insulin, fasting_insulin, fasting_NEFA, 0., 0.,0.,fasting_TG]

  return ODEProblem{true, SciMLBase.FullSpecialize}(
    equations, u0, timespan, parameters, sensealg=ForwardDiffSensitivity()
  )
end