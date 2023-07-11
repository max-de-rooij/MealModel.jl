include("Equations.jl")
include("Parameters.jl")
using Random

struct MixedMealModel{T<:Union{ODEProblem, EnsembleProblem}}
  prob::T
  trajectories::Int
end

MixedMealModel(prob::ODEProblem) = MixedMealModel(prob, 1)

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

  return MixedMealModel(ODEProblem{true, SciMLBase.FullSpecialize}(
    system(), u0, timespan, p
  ))
end

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

  MixedMealModel(EnsembleProblem(prob, prob_func = prob_func), length(fasting_glucose))
end

# default behavior
MixedMealModel() = MixedMealModel(75000., 60000., 75., 5.0, 18.0, 1.3, 0.33)

# default ensemble
MixedMealModel(n_ensembles::Int) = begin 
  
  body_mass = shuffle(range(70, 90, n_ensembles))
  gb = shuffle(range(4.0, 6.5, n_ensembles))
  ib = shuffle(range(9.0, 18.0, n_ensembles))
  tgb = shuffle(range(0.9, 2.3, n_ensembles))
  nefab = shuffle(range(0.25, 0.38, n_ensembles))

  MixedMealModel(
    repeat([75000.], n_ensembles),
    repeat([60000.], n_ensembles),
    body_mass,
    gb,
    ib,
    tgb,
    nefab
  )
end