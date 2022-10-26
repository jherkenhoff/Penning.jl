using Penning.Setups

struct ParticleSelection{T, PC} <: AbstractParticleSelection
    trap :: T
    particle_collection :: PC
    particle_index :: Integer
end

function ParticleSelection(;trap, particle_collection, particle_index::Integer)
    return ParticleSelection(trap, particle_collection, particle_index)
end

function get_particle_selection_q(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].species.q
end

function get_particle_selection_m(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].species.m
end

function get_particle_selection_r(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].r[s.particle_index]
end

function get_particle_selection_v(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].v[s.particle_index]
end

function get_particle_selection_E(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].E[s.particle_index]
end

function get_particle_selection_B(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles[s.particle_collection].B[s.particle_index]
end


function AllParticleSelection(setup::Setup)
    vec = Vector{ParticleSelection}()
    for (trap_index, trap) in pairs(setup.traps)
        for (pc_index, pc) in pairs(trap.particles)
            for p_index in keys(pc.r)
                push!(vec, ParticleSelection(trap_index, pc_index, p_index))
            end
        end
    end
    return vec
end
