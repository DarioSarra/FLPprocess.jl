"""
    iscolumn(df::AbstractDataFrame, col::Symbol)

Return true if `col` is in prepertynames of `df`
"""

function iscolumn(df::AbstractDataFrame, col::Symbol)
    col in propertynames(df)
end

"""
    check_changes(v::AbstractVector)

Given a vector it return a boolean vector of the same length checking if the i value is equal to the i-1 value. By default the first value is false
"""

function check_changes(v::AbstractVector)
    r = v .!= lag(v, default = :placeholder)
    r[1] = false
    return r
end

"""
    count_same(count::T, change) where {T <: Number}
    count_same(v:AbstractVector)

if `change` is false it adds 1 to `count` otherwise it returns exactly 1.
On a vector it is used in conjunction with accumulate to count consecutive same value on the vector `v`
and reset to 1 when a change occurs between `v[i]` and `v[i+1]`
"""

function count_same(count::T, change) where {T <: Number}
    if !change
        count+1
    else
        1
    end
end

function count_same(changes::BitArray)
    res = accumulate(count_same,changes;init=0)
    return res
end

"""
    count_different(count::T, same) where {T <: Number}
    count_same(v:AbstractVector)

if `change` is true it adds 1 to `count` otherwise it returns exactly 1.
On a vector it is used in conjunction with accumulate to count progress a count when `v[i]` is different than `v[i-1]`
"""

function count_different(count::T, change) where {T <: Number}
    if change
        count+1
    else
        count
    end
end

function count_different(changes::BitArray)
    res = accumulate(count_different,changes;init=1)
    return res
end

"""
    `get_hierarchy(v)`
Return a vector indicating how many consecutive falses or trues
preceded an event
"""

function nextcount(count::T, rewarded) where {T <: Number}
    if rewarded
        count > 0 ? count + 1 : one(T)
    else
        count < 0 ? count - 1 : -one(T)
    end
end
signedcount(v::AbstractArray{Bool}) = accumulate(nextcount, v;init = 0)
get_hierarchy(v) = lag(signedcount(v), default = 0)

"""
    gen(mouse::String; dir = joinpath(dirname(@__DIR__), "genotypes"))

Given an animal name `mouse` look in the genotypes folder for a match.
Returns a string indicating the genotype if a match is found otherwise `missing`
"""
function gen(mouse::AbstractString; dir = joinpath(dirname(@__DIR__), "genotypes"))
    genotype = "missing"
    for file in readdir(dir)
        if endswith(file, ".csv")
            df = CSV.read(joinpath(dir, file)) |> DataFrame
            n = names(df)[1]
            if mouse in df[!,n]
                genotype = string(n)
            end
        end
    end
    genotype
end

"""
    set_results_dir(path::AbstractString; exp_name = nothing)

Given a `path` create a directory where to store results of raw data processing.
The  destination folder is named Results followed by the current date inside `dir`.
If `path` is a file the Results folder will be created in its parent directory.
If an experiment name is provided the Results folder will be created in a folder named`exp_name` located in the parent folder 1 level above.
"""
function set_results_dir(path::AbstractString; exp_name = nothing)
    if isfile(path)
        dir = dirname(path)
    elseif isdir(path)
        dir = path
    else
        error("couldn't resolve path destination")
    end
    results_dir = "Results_" * string(today())
    if exp_name != nothing
        parent_dir = dirname(dir)
        destination_dir = joinpath(parent_dir,exp_name,results_dir)
    else
        destination_dir = joinpath(dir, results_dir)
    end
    if !isdirpath(destination_dir)
        mkpath(destination_dir)
    end
    return destination_dir
end
