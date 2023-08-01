abstract type MealResponseData end

struct TimedVector{T<:Real}
  values::AbstractVector{T}
  timepoints::AbstractVector{T}
end

TimedVector(values::AbstractVector{<:Real}, timepoints::AbstractVector{<:Real}) = length(values) == length(timepoints) ? TimedVector(promote(values, timepoints)...) : throw(ErrorException("Values and Timepoints should have equal lengths!"))


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

_get_timepoints(args...) = sort(unique(
  reduce(vcat, [arg.timepoints for arg in args])
))

CompleteMealResponse(glucose::TimedVector{<:Real}, insulin::TimedVector{<:Real}, 
  tg::TimedVector{<:Real}, nefa::TimedVector{<:Real}) = begin 
    timepoints = _get_timepoints(glucose, insulin, tg, nefa)
    CompleteMealResponse(glucose, insulin, tg, nefa, timepoints)
  end

function _get_time_indices(d::CompleteMealResponse, times)
  reduce(vcat, [findall(x -> x ∈ d.glucose.timepoints, times),
   findall(x -> x ∈ d.insulin.timepoints, times),
   findall(x -> x ∈ d.tg.timepoints, times),
   findall(x -> x ∈ d.nefa.timepoints, times)])
end

function _get_time_indices(d::PartialMealResponse, times)
  reduce(vcat, [findall(x -> x ∈ d.glucose.timepoints, times),
   findall(x -> x ∈ d.insulin.timepoints, times),
   findall(x -> x ∈ d.tg.timepoints, times)])
end

PartialMealResponse(glucose::TimedVector{<:Real}, insulin::TimedVector{<:Real}, 
  tg::TimedVector{<:Real}) = begin
    timepoints = _get_timepoints(glucose, insulin, tg)
    PartialMealResponse(glucose, insulin, tg, timepoints)
  end
