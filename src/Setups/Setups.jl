module Setups

export
    Setup,
    add_trap!,
    add_particle_collection!,
    add_field!,
    update_particle_fields!,
    tick!

include("clock.jl")
include("setup.jl")

end # modules