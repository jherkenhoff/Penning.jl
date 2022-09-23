using Penning

const OVERSAMPLING = 100
const omega = 200e9*2*pi

plane_wave = PlaneWaveExcitation(omega, 1)

trap = IdealTrap(5.0, -14960.0, 7.0)
trap.excitations[:plane_wave] = plane_wave

setup = Setup()
setup.traps[:trap] = trap

sim = Simulation(setup, dt=2*pi/omega/OVERSAMPLING, stop_iteration=OVERSAMPLING)

sim.output_writers[:excitation_field] = VtkFieldWriter("studies/data/excitation_field", trap.excitations[:plane_wave], VolumeExtractor(6e-3, 6e-3, 6e-3, nx=5, ny=5, nz=50), IterationInterval(1))

run!(sim)