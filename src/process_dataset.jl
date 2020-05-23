"""
    process_dataset(DataIndex::AbstractDataFrame; exp_name = nothing)
    process_dataset(dir::String; mouse_tag = nothing, exp_name = nothing)

Given a DataIndex, for each file process and collect in a dataframe pokes, bouts and streaks.
It adds information about day of experiment and day of protocol for each animal.
The results are stored in a destination folder named Results followed by the current date inside `dir`.
If an experiment name is provided the Results folder will be created in a folder named`exp_name` located in the parent folder of `dir`.
If a path instead of a DataIndex is provided creates the DataIndex on its own.
"""
function process_dataset(DataIndex::AbstractDataFrame; exp_name = nothing)
    destination_dir = set_results_dir(DataIndex.Path[1], exp_name = exp_name)
    pokes = DataFrame()
    bouts = DataFrame()
    streaks = DataFrame()
    for i=1:size(DataIndex,1)
        filepath = DataIndex.Path[i]
        p,b,s = process_session(filepath)
        if isempty(pokes)
            pokes,bouts,streaks = p,b,s
        else
            append!(pokes, p)
            append!(bouts,b)
            append!(streaks, s)
        end
    end
    for (n,d) in zip(["pokes.csv","bouts.csv", "streaks.csv"], [pokes,bouts,streaks])
        filename = joinpath(destination_dir,n)
        CSV.write(filename,d)
    end
     return DataIndex, pokes, bouts, streaks
end

function process_dataset(dir::String; mouse_tag = nothing, exp_name = nothing)
    DataIndex = get_DataIndex(dir; mouse_tag = mouse_tag)
    process_dataset(DataIndex; exp_name = exp_name)
end
