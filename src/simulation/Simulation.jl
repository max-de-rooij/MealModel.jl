# Predicting in single-subject mode
function predict(model::MixedMealModel{<:ODEProblem}, parameters::AbstractVector{<:Real}, times::AbstractVector{<:Real})
  solve(model.prob, Vern7(), p=parameters, tspan=(times[1], times[end]), saveat=times)
end

function predict(model::MixedMealModel{<:ODEProblem}, parameters::AbstractVector{<:Real}, save_timestep::Real)
  solve(model.prob, Vern7(), p=parameters, saveat=save_timestep)
end

function predict(model::MixedMealModel{<:ODEProblem}, save_timestep::Real)
  solve(model.prob, Vern7(), saveat=save_timestep)
end

function predict(model::MixedMealModel{<:ODEProblem}, times::AbstractVector{<:Real})
  solve(model.prob, Vern7(), tspan=(times[1], times[end]), saveat=times)
end

# Predicting in ensemble-mode
function predict(model::MixedMealModel{<:EnsembleProblem}, save_timestep::Real, ensemble_mode::SciMLBase.EnsembleAlgorithm)
  solve(model.prob, Vern7(), ensemble_mode, saveat=save_timestep, trajectories=model.trajectories)
end

function output(model::MixedMealModel{<:ODEProblem}; times::Union{Real, AbstractVector{<:Real}} = 1)
  # predict state variable outputs
  solution = predict(model, times)
  _compute_output(model.prob.p, solution)
end

function output(model::MixedMealModel{<:ODEProblem}, parameters::AbstractVector{<:Real}; times::Union{Real, AbstractVector{<:Real}} = 1)
  solution = predict(model, parameters, times)
  _compute_output(parameters, solution)
end

function output(model::MixedMealModel{<:EnsembleProblem}; times::Real = 1, ensemble_mode::SciMLBase.EnsembleAlgorithm = EnsembleSerial())
  solution = predict(model, times, ensemble_mode)
  _compute_output(model.prob, solution)
end

function _compute_output(parameters::AbstractVector{<:Real}, solution)

  states = Array(solution)
  # model input
  BW = parameters[28]

  fG = 0.005551
  fTG = 0.00113
  fI = 1.
  VG = (260/sqrt(BW/70))/1000
  VTG = (70/sqrt(BW/70))/1000

  # glucose flux from the gut into the plasma
  glucose_plasma_flux = (parameters[2] * fG / (BW * VG)) .* states[1,:]

  # hepatic glucose flux
  hepatic_glucose_flux = parameters[15] .- (parameters[4] * fI) .* states[5, :] .- parameters[3] .* (states[2,:] .- parameters[13])

  # glucose uptake into tissue
  
  insulin_independent = parameters[15] .* ((parameters[12] .+ parameters[13]) .* states[2, :]) ./ (parameters[13] * (parameters[12] .+ states[2, :]))
  insulin_dependent = states[5,:] .* states[2, :] .* (parameters[5] ./ (parameters[12] .+ states[2, :]))

  glucose_uptake = insulin_dependent .+ insulin_independent
  
  # tg flux from the gut into the plasma
  tg_plasma_flux = (parameters[23] * fTG / (BW * VTG)) .* states[12,:]
  
  # hepatic tg flux (VLDL)
  hepatic_tg_flux = parameters[25] .- parameters[24] .* (states[8,:] .- parameters[14])

  return (
    time = solution.t,
    glucose_gut_to_plasma_flux = glucose_plasma_flux,
    hepatic_glucose_flux = hepatic_glucose_flux,
    glucose_tissue_uptake = glucose_uptake,
    plasma_glucose = states[2, :],
    plasma_insulin = states[4, :],
    tg_gut_to_plasma_flux = tg_plasma_flux,
    hepatic_tg_flux = hepatic_tg_flux,
    plasma_TG = states[13, :],
    plasma_NEFA = states[9, :]
    )
end

function _compute_output(ensemble::EnsembleProblem, solution)
  prob_func = ensemble.prob_func
  prob = ensemble.prob
  outputs = []
  for (i, sol) in enumerate(solution)

    prob = prob_func(prob, i, 1)
    parameters = prob.p

    output = _compute_output(parameters, sol)
    push!(outputs, output)
  end

  return outputs
end
