
"""
    PositionObservable()
Defines an observable that returns the euclidian position vector of a particle.
"""
struct PositionObservable <: AbstractSingleParticleVectorObservable
end

function observe(observable::PositionObservable, selection::AbstractSingleParticleSelection, setup::Setup)
    return get_particle_r(selection, setup)
end


"""
    VelocityObservable()
Defines an observable that returns the euclidian velocity vector of a particle.
"""
struct VelocityObservable <: AbstractSingleParticleVectorObservable
end

function observe(observable::PositionObservable, selection::AbstractSingleParticleSelection, setup::Setup)
    return get_particle_v(selection, setup)
end
