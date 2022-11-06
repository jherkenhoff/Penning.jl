using Plots
using FFTW
using Penning

# Simulation settings
const N_PARTICLES = 100
const N_AXIAL_CYCLES = 300
const OVERSAMPLING = 20
const SAVE_OVERSAMPLING = 4
const N_AVERAGES = 16

# Electrode
const D_eff = 0.6e-3

# Sideband excitation
const A_rf = 3000

# Ion
const base_species = Ion(187, 30)

const base_trap = IdealTrap(-50, -14960.0, 7)
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

# Resonator
const R = 10e6
const C = 10e-12
const L = 1/omega_z^2/C


particle_distribution = SphericalHomogeneousParticleDistribution(N_PARTICLES, 1e-4, 1)
particles = ParticleCollection(deepcopy(base_species), particle_distribution)

trap = deepcopy(base_trap)
trap.particles[:particles] = particles
trap.electrodes[:axial] = AxialParallelPlateElectrode(D_eff)
trap.interactions[:coulomb] = CoulombInteraction([particles])

circuit = SSCircuitResonator(R, L, C, [(:trap, :axial)], T=4.2)

setup = Setup(circuit)
setup.traps[:trap] = trap

sim = Simulation(setup, dt=dt, stop_time=N_AXIAL_CYCLES*2*pi/omega_z)
save_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt)
sim.output_writers[:vtk] = VtkParticleWriter("studies/data/particles", :trap, :particles, setup, IterationInterval(1))

run!(sim)

finalize!(sim.output_writers[:vtk])

fft_v_all[i] = 20*log10.(abs.(rfft(v)))

fft_v_avg = dropdims(sum(permutedims(hcat(fft_v_all...)), dims=(1)), dims=(1)) / N_AVERAGES
fft_f = LinRange(0.0, 1/(t[2]-t[1])/2, length(fft_v_avg))

const SPAN = 20e3
plot(fft_f/1e3, fft_v_avg, label="Simulated resonator voltage", plot_title="Double dip of 187Re30+")
xlims!((omega_z/2/pi-SPAN/2, omega_z/2/pi+SPAN/2)./1e3)
ylims!((-290, -250))

savefig(joinpath(@__DIR__, "resonator_ss_double_dip.png"))