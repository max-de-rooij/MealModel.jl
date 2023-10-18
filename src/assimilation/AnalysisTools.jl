function create_full_parameter_vector(model, p)

  fixed_parameter_filter = [i ∉ model.estimated_parameters for i in eachindex(model.prob.p)]
  fixed_parameters = model.prob.p[fixed_parameter_filter]
  fixed_parameter_indices = eachindex(model.prob.p)[fixed_parameter_filter]
  order = sortperm([fixed_parameter_indices; model.estimated_parameters])
  [fixed_parameters; p][order]
end



