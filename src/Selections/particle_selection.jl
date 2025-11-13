using Penning.Setups

struct ParticleSelection{T, PC} <: AbstractParticleSelection
    trap :: T
    particle_index :: Integer
end

function ParticleSelection(;trap, particle_index::Integer)
    return ParticleSelection(trap, particle_index)
end

function get_particle_selection_q(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles.q[s.particle_index]
end

function get_particle_selection_m(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles.m[s.particle_index]
end

function get_particle_selection_r(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles.r[s.particle_index]
end

function get_particle_selection_v(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles.v[s.particle_index]
end

function get_particle_selection_E(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles.E[s.particle_index]
end

function get_particle_selection_B(s::ParticleSelection, setup::Setup)
    return setup.traps[s.trap].particles.B[s.particle_index]
end

function AllParticleSelection(setup::Setup)
    vec = Vector{ParticleSelection}()
    for (trap_index, trap) in pairs(setup.traps)
        for p_index in keys(trap.particles.r)
            push!(vec, ParticleSelection(trap_index, p_index))
        end
    end
    return vec
end
