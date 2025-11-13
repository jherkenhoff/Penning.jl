using LinearAlgebra

using Penning.Constants

struct CoulombInteraction <: AbstractInteraction
end

function add_interaction_E_field!(interaction::CoulombInteraction, r1, r2, q1, q2, E1)
    E1 .+= 1 / 4 / pi / epsilon_0 * q2 / norm(r1-r2)^3 * (r1-r2)
    nothing
end