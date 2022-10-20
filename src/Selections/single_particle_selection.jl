using Penning.Setups

struct SingleParticleSelection{T, PC} <: AbstractSingleParticleSelection
    trap :: T
    particle_collection :: PC
    particle_index :: Integer
end

function SingleParticleSelection(;trap, particle_collection, particle_index::Integer)
    return SingleParticleSelection(trap, particle_collection, particle_index)
end

function get_particle_selection_q(s::SingleParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].species.q
end

function get_particle_selection_m(s::SingleParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].species.m
end

function get_particle_selection_r(s::SingleParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].r[s.particle_index]
end

function get_particle_selection_v(s::SingleParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].v[s.particle_index]
end

function get_particle_selection_E(s::SingleParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].E[s.particle_index]
end

function get_particle_selection_B(s::SingleParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].B[s.particle_index]
end