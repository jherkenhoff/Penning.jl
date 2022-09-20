# Copied and modified from https://github.com/CliMA/Oceananigans.jl/blob/main/src/Utils/prettytime.jl

using Printf
using Dates: AbstractTime

maybe_int(t) = isinteger(t) ? Int(t) : t

"""
    prettytime(t, longform=true)
Convert a floating point value `t` representing an amount of time in
SI units of seconds to a human-friendly string with three decimal places.
Depending on the value of `t` the string will be formatted to show `t` in
nanoseconds (ns), microseconds (μs), milliseconds (ms),
seconds, minutes, hours, days, or years.
With `longform=false`, we use s, m, hrs, d, and yrs in place of seconds,
minutes, hours, and years.
"""
function prettytime(t, longform=true)
    # Modified from: https://github.com/JuliaCI/BenchmarkTools.jl/blob/master/src/trials.jl
    
    # Some shortcuts
    s = longform ? "seconds" : "s" 
    iszero(t) && return "0 $s"
    t < 1e-9 && return @sprintf("%.3e %s", t, s) # yah that's small

    t = maybe_int(t)
    value, units = prettytimeunits(t, longform)

    if isinteger(value)
        return @sprintf("%d %s", value, units)
    else
        return @sprintf("%.3f %s", value, units)
    end
end

function prettytimeunits(t, longform=true)
    t < 1e-9 && return t * 1e12, "ps"
    t < 1e-6 && return t * 1e9, "ns"
    t < 1e-3 && return t * 1e6, "μs"
    t < 1    && return t * 1e3, "ms"
    if t < 60
        value = t
        !longform && return value, "s"
        units = value == 1 ? "second" : "seconds"
        return value, units
    elseif t < 60*60
        value = maybe_int(t / 60)
        !longform && return value, "m"
        units = value == 1 ? "minute" : "minutes"
        return value, units
    elseif t < 60*24
        value = maybe_int(t / 60*60)
        units = value == 1 ? (longform ? "hour" : "hr") :
                             (longform ? "hours" : "hrs")
        return value, units
    elseif t < 60*24*365
        value = maybe_int(t / 60*24)
        !longform && return value, "d"
        units = value == 1 ? "day" : "days"
        return value, units
    else
        value = maybe_int(t / 60*24*365)
        units = value == 1 ? (longform ? "year" : "yr") :
                             (longform ? "years" : "yrs")
        return value, units
    end
end

prettytime(dt::AbstractTime) = "$dt"