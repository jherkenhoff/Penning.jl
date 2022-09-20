
using Penning.Utils
using Penning.Setups
using Penning.ParticlePushers
using Penning.Diagnostics
using Penning.OutputWriters

import Penning: reset!


mutable struct Simulation{D, OW, CB}
    setup :: Setup
    particle_pusher
    dt :: Float64
    stop_iteration :: Float64
    stop_time :: Float64
    wall_time_limit :: Float64
    diagnostics :: D
    output_writers :: OW
    callbacks :: CB
    run_wall_time :: Float64
    running :: Bool
    initialized :: Bool
end

function Simulation(setup::Setup;
                    dt,
                    particle_pusher::AbstractParticlePusher = ModifiedBorisPusher(),
                    diagnostics=(;),
                    output_writers=(;),
                    stop_iteration = Inf,
                    stop_time = Inf,
                    wall_time_limit = Inf)

    @assert dt > 0.0

    if stop_iteration == Inf && stop_time == Inf && wall_time_limit == Inf
        @warn "This simulation will run forever as stop iteration = stop time " *
            "= wall time limit = Inf."
    end

    callbacks = (;)

    if stop_iteration != Inf
        callbacks = merge(callbacks, (stop_iteration_exceeded = Callback(stop_iteration_exceeded),))
    end

    if stop_time != Inf
        callbacks = merge(callbacks, (stop_time_exceeded = Callback(stop_time_exceeded),))
    end

    if wall_time_limit != Inf
        callbacks = merge(callbacks, (wall_time_limit_exceeded = Callback(wall_time_limit_exceeded),))
    end

    Simulation(setup,
        particle_pusher,
        dt,
        Float64(stop_iteration),
        stop_time,
        Float64(wall_time_limit),
        diagnostics,
        output_writers,
        callbacks,
        0.0,
        false,
        false)
end


# function Base.show(io::IO, s::Simulation)
#     setupstr = summary(s.setup)
#     return print(io, "Simulation of ", setupstr, '\n',
#                      "├── Time step: $(prettytime(s.dt))", '\n',
#                      "├── Elapsed wall time: $(prettytime(s.run_wall_time))", '\n',
#                      "├── Stop time: $(prettytime(s.stop_time))", '\n',
#                      "├── Stop iteration : $(s.stop_iteration)", '\n',
#                      "├── Wall time limit: $(s.wall_time_limit)", '\n',
#                      "├── Callbacks: $(dict_show(s.callbacks, "│"))", '\n',
#                      "├── Output writers: $(dict_show(s.output_writers, "│"))", '\n',
#                      "└── Diagnostics: $(dict_show(s.diagnostics, "│"))")
# end

function stop_iteration_exceeded(sim)
    if sim.setup.clock.iteration >= sim.stop_iteration
        @info "Simulation is stopping. Iteration $(sim.setup.clock.iteration) " *
               "has hit or exceeded simulation stop iteration $(Int(sim.stop_iteration)) at simulation time $(prettytime(sim.setup.clock.time))."
       sim.running = false 
    end
    return nothing
end

function stop_time_exceeded(sim)
    if sim.setup.clock.time >= sim.stop_time
       @info "Simulation is stopping. Time $(prettytime(sim.setup.clock.time)) " *
             "has hit or exceeded simulation stop time $(prettytime(sim.stop_time)) at iteration $(Int(sim.setup.clock.iteration))."
       sim.running = false 
    end
    return nothing
end

function wall_time_limit_exceeded(sim)
    if sim.run_wall_time >= sim.wall_time_limit
        @info "Simulation is stopping. Simulation run time $(run_wall_time(sim)) " *
              "has hit or exceeded simulation wall time limit $(prettytime(sim.wall_time_limit))."
       sim.running = false 
    end
    return nothing
end

function finalize_simulation!(sim::Simulation)
    for writer in sim.output_writers
        finalize_output_writer!(writer)
    end
end

function reset!(sim::Simulation)
    reset!(sim.setup)
    for (key, writer) in sim.output_writers
        reset!(writer)
    end
    nothing
end