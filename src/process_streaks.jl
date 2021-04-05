"""
    process_streaks(df::AbstractDataFrame; photometry = false)

Take as input a processed pokes datafame `df` of 1 single session and returns a dataframe were each row are information about a poking streak.
A poking streak ends when the animal changes side. For photometry data a set of other columns regarding indexes for traces allignment are computed.
"""

function process_streaks(df::AbstractDataFrame; photometry = false)
    vals_per_streak = [:Stim, :StimFreq, :Wall, :Protocol, :Block, :StreakInBlock, :Side, :ReverseStreak]
    vals_per_day = [:Box,:StimDay];
    booleans=[:Reward,:Stim,:Wall,:Correct,:StimDay]#columns to convert to Bool
    for x in booleans
        if x in propertynames(df)
            df[:,x] = eltype(df[:,x]) == Bool ? df[:,x] : occursin.("true",df[:,x],)
        end
    end
    streak_table = combine(groupby(df, :Streak)) do dd
        dt = DataFrame(
        Num_pokes = size(dd,1),
        Num_Rewards = length(findall(dd[!,:Reward].==1)),
        Start_Reward = dd[1,:Reward],
        Last_Reward = findlast(dd[!,:Reward] .== 1).== nothing ? 0 : findlast(dd[!,:Reward] .== 1),
        Prev_Reward = findlast(dd[!,:Reward] .== 1).== nothing ? 0 : findprev(dd[!,:Reward] .==1, findlast(dd[!,:Reward] .==1)-1),
        Trial_duration = (dd[end,:PokeOut]-dd[1,:PokeIn]),
        Start = (dd[1,:PokeIn]),
        Stop = (dd[end,:PokeOut]),
        PreInterpoke = size(dd,1) > 1 ? maximum(skipmissing(dd[!,:PreInterpoke])) : missing,
        PostInterpoke = size(dd,1) > 1 ? maximum(skipmissing(dd[!,:PostInterpoke])) : missing,
        CorrectStart = dd[1,:Correct],
        CorrectLeave = !dd[end,:Correct]
        )

        for v in vals_per_streak
            if v in propertynames(dd)
                dt[!,v] .= dd[1, v]
            end
        end

        return dt
    end
    streak_table[!,:Prev_Reward] = [x .== nothing ? 0 : x for x in streak_table[:,:Prev_Reward]]
    streak_table[!,:AfterLast] = streak_table[!,:Num_pokes] .- streak_table[!,:Last_Reward];
    streak_table[!,:BeforeLast] = streak_table[!,:Last_Reward] .- streak_table[!,:Prev_Reward].-1;
    prov = lead(streak_table[!,:Start],default = 0.0) .- streak_table[!,:Stop];
    streak_table[!,:Travel_to] = [x.< 0 ? 0 : x for x in prov]

    for v in vals_per_day
        if v in propertynames(df)
            streak_table[!,v] .= df[1, v]
        end
    end

    # for photometry datas a set of indexes are extracted to allign the data in the pokes dataframe
    # This indexes are to be reported in the streaks dataframe as well
    if photometry
        frames = combine(groupby(df, :Streak)) do dd
            dd = DataFrame(
            In = dd[1,:In],
            Out = dd[end,:Out],
            LR_In = findlast(dd[:Reward])==0 ? NaN : dd[findlast(dd[:Reward]),:In],
            LR_Out = findlast(dd[:Reward])==0 ? NaN : dd[findlast(dd[:Reward]),:Out]
            )
        end
        streak_table[:In] = frames[:In]
        streak_table[:Out] = frames[:Out]
        streak_table[:LR_In] = frames[:LR_In]
        streak_table[:LR_Out] = frames[:LR_Out]
    end

    return streak_table
end
