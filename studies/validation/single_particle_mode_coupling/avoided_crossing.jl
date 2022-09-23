using Plots
using FFTW
using Base.Threads
using Penning

# Simulation settings
const N_AXIAL_CYCLES = 5000
const OVERSAMPLING = 20
const SAVE_OVERSAMPLING = 4
const N_DETUNINGS = 80
const DETUNING_SPAN = 10e3

# Sideband excitation
const A_rf = 5000

# Ion
const base_species = Ion(187, 30)

const base_trap = IdealTrap(-50, -14960.0, 0.5)
omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(base_trap, base_species)
dt = 2*pi/omega_c/OVERSAMPLING

################################################################################
# Step 1: Let particle evolve freely to extract eigenfrequencies
################################################################################
function run_extract_eigenfrequencies(omega_c, omega_p, omega_m, omega_z, dt)
    particle_distribution = SingleParticleDistribution([1e-6, 0, 1e-6], [10, 0, 0])
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particle] = particles
    setup = Setup()
    setup.traps[:trap] = trap
    sim = Simulation(setup, dt=dt, stop_time=1000*2*pi/omega_z)

    save_x_schedule = AlignedTimeInterval(2*pi/omega_c/SAVE_OVERSAMPLING, dt)
    save_z_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt)
    sim.output_writers[:x] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 1), save_x_schedule)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 3), save_z_schedule)

    run!(sim)

    x_harminv_results = harminv(sim.output_writers[:x].t, sim.output_writers[:x].mem, omega_m/2/pi/2, omega_p/2/pi*2)
    z_harminv_results = harminv(sim.output_writers[:z].t, sim.output_writers[:z].mem, omega_z/2/pi/2, omega_z/2/pi*2)

    # Update theoretically calculated eigenfrequencies with newly found ones
    omega_m = x_harminv_results[1].f*2*pi
    omega_p = x_harminv_results[2].f*2*pi
    omega_z = z_harminv_results[1].f*2*pi

    dt = 2*pi/omega_c/OVERSAMPLING
    return omega_p, omega_m, omega_z, dt
end
omega_p, omeg_m, omega_z, dt = run_extract_eigenfrequencies(omega_c, omega_p, omega_m, omega_z, dt)

################################################################################
# Step 2: Validate sideband frequency
################################################################################
function run_validate_sideband(omega_p, omega_m, omega_z, dt)
    # Theoretical Rabi frequency: (http://hdl.handle.net/21.11116/0000-0005-6361-E)(Page 25, equation 2.46)
    Omega_R = A_rf/4*abs(base_species.q) / base_species.m /sqrt(omega_z*(omega_p-omega_m))
    T_exchange = 2*pi/Omega_R/4

    particle_distribution = SingleParticleDistribution([0, 0, 1e-6], [0, 0, 0])
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particle] = particles
    trap.excitations[:quadrupolar] = QuadrupolarExcitation(omega_p - omega_z, A_rf)
    setup = Setup()
    setup.traps[:trap] = trap
    sim = Simulation(setup, dt=dt, stop_time=T_exchange*1.5)

    save_z_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING/4, dt)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 3), save_z_schedule)

    run!(sim)

    t = sim.output_writers[:z].t
    z = sim.output_writers[:z].mem

    println("Theoretical double dip splitting: $(Omega_R/2/pi) Hz")

    plot(t*1e6, z)
    vline!([T_exchange*1e6], labels="Theoretical pi pulse duration")
    xlabel!("Time / µs")
end
run_validate_sideband(omega_p, omega_m, omega_z, dt)


detunings = LinRange(-DETUNING_SPAN/2, DETUNING_SPAN/2, N_DETUNINGS)*2*pi
t = []
fft_z_all = Vector{Vector{Float64}}(undef, N_DETUNINGS)
@info "Running $N_DETUNINGS different detunings on $(Threads.nthreads()) threads"
Threads.@threads for i = 1:N_DETUNINGS
    particle_distribution = SingleParticleDistribution([1e-6,0,0], [0,0,0])
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particles] = particles
    trap.excitations[:quadrupolar] = QuadrupolarExcitation(omega_p - omega_z + detunings[i], A_rf)

    setup = Setup()
    setup.traps[:trap] = trap

    sim = Simulation(setup, dt=dt, stop_time=N_AXIAL_CYCLES*2*pi/omega_z)
    save_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particles, 1, 3), save_schedule)

    run!(sim)

    z = sim.output_writers[:z].mem

    z .+= randn(length(z))*1e-7

    if i == 1
        push!(t, sim.output_writers[:z].t)
    end

    fft_z_all[i] = 20*log10.(abs.(rfft(z)))
end

t = t[1]

fft_f = LinRange(0.0, 1/(t[2]-t[1])/2, length(fft_z_all[1]))

const SPAN = 20e3
data = hcat(fft_z_all...)
heatmap(detunings/2/pi/1e3, fft_f/1e3.-omega_z/2/pi/1e3, data, interpolation=true, title="Avoided crossing during sideband coupling")
ylims!((-SPAN/2, SPAN/2)./1e3)
xlabel!("Sideband Detuning / kHz")
savefig(joinpath(@__DIR__, "avoided_crossing.png"))


