using MealModel
using Test
using Plots

global figure_store = "../temp/figure_store"
global data_store = "../temp/data_store"

# single subject simulation
function define_model()
    
    MixedMealModel()
    true
end

function run_model_simulation()

    model = MixedMealModel()
    output(model)
    true
end

# local test to check if plots make sense. not used anymore
# function plot_output()

#     model = MixedMealModel()
#     outputs = output(model)
#     plot_collection = []
#     for key in keys(outputs)[2:end] # skip the time key
#         pl = plot(outputs.time, outputs[key], title=string(key), titlefontsize=6)
#         push!(plot_collection, pl)
#     end

#     try
#         savefig(plot(plot_collection...), joinpath(figure_store, "test_plot.png"))
#     catch
#         println("Figure couldn't be saved, but plotting went well.")
#     end

#     true
# end
        



@testset "MealModel.jl" begin
    @test define_model()
    @test run_model_simulation()
end
