module Traps

export
    Trap,
    Particles,
    N_particles,
    update_trap_fields!,
    spherical_homogeneous_positions,
    cubic_homogeneous_positions,
    boltzman_velocities,
    zero_velocities,
    rotating_spheroid_velocities

include("particles.jl")
include("trap.jl")
include("initial_positions.jl")
include("initial_velocities.jl")

end # module