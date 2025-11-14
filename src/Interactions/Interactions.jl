module Interactions

export
    AbstractInteraction,
    CoulombInteraction,
    add_interaction_E_field!

abstract type AbstractInteraction end

include("coulomb.jl")

function add_interaction_E_field!(interaction::AbstractInteraction, trap)
    for i in 1:size(trap.particles.r)[2]
        r1 = view(trap.particles.r, :, i)
        q1 = trap.particles.q[i]
        for j in 1:size(trap.particles.r)[2]
            if i != j
                r2 = view(trap.particles.r, :, j)
                q2 = trap.particles.q[i]
                add_interaction_E_field!(interaction, r1, r2, q1, q2, view(trap.particles.E, :, i))
            end
        end
    end
end

end # module