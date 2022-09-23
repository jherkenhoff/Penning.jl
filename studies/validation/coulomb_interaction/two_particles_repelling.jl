using Penning
using Plots

const N = 50
const OVERSAMPLING = 30
const N_AXIAL_CYCLES = 2

const D_0 = 1e-6

particle_collection = ParticleCollection(Electron(), ParticleDistribution([[0, 0, D_0/2], [0, 0, -D_0/2]], [zeros(3), zeros(3)]))
trap = IdealTrap(0, -14960.0, 0)
trap.particles[:electrons] = particle_collection
trap.interactions[:coulomb] = CoulombInteraction([particle_collection])

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=1e-12, stop_iteration=100, particle_pusher=BorisPusher())

sim.output_writers[:z1] = MemoryWriter(PositionComponentObservable(:electron_trap, :electrons, 1, 3), IterationInterval(1))
sim.output_writers[:z2] = MemoryWriter(PositionComponentObservable(:electron_trap, :electrons, 2, 3), IterationInterval(1))

@time run!(sim)

t = sim.output_writers[:z1].t
z1 = sim.output_writers[:z1].mem
z2 = sim.output_writers[:z2].mem

plot(t, z1, labels="Electron 1")
plot!(t, z2, labels="Electron 2")

savefig(joinpath(@__DIR__, "two_particles_repelling.png"))