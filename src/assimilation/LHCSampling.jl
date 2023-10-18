function perform_preselection(loss, number_of_parameter_sets::Int, lhc_lb::Vector{<:Real}, lhc_ub::Vector{<:Real}; selection_criterion::Number = 0.1, rng=Random.default_rng())


  parameter_sets = LHCoptim(number_of_parameter_sets, length(lhc_lb), 100, rng = rng)[1] ./ number_of_parameter_sets
  ubx = (1-1e-9).*lhc_ub;
  lbx = (1+1e-9).*lhc_lb;
  parameter_sets = (parameter_sets' .* (ubx.-lbx)) .+ lbx
  
  initial_objectives = []
  for i in axes(parameter_sets, 2)
    try
      objective = loss(parameter_sets[:,i])
      push!(initial_objectives, objective)
    catch e
      push!(initial_objectives, Inf)
    end
  end

  upper_limit = Int(floor(number_of_parameter_sets*selection_criterion))

  best_indices = partialsortperm(initial_objectives, 1:upper_limit)

  parameter_sets[:,best_indices]
end