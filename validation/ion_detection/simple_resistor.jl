using Penning

using ModelingToolkit, DifferentialEquations

const N_AXIAL_CYCLES = 60
const OVERSAMPLING = 20

species = Ion(187, 30)
particle_distribution = SingleParticleDistribution([0, 0, 0.5], [0, 0, 0]) # No radial displacement or velocity. We only want to simulate axial motion
particles = ParticleCollection(species, particle_distribution)

trap = IdealTrap(-50.0, -14960.0, 7.0)
trap.particles[:particles] = particles
trap.electrodes[:axial] = AxialParallelPlateElectrode(5e-3)

R = 10000e6
@named resistor = Resistor(R=R)
@named ground = Ground()

connections = [
    connect(trap.electrodes[:axial].pin, resistor.p)
    connect(resistor.n, ground.g)
]
circuit = Circuit(connections, [trap.electrodes[:axial].pin, resistor, ground])

setup = Setup(circuit)
setup.traps[:trap] = trap

sim = Simulation(setup, dt=2*pi/omega_z(trap, species)/OVERSAMPLING, stop_time=2*pi/omega_z(trap, species)*N_AXIAL_CYCLES)
sim.diagnostics[:progress] = ProgressDiagnostic()
sim.output_writers[:memory_position] = PositionMemoryWriter(:trap, :particles, IterationInterval(1))

run!(sim)

using Plots
t = sim.output_writers[:memory_position].t
r_log = sim.output_writers[:memory_position].mem
z = [r[1][3] for r in r_log]
plot(t, z)

harminv_results = harminv(t, z, 10e3, 900e3)


A = harminv_results[1].amp
d = harminv_results[1].decay_const
envelope = 2*A*exp.(-t*d)
plot!(t, envelope)


d_theory = species.q^2*R/species.m/trap.electrodes[:axial].D[3]^2 / 2
theory = 2*A*exp.(-t*d_theory)
plot!(t, theory)