using Penning.ParticlePushers
using Penning.Particles
using Penning.Setups
using Penning.Traps
using Penning.Fields
using Penning.Interactions
using Penning.Electrodes
using Penning.Circuits

function run!(sim::Simulation; pickup::Bool=false,
              run_until_time = Inf,
              run_until_iteration = Inf,
              run_for_time = Inf,
              run_for_iterations = Inf,
              run_for_wall_time = Inf,
              run_until_wall_time = Inf)

    @info "Starting simulation at iteration $(Int(sim.setup.clock.iteration)) and time $(prettytime(sim.setup.clock.time))"

    if run_until_time == Inf && run_until_iteration == Inf && 
       run_for_time == Inf && run_for_iterations == Inf && 
       run_for_wall_time == Inf && run_until_wall_time == Inf
        @warn "This simulation will run forever as no time, iteration or wall time limit was specified"
    end

    start_iteration = sim.setup.clock.iteration
    start_time = sim.setup.clock.time

    start_wall_time = time_ns()
    last_step_wall_time = start_wall_time
    while true
        step_start_wall_time = last_step_wall_time

        time_step!(sim)

        if sim.setup.clock.iteration >= run_until_iteration
            @info "Simulation is stopping. Iteration $(sim.setup.clock.iteration) " *
                "has hit or exceeded simulation stop iteration $(Int(run_until_iteration)) at simulation time $(prettytime(sim.setup.clock.time))."
            break
        end

        if sim.setup.clock.time >= run_until_time
            @info "Simulation is stopping. Time $(prettytime(sim.setup.clock.time)) " *
                    "has hit or exceeded simulation stop time $(prettytime(run_until_time)) at iteration $(Int(sim.setup.clock.iteration))."
            break
        end

        if sim.setup.clock.iteration - start_iteration >= run_for_iterations
            @info "Simulation is stopping. Simulation advanced by at least $(Int(run_for_iterations)) iterations from iteration $(Int(start_iteration)) " *
                    "to $(Int(sim.setup.clock.iteration)) at simulation time $(prettytime(sim.setup.clock.time))."
            break
        end

        if sim.setup.clock.time - start_time >= run_for_time
            @info "Simulation is stopping. Simulation advanced by a durtion of at least $(prettytime(run_for_time)) from $(prettytime(start_time)) " *
                    "to $(prettytime(sim.setup.clock.time)) at iteration $(Int(sim.setup.clock.iteration))."
            break
        end

        last_step_wall_time = time_ns()
        sim.wall_time += 1e-9*(last_step_wall_time - step_start_wall_time)
        if sim.wall_time >= run_until_wall_time
            @info "Simulation is stopping. Simulation run time $(sim.wall_time) " *
                "has hit or exceeded simulation total wall time limit $(prettytime(run_until_wall_time))."
            break
        end

        if sim.wall_time - start_wall_time >= run_for_wall_time
            @info "Simulation is stopping. Simulation did run for at least $(run_for_wall_time)."
            break
        end
    end

    finalize_simulation!(sim)

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

    # Callbacks, diagnostics and writers

    for diag in values(sim.diagnostics)
        diag.schedule(sim.setup) && diag(sim.setup)
    end
    for writer in values(sim.output_writers)
        writer.schedule(sim.setup) && writer(sim.setup)
    end
    for callback in values(sim.callbacks)
        callback.schedule(sim.setup) && callback(sim)
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
    for particle_collection in values(trap.particles)
        for i in 1:N_particles(particle_collection)
            for (i_f, field) in enumerate(values(trap.fields))
                if i_f == 1
                    set_E_field!(field, particle_collection.E[i], particle_collection.r[i], t)
                    set_B_field!(field, particle_collection.B[i], particle_collection.r[i], t)
                else
                    add_E_field!(field, particle_collection.E[i], particle_collection.r[i], t)
                    add_B_field!(field, particle_collection.B[i], particle_collection.r[i], t)
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

    for circuit in values(setup.circuits)
        circuit.i .= 0.0 
    end

    for connection in values(setup.connections)
        i = setup.traps[connection.trap].electrodes[connection.electrode].i
        setup.circuits[connection.circuit].i[connection.pin] += i
    end

    # Time step circuits
    for circuit in values(setup.circuits)
        step_circuit!(circuit, dt)
    end

    for connection in values(setup.connections)
        u = setup.circuits[connection.circuit].u[connection.pin]
        setup.traps[connection.trap].electrodes[connection.electrode].u = u
    end

    for trap in values(setup.traps)
        for electrode in trap.electrodes
            for particle_collection in trap.particles
                particle_collection.E .+= calc_electrode_backaction_field.( (electrode,), particle_collection.r)
            end
        end
    end
end
