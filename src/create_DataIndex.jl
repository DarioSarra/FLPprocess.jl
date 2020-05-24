"""
    get_data(dir::String; mouse_tag = nothing)

Read directory `dir` and make a list of all the csv files present.
Additionally if a `mouse_tag` is provided filter out all the files where the tag doesn't occur in the filename
"""
function get_data(dir; mouse_tag = nothing)
    f = readdir(dir)
    filter!(x -> occursin(".csv", x), f)
    if mouse_tag != nothing
        filter!(x -> occursin(mouse_tag,x), f)
    end
    return f
end

"""
    get_DataIndex(dir::String; mouse_tag = nothing)

Read and filters files in directory `dir` using `get_data` and extract informations from the filename in a DataFrame.
It returns a DataFrame with File path, Session, MouseID, Day, Turn.
"""
function get_DataIndex(dir; mouse_tag = nothing)
    f = get_data(dir;mouse_tag = mouse_tag)
    DataIndex = DataFrame(Path = joinpath.(dir,f), Session = replace.(f, ".csv"=>""))
    DataIndex.MouseID = [match(r"[a-zA-Z]{1,2}\d{1,2}",file).match for file in f]
    DataIndex.Day = Date.(["20" * match(r"\d{6}",file).match for file in f], "yyyymmdd")
    DataIndex.Turn = [file[end] for file in DataIndex.Session]
    return DataIndex
end
