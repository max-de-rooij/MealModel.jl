# Predicting
function predict(prob::ODEProblem, parameters, saveat::AbstractVector{<:Real})
  _prob = remake(prob, p=parameters, tspan=(saveat[1], saveat[end]))
  solve(_prob, Tsit5(), saveat=saveat)
end

predict(prob::ODEProblem, parameters, saveat::Real) = solve(prob, Tsit5(), p=parameters, saveat=saveat)
predict(prob::ODEProblem, saveat::Real) = solve(prob, Tsit5(), saveat=saveat)
predict(prob::ODEProblem, saveat::AbstractVector{<:Real}) = solve(prob, Tsit5(), saveat=saveat)

# Model outputs
function output(prob::ODEProblem, parameters; saveat::Union{Real, AbstractVector{<:Real}} = 1)
  # predict state variable outputs
  solution = predict(prob, parameters, saveat)
  _compute_output(parameters, solution)
end

function output(prob::ODEProblem; saveat::Union{Real, AbstractVector{<:Real}} = 1)
  solution = predict(prob, saveat)
  _compute_output(prob.p, solution)
end

function _compute_output(parameters, solution)

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

