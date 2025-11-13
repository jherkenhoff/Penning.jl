
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

        # Check if simulation should stop
        sim.wall_time_ns = (time_ns() - run_start_wall_time_ns)

        should_stop, stop_reason = stop_condition(sim)
        if should_stop
            @info "Simulation stopping: " * stop_reason
            break
        end
    end

    Common.checkpoint!(sim)

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
    # TODO: Refactor and make it less ugly
    for i in eachindex(trap.particles.r)
        if (length(trap.fields) == 0)
            # If there are no fields, explicitly set the fields to zero
            trap.particles.E[i] .= 0.0
            trap.particles.B[i] .= 0.0
        else
            for (i_f, field) in enumerate(values(trap.fields))
                if i_f == 1
                    set_E_field!(field, trap.particles.E[i], trap.particles.r[i], t)
                    set_B_field!(field, trap.particles.B[i], trap.particles.r[i], t)
                else
                    add_E_field!(field, trap.particles.E[i], trap.particles.r[i], t)
                    add_B_field!(field, trap.particles.B[i], trap.particles.r[i], t)
                end
            end
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
        for electrode in trap.electrodes
            trap.particles.E .+= calc_electrode_backaction_field.( (electrode,), trap.particles.r)
        end
    end
end
