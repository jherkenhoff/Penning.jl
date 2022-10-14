module Selections

export
    AbstractSelection,
    AbstractParticleSelection,
    AbstractSingleParticleSelection,
    AbstractMultiParticleSelection

export
    SingleParticleSelection

export
    get_particle_q,
    get_particle_m,
    get_particle_r,
    get_particle_v,
    get_particle_E,
    get_particle_B

abstract type AbstractSelection end

abstract type AbstractParticleSelection <: AbstractSelection end
abstract type AbstractSingleParticleSelection <: AbstractParticleSelection end
abstract type AbstractMultiParticleSelection <: AbstractParticleSelection end

include("single_particle_selection.jl")

end # module