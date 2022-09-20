using Penning

const OVERSAMPLING = 100
cavity = TMCavityExcitation(1, 2, 2, 3e-3, 3e-3)

trap = IdealTrap(5.0, -14960.0, 7.0)
trap.excitations[:cavity] = cavity

setup = Setup()
setup.traps[:trap] = trap

sim = Simulation(setup, dt=2*pi/cavity.omega/OVERSAMPLING, stop_iteration=OVERSAMPLING)

sim.output_writers[:excitation_field] = VtkFieldWriter("studies/data/excitation_field", trap.excitations[:cavity], VolumeExtractor(6e-3, 6e-3, 6e-3, nx=20, ny=20, nz=20), IterationInterval(1))

run!(sim)