using SpecialFunctions

"""
Meal Apprearance function of glucose or TG into the gut, using Mδ(t) as an input for stacked delays of depth σ and 
  rate coefficient k.
"""
function meal_appearance(σ, k, t, M)
  # σ*(k^σ)*t^(σ-1) * exp(-1*(k*t)^σ) * M (change the line blow to this for the original meal model function)
  (k^σ)*t^(σ-1) * exp(-1*(k*t)) * M * (1/gamma(σ))
end

"""
Meal Apprearance function of glucose or TG into the gut, using Mδ(t-tMeal) as an input for stacked delays of depth σ and 
rate coefficient k.
"""
function meal_appearance(σ, k, t, M, tMeal)
  t̂ = (t ≥ tMeal) * (t - tMeal)
  meal_appearance(σ, k, t̂, M)
end

"""
Glucose flux in the gut, which is the difference of the appearance from a meal at time t=0, and absorption from the 
intestine into the blood plasma, with rate k2.
"""
function glucose_meal_appearance(σ, k, t, M, k2, g_gut)
  glucose_from_meal = meal_appearance(σ, k, t, M)
  intestinal_absorption = k2 * g_gut
  
  glucose_from_meal - intestinal_absorption
end

"""
Glucose flux in the gut, which is the difference of the appearance from a meal at time t=tMeal, and absorption from the 
intestine into the blood plasma, with rate k2.
"""
function glucose_meal_appearance(σ, k, t, M, k2, g_gut, meal_times)
  glucose_from_meal = sum(meal_appearance(σ,k,t,M[i],tMeal) for (i, tMeal) in enumerate(meal_times))
  intestinal_absorption = k2 * g_gut
  
  glucose_from_meal - intestinal_absorption
end

"""
Glucose flux in the blood plasma compartment. The flux consists of five components:
  1. Liver: endogenous glucose production, inhibited by glucose and insulin concentrations above baseline
  2. Gut: glucose appearance from the gut compartment
  3. Insulin-independent utilization: glucose absorption into tissue, independent from insulin concentrations (brain)
  4. Insulin-dependent utilization: glucose absorption into tissue, dependent on insulin concentrations
  5. Renal: glucose excretion through the kidneys if the plasma concentration becomes large (Gpl > 9)
"""
function plasma_glucose_flux(VG, BW, fI, fG, c1, G_threshold_pl, p, u)

  # Constants
  distribution_volume_correction = 1/(VG*BW)
  unit_conversion_glucose_insulin = 1/fI
  unit_conversion_mg_to_mM = fG
  basal_production = p[15]
  glomerular_filtration_rate = c1
  renal_threshold = G_threshold_pl

  # Liver
  egp_inhibition_by_insulin = p[4]*u[5]*unit_conversion_glucose_insulin
  egp_inhibition_by_glucose = p[3] * (u[2] - p[13])
  G_liver = basal_production - egp_inhibition_by_insulin - egp_inhibition_by_glucose
  
  # Intestines (gut)
  glucose_appearance = p[2] * u[1]
  G_gut = glucose_appearance * distribution_volume_correction * unit_conversion_mg_to_mM

  # Insulin-independent glucose utilization (maintain steady-state)
  normalized_utilization_rate = ((p[12] + p[13]) * u[2]) / (p[13] * (p[12] + u[2]))
  G_iid = normalized_utilization_rate * basal_production

  # Insulin-dependent glucose utilization
  utilization_rate = p[5] * u[2] / (p[12] + u[2])
  G_idp = utilization_rate * u[5]

  # Renal excretion of excess glucose
  G_ren = glomerular_filtration_rate * distribution_volume_correction * (u[2] - renal_threshold) * (u[2] > renal_threshold)
  
  G_liver + G_gut - G_iid - G_idp - G_ren
end

function plasma_insulin_flux(fI, tau_i, tau_d, p, u, du)
  unit_conversion_glucose_insulin = 1/fI

  # Pancreas
  proportional = p[6] * (u[2] - p[13])
  integral = (p[7]/tau_i) * (u[3] + p[13])
  derivative = (p[8]*tau_d) * du[2]
  I_pnc = unit_conversion_glucose_insulin * (proportional + integral + derivative)

  # Liver insulin degradation (maintain steady-state)
  basal_rate = unit_conversion_glucose_insulin * (p[7]/tau_i) * p[13]
  I_liv = basal_rate * (u[4]/p[14])

  # Transport to interstitial fluid
  I_int = p[9]*(u[4] - p[14])

  I_pnc - I_liv - I_int
end

function interstitial_insulin_flux(p, u)
  appearance = p[9] * (u[4] - p[14])
  degradation = p[10] * u[5]

  appearance - degradation
end

function plasma_nefa_flux(p, u)
  LPL_lipolysis = p[17] * u[13] * u[8]
  fractional_spillover =  (1/100) * p[16] * (p[14]/u[6])

  spillover = 3*fractional_spillover*LPL_lipolysis

  adipose_tg_lipolysis = p[18] / (1 + p[19] * u[6]^2)

  tissue_uptake = p[20] * u[9]

  spillover + adipose_tg_lipolysis - tissue_uptake
end

function plasma_tg_flux(VTG, BW, fTG, p, u)
  distribution_volume_correction = 1/(VTG*BW)
  unit_conversion_mg_to_mM = fTG

  # endogenous secretion of TG (in the form of VLDL)
  VLDL = p[25] - p[24] * (u[8] - p[14])

  # TG from the gut
  TG_gut = p[23] * distribution_volume_correction * unit_conversion_mg_to_mM * u[12]

  # LPL lipolysis
  LPL_lipolysis = p[17] * u[13] * u[8]
  
  VLDL + TG_gut - LPL_lipolysis
end

function system()

  # model input
  fG = 0.005551
  fTG = 0.00113
  fI = 1.
  tau_i = 31.
  tau_d = 3.
  G_threshold_pl = 9.
  c1 = 0.1
  
  equations! = function(du, u, p, t)

    mG = p[26]
    mTG = p[27]
    BW = p[28]

    VG = (260/sqrt(BW/70))/1000
    VTG = (70/sqrt(BW/70))/1000
    # glucose appearance from the meal
    du[1] = glucose_meal_appearance(p[11], p[1], t, mG, p[2], u[1]) 

    # glucose in the plasma
    du[2] = plasma_glucose_flux(VG, BW, fI, fG, c1, G_threshold_pl, p, u)

    # PID Integrator equation
    du[3] = u[2] - p[13]

    # insulin in the plasma
    du[4] = plasma_insulin_flux(fI, tau_i, tau_d, p, u, du)

    # Insulin in the interstitial fluid
    du[5] = interstitial_insulin_flux(p, u)

    # Insulin delays for NEFA_pl
    du[6] = 3/p[21] * (u[4] - u[6])
    du[7] = 3/p[21] * (u[6] - u[7])
    du[8] = 3/p[21] * (u[7] - u[8])
   
    # plasma NEFA
    du[9] = plasma_nefa_flux(p, u)

    # Gut TG
    du[10] = meal_appearance(p[11], p[22], t, mTG) - p[23] * u[10]
    du[11] = p[23] * (u[10] - u[11])
    du[12] = p[23] * (u[11] - u[12])

    # plasma TG
    du[13] = plasma_tg_flux(VTG, BW, fTG, p, u)
  end

  return equations!
end

function system(meal_times)
    # model input
    fG = 0.005551
    fTG = 0.00113
    fI = 1.
    tau_i = 31.
    tau_d = 3.
    G_threshold_pl = 9.
    c1 = 0.1
    
    nMeals = length(meal_times)

    equations! = function(du, u, p, t)
      
      
      mG = p[26:25+nMeals]
      mTG = p[26+nMeals:25+2*nMeals]
      BW = p[end]
  
      VG = (260/sqrt(BW/70))/1000
      VTG = (70/sqrt(BW/70))/1000
      # glucose appearance from the meal
      du[1] = glucose_meal_appearance(p[11], p[1], t, mG, p[2], u[1], meal_times) 
  
      # glucose in the plasma
      du[2] = plasma_glucose_flux(VG, BW, fI, fG, c1, G_threshold_pl, p, u)
  
      # PID Integrator equation
      du[3] = u[2] - p[13]
  
      # insulin in the plasma
      du[4] = plasma_insulin_flux(fI, tau_i, tau_d, p, u, du)
  
      # Insulin in the interstitial fluid
      du[5] = interstitial_insulin_flux(p, u)
  
      # Insulin delays for NEFA_pl
      du[6] = 3/p[21] * (u[4] - u[6])
      du[7] = 3/p[21] * (u[6] - u[7])
      du[8] = 3/p[21] * (u[7] - u[8])
     
      # plasma NEFA
      du[9] = plasma_nefa_flux(p, u)
  
      # Gut TG
      du[10] = sum(meal_appearance(p[11], p[22], t, mTG[i], tMeal) for (i,tMeal) in enumerate(meal_times)) - p[23] * u[10]
      du[11] = p[23] * (u[10] - u[11])
      du[12] = p[23] * (u[11] - u[12])
  
      # plasma TG
      du[13] = plasma_tg_flux(VTG, BW, fTG, p, u)
    end
  
    return equations!
  end
