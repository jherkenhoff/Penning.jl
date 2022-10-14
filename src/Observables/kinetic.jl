

struct PositionObservable <: AbstractSingleParticleVectorObservable
end

function observe(observable::PositionObservable, selection::AbstractSingleParticleSelection, setup::Setup)
    return get_particle_r(selection, setup)
end



struct PositionComponentObservable <: AbstractSingleParticleScalarObservable
    component :: Integer
end

function observe(observable::PositionComponentObservable, selection::AbstractSingleParticleSelection, setup::Setup)
    return get_particle_r(selection, setup)[observable.component]
end




# struct VelocityObservable <: AbstractSingleParticleVectorObservable
#     trap :: Symbol
#     particle_collection :: Symbol
#     particle_index :: Integer
# end

# function (obs::VelocityObservable)(setup::Setup)
#     return setup.traps[obs.trap].particles[obs.particle_collection].v[obs.particle_index]
# end




# struct VelocityComponentObservable <: AbstractSingleParticleScalarObservable
#     trap :: Symbol
#     particle_collection :: Symbol
#     particle_index :: Integer
#     component :: Integer
# end

# function (obs::VelocityComponentObservable)(setup::Setup)
#     return setup.traps[obs.trap].particles[obs.particle_collection].v[obs.particle_index][obs.component]
# end