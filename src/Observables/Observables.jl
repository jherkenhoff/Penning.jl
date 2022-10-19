module Observables

using Penning.Selections
using Penning.Setups

export
    AbstractObservable,
    AbstractScalarObservable,
    AbstractVectorObservable,
    PositionObservable,
    VelocityObservable,
    EFieldObservable,
    BFieldObservable,
    ElectrodeVoltageObservable,
    ElectrodeCurrentObservable,
    SingleParticleTotalEnergy,
    VectorComponentObservable

export
    observe

abstract type AbstractObservable end

abstract type AbstractScalarObservable <: AbstractObservable end
abstract type AbstractVectorObservable <: AbstractObservable end

abstract type AbstractSingleParticleScalarObservable <: AbstractScalarObservable end
abstract type AbstractSingleParticleVectorObservable <: AbstractVectorObservable end

abstract type AbstractCollectiveParticleScalarObservable <: AbstractScalarObservable end
abstract type AbstractCollectiveParticleVectorObservable <: AbstractVectorObservable end

include("kinetic.jl")
include("energetic.jl")
include("electrode.jl")
include("field.jl")
include("vector_component_observable.jl")

end # module