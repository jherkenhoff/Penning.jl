
using Penning.ParticlePushers
using Penning.Setups
using Penning.Traps
using Penning.Fields
using Penning.Interactions
using Penning.Electrodes
using Penning.Circuits
using Penning.CircuitConnections

import Penning.Common

function run!(sim::Simulation, stop_condition::AbstractStopCondition)
    @info "Starting simulation at simulation time $(prettytime(sim.setup.clock.time)) and iteration $(Int(sim.setup.clock.iteration))"

    run_start_wall_time_ns = time_ns()
    while true
        time_step!(sim)

        # Callbacks, diagnostics and writers
        for diag in values(sim.diagnostics)
            diag.schedule(sim.setup) && diag(sim.setup)
        end
        for writer in values(sim.output_writers)
            writer.schedule(sim.setup) && write_output(writer, sim.setup)
        end
        for callback in values(sim.callbacks)
            callback.schedule(sim.setup) && callback(sim)
        end

        # Current wall time
        sim.wall_time_ns = (time_ns() - run_start_wall_time_ns)

        # Check if simulation should stop
        should_stop, stop_reason = stop_condition(sim)
        if should_stop
            @info "Simulation stopping: " * stop_reason
            break
        end
    end

    Common.checkpoint!(sim)

    @info "Simulation took $(prettytime(sim.wall_time_ns/1e9))"
    @info "Stopped at iteration $(sim.setup.clock.iteration) ($(prettytime(sim.setup.clock.time)))"

    nothing
end

function time_step!(sim::Simulation)

    if !(sim.initialized) # execute initialization step
        @debug "Executing initial time step..."
        start_time = time_ns()
        update_trap_fields!(sim.setup)
        initial_particle_push!(sim.particle_pusher, sim.setup, sim.dt)
        elapsed_initial_step_time = prettytime(1e-9 * (time_ns() - start_time))
        @debug "    ... initial time step complete ($elapsed_initial_step_time)."
        sim.initialized = true
    else # business as usual...
        update_trap_fields!(sim.setup)
        add_interaction_fields!(sim.setup)
        if !isempty(sim.setup.circuits)
            handle_external_circuit!(sim.setup, sim.dt)
        end
        push_particles!(sim.particle_pusher, sim.setup, sim.dt)
    end

    tick!(sim.setup.clock, sim.dt)

    return nothing
end

@inline function update_trap_fields!(setup::Setup)
    for trap in values(setup.traps)
        update_trap_fields!(trap, setup.clock.time)
    end
    nothing
end

function update_trap_fields!(trap::Trap, t::Number)
    trap.particles.E .= 0.0
    trap.particles.B .= 0.0
    for i in 1:N_particles(trap.particles)
        for field in values(trap.fields)
            trap.particles.E[:, i] += calc_E_field(field, view(trap.particles.r, :, i), t)
            trap.particles.B[:, i] += calc_B_field(field, view(trap.particles.r, :, i), t)
        end
    end
    nothing
end

function add_interaction_fields!(setup::Setup)
    for trap in values(setup.traps)
        for interaction in values(trap.interactions)
            add_interaction_E_field!(interaction, trap)
        end
    end
end

function handle_external_circuit!(setup::Setup, dt::Float64)
    # Collect induced currents on electrodes
    for trap in values(setup.traps)
        for electrode in values(trap.electrodes)
            electrode.i = 0.0
            for p in values(trap.particles)
                electrode.i += sum(calc_electrode_induced_current.((electrode,), p.r, p.v, (p.species.q,)))
            end
        end
    end

    # Reset circuit input currents to zero
    for circuit in values(setup.circuits)
        reset_circuit_input_current!(circuit)
    end

    for connection in values(setup.circuit_connections)
        connect_electrode_to_circuit!(connection, setup)
    end

    # Time step circuits
    for circuit in values(setup.circuits)
        step_circuit!(circuit, dt)
    end

    for connection in values(setup.circuit_connections)
        connect_circuit_to_electrode!(connection, setup)
    end

    for trap in values(setup.traps)
        for i in 1:N_particles(trap.particles)
            for electrode in trap.electrodes
                trap.particles.E[:, i] += calc_electrode_backaction_field(electrode, trap.particles.r[:, i])
            end
        end
    end
end
