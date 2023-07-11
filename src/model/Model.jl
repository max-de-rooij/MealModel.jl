include("Equations.jl")

# default parameters
function parameters(
  fasting_glucose, 
  fasting_insulin, 
  meal_glucose_mass, 
  meal_tg_mass, 
  subject_body_mass; 
  k1 = 0.0105, 
  k2 = 0.28, 
  k3 = 6.07e-3,
  k4 = 2.35e-4,
  k5 = 0.0424,
  k6 = 2.2975,
  k7 = 1.15,
  k8 = 7.27,
  k9 = 3.83e-2,
  k10 = 2.84e-1,
  sigma = 1.4,
  Km = 13.2,
  G_b = fasting_glucose,
  I_pl_b = fasting_insulin,
  G_liv_b = 0.043,
  spill = 30, 
  k11 = 0.00045, 
  ATL_max = 0.215, 
  K_ATL = 0.2, 
  k12 = 0.0713, 
  tau_LPL = 208.88, 
  k13 = 0.0088, 
  k14 = 0.0163, 
  k15 = 1e-5, 
  k16 = 0.0119
  )

  return [
    k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, sigma, Km, G_b, I_pl_b, G_liv_b, spill, k11, ATL_max, K_ATL, k12, tau_LPL, k13, k14, k15, k16, meal_glucose_mass, meal_tg_mass, subject_body_mass
  ]
end

# single-subject
function MixedMealModel(
  meal_glucose_mass::T,
  meal_tg_mass::T,
  subject_body_mass::T,
  fasting_glucose::T,
  fasting_insulin::T,
  fasting_TG::T,
  fasting_NEFA::T;
  timespan::Tuple{<:Real, <:Real} = (0., 480.)) where T<:Real

  u0 = [
    0., fasting_glucose, 0., fasting_insulin, 0., fasting_insulin, fasting_insulin, fasting_insulin, fasting_NEFA, 0., 0., 0., fasting_TG
  ]

  p = parameters(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass)

  ODEProblem{true, SciMLBase.FullSpecialize}(
    system(), u0, timespan, p
  )
end

MixedMealModel() = MixedMealModel(75000., 60000., 75., 5.0, 18.0, 1.3, 0.33)


function MixedMealModel(
  meal_glucose_mass::T,
  meal_tg_mass::T,
  subject_body_mass::T,
  fasting_glucose::T,
  fasting_insulin::T,
  fasting_TG::T,
  fasting_NEFA::T;
  timespan::Tuple{<:Real, <:Real} = (0., 480.)) where T<:AbstractVector{<:Real}

  u0 = [
    [0., glc, 0., ins, 0., ins, ins, ins, nfa, 0., 0., 0., tg] for 
    (glc, ins, tg, nfa) in zip(fasting_glucose, fasting_insulin, fasting_TG, fasting_NEFA)
  ]

  p = [
    parameters(glc, ins, meal_glc, meal_tg, bm) for 
    (glc, ins, meal_glc, meal_tg, bm) in zip(fasting_glucose, fasting_insulin, meal_glucose_mass, meal_tg_mass, subject_body_mass)
  ]

  prob = ODEProblem{true, SciMLBase.FullSpecialize}(
      system(), u0[1], timespan, p[1]
    )
  
  prob_func = let p=p, u0=u0
    (prob, i, rep) -> begin
      remake(prob, p=p[i], u0=u0[i])
    end
  end

  EnsembleProblem(prob, prob_func = prob_func)
end