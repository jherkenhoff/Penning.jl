module Fields

export
    AbstractField,
    IdealTrapField,
    DipolarExcitationField,
    QuadrupolarExcitationField,
    PlaneWaveExcitationField,
    calc_E_field,
    set_E_field!,
    add_E_field!,
    calc_B_field,
    set_B_field!,
    add_B_field!

abstract type AbstractField end

include("traps/ideal_trap.jl")
include("excitations/dipolar.jl")
include("excitations/quadrupolar.jl")
include("excitations/cavity_TE.jl")
include("excitations/cavity_TM.jl")
include("excitations/plane_wave.jl")

end # module