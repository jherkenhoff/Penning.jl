using Penning

const N = 70
const OVERSAMPLING = 30
const N_AXIAL_CYCLES = 4

species = Ion(84, 30)
particle_collection = ParticleCollection(species, SphericalParticleDistribution(N, 1e-4, 1000))
trap = IdealTrap(-50.0, -14960.0, 7.0)
trap.particles[:electrons] = particle_collection
trap.interactions[:coulomb] = CoulombInteraction([particle_collection])

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=2*pi/omega_c(trap, species)/OVERSAMPLING, stop_time=N_AXIAL_CYCLES*2*pi/omega_z(trap, species))

sim.diagnostics[:progress] = ProgressDiagnostic()

sim.output_writers[:vtk] = VtkParticleWriter("studies/data/particles", :electron_trap, :electrons, setup, IterationInterval(50))

run!(sim)