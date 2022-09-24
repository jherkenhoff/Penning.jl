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

    sim.initialized = false

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
        initialize_simulation!(sim)

        @debug "Executing initial time step..."
        start_time = time_ns()
        update_trap_fields!(sim.setup)
        initial_particle_push!(sim.particle_pusher, sim.setup, sim.dt)
        elapsed_initial_step_time = prettytime(1e-9 * (time_ns() - start_time))
        @debug "    ... initial time step complete ($elapsed_initial_step_time)."
    else # business as usual...
        update_trap_fields!(sim.setup)
        add_interaction_fields!(sim.setup)
        if sim.setup.circuit != nothing
            handle_external_circuit!(sim.setup, sim.dt)
        end
        push_particles!(sim.particle_pusher, sim.setup, sim.dt)
    end

    # Callbacks, diagnostics and writers

    for diag in sim.diagnostics
        diag.schedule(sim.setup) && diag(sim.setup)
    end
    for writer in sim.output_writers
        writer.schedule(sim.setup) && writer(sim.setup)
    end
    for callback in sim.callbacks
        callback.schedule(sim.setup) && callback(sim)
    end

    tick!(sim.setup.clock, sim.dt)

    return nothing
end

function initialize_simulation!(sim::Simulation)
    @debug "Initializing simulation..."
    start_time = time_ns()

    setup = sim.setup

    for writer in sim.output_writers
        init_output_writer!(writer, sim.setup)
    end

    sim.initialized = true

    initialization_time = prettytime(1e-9 * (time_ns() - start_time))
    @debug "    ... simulation initialization complete ($initialization_time)"

    return nothing
end

@inline function update_trap_fields!(setup::Setup)
    for trap in setup.traps
        update_trap_fields!(trap, setup.clock.time)
    end
    nothing
end

function update_trap_fields!(trap::Trap, t::Number)
    for particle_collection in trap.particles
        for i in 1:N_particles(particle_collection)
            for (i_f, field) in enumerate(trap.fields)
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
    for trap in setup.traps
        for interaction in trap.interactions
            add_interaction_E_field!(interaction, trap)
        end
    end
end

function handle_external_circuit!(setup::Setup, dt::Float64)
    # Collect induced currents on electrodes
    i = 0.0
    for trap in setup.traps
        for electrode in trap.electrodes
            electrode.i = 0.0
            for p in values(trap.particles)
                electrode.i += sum(calc_electrode_induced_current.((electrode,), p.r, p.v, (p.species.q,)))
            end
            i += electrode.i
        end
    end

    # Time step circuit
    step_circuit!(setup.circuit, i, dt)

    # Read the voltages on the electrodes from circuit simulation
    u = get_circuit_output_voltage(setup.circuit, i)
    

    for trap in setup.traps
        for electrode in trap.electrodes
            electrode.u = u

            for particle_collection in trap.particles
                particle_collection.E .+= calc_electrode_backaction_field.( (electrode,), particle_collection.r)
            end
        end
    end
end
