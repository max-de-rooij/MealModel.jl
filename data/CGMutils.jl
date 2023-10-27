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

"""
Process CGM data.

Arguments:
* `cgm_file` : file path to cgm data (CSV)
* `meal_file`: file path to meal data (CSV)

Keyword arguments:
* `glucose_meter_column` : column for the glucose meter data (mmol/L)
* `glucose_sensor_column` : column for the glucose sensor data (mmol/L)
* `glucose_time_column` : column for the glucose time (timestamp)
* `meals_tg_column` : column for tg in meal (g)
* `meals_glucose_column` : column for glucose in meal (g)
* `meals_time_column` : column for meal time (timestamp)
* `start_time_use` : time to use as start time for the data (defaults to 00:00:00)
"""
function CGMData(cgm_file::String, meal_file::String;
  glucose_meter_column = :meter, 
  glucose_sensor_column = :sensor,
  glucose_time_column = :Time,
  meals_tg_column = :Vet_totaal_g,
  meals_glucose_column = :Koolhydraten_totaal_g,
  meals_time_column = :Tijdstip,
  start_time_use = Time(0))
  cgm = CSV.read(cgm_file, DataFrame; delim=";", decimal = ',')
  meals = CSV.read(meal_file, DataFrame; delim=";", decimal=',')
  return CGMData(cgm, meals, glucose_meter_column, glucose_sensor_column, glucose_time_column, meals_tg_column, meals_glucose_column, meals_time_column; start_time_use=start_time_use)
end


function CGMData(cgm::DataFrame, meals::DataFrame, glucose_meter_column::Symbol,
  glucose_sensor_column::Symbol, glucose_time_column::Symbol, meals_tg_column::Symbol,
  meals_glucose_column::Symbol, meals_time_column::Symbol; start_time_use = Time(0))

  start_time = start_time_use
  
  # parse cgm file

  # glucose times
  glucose_times = [x.value for x in round.(cgm[!,glucose_time_column] .- start_time, Minute)]

  # glucose data
  glucose_data_meter = cgm[!,glucose_meter_column]
  glucose_data_sensor = cgm[!,glucose_sensor_column]
  glucose_data = glucose_data_sensor

  # replace missing data from sensor with meter data
  glucose_data[ismissing.(glucose_data)] .= glucose_data_meter[ismissing.(glucose_data)]

  # convert to float 
  glucose_data = Float64.(glucose_data)

  # parse meal file

  # meal times
  meal_times = [x.value for x in round.(meals[!,meals_time_column] .- start_time, Minute)]

  meal_tg = meals[!,meals_tg_column].*1000 # convert to mg
  meal_glucose = meals[!,meals_glucose_column].*1000 # convert to mg

  return CGMData(meal_times, meal_glucose, meal_tg, glucose_times, glucose_data)
end


