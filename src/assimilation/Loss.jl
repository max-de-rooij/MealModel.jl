# single-subject loss function

function make_predictor(model::MixedMealModel)

  fixed_parameter_filter = [i ∉ model.estimated_parameters for i in eachindex(model.prob.p)]
  fixed_parameters = model.prob.p[fixed_parameter_filter]
  fixed_parameter_indices = eachindex(model.prob.p)[fixed_parameter_filter]
  order = sortperm([fixed_parameter_indices; model.estimated_parameters])
  
  function _predict(p, save_timestep = 0.5)
    full_parameter_vector = [fixed_parameters; p][order]
    #_prob = remake(model.prob, p=full_parameter_vector)
    output(model.prob, full_parameter_vector, model.prob.tspan[1]:save_timestep:model.prob.tspan[end])
  end

  return _predict
end

"""
Make a loss function for optimization.

Arguments:
* `model` : model as `MixedMealModel` object
* `data...` : Measured data in one of the following combinations:
  * `glucose_data`, `glucose_timepoints` for CGM
  * `glucose_data`, `glucose_timepoints`, `insulin_data`, `insulin_timepoints`, `tg_data`, `tg_timepoints`
  * `glucose_data`, `glucose_timepoints`, `insulin_data`, `insulin_timepoints`, `tg_data`, `tg_timepoints`, `nefa_data`, `nefa_timepoints`

Keyword arguments:
* `save_timestep` = 0.5 : save timestep to use for computing the regularisation errors. Smaller timesteps mean more memory but more accurate AUC computation. 
Values smaller than 0.5 (default) have no significant additional benefit for the parameter estimation.
"""
make_loss(model::MixedMealModel, data...; save_timestep = 0.5) = make_loss(model, make_error(
  model, data...; save_timestep = save_timestep); save_timestep = save_timestep)

function make_loss(model::MixedMealModel, error::Function; save_timestep = 0.5)

  fixed_parameter_filter = [i ∉ model.estimated_parameters for i in eachindex(model.prob.p)]
  fixed_parameters = model.prob.p[fixed_parameter_filter]
  fixed_parameter_indices = eachindex(model.prob.p)[fixed_parameter_filter]
  order = sortperm([fixed_parameter_indices; model.estimated_parameters])

  function _loss(p)
    full_parameter_vector = [fixed_parameters; p][order]
    #_prob = remake(model.prob, p=full_parameter_vector)
    model_output = output(model.prob, full_parameter_vector; saveat=save_timestep)
    error(model_output, full_parameter_vector)
  end

  _loss
end


function make_error(model::MixedMealModel, glucose_data, glucose_timepoints, insulin_data, insulin_timepoints, tg_data, tg_timepoints, nefa_data, nefa_timepoints; save_timestep = 0.5)

  # times
  times = model.prob.tspan[1]:save_timestep:model.prob.tspan[end]

  # obtain timepoints
  indices = [
    findall(x -> x ∈ glucose_timepoints, times),
    findall(x -> x ∈ insulin_timepoints, times),
    findall(x -> x ∈ tg_timepoints, times),
    findall(x -> x ∈ nefa_timepoints, times)]

  _glucose_reg_time = times[times .<= 240]
  _tg_reg_time = times[times .<= 480]
  
  function _error(model_output, parameters)
  
    # Data loss
    glucose_loss = (model_output.plasma_glucose[indices[1]] .- glucose_data)/maximum(glucose_data)
    insulin_loss = (model_output.plasma_insulin[indices[2]] .- insulin_data)/maximum(insulin_data)
    tg_loss = (model_output.plasma_TG[indices[3]] .- tg_data)/maximum(tg_data)
    nefa_loss = (model_output.plasma_NEFA[indices[4]] .- nefa_data)/maximum(nefa_data)

    # Fit error
    scaling_term = maximum(glucose_data)
    fit_error = scaling_term .* [glucose_loss; insulin_loss; tg_loss; nefa_loss]

    # Regularisation

    VG = (260/sqrt(parameters[28]/70))/1000
    VTG = (70/sqrt(parameters[28]/70))/1000
    fG = 0.005551
    fTG = 0.00113
    
    AUC_G_norm = trapz(_glucose_reg_time,model_output.glucose_gut_to_plasma_flux[times .<= 240]) * (VG*parameters[28])/fG
    err_AUC_G = abs(AUC_G_norm-parameters[26])/10_000

    AUC_TG_norm = trapz(_tg_reg_time,model_output.tg_gut_to_plasma_flux[times .<= 480]) * (VTG*parameters[28])/fTG
    err_AUC_TG = abs(AUC_TG_norm-parameters[27])/10_000

    G_steady_state = parameters[13] - model_output.plasma_glucose[times .== 300][1]

    TG_steady_state = tg_data[1] - model_output.plasma_TG[times .== 720][1]

    model_fasting_NEFA = (3 *(parameters[16]/100)*parameters[17]*tg_data[1]*parameters[14] + (parameters[18]/(1 +parameters[19]*(parameters[14]^2))))/parameters[20]
    NEFA_diff = nefa_data[1] - model_fasting_NEFA

    VLDL_nonneg = sum(abs2, min.(0, model_output.hepatic_tg_flux))

    regularisation_error = [err_AUC_G, err_AUC_TG, G_steady_state, VLDL_nonneg, TG_steady_state, 8*NEFA_diff]

    # Combined Loss Value
    sum(abs2, [fit_error; regularisation_error])
  end

  return _error
end

function make_error(model::MixedMealModel, glucose_data, glucose_timepoints, insulin_data, insulin_timepoints, tg_data, tg_timepoints; save_timestep = 0.5)
  # times
  times = model.prob.tspan[1]:save_timestep:model.prob.tspan[end]

  # obtain timepoints
  indices = [
    findall(x -> x ∈ glucose_timepoints, times),
    findall(x -> x ∈ insulin_timepoints, times),
    findall(x -> x ∈ tg_timepoints, times)]

  _glucose_reg_time = times[times .<= 240]
  _tg_reg_time = times[times .<= 480]
  
  function _error(model_output, parameters, ::Any)

    # Data loss
    glucose_loss = (model_output.plasma_glucose[indices[1]] .- glucose_data)/maximum(glucose_data)
    insulin_loss = (model_output.plasma_insulin[indices[2]] .- insulin_data)/maximum(insulin_data)
    tg_loss = (model_output.plasma_TG[indices[3]] .- tg_data)/maximum(tg_data)

    # Fit error
    scaling_term = maximum(glucose_data)
    fit_error = scaling_term .* [glucose_loss; insulin_loss; tg_loss]

    # Regularisation

    VG = (260/sqrt(parameters[28]/70))/1000
    VTG = (70/sqrt(parameters[28]/70))/1000
    fG = 0.005551
    fTG = 0.00113
    
    AUC_G_norm = trapz(_glucose_reg_time,model_output.glucose_gut_to_plasma_flux[times .<= 240]) * (VG*parameters[28])/fG
    err_AUC_G = abs(AUC_G_norm-parameters[26])/10_000

    AUC_TG_norm = trapz(_tg_reg_time,model_output.tg_gut_to_plasma_flux[times .<= 480]) * (VTG*parameters[28])/fTG
    err_AUC_TG = abs(AUC_TG_norm-parameters[27])/10_000

    G_steady_state = parameters[13] - model_output.plasma_glucose[times .== 300][1]

    TG_steady_state = tg_data[1] - model_output.plasma_TG[times .== 720][1]

    VLDL_nonneg = sum(abs2, min.(0, model_output.hepatic_tg_flux))

    regularisation_error = [err_AUC_G, err_AUC_TG, G_steady_state, VLDL_nonneg, TG_steady_state]

    # Combined Loss Value
    sum(abs2, [fit_error; regularisation_error])
  end

  return _error
end

function make_error(model::MixedMealModel, glucose_data, glucose_timepoints; save_timestep = 0.5)
  # times
  times = model.prob.tspan[1]:save_timestep:model.prob.tspan[end]

  # obtain timepoints
  indices = findall(x -> x ∈ glucose_timepoints, times)

  _glucose_reg_time = times[times .<= 240]
  
  function _error(model_output, parameters, ::Any)

    # Data loss
    glucose_loss = model_output.plasma_glucose[indices[1]] .- glucose_data

    # Regularisation

    VG = (260/sqrt(parameters[28]/70))/1000
    fG = 0.005551
    
    AUC_G_norm = trapz(_glucose_reg_time,model_output.glucose_gut_to_plasma_flux[times .<= 240]) * (VG*parameters[28])/fG
    err_AUC_G = abs(AUC_G_norm-parameters[26])/10_000

    G_steady_state = parameters[13] - model_output.plasma_glucose[times .== 300][1]

    regularisation_error = [err_AUC_G, G_steady_state]

    # Combined Loss Value
    sum(abs2, [glucose_loss; regularisation_error])
  end

  return _error
end