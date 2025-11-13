module ParticlePushers

using Penning.Setups
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

function initial_particle_push!(pusher::AbstractParticlePusher, setup::Setup, dt)
    for trap in setup.traps
        initial_particle_push!(pusher, trap.particles, dt)
    end
end

function initial_particle_push!(pusher::AbstractParticlePusher, particles::Particles, dt)
    for i in 1:N_particles(particles)
        initial_particle_push!(pusher,
            view(particles.r, :, i),
            view(particles.v, :, i),
            view(particles.E, :, i),
            view(particles.B, :, i),
            particles.q[i],
            particles.m[i],
            dt
        )
    end
end

function push_particles!(pusher::AbstractParticlePusher, setup::Setup, dt)
    for trap in setup.traps
        push_particles!(pusher, trap.particles, dt)
    end
end

function push_particles!(pusher::AbstractParticlePusher, particles::Particles, dt)
    for i in 1:N_particles(particles)
        push_particle!(pusher,
            view(particles.r, :, i),
            view(particles.v, :, i),
            view(particles.E, :, i),
            view(particles.B, :, i),
            particles.q[i],
            particles.m[i],
            dt
        )
    end
end



end # module