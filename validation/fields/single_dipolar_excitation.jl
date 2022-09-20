using Penning

const OVERSAMPLING = 20

species = Ion(187, 30)

trap = IdealTrap(-50.0, -14960.0, 7.0)
trap.particles[:ions] = ParticleCollection(species, SingleParticleDistribution([0.3,0,0.5], [1000,0,0]))
trap.excitations[:dipolar] = DipolarExcitation(omega_z(trap, species), [0, 0, 1000])

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=omega_p(trap, species)/OVERSAMPLING, stop_iteration=1000)

sim.diagnostics[:progress] = ProgressDiagnostic()

sim.output_writers[:vtk] = VtkParticleWriter("studies/data/particles", :electron_trap, :ions, setup, IterationInterval(1))

sim.output_writers[:trap_field] = VtkFieldWriter("studies/data/trap_field", trap, VolumeExtractor(2.0, 2.0, 2.0), IterationInterval(100))

sim.output_writers[:excitation_field] = VtkFieldWriter("studies/data/excitation_field", trap.excitations[:dipolar], VolumeExtractor(2.0, 2.0, 2.0, nx=5, ny=5, nz=5), IterationInterval(1))

run!(sim)