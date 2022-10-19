module Selections

export
    AbstractSelection,
    AbstractParticleSelection,
    AbstractElectrodeSelection

export
    SingleParticleSelection,
    MultiParticleSelection,
    AllParticleSelection,
    ElectrodeSelection

export
    get_particle_selection_q,
    get_particle_selection_m,
    get_particle_selection_r,
    get_particle_selection_v,
    get_particle_selection_E,
    get_particle_selection_B

abstract type AbstractSelection end
abstract type AbstractParticleSelection <: AbstractSelection end
abstract type AbstractElectrodeSelection <: AbstractSelection end

include("single_particle_selection.jl")
include("multi_particle_selection.jl")
include("electrode_selection.jl")

end # module