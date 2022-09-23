using Penning
using Penning.Utils.Bessel
using Plots

const OVERSAMPLING = 20
const N_AXIAL_CYCLES = 30
const E_0 = 300

const m = 1
const n = 4
const p = 4
const z_0 = 3.3045e-3
const rho_0 = 3.25e-3

species = Electron()

trap = IdealTrap(5.0, -14960.0, 7.0)
trap.particles[:electrons] = ParticleCollection(species, SingleParticleDistribution([0,0,0], [10000,0,0]))
trap.excitations[:cavity] = TECavityExcitation(m, n, p, z_0, rho_0, E_0=200/(p*pi*rho_0/2/z_0/besseljp_zero(m, n))^2)

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=2*pi/calc_omega_c(trap, species)/OVERSAMPLING, stop_time=N_AXIAL_CYCLES*2*pi/calc_omega_z(trap, species))

sim.output_writers[:memory_position] = MemoryWriter(PositionComponentObservable(:electron_trap, :electrons, 1, 3), IterationInterval(600))

run!(sim)

t = sim.output_writers[:memory_position].t
z = sim.output_writers[:memory_position].mem
plot(t, z, labels="Simulated Z position", plot_title="Cavity")

savefig(joinpath(@__DIR__, "cavity.png"))



