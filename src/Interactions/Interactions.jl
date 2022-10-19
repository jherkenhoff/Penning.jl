module Interactions

export 
    AbstractInteraction,
    InteractionGroup,
    CoulombInteraction,
    add_interaction_E_field!

abstract type AbstractInteraction end

include("interaction_group.jl")
include("coulomb.jl")

function add_interaction_E_field!(interaction::AbstractInteraction, trap)
    for this_particle_collection in trap.particles
        #@batch for this_particle in 1:N_particles(this_particle_collection)
        for this_particle in 1:N_particles(this_particle_collection)
            r1 = this_particle_collection.r[this_particle]
            q1 = this_particle_collection.species.q
            for other_particle_collection in trap.particles
                for other_particle in 1:N_particles(other_particle_collection)
                    if !(this_particle == other_particle && this_particle_collection == other_particle_collection)
                        r2 = other_particle_collection.r[other_particle]
                        q2 = other_particle_collection.species.q
                        add_interaction_E_field!(interaction, r1, r2, q1, q2, this_particle_collection.E[this_particle])
                    end
                end
            end
        end
    end
end

end # module