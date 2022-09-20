using Penning.ParticlePushers
using Penning.Particles
using Penning.Setups
using Penning.Traps
using Penning.Fields
using Penning.Interactions
using Penning.Electrodes
using Penning.Circuits

function run!(sim::Simulation; pickup::Bool=false)
    sim.initialized = false
    sim.running = true

    while sim.running
        time_step!(sim)
    end

    finalize_simulation!(sim)

    nothing
end

function time_step!(sim::Simulation)
    start_time_step = time_ns()

    if !(sim.initialized) # execute initialization step
        initialize_simulation!(sim)

        if sim.running # check that initialization didn't stop time-stepping
            @debug "Executing initial time step..."

            start_time = time_ns()

            update_trap_fields!(sim.setup)
            initial_particle_push!(sim.particle_pusher, sim.setup, sim.dt)

            elapsed_initial_step_time = prettytime(1e-9 * (time_ns() - start_time))
            @debug "    ... initial time step complete ($elapsed_initial_step_time)."
        else
            @warn "Simulation stopped during initialization."
        end
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
    end_time_step = time_ns()

    # Increment the wall clock
    sim.run_wall_time += 1e-9 * (end_time_step - start_time_step)

    return nothing
end

function initialize_simulation!(sim::Simulation)
    @debug "Initializing simulation..."
    start_time = time_ns()

    setup = sim.setup
    clock = setup.clock

    for writer in sim.output_writers
        init_output_writer!(writer, sim.setup)
    end

    # update_state!(model)

    # # Output and diagnostics initialization
    # [add_dependencies!(sim.diagnostics, writer) for writer in values(sim.output_writers)]

    # # Reset! the model particle-pusher, evaluate all diagnostics, and write all output at first iteration
    # if clock.iteration == 0
    #     reset!(sim.particle_pusher)

    #     # Initialize schedules and run diagnostics, callbacks, and output writers
    #     for diag in values(sim.diagnostics)
    #         diag.schedule(sim.model)
    #         run_diagnostic!(diag, model)
    #     end

    #     for callback in values(sim.callbacks)
    #         callback.schedule(model)
    #         callback(sim)
    #     end

    #     for writer in values(sim.output_writers)
    #         writer.schedule(sim.model)
    #         write_output!(writer, model)
    #     end
    # end

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
