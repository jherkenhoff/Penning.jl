module Interactions

export 
    AbstractInteraction,
    CoulombInteraction

export 
    add_interaction_E_field!

abstract type AbstractInteraction end

include("coulomb.jl")

end # module