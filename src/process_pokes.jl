"""
    process_pokes(filepath::String)

Given a path of flipping data it preprocess the main variables such as Trial and Block. To deal with the different formats of raw data
collect over the year it checks the presence of a set of preexisting column
"""

function process_pokes(filepath::String)
    df = CSV.read(filepath, DataFrame)
    if !iscolumn(df,:Poke)
        DataFrames.rename!(df, propertynames(df)[1] => :Poke) #change poke counter name
    end
    if iscolumn(df,:delta)
        DataFrames.rename!(df, :delta => :Delta)
    end
    df[!,:Poke] = df[!,:Poke].+1
    start_time = df[1,:PokeIn]
    df[!,:PokeIn] = df[!,:PokeIn] .- start_time
    df[!,:PokeOut] = df[!,:PokeOut] .- start_time
    df[!,:PokeDur] = df[!,:PokeOut] - df[!,:PokeIn]
    if !iscolumn(df,:Wall)
        df[:,:Wall] = zeros(size(df,1))
    end
    booleans=[:Reward,:Side,:SideHigh,:Stim,:Wall]#columns to convert to Bool
    for x in booleans
        if df[1,x] isa AbstractString
                df[!,x] = parse.(Bool,df[!,x])
        elseif df[1,x] isa Real
            df[!,x] = Bool.(df[:,x])
        end
    end
    df[!,:Side] = [a ? "L" : "R" for a in df[!,:Side]]
    if iscolumn(df,:ProbVec0)
        integers=[:Protocollo,:ProbVec0,:ProbVec1,:GamVec0,:GamVec1,:Delta]; #columns to convert to Int64
        for x in integers
            df[!,x] = Int64.(df[!,x])
        end
        df[!,:Protocol] = [r.Protocollo == 0 ? string(r.ProbVec0,"/",r.GamVec0) : string(r.ProbVec1,"/",r.GamVec1) for r in eachrow(df)]
        for x in[:ProbVec0,:ProbVec1,:GamVec0,:GamVec1,:Protocollo]
            DataFrames.select!(df,DataFrames.Not(x))
        end
        if !iscolumn(df,:StimFreq)
            df[!,:StimFreq] .= 10000
        end
        df[!,:StimFreq] = [a == 10000 ? 25 : a  for a in df[!,:StimFreq]]
        df[!,:Box] .= "Box0"
    elseif iscolumn(df,:Prwd)
        df[!,:Protocol] = string.(df[!,:Prwd],'/',df[!,:Ptrs])
        df[!,:Box] = "Box".*string.(df[:,:Box])
    end
    df[!,:StimDay] .= length(findall(df[:,:Stim])) == 0 ? false : true
    df[!,:Leave] = lead(check_changes(df[:,:Side]), default = false)
    df[!,:Bout] = count_different(df.Reward .| check_changes(df.Side))
    df[!,:Streak] = count_different(check_changes(df[:,:Side]))
    df[!,:ReverseStreak] = reverse(df[:,:Streak])
    df[!,:PokeInStreak] .= 0
    df[!,:PokeHierarchy] .= 0.0
    df[!,:PokeInStreak] = Vector{Union{Float64,Missing}}(undef,size(df,1))
    df[!,:PreInterpoke] = Vector{Union{Float64,Missing}}(undef,size(df,1))
    df[!,:PostInterpoke] = Vector{Union{Float64,Missing}}(undef,size(df,1))
    combine(groupby(df,:Streak)) do dd
        dd[:,:PokeInStreak] = count_different(check_changes(dd[!,:Poke]))
        dd[:,:PreInterpoke] =  dd[!,:PokeIn] .-lag(dd[!,:PokeOut],default = missing)
        dd[:,:PostInterpoke] = lead(dd[!,:PokeIn],default = missing).- dd[!,:PokeOut]
        dd[:,:PokeHierarchy] = get_hierarchy(dd[!,:Reward])
    end
    df[!,:Block] = count_different(check_changes(df[!,:Wall]))
    df[!,:StreakInBlock] .= 0
    combine(groupby(df,:Block)) do dd
        dd[:,:StreakInBlock] = count_different(check_changes(dd[!,:Side]))
    end
    df[!,:SideHigh] = [x ? "L" : "R" for x in df[!,:SideHigh]]
    df[!,:Correct] = df[!,:Side] .== df[!,:SideHigh]
    return df[:, [:Poke,:Side,:SideHigh, :Correct,
    :Reward, :PokeHierarchy, :PokeInStreak,
    :Leave, :Bout, :Streak, :Stim, :StimFreq, :Wall, :Block, :StreakInBlock,
    :Delta, :Protocol, :Box, :StimDay,
    :PokeIn, :PokeOut, :PokeDur, :PreInterpoke, :PostInterpoke,:ReverseStreak]]
end
