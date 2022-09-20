using LinearAlgebra

using Penning.Constants
using Penning.Particles

using Polyester

struct CoulombInteraction <: AbstractInteraction
end

function add_interaction_E_field!(interaction::CoulombInteraction, trap)
    # Woooow, THIS is ugly! TODO: Find more elegant solution
    for this_particle_collection in trap.particles
        @batch for this_particle in 1:N_particles(this_particle_collection)
            r1 = this_particle_collection.r[this_particle]
            for other_particle_collection in trap.particles
                for other_particle in 1:N_particles(other_particle_collection)
                    if !(this_particle == other_particle && this_particle_collection == other_particle_collection)
                        r2 = other_particle_collection.r[other_particle]
                        this_particle_collection.E[this_particle] .+= 1 / 4 / pi / epsilon_0 * other_particle_collection.species.q / norm(r1-r2)^3 * (r1-r2)
                    end
                end
            end
        end
    end
end