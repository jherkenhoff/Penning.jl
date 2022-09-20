using Penning.Setups

struct PositionObservable <: AbstractVectorObservable
    trap :: Symbol
    particle_collection :: Symbol
    particle_index :: Integer
end

function (obs::PositionObservable)(setup::Setup)
    return setup.traps[obs.trap].particles[obs.particle_collection].r[obs.particle_index]
end




struct PositionComponentObservable{T, PC} <: AbstractScalarObservable
    trap :: T
    particle_collection :: PC
    particle_index :: Integer
    component :: Integer
end

function (obs::PositionComponentObservable)(setup::Setup)
    return setup.traps[obs.trap].particles[obs.particle_collection].r[obs.particle_index][obs.component]
end




struct VelocityObservable <: AbstractVectorObservable
    trap :: Symbol
    particle_collection :: Symbol
    particle_index :: Integer
end

function (obs::VelocityObservable)(setup::Setup)
    return setup.traps[obs.trap].particles[obs.particle_collection].v[obs.particle_index]
end




struct VelocityComponentObservable <: AbstractScalarObservable
    trap :: Symbol
    particle_collection :: Symbol
    particle_index :: Integer
    component :: Integer
end

function (obs::VelocityComponentObservable)(setup::Setup)
    return setup.traps[obs.trap].particles[obs.particle_collection].v[obs.particle_index][obs.component]
end

