function _meal_appearance(σ, k, t, M)
  σ*(k^σ)*t^(σ-1) * exp(-1*(k*t)^σ) * M
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
    du[1] = begin 
      glucose_from_meal = _meal_appearance(p[11], p[1], t, mG)
      intestinal_absorption = p[2] * u[1]
      
      glucose_from_meal - intestinal_absorption
    end

    # glucose in the plasma
    du[2] = begin

      distribution_volume_correction = 1/(VG*BW)
      unit_conversion_glucose_insulin = 1/fI
      unit_conversion_mg_to_mM = fG
      basal_production = p[15]
      glomerular_filtration_rate = c1
      renal_threshold = G_threshold_pl

      # Liver
      G_liver = begin
        egp_inhibition_by_insulin = p[4]*u[5]*unit_conversion_glucose_insulin
        egp_inhibition_by_glucose = p[3] * (u[2] - p[13])

        basal_production - egp_inhibition_by_insulin - egp_inhibition_by_glucose
      end

      # Intestines (gut)
      G_gut = begin
        glucose_appearance = p[2] * u[1]

        glucose_appearance * distribution_volume_correction * unit_conversion_mg_to_mM
      end

      # Insulin-independent glucose utilization (maintain steady-state)
      G_iid = begin
        normalized_utilization_rate = ((p[12] + p[13]) * u[2]) / (p[13] * (p[12] + u[2]))

        normalized_utilization_rate * basal_production
      end

      # Insulin-dependent glucose utilization
      G_idp = begin
        utilization_rate = p[5] * u[2] / (p[12] + u[2])

        utilization_rate * u[5]
      end

      # Renal excretion of excess glucose
      G_ren = begin
        glomerular_filtration = glomerular_filtration_rate * distribution_volume_correction * (u[2] - renal_threshold)
        renal_excretion_switch = u[2] > renal_threshold

        glomerular_filtration * renal_excretion_switch
      end

      G_liver + G_gut - G_iid - G_idp - G_ren
    end

    # PID Integrator equation
    du[3] = u[2] - p[13]

    # insulin in the plasma
    du[4] = begin
      
      unit_conversion_glucose_insulin = 1/fI

      # Pancreas
      I_pnc = begin
        proportional = p[6] * (u[2] - p[13])
        integral = (p[7]/tau_i) * (u[3] + p[13])
        derivative = (p[8]/tau_d) * du[2]

        unit_conversion_glucose_insulin * (proportional + integral + derivative)
      end

      # Liver insulin degradation (maintain steady-state)
      I_liv = begin
        basal_rate = unit_conversion_glucose_insulin * (p[7]/tau_i) * p[13]

        basal_rate * (u[4]/p[14])
      end

      # Transport to interstitial fluid
      I_int = p[9]*(u[4] - p[14])

      I_pnc - I_liv - I_int
    end

    # Insulin in the interstitial fluid
    du[5] = begin
      appearance = p[9] * (u[4] - p[14])
      degradation = p[10] * u[5]

      appearance - degradation
    end

    # Insulin delays for NEFA_pl
    du[6:8] = begin
      transport_rate = 3/p[21]

      transport_rate .* [
        u[4] - u[6],
        u[6] - u[7],
        u[7] - u[8]
      ]
    end

    # plasma NEFA
    du[9] = begin

      spillover = begin
        LPL_lipolysis = p[17] * u[13] * u[8]
        fractional_spillover =  (1/100) * p[16] * (p[14]/u[6])

        3*fractional_spillover*LPL_lipolysis
      end

      adipose_tg_lipolysis = p[18] / (1 + p[19] * u[6]^2)

      tissue_uptake = p[20] * u[9]

      spillover + adipose_tg_lipolysis - tissue_uptake
    end

    # Gut TG
    du[10:12] = begin
      tg_from_meal = _meal_appearance(p[11], p[22], t, mTG)

      [
        tg_from_meal - p[23] * u[10],
        p[23] * (u[10] - u[11]),
        p[23] * (u[11] - u[12])
      ]
    end

    # plasma TG
    du[13] = begin

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

  end

  return equations!
end