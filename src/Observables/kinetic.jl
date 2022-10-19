
"""
    PositionObservable()
Defines an observable that returns the euclidian position vector of a particle.
"""
struct PositionObservable <: AbstractSingleParticleVectorObservable
end

function observe(observable::PositionObservable, selection::AbstractParticleSelection, setup::Setup)
    return get_particle_selection_r(selection, setup)
end

"""
    VelocityObservable()
Defines an observable that returns the euclidian velocity vector of a particle.
"""
struct VelocityObservable <: AbstractSingleParticleVectorObservable
end

function observe(observable::VelocityObservable, selection::AbstractParticleSelection, setup::Setup)
    return get_particle_selection_v(selection, setup)
end
