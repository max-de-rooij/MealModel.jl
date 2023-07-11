function predict(model, parameters::AbstractVector{<:Real}, times::AbstractVector{<:Real})
  solve(model, Vern7(), p=parameters, tspan=(times[1], times[end]), saveat=times)
end

function predict(model, parameters::AbstractVector{<:Real}, save_timestep::Real)
  solve(model, Vern7(), p=parameters, saveat=save_timestep)
end

function predict(model, save_timestep::Real)
  solve(model, Vern7(), saveat=save_timestep)
end

function predict(model, times::AbstractVector{<:Real})
  solve(model, Vern7(), tspan=(times[1], times[end]), saveat=times)
end

function output(model; times::Union{Real, AbstractVector{<:Real}} = 1)
  # predict state variable outputs
  solution = predict(model, times)
  _compute_output(model.p, solution)
end

function output(model, parameters::AbstractVector{<:Real}; times::Union{Real, AbstractVector{<:Real}} = 1)
  solution = predict(model, parameters, times)
  _compute_output(parameters, solution)
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
  glucose_uptake = begin 
    insulin_independent = parameters[15] .* ((parameters[12] .+ parameters[13]) .* states[2, :]) ./ (parameters[13] * (parameters[12] .+ states[2, :]))
    insulin_dependent = states[5,:] .* states[2, :] .* (parameters[5] ./ (parameters[12] .+ states[2, :]))

    insulin_dependent .+ insulin_independent
  end

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

