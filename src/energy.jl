using LinearAlgebra: dot

using Penning.Particles
using Penning.Traps
using Penning.Setups

function calc_kinetic_energy(v::Vector{<:Number}, m::Number)
    return 0.5 * m * dot(v, v)
end

function calc_kinetic_energy(particle_collection::ParticleCollection)
    return sum(calc_kinetic_energy.(particle_collection.v, (particle_collection.species.m,)))
end

function calc_kinetic_energy(trap::Trap)
    return sum(calc_kinetic_energy.(values(trap.particles)))
end

function calc_kinetic_energy(setup::Setup)
    return sum(calc_kinetic_energy.(values(setup.traps)))
end

function calc_potential_energy(trap::Trap, r::Vector{<:Number}, t::Number, q::Number)

    PE = 0.0

    for field in trap.fields
        PE += calc_field_PE(field, r, t, q)
    end

    # TODO: Add coulomb potential energy
    return PE
end

function calc_potential_energy(trap::Trap, t::Number, particle_collection::ParticleCollection)
    return sum(calc_potential_energy.((trap,), particle_collection.r, (t,), (particle_collection.species.q,)))
end

function calc_potential_energy(trap::Trap, t::Number)
    return sum(calc_potential_energy.((trap,), (t,), trap.particles))
end

function calc_potential_energy(setup::Setup)
    return sum(calc_potential_energy.(setup.traps, (setup.clock.time,)))
end