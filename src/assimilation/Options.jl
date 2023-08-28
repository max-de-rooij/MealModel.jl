mutable struct AssimilationOptions

  # optimizer options
  maximum_iterations::Int
  n_initial_points::Int
  parameter_tolerance::Real
  objective_tolerance::Real

  # parameters
  estimated_parameters::Vector{Int}
  initial_parameter_values::Vector{<:Real}
  lower_parameter_bounds::Vector{<:Real}
  upper_parameter_bounds::Vector{<:Real}

end

ParsimoniousModelOptions(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass) = AssimilationOptions(
  1000, 10, 1e-6, 1e-6, [1, 5, 6, 17, 23], 
  parameters(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass),
  [0.005, 1e-6,1e-6,1e-6, 0.005], [0.1,1.,5.,1., 0.1]
)

DefaultModelOptions(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass) = AssimilationOptions(
  1000, 10, 1e-6, 1e-6, [1,5,6,17,20,21,23,25], 
  parameters(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass),
  [0.005, 1e-6,1e-6,1e-6,1e-6,60.,0.005, 1e-6], [0.1,1.,5.,1.,1.,600.,0.1,1.]
)

DefaultModelOptions(model::ODEProblem) = AssimilationOptions(
  1000, 10, 1e-6, 1e-6, [1,5,6,17,20,21,23,25], 
  model.p,
  [0.005, 1e-6,1e-6,1e-6,1e-6,60.,0.005, 1e-6], [0.1,1.,5.,1.,1.,600.,0.1,1.]
)

ParsimoniousModelOptions(model::ODEProblem) = AssimilationOptions(
  1000, 10, 1e-6, 1e-6, [1, 5, 6, 17, 23], 
  model.p,
  [0.005, 1e-6,1e-6,1e-6, 0.005], [0.1,1.,5.,1., 0.1]
)