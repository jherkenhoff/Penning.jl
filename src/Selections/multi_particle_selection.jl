using Penning.Setups

struct MultiParticleSelection <: AbstractParticleSelection
    vec :: Vector{SingleParticleSelection}
end

function MultiParticleSelection(vec::AbstractVector{SingleParticleSelection})
    return MultiParticleCollection(vec)
end

Base.iterate(s::MultiParticleSelection) = iterate(s.vec)
Base.iterate(s::MultiParticleSelection, state) = iterate(s.vec, state)
Base.length(s::MultiParticleSelection) = length(s.vec)


function AllParticleSelection(setup::Setup)
    vec = []
    for (trap_index, trap) in pairs(setup.traps)
        for (pc_index, pc) in pairs(trap.particles)
            for p_index in keys(pc.r)
                push!(vec, SingleParticleSelection(trap_index, pc_index, p_index))
            end
        end
    end
    return MultiParticleSelection(vec)
end

function get_particle_selection_q(s::MultiParticleSelection, setup::Setup)
    return get_particle_selection_q.(s, (setup,))
end

function get_particle_selection_m(s::MultiParticleSelection, setup::Setup)
    return get_particle_selection_m.(s, (setup,))
end

function get_particle_selection_r(s::MultiParticleSelection, setup::Setup)
    return get_particle_selection_r.(s, (setup,))
end

function get_particle_selection_v(s::MultiParticleSelection, setup::Setup)
    return get_particle_selection_v.(s, (setup,))
end

function get_particle_selection_E(s::MultiParticleSelection, setup::Setup)
    return get_particle_selection_E.(s, (setup,))
end

function get_particle_selection_B(s::MultiParticleSelection, setup::Setup)
    return get_particle_selection_B.(s, (setup,))
end