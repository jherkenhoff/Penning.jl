using Penning
using Plots

const OVERSAMPLING = 20
const N_AXIAL_CYCLES = 2

const D_0 = 1e-6

species = Ion(187, 30)
particle_collection = ParticleCollection(species, ParticleDistribution([[0, 0, D_0/2], [0, 0, -D_0/2]], [zeros(3), zeros(3)]))
trap = IdealTrap(-50, -14960.0, 5)
trap.particles[:electrons] = particle_collection
trap.interactions[:coulomb] = CoulombInteraction([particle_collection])

omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(trap, species)
dt = 2*pi/omega_p/OVERSAMPLING

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=dt, stop_time=2*pi/omega_z*N_AXIAL_CYCLES)

sim.output_writers[:z1] = MemoryWriter(PositionComponentObservable(:electron_trap, :electrons, 1, 3), IterationInterval(1))
sim.output_writers[:z2] = MemoryWriter(PositionComponentObservable(:electron_trap, :electrons, 2, 3), IterationInterval(1))

@time run!(sim)

t = sim.output_writers[:z1].t
z1 = sim.output_writers[:z1].mem
z2 = sim.output_writers[:z2].mem

plot(t, z1, labels="Electron 1")
plot!(t, z2, labels="Electron 2")