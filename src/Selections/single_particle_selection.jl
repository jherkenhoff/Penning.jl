using Penning.Setups

struct SingleParticleSelection{T, PC, PI} <: AbstractSingleParticleSelection
    trap :: T
    particle_collection :: PC
    particle_index :: PI
end

function SingleParticleSelection(;trap, particle_collection, particle_index)
    return SingleParticleSelection(trap, particle_collection, particle_index)
end

function get_particle_q(p::SingleParticleSelection, setup::Setup)
    return setup.traps[p.trap].particles[p.particle_collection].species.q
end

function get_particle_m(p::SingleParticleSelection, setup::Setup)
    return setup.traps[p.trap].particles[p.particle_collection].species.m
end

function get_particle_r(p::SingleParticleSelection, setup::Setup)
    return setup.traps[p.trap].particles[p.particle_collection].r[p.particle_index]
end

function get_particle_v(p::SingleParticleSelection, setup::Setup)
    return setup.traps[p.trap].particles[p.particle_collection].v[p.particle_index]
end

function get_particle_E(p::SingleParticleSelection, setup::Setup)
    return setup.traps[p.trap].particles[p.particle_collection].E[p.particle_index]
end

function get_particle_B(p::SingleParticleSelection, setup::Setup)
    return setup.traps[p.trap].particles[p.particle_collection].B[p.particle_index]
end