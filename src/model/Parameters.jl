# default parameters
function parameters(
  fasting_glucose, 
  fasting_insulin, 
  meal_glucose_mass::Real, 
  meal_tg_mass::Real, 
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
  spill = 30., 
  k11 = 0.00045, 
  ATL_max = 0.215, 
  K_ATL = 0.0385, 
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

# default parameters
function parameters(
  fasting_glucose, 
  fasting_insulin, 
  meals_glucose_mass::AbstractVector{<:Real}, 
  meals_tg_mass::AbstractVector{<:Real}, 
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
  spill = 30., 
  k11 = 0.00045, 
  ATL_max = 0.215, 
  K_ATL = 0.0385, 
  k12 = 0.0713, 
  tau_LPL = 208.88, 
  k13 = 0.0088, 
  k14 = 0.0163, 
  k15 = 1e-5, 
  k16 = 0.0119
  )

  pvector = [k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, sigma, Km, G_b, I_pl_b, G_liv_b, spill, k11, ATL_max, K_ATL, k12, tau_LPL, k13, k14, k15, k16] 
  
  return [pvector; meals_glucose_mass; meals_tg_mass; subject_body_mass]
end