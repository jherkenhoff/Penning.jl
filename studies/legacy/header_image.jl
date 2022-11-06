using Penning

const N = 50
const OVERSAMPLING = 30
const N_AXIAL_CYCLES = 2

species = Ion(84, 30)
particle_collection = ParticleCollection(species, SphericalParticleDistribution(N, 2e-5, 1000))
trap = IdealTrap(-1900.0, -14960.0, 7.0)
trap.particles[:electrons] = particle_collection
trap.interactions[:coulomb] = CoulombInteraction([particle_collection])

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=2*pi/omega_c(trap, species)/OVERSAMPLING, stop_time=N_AXIAL_CYCLES*2*pi/omega_z(trap, species))

sim.diagnostics[:progress] = ProgressDiagnostic()

sim.output_writers[:vtk] = VtkParticleWriter("studies/data/particles", :electron_trap, :electrons, setup, IterationInterval(1))

run!(sim)