module Observables

using Penning.Selections
using Penning.Setups

export
    AbstractObservable,
    AbstractScalarObservable,
    AbstractVectorObservable,
    PositionObservable,
    VelocityObservable,
    KineticEnergyObservable,
    EFieldObservable,
    BFieldObservable,
    ElectrodeVoltageObservable,
    ElectrodeCurrentObservable,
    CircuitPinVoltageObservable,
    CircuitPinCurrentObservable,
    SingleParticleTotalEnergy,
    VectorComponentObservable,
    VectorNormObservable

export
    observe

abstract type AbstractObservable end

abstract type AbstractScalarObservable <: AbstractObservable end
abstract type AbstractVectorObservable <: AbstractObservable end

abstract type AbstractSingleParticleScalarObservable <: AbstractScalarObservable end
abstract type AbstractSingleParticleVectorObservable <: AbstractVectorObservable end

abstract type AbstractMultiParticleScalarObservable <: AbstractScalarObservable end
abstract type AbstractMultiParticleVectorObservable <: AbstractVectorObservable end

"""
    observe(obs, selection, setup)

Returns the value of an observable `obs` of a given `selection`.

The returned type depends on the specific observable.
"""
function observe(obs::AbstractObservable, selection::AbstractSelection, setup::Setup)
    error("Function `observe` is not implemented for observable $(typeof(obs)) and selection $(typeof(selection)).")
end

include("kinetic.jl")
include("energetic.jl")
include("electrode.jl")
include("circuit.jl")
include("field.jl")
include("higher_order_observables/vector_norm_observable.jl")
include("higher_order_observables/vector_component_observable.jl")

end # module