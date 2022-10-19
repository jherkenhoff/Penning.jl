
"""
    EFieldObservable()
Defines an observable that returns the E-field vector.
"""
struct EFieldObservable <: AbstractSingleParticleVectorObservable
end

function observe(observable::EFieldObservable, selection::AbstractParticleSelection, setup::Setup)
    return get_particle_selection_E(selection, setup)
end

"""
    BFieldObservable()
Defines an observable that returns the B-field vector.
"""
struct BFieldObservable <: AbstractSingleParticleVectorObservable
end

function observe(observable::BFieldObservable, selection::AbstractParticleSelection, setup::Setup)
    return get_particle_selection_B(selection, setup)
end


