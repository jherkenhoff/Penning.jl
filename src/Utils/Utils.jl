module Utils

export cylindrical2cartesian, cartesian2cylindrical, cylindrical_unit_vectors
export prettytime
export prettysummary
export prettykeys
export dict_show
export safe_divide
export AbstractSchedule, TimeInterval, AlignedTimeInterval, IterationInterval, WallTimeInterval, SpecifiedTimes, ConsecutiveIterations, AndSchedule, OrSchedule
export harminv
export prettyfrequency
export calc_omega_z
export calc_omega_c
export calc_omega_p
export calc_omega_m
export calc_eigenfrequencies

include("coordinate_transforms.jl")
include("ideal_penning_trap.jl")
include("prettytime.jl")
include("prettysummary.jl")
include("prettyfrequency.jl")
include("schedules.jl")
include("dict_show.jl")
include("harminv.jl")
include("Bessel/Bessel.jl")

# http://sepwww.stanford.edu/sep/prof/pvi/uni/paper_html/node19.html
safe_divide(x, y) = x*y/(y^2+eps()^2)

end