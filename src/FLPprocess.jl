module FLPprocess

using DataFrames
using Dates
using OrderedCollections
using ShiftedArrays
using CSV

#=
Remember to:
Pokes doesn't process anymore the file name to extract name etc, move this to process session
=#

include("utilities.jl")
include("create_DataIndex.jl")
include("process_pokes.jl")
include("process_bouts.jl")
include("process_streaks.jl")
include("process_session.jl")
include("process_dataset.jl")

export check_changes, count_same, count_different
export get_DataIndex, process_pokes, process_bouts, process_streaks, process_session, process_dataset

end # module
