using MealModel
using Plots
using Optimization, OptimizationOptimJL, LineSearches

datadir = joinpath(dirname(@__DIR__), "data")
include(joinpath(datadir, "SampleData.jl"))

glc, ins, trg, nfa, bwg, time = SampleData()

# select patient
patient_id = 1 # for this sample data, we can select from patients 1-5

glucose_data = glc[patient_id, :]
insulin_data = ins[patient_id, :]
tg_data = trg[patient_id, :]
nefa_data = nfa[patient_id, :];
body_weight = bwg[patient_id];

model = MixedMealModel(
  subject_body_mass = body_weight,
  fasting_glucose = glucose_data[1],
  fasting_insulin = insulin_data[1],
  fasting_TG = tg_data[1],
  fasting_NEFA = nefa_data[1],
  timespan = (0., 720.)
)

@testset begin
  
  function test_optimize()
    loss = make_loss(model, glucose_data, time, insulin_data, time, tg_data, time, nefa_data, time)
    optimizer = LBFGS(linesearch = BackTracking(order=3))
    
    # select bounds for the latin hypercube sampler
    lhc_lb = [0.005, 0, 0, 0, 0, 60., 0.005, 0]
    lhc_ub = [0.05, 1., 10., 1., 1., 720., 0.1, 1.]
    
    # create preselected samples
    initial_parameters = perform_preselection(loss, 100, lhc_lb, lhc_ub)
    
    # for each initial parameter set we can easily optimize the model
    
    objectives = []
    parameters = []
    
    opt_lb = lhc_lb
    opt_ub = lhc_ub
    
    for it in axes(initial_parameters, 2)
      try
        optf = OptimizationFunction((x,p) -> loss(x), Optimization.AutoForwardDiff())
        starting_p = initial_parameters[:, it]
        optprob = OptimizationProblem(optf, starting_p, lb=opt_lb, ub=opt_ub)
        sol = Optimization.solve(optprob, optimizer, x_tol=1e-8, f_tol = 1e-6, g_tol=1e-6)
        push!(parameters, sol.u)
        push!(objectives, sol.objective)
        println("Optimization successful! (E = $(sol.objective)) Moving on...")
      catch e 
        throw(e)
        println("Optimization failed... Resampling...")
      end
    end

    true
  end

  @test test_optimize()
    
end


# glc = [4.97828626648081,	9.83226219754181,	6.91736265000290,	3.99736583151076,	4.74531292225800,	5.43827322143290,	5.00061029702766,	4.90628637452010]
# ins = [21.7542994608033,	287.361969174996,	294.323541530305,	85.4388252908261,	18.0684917209633,	21.0182483747640,	23.1679411923448,	21.8618244436204]
# trg = [1.16871366007653,	1.58440178335270,	1.78195011372397,	2.39301829368748,	2.41622964225137,	2.31174933441785,	1.93219870120156,	1.72103932334563]
# nfa = [0.335735045292724,	0.306808022891325,	0.175773322340940,	0.126453528770619,	0.186422309973495,	0.317877874980899,	0.504623299086489,	0.561199670138616]

# time = [0.,30.,60.,120.,180.,240.,360.,480.]

# model = MixedMealModel(;
#     fasting_glucose = glc[1], 
#     fasting_insulin = ins[1], 
#     fasting_TG = trg[1],
#     fasting_NEFA = nfa[1],
#     timespan = (0., 720.))


# errorfunction = make_error(model, glc, time, ins, time, trg, time, nfa, time)
# loss = make_loss(model, errorfunction)

# optimizer = LBFGS(linesearch = BackTracking(order=3))

# # define bounds
# bfgs_lb = [0.005, 1e-6,1e-6,1e-6,1e-6,60.,0.005, 1e-6];
# bfgs_ub = [0.1,1.,15.,1.,1.,600.,0.1,1.];

# lhc_lb = bfgs_lb
# lhc_ub = [0.1,1.,4.,1.,1.,600.,0.1,1.];
# # define initial parameter sets 
# parameter_sets = LHCoptim(250, length(lhc_lb), 100)[1] ./ 250
# ubx = (1-1e-9).*lhc_ub;
# lbx = (1+1e-9).*lhc_lb;
# parameter_sets = (parameter_sets' .* (ubx.-lbx)) .+ lbx

# initial_objectives = []
# for i in axes(parameter_sets, 2)
#   try
#     objective = loss(parameter_sets[:,i])
#     push!(initial_objectives, objective)
#   catch
#     push!(initial_objectives, Inf)
#   end
# end
# best_indices = partialsortperm(initial_objectives, 1:5)
# local_objectives = []
# local_parameters = []

# for it in best_indices
  
#   try
#     optf = OptimizationFunction((x, p) -> loss(x), Optimization.AutoForwardDiff())
#     optprob = OptimizationProblem(optf, parameter_sets[:,it], lb=bfgs_lb, ub=bfgs_ub)
#     sol = Optimization.solve(optprob, optimizer, x_tol=1e-8, f_tol = 1e-6, g_tol=1e-6, maxiters=400)
#     push!(local_parameters, sol.minimizer)
#     push!(local_objectives, sol.objective)
#     println("Optimization successful! Moving on...")
#   catch
#     println("Optimization failed... Resampling...")
#   end
# end

# best_objective = partialsortperm(local_objectives, 1)
# local_objectives[best_objective]
# best_parameters = local_parameters[best_objective]
