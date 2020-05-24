# FLPprocess

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://DarioSarra.github.io/FLPprocess.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://DarioSarra.github.io/FLPprocess.jl/dev)
[![Build Status](https://travis-ci.com/DarioSarra/FLPprocess.jl.svg?branch=master)](https://travis-ci.com/DarioSarra/FLPprocess.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/DarioSarra/FLPprocess.jl?svg=true)](https://ci.appveyor.com/project/DarioSarra/FLPprocess-jl)
[![Codecov](https://codecov.io/gh/DarioSarra/FLPprocess.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/DarioSarra/FLPprocess.jl)
[![Coveralls](https://coveralls.io/repos/github/DarioSarra/FLPprocess.jl/badge.svg?branch=master)](https://coveralls.io/github/DarioSarra/FLPprocess.jl?branch=master)
[![Build Status](https://api.cirrus-ci.com/github/DarioSarra/FLPprocess.jl.svg)](https://cirrus-ci.com/github/DarioSarra/FLPprocess.jl)

Raw data search and processing tools for the [Flipping Task](https://doi.org/10.1016/j.neuron.2020.01.017) in the [Systems Neuroscience lab](https://www.fchampalimaud.org/researchfc/groups/grupo-systems-neuroscience) at the Champalimaud Foundation, Portugal.

## Usage

### Process
The main process function is

```
DataIndex, Pokes, Bouts, Streaks = process_dataset(dir::String; mouse_tag = nothing, exp_name = nothing)
```

Process pokes, bouts and streaks dataframes for all data raw data found in the
directory `dir` and stores them in a folder called Results followed by the
current date. Returns a `Tuple` with 4 `DataFrame` in the following order:
#### DataIndex
each row contains information about a file: Path, Session, MouseID, Day, Turn
#### Pokes
each row contains information about a single poke
#### Bouts
A bout is defined as a series of consecutive pokes until either a reward is
delivered or if the animal changes side.
#### Streaks
A streak is defined as a series of consecutive poke on the same side.

* `mouse_tag`: a string to filter the file to process according to a label.

* `exp_name`: if a `String` is provided the Results folder will be created
in a folder named `exp_name` located in the parent folder of `dir`.

Alternatively the index of raw data to be processed can be created separately
```
process_dataset(DataIndex::AbstractDataFrame; exp_name = nothing)
```
see `get_DataIndex`

### Search
The main search function is `get_DataIndex`

```
get_DataIndex(dir::String; mouse_tag = nothing)
```
Read all .csv files in directory `dir` and extract informations from the
filename.
It returns a DataFrame with File path, Session, MouseID, Day, Turn.


* `mouse_tag`: a string to filter the results according to a label.
