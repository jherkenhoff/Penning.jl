
import Penning.Common: finalize!, checkpoint!
using Penning.Utils
using Penning.Setups
using Penning.ParticlePushers
using Penning.Diagnostics
using Penning.OutputWriters

import Penning.Common

mutable struct Simulation{D, OW, CB}
    setup :: Setup
    particle_pusher
    dt :: Float64
    diagnostics :: D
    output_writers :: OW
    callbacks :: CB
    initialized :: Bool
    wall_time :: Float64
end

function Simulation(setup::Setup;
                    dt,
                    particle_pusher::AbstractParticlePusher = ModifiedBorisPusher(),
                    diagnostics=(;),
                    output_writers=(;))

    @assert dt > 0.0

    callbacks = (;)

    Simulation(setup,
        particle_pusher,
        dt,
        diagnostics,
        output_writers,
        callbacks,
        false,
        0.0)
end

# function Base.show(io::IO, s::Simulation)
#     setupstr = summary(s.setup)
#     return print(io, "Simulation of ", setupstr, '\n',
#                      "├── Time step: $(prettytime(s.dt))", '\n',
#                      "├── Callbacks: $(dict_show(s.callbacks, "│"))", '\n',
#                      "├── Output writers: $(dict_show(s.output_writers, "│"))", '\n',
#                      "└── Diagnostics: $(dict_show(s.diagnostics, "│"))")
# end

function Common.checkpoint!(sim::Simulation)
    for writer in values(sim.output_writers)
        checkpoint!(writer)
    end
end

function Common.finalize!(sim::Simulation)
    for writer in values(sim.output_writers)
        finalize!(writer)
    end
end

function Common.reset!(sim::Simulation)
    reset!(sim.setup)
    for writer in values(sim.output_writers)
        reset!(writer)
    end
    nothing
end