module Selections

export
    AbstractSelection,
    AbstractParticleSelection,
    AbstractSingleParticleSelection,
    AbstractMultiParticleSelection,
    AbstractElectrodeSelection,
    AbstractCircuitPinSelection

export
    SingleParticleSelection,
    MultiParticleSelection,
    AllParticleSelection,
    ElectrodeSelection,
    CircuitPinSelection

export
    get_particle_selection_q,
    get_particle_selection_m,
    get_particle_selection_r,
    get_particle_selection_v,
    get_particle_selection_E,
    get_particle_selection_B,
    get_electrode_selection_voltage,
    get_electrode_selection_current,
    set_electrode_selection_voltage!,
    set_electrode_selection_current!,
    get_circuit_pin_selection_voltage,
    get_circuit_pin_selection_current,
    set_circuit_pin_selection_voltage!,
    set_circuit_pin_selection_current!

abstract type AbstractSelection end
abstract type AbstractParticleSelection <: AbstractSelection end
abstract type AbstractSingleParticleSelection <: AbstractParticleSelection end
abstract type AbstractMultiParticleSelection <: AbstractParticleSelection end
abstract type AbstractElectrodeSelection <: AbstractSelection end
abstract type AbstractCircuitPinSelection <: AbstractSelection end

include("single_particle_selection.jl")
include("multi_particle_selection.jl")
include("electrode_selection.jl")
include("circuit_pin_selection.jl")

end # module