# utilities for opening CGM data 

# constants_file = "data/private/constants.csv"
# cgm_file = "data/private/ps020113-010821-cgm.csv"
# meal_file = "data/private/ps020113-010821-food.csv"

# constants = CSV.read(constants_file, DataFrame; delim=";", decimal=',')

using CSV, DataFrames, Dates

struct CGMData
  meal_times
  meal_glucose
  meal_tg
  glucose_times
  glucose_values
end

function CGMData(cgm::DataFrame, meals::DataFrame)
  start_time = Time(0)
  
  # parse cgm file

  # glucose times
  glucose_times = [x.value for x in round.(cgm[!,:Time] .- start_time, Minute)]

  # glucose data
  glucose_data_meter = cgm[!,:meter]
  glucose_data_sensor = cgm[!,:sensor]
  glucose_data = glucose_data_sensor

  # replace missing data from sensor with meter data
  glucose_data[ismissing.(glucose_data)] .= glucose_data_meter[ismissing.(glucose_data)]

  # convert to float 
  glucose_data = Float64.(glucose_data)

  # parse meal file

  # meal times
  meal_times = [x.value for x in round.(meals[!,:Tijdstip] .- start_time, Minute)]

  meal_tg = meals[!,:Vet_totaal_g].*1000 # convert to mg
  meal_glucose = meals[!,:Koolhydraten_totaal_g].*1000 # convert to mg

  return CGMData(meal_times, meal_glucose, meal_tg, glucose_times, glucose_data)
end

function CGMData(cgm_file::String, meal_file::String)
  cgm = CSV.read(cgm_file, DataFrame; delim=";", decimal = ',')
  meals = CSV.read(meal_file, DataFrame; delim=";", decimal=',')
  return CGMData(cgm, meals)
end