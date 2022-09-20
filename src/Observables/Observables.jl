module Observables

export
    AbstractObservable,
    AbstractScalarObservable,
    AbstractVectorObservable,
    PositionObservable,
    PositionComponentObservable,
    VelocityObservable,
    VelocityComponentObservable,
    ElectrodeVoltageObservable,
    SingleParticleTotalEnergy

abstract type AbstractObservable end

abstract type AbstractScalarObservable <: AbstractObservable end
abstract type AbstractVectorObservable <: AbstractObservable end

include("kinetic.jl")
include("energetic.jl")
include("circuit.jl")

end # module