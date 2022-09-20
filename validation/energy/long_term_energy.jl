using Penning

const OVERSAMPLING = 20
const N_AXIAL_CYCLES = 3

species = Ion(187, 30)
trap = IdealTrap(-50, -14960.0, 7.0)
trap.particles[:particles] = ParticleCollection(species, SingleParticleDistribution([0, 0, 1e-6], [10000, 0, 0]))

setup = Setup()
setup.traps[:trap] = trap

sim = Simulation(setup, dt=2*pi/omega_c(trap, species)/OVERSAMPLING, stop_time=N_AXIAL_CYCLES*2*pi/omega_z(trap, species))

sim.diagnostics[:progress] = ProgressDiagnostic()
sim.output_writers[:memory_position] = PositionMemoryWriter(:trap, :particles, IterationInterval(600))

run!(sim)

calc_PE(setup)