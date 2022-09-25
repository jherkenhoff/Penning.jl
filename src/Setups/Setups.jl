module Setups

export
    Setup,
    Connection,
    add_trap!,
    add_particle_collection!,
    add_field!,
    update_particle_fields!,
    tick!

include("clock.jl")
include("setup.jl")
include("connection.jl")

end # modules