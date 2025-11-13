module Interactions

export
    AbstractInteraction,
    CoulombInteraction,
    add_interaction_E_field!

abstract type AbstractInteraction end

include("coulomb.jl")

function add_interaction_E_field!(interaction::AbstractInteraction, trap)
    for i in 1:eachindex(trap.particles.r)
        r1 = trap.particles.r[this_particle]
        q1 = trap.particles.q[this_particle]
        for j in 1:eachindex(trap.particles.r)
            if i != j
                r2 = trap.particles.r[j]
                q2 = trap.particles.q[j]
                add_interaction_E_field!(interaction, r1, r2, q1, q2, trap.particles.E[i])
            end
        end
    end
end

end # module