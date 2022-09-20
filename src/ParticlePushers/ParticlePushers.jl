module ParticlePushers

using Penning.Setups
using Penning.Particles
using Penning.Traps

export
    AbstractParticlePusher,
    BorisPusher,
    ModifiedBorisPusher,
    initial_particle_push!,
    push_particles!

abstract type AbstractParticlePusher end

include("boris.jl")
include("boris_modified.jl")

function initial_particle_push!(pusher::AbstractParticlePusher, particle_collection::ParticleCollection, dt)
    for i in 1:N_particles(particle_collection)
        initial_particle_push!(pusher, 
            particle_collection.r[i],
            particle_collection.v[i],
            particle_collection.E[i],
            particle_collection.B[i],
            particle_collection.damping,
            particle_collection.species.q,
            particle_collection.species.m,
            dt
        )
    end
end

function initial_particle_push!(pusher::AbstractParticlePusher, trap::Trap, dt)
    for particle_collection in trap.particles
        initial_particle_push!(pusher, particle_collection, dt)
    end
end

function initial_particle_push!(pusher::AbstractParticlePusher, setup::Setup, dt)
    for trap in setup.traps
        initial_particle_push!(pusher, trap, dt)
    end
end

function push_particles!(pusher::AbstractParticlePusher, particle_collection::ParticleCollection, dt)
    for i in 1:N_particles(particle_collection)
        push_particle!(pusher, 
            particle_collection.r[i],
            particle_collection.v[i],
            particle_collection.E[i],
            particle_collection.B[i],
            particle_collection.damping,
            particle_collection.species.q,
            particle_collection.species.m,
            dt
        )
    end
end

function push_particles!(pusher::AbstractParticlePusher, trap::Trap, dt)
    for particle_collection in trap.particles
        push_particles!(pusher, particle_collection, dt)
    end
end

function push_particles!(pusher::AbstractParticlePusher, setup::Setup, dt)
    for trap in setup.traps
        push_particles!(pusher, trap, dt)
    end
end


end # module