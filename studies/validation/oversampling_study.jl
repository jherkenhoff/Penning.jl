using Plots
using FFTW
using Base.Threads
using Penning

# Simulation settings
const N_AXIAL_CYCLES = 4
const MIN_OVERSAMPLING = 21
const MAX_OVERSAMPLING = 200
const N_OVERSAMPLING_STEPS = 16
const SAVE_OVERSAMPLING = 15


# Ion
const base_species = Ion(187, 30)

const base_trap = IdealTrap(-50, -14960.0, 0.5)
omega_c_theory, omega_p_theory, omega_m_theory, omega_z_theory = calc_eigenfrequencies(base_trap, base_species)

const dt_vec = LinRange(2*pi/omega_p_theory/MIN_OVERSAMPLING, 2*pi/omega_p_theory/MAX_OVERSAMPLING/OVERSAMPLING, N_OVERSAMPLING_STEPS)

omega_z_all = Vector{Float64}(undef, N_OVERSAMPLING_STEPS)
omega_m_all = Vector{Float64}(undef, N_OVERSAMPLING_STEPS)
omega_p_all = Vector{Float64}(undef, N_OVERSAMPLING_STEPS)
@info "Running $N_OVERSAMPLING_STEPS dt steps on max. $(Threads.nthreads()) threads"
Threads.@threads for i in 1:N_OVERSAMPLING_STEPS

    dt = dt_vec[i]
    particle_distribution = SingleParticleDistribution([1e-6, 0, 1e-6], [1, 0, 0])
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particles] = particles

    setup = Setup()
    setup.traps[:trap] = trap

    sim = Simulation(setup, dt=dt, stop_time=N_AXIAL_CYCLES*2*pi/omega_z_theory)
    x_save_schedule = AlignedTimeInterval(2*pi/omega_p_theory/SAVE_OVERSAMPLING, dt)
    z_save_schedule = AlignedTimeInterval(2*pi/omega_z_theory/SAVE_OVERSAMPLING, dt)
    sim.output_writers[:x] = MemoryWriter(PositionComponentObservable(:trap, :particles, 1, 1), x_save_schedule)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particles, 1, 3), z_save_schedule)

    run!(sim)


    x_harminv_results = harminv(sim.output_writers[:x].t, sim.output_writers[:x].mem, omega_m_theory/2/pi/2, omega_p_theory/2/pi*2)
    @show z_harminv_results = harminv(sim.output_writers[:z].t, sim.output_writers[:z].mem, omega_z_theory/2/pi/2, omega_z_theory/2/pi*2)

    omega_z_all[i] = z_harminv_results[1].f*2*pi
    omega_m_all[i] = x_harminv_results[1].f*2*pi
    omega_p_all[i] = x_harminv_results[2].f*2*pi
end

plot(dt_vec, abs.(omega_m_all.-omega_m_theory)/omega_m_theory, label="Mag.", yaxis=:log, xaxis=:log)
plot!(dt_vec, abs.(omega_p_all.-omega_p_theory)/omega_p_theory, label="Cyc.")
plot!(dt_vec, abs.(omega_z_all.-omega_z_theory)/omega_z_theory, label="Axial")