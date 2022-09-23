using Penning

const OVERSAMPLING = 20
const N_AXIAL_CYCLES = 30
const E_0 = 300

species = Electron()

trap = IdealTrap(5.0, -14960.0, 7.0)
trap.particles[:electrons] = ParticleCollection(species, SingleParticleDistribution([0,0,0], [10000,0,0]))
trap.excitations[:plane_wave] = PlaneWaveExcitation(calc_omega_p(trap, species) - calc_omega_z(trap, species), E_0)

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=2*pi/calc_omega_c(trap, species)/OVERSAMPLING, stop_time=N_AXIAL_CYCLES*2*pi/calc_omega_z(trap, species))

sim.diagnostics[:progress] = ProgressDiagnostic()

sim.output_writers[:memory_position] = MemoryWriter(PositionComponentObservable(:electron_trap, :electrons, 1, 3), IterationInterval(600))

run!(sim)

using Plots
t = sim.output_writers[:memory_position].t
z = sim.output_writers[:memory_position].mem
plot(t, z, labels="Simulated Z position", plot_title="Plane Wave")

savefig(joinpath(@__DIR__, "plane_wave.png"))