
function process_bouts(p::DataFrames.AbstractDataFrame)
    dayly_vars_list = [:Box,:Protocol,:Stim_Day];
    bout_table = combine(groupby(df, :Bout)) do dd
        dt = DataFrame(
        Omissions_plus_one = size(dd,1),
        Leave = dd[end,:Leave],
        Start_Reward = dd[1,:Reward],
        Side = dd[1,:Side],
        Stim = dd[1,:Stim],
        Trial_duration = (dd[end,:PokeOut]-dd[1,:PokeIn]),
        Pre_Interpoke = size(dd,1) > 1 ? maximum(skipmissing(dd[!,:Pre_Interpoke])) : missing,
        Post_Interpoke = size(dd,1) > 1 ? maximum(skipmissing(dd[!,:Post_Interpoke])) : missing,
        Wall = dd[1,:Wall],
        Correct_start = dd[1,:Correct],
        Block = dd[1,:Block],
        Streak_within_Block = dd[1,:Streak_within_Block],
        Streak = dd[1,:Streak],
        ReverseStreak = dd[1,:ReverseStreak]
        )
        for s in dayly_vars_list
            if s in names(df)
                dt[!,s] .= df[1, s]
            end
        end
        return dt
    end
    return bout_table
end
