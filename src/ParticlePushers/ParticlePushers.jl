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
    for i in eachindex(particles.r)
        initial_particle_push!(pusher,
            particles.r[i],
            particles.v[i],
            particles.a[i],
            particles.E[i],
            particles.B[i],
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
    for i in 1:N_particles(particle_collection)
        push_particle!(pusher,
            particles.r[i],
            particles.v[i],
            particles.a[i],
            particles.E[i],
            particles.B[i],
            particles.q[i],
            particles.m[i],
            dt
        )
    end
end



end # module