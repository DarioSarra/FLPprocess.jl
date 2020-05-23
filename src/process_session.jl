"""
    process_session(filepath::String)

Given a raw data file location it computes pokes, bouts and streaks dataframe adding informations about daily variables:
[:Session, :Day, :Turn, :MouseID, :Gen]
"""
function process_session(filepath::String)
    filename = splitpath(filepath)[end]
    Session = replace(filename, ".csv" => "")
    Day = Date("20" * match(r"\d{6}",filename).match, "yyyymmdd")
    Turn = Session[end]
    MouseID = match(r"[a-zA-Z]{1,2}\d{1,2}",filename).match
    Gen = gen(MouseID)
    p = process_pokes(filepath)
    b = process_bouts(p)
    s = process_streaks(p)
    for df in (p,b,s)
        for (n,v) in zip([:Session, :Day, :Turn, :MouseID, :Gen],[Session, Day, Turn, MouseID, Gen])
            df[!,n] .= v
        end
    end
    return p,b,s
end
