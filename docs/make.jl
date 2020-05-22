using Documenter, FLPprocess

makedocs(;
    modules=[FLPprocess],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/DarioSarra/FLPprocess.jl/blob/{commit}{path}#L{line}",
    sitename="FLPprocess.jl",
    authors="DarioSarra",
    assets=String[],
)

deploydocs(;
    repo="github.com/DarioSarra/FLPprocess.jl",
)
