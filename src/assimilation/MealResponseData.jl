abstract type MealResponseData end

struct TimedVector{T<:Real}
  values::AbstractVector{T}
  timepoints::AbstractVector{T}
end

TimedVector(values::AbstractVector{<:Real}, timepoints::AbstractVector{<:Real}) = TimedVector(promote(values, timepoints)...)


# complete meal response
struct CompleteMealResponse{T<:Real} <: MealResponseData
  glucose::TimedVector{T}
  insulin::TimedVector{T}
  tg::TimedVector{T}
  nefa::TimedVector{T}
  timepoints::AbstractVector{T}
end

struct PartialMealResponse{T<:Real} <: MealResponseData
  glucose::TimedVector{T}
  insulin::TimedVector{T}
  tg::TimedVector{T}
  timepoints::AbstractVector{T}
end

_get_timepoints(args...) = promote(sort(unique([arg.timepoints for arg in args])))

CompleteMealResponse(glucose::TimedVector{<:Real}, insulin::TimedVector{<:Real}, 
  tg::TimedVector{<:Real}, nefa::TimedVector{<:Real}) = begin 
    timepoints = _get_timepoints(glucose, insulin, tg, nefa)
    CompleteMealResponse(promote(glucose, insulin, tg, nefa, timepoints)...,)
  end

function _get_time_indices(d::CompleteMealResponse, times)
  [findall(x -> x ∈ d.glucose.timepoints, times),
   findall(x -> x ∈ d.insulin.timepoints, times),
   findall(x -> x ∈ d.tg.timepoints, times),
   findall(x -> x ∈ d.nefa.timepoints, times)]
end

function _get_time_indices(d::PartialMealResponse, times)
  [findall(x -> x ∈ d.glucose.timepoints, times),
   findall(x -> x ∈ d.insulin.timepoints, times),
   findall(x -> x ∈ d.tg.timepoints, times)]
end

PartialMealResponse(glucose::TimedVector{<:Real}, insulin::TimedVector{<:Real}, 
  tg::TimedVector{<:Real}) = begin
    timepoints = _get_timepoints(glucose, insulin, tg)
    PartialMealResponse(promote(glucose, insulin, tg, timepoints)...)
  end
