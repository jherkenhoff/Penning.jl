using Printf

"""
prettyfrequency(f)
Convert a floating point value `f` representing a frequency in
SI units of Hz to a human-friendly string with three decimal places.
"""
function prettyfrequency(f::Number)
    iszero(f) && return "0 Hz"

    f >= 1e12 && return @sprintf("%.3f THz", f/1e12)
    f >= 1e9 && return @sprintf("%.3f GHz", f/1e9)
    f >= 1e6 && return @sprintf("%.3f MHz", f/1e6)
    f >= 1e3 && return @sprintf("%.3f kHz", f/1e3)
    f >= 1e-1 && return @sprintf("%.3f Hz", f)

    return @sprintf("%.3f Hz", f)
end