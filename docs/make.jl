using MealModel
using Documenter

DocMeta.setdocmeta!(MealModel, :DocTestSetup, :(using MealModel); recursive=true)

makedocs(;
    modules=[MealModel],
    authors="Max de Rooij",
    repo="https://github.com/max-de-rooij/MealModel.jl/blob/{commit}{path}#{line}",
    sitename="MealModel.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://max-de-rooij.github.io/MealModel.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/max-de-rooij/MealModel.jl",
    devbranch="main",
)
