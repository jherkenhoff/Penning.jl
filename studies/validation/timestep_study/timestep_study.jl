using Plots
using Base.Threads
using Penning

# Simulation settings
const N_AXIAL_CYCLES = 4
const MIN_OVERSAMPLING = 21
const MAX_OVERSAMPLING = 501
const N_OVERSAMPLING_STEPS = 8
const SAVE_OVERSAMPLING = 15

# Trap parameters
const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 0.5

const ion = Ion(187, 30)
const omega_p_theory = calc_omega_p(U₀, c₂, B₀, ion.q, ion.m)
const omega_m_theory = calc_omega_m(U₀, c₂, B₀, ion.q, ion.m)
const omega_z_theory = calc_omega_z(U₀, c₂, B₀, ion.q, ion.m)

const oversampling_vec = LinRange(MIN_OVERSAMPLING, MAX_OVERSAMPLING, N_OVERSAMPLING_STEPS)

omega_z_all = Vector{Float64}(undef, N_OVERSAMPLING_STEPS)
omega_m_all = Vector{Float64}(undef, N_OVERSAMPLING_STEPS)
omega_p_all = Vector{Float64}(undef, N_OVERSAMPLING_STEPS)
wall_times_all = Vector{Float64}(undef, N_OVERSAMPLING_STEPS)
@info "Running $N_OVERSAMPLING_STEPS oversampling steps on max. $(Threads.nthreads()) threads"
Threads.@threads for i in 1:N_OVERSAMPLING_STEPS

    oversampling = oversampling_vec[i]

    dt = 2*pi/omega_p_theory/oversampling

    trap = Trap(
        fields = (
            IdealTrapField(U₀, c₂, B₀),
        ),
        particles = (
            ParticleCollection(deepcopy(ion), [[0, 0, 0.5]], [[1000, 0, 0]]),
        )
    )

    setup = Setup(
        traps = (
            trap,
        )
    )

    x_save_schedule = AlignedTimeInterval(2*pi/omega_p_theory/SAVE_OVERSAMPLING, dt)
    z_save_schedule = AlignedTimeInterval(2*pi/omega_z_theory/SAVE_OVERSAMPLING, dt)

    sim = Simulation(
        setup, 
        dt=dt,
        #particle_pusher = BorisPusher(),
        output_writers = (
            x = MemoryWriter(PositionComponentObservable(1, 1, 1, 1), x_save_schedule),
            z = MemoryWriter(PositionComponentObservable(1, 1, 1, 3), z_save_schedule),
        )
    )

    run!(sim, run_until_time=N_AXIAL_CYCLES*2*pi/omega_z_theory)

    wall_times_all[i] = sim.wall_time

    x_harminv_results = harminv(sim.output_writers.x.t, sim.output_writers.x.mem, omega_m_theory/2/pi/2, omega_p_theory/2/pi*2)
    z_harminv_results = harminv(sim.output_writers.z.t, sim.output_writers.z.mem, omega_z_theory/2/pi/2, omega_z_theory/2/pi*2)

    omega_z_all[i] = z_harminv_results[1].f*2*pi
    omega_m_all[i] = x_harminv_results[1].f*2*pi
    omega_p_all[i] = x_harminv_results[2].f*2*pi
end

plot(
    oversampling_vec,
    abs.(omega_m_all.-omega_m_theory)/omega_m_theory, 
    label="Mag.",
    marker = 4,
    yaxis=:log,
    xlabel = "Oversampling",
    ylabel = "Freq. error: \$|\\nu - \\nu_\\textnormal{theo.}| / \\nu_\\textnormal{theo.}\$")
plot!(oversampling_vec, abs.(omega_p_all.-omega_p_theory)/omega_p_theory, label="Cyc.", marker = 4)
plot!(oversampling_vec, abs.(omega_z_all.-omega_z_theory)/omega_z_theory, label="Axial", marker = 4)
