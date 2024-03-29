"""
    process_bouts(df::AbstractDataFrame)

Take as input a processed pokes datafame `df` of 1 single session and returns a dataframe were each row are information about a poking bout.
A poking bout ends either when a reward occurs or the animal changes side
"""
function process_bouts(df::AbstractDataFrame)
    vals_per_bout = [:Stim, :StimFreq, :Wall, :Protocol, :Block, :StreakInBlock, :Side, :ReverseStreak]
    vals_per_day = [:Box,:StimDay];
    bout_table = combine(groupby(df, :Bout)) do dd
        dt = DataFrame(
        Omissions_plus_one = size(dd,1),
        Leave = dd[end,:Leave],
        Start_Reward = dd[1,:Reward],
        Side = dd[1,:Side],
        Stim = dd[1,:Stim],
        Trial_duration = (dd[end,:PokeOut]-dd[1,:PokeIn]),
        PreInterpoke = size(dd,1) > 1 ? maximum(skipmissing(dd[!,:PreInterpoke])) : missing,
        PostInterpoke = size(dd,1) > 1 ? maximum(skipmissing(dd[!,:PostInterpoke])) : missing,
        Wall = dd[1,:Wall],
        Correct_start = dd[1,:Correct],
        Block = dd[1,:Block],
        StreakInBlock = dd[1,:StreakInBlock],
        Streak = dd[1,:Streak],
        ReverseStreak = dd[1,:ReverseStreak],
        CorrectStart = dd[1,:Correct]
        )


        for v in vals_per_bout
            if v in propertynames(dd)
                dt[!,v] .= dd[1, v]
            end
        end

        return dt
    end

    for v in vals_per_day
        if v in propertynames(df)
            bout_table[!,v] .= df[1, v]
        end
    end

    return bout_table
end
