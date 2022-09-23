using Penning

const OVERSAMPLING = 20
const N_AXIAL_CYCLES = 30

const A_rf = 1000000

species = Electron()
trap = IdealTrap(5.0, -14960.0, 7.0)
trap.particles[:electrons] = ParticleCollection(species, SingleParticleDistribution([0,0,0], [10000,0,0]))
trap.excitations[:quadrupolar] = QuadrupolarExcitation(calc_omega_p(trap, species) - calc_omega_z(trap, species), A_rf)

setup = Setup()
setup.traps[:electron_trap] = trap

sim = Simulation(setup, dt=2*pi/calc_omega_c(trap, species)/OVERSAMPLING, stop_time=N_AXIAL_CYCLES*2*pi/calc_omega_z(trap, species))

sim.diagnostics[:progress] = ProgressDiagnostic()
sim.output_writers[:position_z] = MemoryWriter(PositionComponentObservable(:electron_trap, :electrons, 1, 3), IterationInterval(600))

run!(sim)


# Theoretical Rabi frequency: (http://hdl.handle.net/21.11116/0000-0005-6361-E)(Page 25, equation 2.46)
Omega_R = A_rf/4*abs(species.q) / species.m /sqrt(calc_omega_z(trap, species)*(calc_omega_p(trap, species)-calc_omega_m(trap, species)))
T_exchange = 2*pi/Omega_R/2
println("Theoretical exchange period: $T_exchange s")

using Plots
t = sim.output_writers[:position_z].t
z = sim.output_writers[:position_z].mem
plot(t*1e6, z, labels="Simulated Z position")
vline!([T_exchange*1e6], labels="Theoretical pi pulse duration", plot_title="Sideband coupling")
xlabel!("Time / µs")

savefig(joinpath(@__DIR__, "quadrupolar.png"))