# single-subject loss function
function setup(model::MixedMealModel{<:ODEProblem}, data<:MealResponseData, Options::AssimilationOptions)


  timepoints = [model.prob.tspan[1]:model.prob.tspan[end]...]
  indices = _get_time_indices(data, timepoints)


  # TODO: find a way to get the parameters in the right format
  # TODO: finish loss function 
  # TODO: make loss for PartialMealResponse
  # TODO: make losses for EnsembleProblem models with multiple MealResponseData
  # TODO: write setup function with default model options
  # TODO: add warning for non-identifiability if parameter indices and data-type combination is not tested






end

function _generate_loss(model::MixedMealModel{<:ODEProblem}, data::CompleteMealResponse, timepoints, indices)

  # obtain the data
  glucose_data = data.glucose.values
  insulin_data = data.insulin.values
  tg_data = data.tg.values
  nefa_data = data.nefa.values

  fasting_nefa = model.prob.u0[9]
  fasting_tg = model.prob.u0[13]

  function _loss(p)

    outputs = output(model, parameters, timepoints)

    glucose_loss = (outputs.plasma_glucose[indices[1]] .- glucose_data)/maximum(glucose_data)
    insulin_loss = (outputs.plasma_insulin[indices[2]] .- insulin_data)/maximum(insulin_data)
    tg_loss = (outputs.plasma_TG[indices[3]] .- tg_data)/maximum(tg_data)
    nefa_loss = (outputs.plasma_NEFA[indices[4]] .- nefa_data)/maximum(nefa_data)

    # Fit error
    scaling_term = maximum(glucose_data)
    fit_error = scaling_term .* [glucose_loss; insulin_loss; tg_loss; nefa_loss]

    # Regularisation terms

    # error if AUC of roc of gut glucose < meal content
    AUC_G = sum(outputs.glucose_gut_to_plasma_flux, 2:239) + 0.5 * (outputs.glucose_gut_to_plasma_flux[1] + outputs.glucose_gut_to_plasma_flux[240])
    err_AUC_G = abs(AUC_G - parameters[26])/10000

    # error if AUC of roc of TG in plasma < meal content
    AUC_TG = sum(outputs.tg_gut_to_plasma_flux, 2:479) + 0.5 * (outputs.tg_gut_to_plasma_flux[1] + outputs.tg_gut_to_plasma_flux[480])
    err_AUC_TG = abs(AUC_TG - parameters[27])/10000
    
    # constrain steady state G to measured fasting value
    G_steady_state = parameters[13] - outputs.plasma_glucose[301]

    # constrain steady state TG to measured fasting value
    TG_steady_state = fasting_tg - outputs.plasma_TG[481]

    # constrain steady state NEFA to measured fasting value
    model_fasting_NEFA = (3 *(parameters[16]/100)*p[17]*fasting_tg*parameters[14] + (parameters[18]/(1 +parameters[19]*(parameters[14]^2))))/parameters[20]
    NEFA_diff = fasting_nefa - model_fasting_NEFA

    # non-negative VLDL flux
    VLDL_nonneg = sum(abs2, min.(0, outputs.hepatic_tg_flux))

    # Regularisation error
    regularisation_error = [err_AUC_G, err_AUC_TG, G_steady_state, VLDL_nonneg, TG_steady_state, 8*NEFA_diff]

    # Combined Loss Value
    sum(abs2, [fit_error; regularisation_error])
  end

  loss(x, p) = _loss(x)

  loss
end